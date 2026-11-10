#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
driver_script="$repo_root/.github/scripts/merge-al-permissionset.py"
python_cmd="$(command -v python3 || command -v python || true)"

if [[ -z "$python_cmd" ]]; then
  echo "python3 or python is required to register the al-permset merge driver." >&2
  exit 1
fi

if [[ ! -f "$driver_script" ]]; then
  echo "Merge driver script not found: $driver_script" >&2
  exit 1
fi

git config merge.al-permset.name "AL permission set 3-way merge driver"
git config merge.al-permset.driver "\"$python_cmd\" \"$driver_script\" %O %A %B"

echo "Registered merge.al-permset in $(git rev-parse --git-path config)"
echo "Git will now use .github/scripts/merge-al-permissionset.py for matching *.permissionset.al files from .gitattributes."
