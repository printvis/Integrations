import fnmatch
import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
SCRIPTS = ROOT / ".github" / "scripts"
MOVED_FILES = (
    "GitHub/GitHubAPI.class.psm1",
    "GitHub/GitHubIssue.class.psm1",
    "GitHub/GitHubPullRequest.class.psm1",
    "GitHub/GitHubWorkItemLink.class.psm1",
    "PullRequestValidation/PVS_ValidateIssuesForPullRequest.ps1",
)


class ScriptLayoutTests(unittest.TestCase):
    def test_moved_helpers_and_relative_module_imports_exist(self):
        self.assertFalse((ROOT / "build" / "scripts").exists())
        for relative_path in MOVED_FILES:
            script = SCRIPTS / relative_path
            with self.subTest(script=relative_path):
                self.assertTrue(script.is_file())
                for module in re.findall(r"(?m)^using module (\S+)", script.read_text()):
                    self.assertTrue((script.parent / module.replace("\\", "/")).is_file())

    def test_issue_validation_workflow_uses_relocated_script(self):
        workflow = (ROOT / ".github" / "workflows" / "PVS_Issue_Validate.yaml").read_text()
        self.assertIn(
            ".github/scripts/PullRequestValidation/PVS_ValidateIssuesForPullRequest.ps1"
            " -PullRequestNumber",
            workflow,
        )
        self.assertNotIn("build/scripts/", workflow)

    def test_custom_file_sync_preserves_every_helper_path(self):
        settings = json.loads((ROOT / ".github" / "AL-Go-Settings.json").read_text())
        entries = settings["customALGoFiles"]["filesToInclude"]
        for script in SCRIPTS.rglob("*"):
            if not script.is_file() or "__pycache__" in script.parts:
                continue
            with self.subTest(script=script.relative_to(ROOT)):
                matches = [
                    entry
                    for entry in entries
                    if ROOT / entry["sourceFolder"] == script.parent
                    and fnmatch.fnmatchcase(script.name, entry["filter"])
                ]
                self.assertTrue(matches, "AL-Go custom-file matching is non-recursive")
                for entry in matches:
                    self.assertEqual(
                        ROOT / entry["destinationFolder"] / script.name, script
                    )


if __name__ == "__main__":
    unittest.main()
