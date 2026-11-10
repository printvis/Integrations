const test = require("node:test");
const assert = require("node:assert/strict");

const { run, copyReleaseNotesForPullRequest, getLinkedIssueNumbers } = require("./copyReleaseNotesToSubissue");

function createHarness({ parentMap = {}, issues = {} } = {}) {
  const updates = [];
  const logs = [];
  const issueStore = new Map(Object.entries(issues).map(([k, v]) => [k, { ...v }]));

  function key(owner, repo, number) {
    return `${owner}/${repo}#${number}`;
  }

  const github = {
    request: async (route, params) => {
      assert.equal(route, "GET /repos/{owner}/{repo}/issues/{issue_number}/parent");
      const parent = parentMap[key(params.owner, params.repo, params.issue_number)];
      if (!parent) {
        const error = new Error("Not Found");
        error.status = 404;
        throw error;
      }

      return {
        data: {
          number: parent.number,
          repository: { full_name: `${parent.owner}/${parent.repo}` }
        }
      };
    },
    rest: {
      issues: {
        get: async ({ owner, repo, issue_number }) => {
          const item = issueStore.get(key(owner, repo, issue_number));
          if (!item) {
            const error = new Error("Not Found");
            error.status = 404;
            throw error;
          }

          return { data: { ...item } };
        },
        update: async ({ owner, repo, issue_number, body }) => {
          const issueKey = key(owner, repo, issue_number);
          issueStore.set(issueKey, { ...issueStore.get(issueKey), body });
          updates.push({ issueKey, body });
          return { data: { ...issueStore.get(issueKey) } };
        }
      }
    }
  };

  const core = {
    info: (message) => logs.push(`INFO ${message}`),
    warning: (message) => logs.push(`WARN ${message}`),
    setFailed: (message) => {
      throw new Error(message);
    }
  };

  return { github, core, updates, logs };
}

test("copies root release notes for an opened sub-issue", async () => {
  const rootBody = "# Root\n\n## Release notes\n\nOrder No.: 00000\nName: test sub issue";
  const harness = createHarness({
    parentMap: {
      "printvis/Test-Copilot-Release-Notes#107": {
        owner: "printvis",
        repo: "Test-Copilot-Release-Notes",
        number: 106
      }
    },
    issues: {
      "printvis/Test-Copilot-Release-Notes#106": { number: 106, body: rootBody },
      "printvis/Test-Copilot-Release-Notes#107": { number: 107, body: "" }
    }
  });

  await run({
    github: harness.github,
    core: harness.core,
    context: {
      eventName: "issues",
      payload: {
        action: "opened",
        issue: { number: 107 },
        repository: { full_name: "printvis/Test-Copilot-Release-Notes" }
      },
      repo: { owner: "printvis", repo: "Test-Copilot-Release-Notes" }
    }
  });

  assert.deepEqual(harness.updates, [{
    issueKey: "printvis/Test-Copilot-Release-Notes#107",
    body: "## Release notes\n\nOrder No.: 00000\nName: test sub issue"
  }]);
});

test("extracts linked issue numbers like the PR validation script", () => {
  assert.deepEqual(
    getLinkedIssueNumbers("Fixes #107\ncloses #108 and resolved #107\nIssue #109\nSee #110\nabcfix #111"),
    [107, 108, 109]
  );
  assert.deepEqual(getLinkedIssueNumbers(""), []);
});

test("pull request validation copies root release notes only to linked sub-issues", async () => {
  const rootBody = "# Root\n\n## Release notes\n\nOrder No.: 00000\nName: test sub issue";
  const harness = createHarness({
    parentMap: {
      "printvis/Test-Copilot-Release-Notes#107": {
        owner: "printvis",
        repo: "Test-Copilot-Release-Notes",
        number: 106
      }
    },
    issues: {
      "printvis/Test-Copilot-Release-Notes#106": { number: 106, body: rootBody },
      "printvis/Test-Copilot-Release-Notes#107": { number: 107, body: "Details" },
      "printvis/Test-Copilot-Release-Notes#108": { number: 108, body: "" }
    }
  });

  await copyReleaseNotesForPullRequest({
    github: harness.github,
    core: harness.core,
    context: {
      eventName: "pull_request_target",
      payload: {
        pull_request: { number: 200, body: "Fixes #107\nFixes #108" }
      },
      repo: { owner: "printvis", repo: "Test-Copilot-Release-Notes" }
    }
  });

  assert.deepEqual(harness.updates, [{
    issueKey: "printvis/Test-Copilot-Release-Notes#107",
    body: "Details\n\n## Release notes\n\nOrder No.: 00000\nName: test sub issue"
  }]);
  assert.ok(harness.logs.some((message) => message.includes("Linked issue printvis/Test-Copilot-Release-Notes#108 is not a sub-issue. Skipping.")));
});

test("pull request validation warns instead of failing when a linked issue cannot be resolved", async () => {
  const harness = createHarness();

  await copyReleaseNotesForPullRequest({
    github: harness.github,
    core: harness.core,
    context: {
      eventName: "pull_request_target",
      payload: {
        pull_request: { number: 200, body: "Fixes #999" }
      },
      repo: { owner: "printvis", repo: "Test-Copilot-Release-Notes" }
    }
  });

  assert.deepEqual(harness.updates, []);
  assert.ok(harness.logs.some((message) => message.startsWith("WARN Could not copy release notes to linked issue printvis/Test-Copilot-Release-Notes#999")));
});

test("workflow_dispatch rejects invalid issue_number", async () => {
  const harness = createHarness();

  await assert.rejects(() => run({
    github: harness.github,
    core: harness.core,
    context: {
      eventName: "workflow_dispatch",
      payload: { inputs: { issue_number: "0" } },
      repo: { owner: "printvis", repo: "Test-Copilot-Release-Notes" }
    }
  }), /positive integer/);

  await assert.rejects(() => run({
    github: harness.github,
    core: harness.core,
    context: {
      eventName: "workflow_dispatch",
      payload: { inputs: { issue_number: "1e2" } },
      repo: { owner: "printvis", repo: "Test-Copilot-Release-Notes" }
    }
  }), /positive integer/);
});
