# Git merge helpers

The generated `*GeneratedPermission.permissionset.al` files use a custom Git merge driver so unrelated permission entries can merge cleanly without breaking AL punctuation.

`.gitattributes` only selects that driver by name. Each contributor still needs to register the driver in local Git config once:

```bash
bash .github/scripts/setup-merge-driver.sh
```

That script writes the `merge.al-permset` configuration into the local `.git/config`, which is required before Git will invoke `.github/scripts/merge-al-permissionset.py` during local merges.
