
Repo moved / merged into https://github.com/printvis/OpenSource

# AL-Go Per Tenant Extension Template

This template repository can be used for managing Per-tenant Extensions (PTEs) for Business Central.

Please go to https://aka.ms/AL-Go to learn more.

## Template helper scripts

Workflow helpers are stored in `.github/scripts/`, including the `GitHub/` modules
and `PullRequestValidation/` scripts. AL-Go hooks belong in `.AL-Go/`.
The `customALGoFiles.filesToInclude` entries in `.github/AL-Go-Settings.json`
sync the helpers from this template. AL-Go v10 uses `filter` and does not search
subfolders recursively, so add an entry for each new script subfolder.

After merging, maintainers should run **Update AL-Go System Files** in one
downstream repository using this template and verify that the helper scripts and
updated workflow arrive with their subfolder structure intact. Check for obsolete
copies in the old script location; custom-file syncing does not remove them.
Synced helpers are template-managed and may overwrite downstream customizations.

## Contributing

Please read [this](https://github.com/microsoft/AL-Go/blob/main/Scenarios/Contribute.md) description on how to contribute to AL-Go for GitHub.

We do not accept Pull Requests on the template repository directly.
