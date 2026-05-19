#!/usr/bin/env bash
# Usage: scripts/validate-pack.sh <pack-name>
# Description: Run the repository's canonical cursor pack validator for one pack.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <pack-name>" >&2
  exit 1
fi

PACK_NAME="$1"

REPO_ROOT="${AGENT_SKILLS_REPO:-}"
if [[ -z "$REPO_ROOT" ]]; then
  if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
  else
    echo "validate-pack.sh: cannot locate repository root." >&2
    echo "  Run this script from inside agent-skills, or export AGENT_SKILLS_REPO." >&2
    exit 2
  fi
fi

VERIFY="$REPO_ROOT/scripts/cursor-pack-verify.sh"
if [[ ! -x "$VERIFY" ]]; then
  echo "validate-pack.sh: expected $VERIFY to exist." >&2
  echo "  This wrapper only works inside the agent-skills repository." >&2
  exit 2
fi

exec bash "$VERIFY" --pack="$PACK_NAME"
