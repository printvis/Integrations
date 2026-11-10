using module ..\GitHub\GitHubPullRequest.class.psm1
using module ..\GitHub\GitHubIssue.class.psm1

param(
    [Parameter(Mandatory = $true)]
    [string] $PullRequestNumber,
    [Parameter(Mandatory = $true)]
    [string] $Repository
)

# Set error action
$ErrorActionPreference = "Stop"

<#
    .SYNOPSIS
    Validates that the pull request description contains a line that links the pull request to an issue.
    .Parameter IssueIds
    The IDs of the issues linked to the pull request.
    .Parameter PullRequest
    The pull request to validate.
#>
function Test-IssueIsLinked() {
    param(
        [Parameter(Mandatory = $false)]
        [string[]] $IssueIds,
        [Parameter(Mandatory = $false)]
        [object] $PullRequest
    )

    $LegacyComment = "Could not find linked issues in the pull request description. Please make sure the pull request description contains a line that contains 'Fixes #' followed by the issue number being fixed. Use that pattern for every issue you want to link."
    $Comment = "**Issue link validation failed - this is NOT a merge conflict.** Could not find linked issues in the pull request description. Please make sure the pull request description contains a line that contains 'Fixes #' followed by the issue number being fixed (e.g. ``Fixes #123``). The keywords Close/Closes/Closed, Fix/Fixes/Fixed, Resolve/Resolves/Resolved and Issue are also accepted (case-insensitive). Use that pattern for every issue you want to link. Once the description is updated, this check will re-run automatically."

    if (-not $IssueIds) {
        # Add a comment to the pull request and throw an error
        $PullRequest.AddComment($Comment)
        Write-Host "::error title=Issue link validation failed (not a merge conflict)::$Comment"
        throw $Comment
    }

    $PullRequest.RemoveComment($Comment)
    $PullRequest.RemoveComment($LegacyComment)
}

<#
    .SYNOPSIS
    Validates all issues linked to a pull request.
    .Description
    Validates all issues linked to a pull request.
    If the pull request is from a fork, it will validate that the issue is open and approved.
    If the pull request is not from a fork, it will validate that the issue is open.
    .Parameter Repository
    The repository that contains the pull request.
    .Parameter IssueIds
    The IDs of the issues linked to the pull request.
    .Parameter PullRequest
    The pull request to validate.
#>
function Test-GitHubIssue() {
    param(
        [Parameter(Mandatory = $false)]
        [string] $Repository,
        [Parameter(Mandatory = $false)]
        [string[]] $IssueIds,
        [Parameter(Mandatory = $false)]
        [object] $PullRequest
    )
    $invalidIssues = @()

    foreach ($issueId in $IssueIds) {
        Write-Host "Validating issue $issueId"
        $issue = [GitHubIssue]::Get($issueId, $Repository)

        # If the issue is not approved, add a comment to the pull request and throw an error
        $isValid = $issue -and ((-not $PullRequest.IsFromFork()) -or $issue.IsApproved()) -and $issue.IsOpen() -and (-not $issue.IsPullRequest())
        $Comment = "Issue #$($issueId) is not valid. Please make sure you link an **issue** that exists, is **open** and is **approved**."
        if (-not $isValid) {
            $PullRequest.AddComment($Comment)
            $invalidIssues += $issueId
        }
        else {
            $PullRequest.RemoveComment($Comment)
        }
    }

    if ($invalidIssues) {
        $message = "Issue link validation failed (not a merge conflict). The following linked issues are not valid (they must exist, be open and be approved): $($invalidIssues -join ', ')"
        Write-Host "::error title=Issue link validation failed (not a merge conflict)::$message"
        throw $message
    }
}

Write-Host "Validating PR $PullRequestNumber"

$pullRequest = [GitHubPullRequest]::Get($PullRequestNumber, $Repository)
if (-not $pullRequest) {
    throw "Could not get PR $PullRequestNumber from repository $Repository"
}

$issueIds = $pullRequest.GetLinkedIssueIDs()

# If the pull request is from a fork, validate that it links to an issue
#f ($pullRequest.IsFromFork()) {
Test-IssueIsLinked -IssueIds $issueIds -PullRequest $PullRequest
#

# Validate that all issues linked to the pull request are open and approved
Test-GitHubIssue -Repository $Repository -IssueIds $issueIds -PullRequest $PullRequest

Write-Host "PR $PullRequestNumber validated successfully" -ForegroundColor Green