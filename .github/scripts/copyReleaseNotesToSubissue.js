const { extractSection, hasSection } = require("./releaseNotesSection");

const MAX_ANCESTOR_DEPTH = 20;

function parseRepository(fullName) {
  const [owner, repo] = fullName.split("/", 2);
  if (!owner || !repo) {
    throw new Error(`Invalid repository name: ${fullName}`);
  }
  return { owner, repo };
}

function issueKey(issueRef) {
  return `${issueRef.owner}/${issueRef.repo}#${issueRef.number}`;
}

function appendReleaseNotes(body, releaseNotes) {
  const trimmedBody = (body || "").trim();
  const section = `## Release notes\n\n${releaseNotes.trim()}`;
  return trimmedBody ? `${trimmedBody}\n\n${section}` : section;
}

async function getIssue(github, issueRef) {
  return github.rest.issues.get({
    owner: issueRef.owner,
    repo: issueRef.repo,
    issue_number: issueRef.number
  });
}

async function getParentIssue(github, issueRef) {
  try {
    const response = await github.request("GET /repos/{owner}/{repo}/issues/{issue_number}/parent", {
      owner: issueRef.owner,
      repo: issueRef.repo,
      issue_number: issueRef.number,
      headers: {
        "X-GitHub-Api-Version": "2022-11-28"
      }
    });

    const parent = response.data;
    const parentRepoFullName = parent.repository?.full_name || `${issueRef.owner}/${issueRef.repo}`;
    const parentRepo = parseRepository(parentRepoFullName);

    return {
      owner: parentRepo.owner,
      repo: parentRepo.repo,
      number: parent.number
    };
  } catch (error) {
    if (error.status === 404) {
      try {
        await getIssue(github, issueRef);
        return null;
      } catch {
        throw new Error(`Received 404 while resolving the parent of ${issueKey(issueRef)}, and could not verify access to that issue's repository. Refusing to treat the hierarchy as missing.`);
      }
    }

    throw error;
  }
}

async function getRootAncestor({ github, core, issueRef }) {
  const visited = new Set([issueKey(issueRef)]);
  let current = issueRef;
  let lastParent = null;

  for (let depth = 0; depth < MAX_ANCESTOR_DEPTH; depth++) {
    const parent = await getParentIssue(github, current);
    if (!parent) {
      return lastParent;
    }

    const key = issueKey(parent);
    if (visited.has(key)) {
      core.warning(`Detected a parent cycle at ${key}. Skipping release-note copy.`);
      return null;
    }

    visited.add(key);
    lastParent = parent;
    current = parent;
  }

  core.warning(`Reached the maximum parent depth (${MAX_ANCESTOR_DEPTH}) while resolving ${issueKey(issueRef)}. Skipping release-note copy.`);
  return null;
}

async function maybeCopyReleaseNotes({ github, core, targetIssueRef, source }) {
  core.info(`Processing ${issueKey(targetIssueRef)} from ${source}.`);

  const targetIssue = await getIssue(github, targetIssueRef);
  if (targetIssue.data.pull_request) {
    core.info(`${issueKey(targetIssueRef)} is a pull request. Skipping.`);
    return false;
  }

  if (hasSection(targetIssue.data.body || "", "release notes")) {
    core.info(`Issue ${issueKey(targetIssueRef)} already has a ## Release notes section. Skipping.`);
    return false;
  }

  const rootAncestor = await getRootAncestor({ github, core, issueRef: targetIssueRef });
  if (!rootAncestor) {
    core.info(`Issue ${issueKey(targetIssueRef)} has no parent hierarchy with a resolvable root ancestor. Skipping.`);
    return false;
  }

  core.info(`Resolved root ancestor to ${issueKey(rootAncestor)}.`);

  const rootIssue = await getIssue(github, rootAncestor);
  const releaseNotes = extractSection(rootIssue.data.body || "", "release notes");
  if (!releaseNotes) {
    core.info(`Root ancestor ${issueKey(rootAncestor)} has no ## Release notes section. Skipping.`);
    return false;
  }

  const latestTargetIssue = await getIssue(github, targetIssueRef);
  if (hasSection(latestTargetIssue.data.body || "", "release notes")) {
    core.info(`Issue ${issueKey(targetIssueRef)} gained a ## Release notes section while this workflow was running. Skipping update.`);
    return false;
  }

  const updatedBody = appendReleaseNotes(latestTargetIssue.data.body || "", releaseNotes);
  await github.rest.issues.update({
    owner: targetIssueRef.owner,
    repo: targetIssueRef.repo,
    issue_number: targetIssueRef.number,
    body: updatedBody
  });

  core.info(`Copied root release notes from ${issueKey(rootAncestor)} to ${issueKey(targetIssueRef)}.`);
  return true;
}

