#!/usr/bin/env bash
# Usage: scripts/validate-pack.sh <pack-name>
# Description: Run the repository's canonical cursor pack validator for one pack.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <pack-name>" >&2
  exit 1
fi

PACK_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

exec bash "$REPO_ROOT/scripts/cursor-pack-verify.sh" --pack="$PACK_NAME"
