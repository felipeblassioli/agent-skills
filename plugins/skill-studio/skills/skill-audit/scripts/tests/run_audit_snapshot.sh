#!/usr/bin/env bash
# Snapshot test for skill_hot_path_audit.py.
# Diffs auditor output against tests/fixtures/expected.json.
# Update the snapshot deliberately via:
#   python3 ../skill_hot_path_audit.py ./fixtures --write-snapshot ./fixtures/expected.json
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
FIXTURES="$HERE/fixtures"
EXPECTED="$FIXTURES/expected.json"
SCRIPT="$HERE/../skill_hot_path_audit.py"

if [[ ! -f "$EXPECTED" ]]; then
  echo "expected.json missing at $EXPECTED" >&2
  exit 2
fi

ACTUAL="$(mktemp)"
trap 'rm -f "$ACTUAL"' EXIT

python3 "$SCRIPT" "$FIXTURES" --write-snapshot "$ACTUAL" >/dev/null

if diff -u "$EXPECTED" "$ACTUAL"; then
  echo "OK"
else
  echo "snapshot drift; regenerate with --write-snapshot if intentional" >&2
  exit 1
fi
