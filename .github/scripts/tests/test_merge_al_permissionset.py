import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT_PATH = Path(__file__).resolve().parents[1] / "merge-al-permissionset.py"
SPEC = importlib.util.spec_from_file_location("merge_al_permissionset", SCRIPT_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)

BASE = """permissionset 50000 TestPermission
{
    Assignable = true;
    Permissions = tabledata \"A\" = RIMD,
        table \"A\" = X,
        page \"Alpha\" = X,
        page \"Gamma\" = X;
}"""


def merge(base: str, ours: str, theirs: str) -> str:
    return MODULE.merge_permission_sets(base, ours, theirs)


class MergeALPermissionSetTests(unittest.TestCase):
    def test_two_additive_non_overlapping_changes_merge(self) -> None:
        ours = BASE.replace('        page "Gamma" = X;', '        page "Beta" = X,\n        page "Gamma" = X;')
        theirs = BASE.replace('        page "Gamma" = X;', '        page "Delta" = X,\n        page "Gamma" = X;')

        merged = merge(BASE, ours, theirs)

        self.assertIn('        page "Beta" = X,', merged)
        self.assertIn('        page "Gamma" = X,', merged)
        self.assertIn('        page "Delta" = X;', merged)

    def test_addition_and_unrelated_removal_merge(self) -> None:
        ours = BASE.replace('        page "Alpha" = X,\n', '')
        theirs = BASE.replace('        page "Gamma" = X;', '        page "Delta" = X,\n        page "Gamma" = X;')

        merged = merge(BASE, ours, theirs)

        self.assertNotIn('page "Alpha" = X', merged)
        self.assertIn('        page "Gamma" = X,', merged)
        self.assertIn('        page "Delta" = X;', merged)

    def test_same_addition_is_deduplicated(self) -> None:
        ours = BASE.replace('        page "Gamma" = X;', '        page "Delta" = X,\n        page "Gamma" = X;')
        theirs = ours

        merged = merge(BASE, ours, theirs)

        self.assertEqual(merged.count('page "Delta" = X'), 1)

    def test_conflicting_update_returns_non_zero_for_cli(self) -> None:
        ours = BASE.replace('page "Alpha" = X', 'page "Alpha" = Y')
        theirs = BASE.replace('page "Alpha" = X', 'page "Alpha" = Z')

        with tempfile.TemporaryDirectory() as temp_dir:
            base_path = Path(temp_dir) / 'base.permissionset.al'
            ours_path = Path(temp_dir) / 'ours.permissionset.al'
            theirs_path = Path(temp_dir) / 'theirs.permissionset.al'
            base_path.write_text(BASE, encoding='utf-8', newline='')
            ours_path.write_text(ours, encoding='utf-8', newline='')
            theirs_path.write_text(theirs, encoding='utf-8', newline='')

            exit_code = MODULE.merge_files(base_path, ours_path, theirs_path)

        self.assertNotEqual(exit_code, 0)

    def test_last_entry_ends_with_semicolon_after_merge(self) -> None:
        ours = BASE.replace('        page "Gamma" = X;', '        page "Beta" = X,\n        page "Gamma" = X;')
        theirs = BASE.replace('        page "Alpha" = X,\n', '')

        merged = merge(BASE, ours, theirs)
        merged_lines = merged.splitlines()

        self.assertEqual(merged_lines[-2], '        page "Beta" = X;')
        self.assertFalse(merged.endswith('\n'))


if __name__ == '__main__':
    unittest.main()