function getLinkedIssueNumbers(description) {
  if (!description) {
    return [];
  }

  // Mirrors GitHubWorkItemLink.GetLinkedIssueIDs used by PVS_ValidateIssuesForPullRequest.ps1.
  const linkedIssueRe = /(^|\s)(close|closes|closed|fix|fixes|fixed|resolve|resolves|resolved|issue) #(\d+)/gi;
  const issueNumbers = new Set();
  for (const match of description.matchAll(linkedIssueRe)) {
    issueNumbers.add(Number(match[3]));
  }
  return [...issueNumbers];
}

async function copyReleaseNotesForPullRequest({ github, context, core }) {
  const pullRequest = context.payload.pull_request;
  if (!pullRequest?.number) {
    core.info("No pull request found in the event payload. Skipping.");
    return;
  }

  const issueNumbers = getLinkedIssueNumbers(pullRequest.body || "");
  if (issueNumbers.length === 0) {
    core.info(`Pull request #${pullRequest.number} has no linked issues. Skipping.`);
    return;
  }

  for (const issueNumber of issueNumbers) {
    const issueRef = {
      owner: context.repo.owner,
      repo: context.repo.repo,
      number: issueNumber
    };

    try {
      const parent = await getParentIssue(github, issueRef);
      if (!parent) {
        core.info(`Linked issue ${issueKey(issueRef)} is not a sub-issue. Skipping.`);
        continue;
      }

      await maybeCopyReleaseNotes({
        github,
        core,
        targetIssueRef: issueRef,
        source: `pull request #${pullRequest.number}`
      });
    } catch (error) {
      core.warning(`Could not copy release notes to linked issue ${issueKey(issueRef)}: ${error.message}`);
    }
  }
}

async function run({ github, context, core }) {
  if (context.eventName === "workflow_dispatch") {
    const rawIssueNumber = context.payload.inputs?.issue_number;
    if (rawIssueNumber === undefined || rawIssueNumber === null || String(rawIssueNumber).trim() === "") {
      core.setFailed("workflow_dispatch requires issue_number.");
      return;
    }

    const normalizedIssueNumber = String(rawIssueNumber).trim();
    if (!/^[1-9]\d*$/.test(normalizedIssueNumber)) {
      core.setFailed(`workflow_dispatch issue_number must be a positive integer. Received: ${rawIssueNumber}`);
      return;
    }
    const inputIssueNumber = Number(normalizedIssueNumber);

    await maybeCopyReleaseNotes({
      github,
      core,
      targetIssueRef: {
        owner: context.repo.owner,
        repo: context.repo.repo,
        number: inputIssueNumber
      },
      source: "workflow_dispatch input"
    });
    return;
  }

  const targetIssuePayload = context.payload.issue;
  if (!targetIssuePayload?.number) {
    core.info("No target issue number found in the event payload. Skipping.");
    return;
  }

  const targetRepo = parseRepository(context.payload.repository.full_name);
  await maybeCopyReleaseNotes({
    github,
    core,
    targetIssueRef: {
      owner: targetRepo.owner,
      repo: targetRepo.repo,
      number: targetIssuePayload.number
    },
    source: `${context.eventName}:${context.payload.action}`
  });
}

module.exports = {
  run,
  copyReleaseNotesForPullRequest,
  getLinkedIssueNumbers
};
