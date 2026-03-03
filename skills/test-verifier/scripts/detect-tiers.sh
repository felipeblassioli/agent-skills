#!/usr/bin/env bash
# detect-tiers.sh — Map changed file paths to recommended test tiers.
#
# Reads file paths from stdin (one per line) or as positional arguments.
# Outputs a JSON object with recommended tiers and any skipped tiers
# (with reasons, e.g. Docker unavailable for integration).
#
# Usage:
#   git diff --name-only HEAD | detect-tiers.sh
#   detect-tiers.sh domain/services/alert.service.js domain/repositories/rules.repository.js
#
# Output (JSON to stdout):
#   {
#     "recommended": ["unit", "integration"],
#     "skipped": [{ "tier": "integration", "reason": "Docker not running" }],
#     "changed_files": ["domain/services/alert.service.js", ...],
#     "unmapped_files": ["some/unknown/path.js"]
#   }

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: detect-tiers.sh [FILE ...]

  Reads changed file paths from arguments or stdin (one per line).
  Paths should be relative to functions/ (e.g. domain/services/alert.service.js).
  Paths prefixed with functions/ are automatically stripped.

  Outputs JSON with recommended tiers, skipped tiers, and unmapped files.

Options:
  -h, --help    Show this help message
USAGE
  exit 0
}

# ── Parse args ────────────────────────────────────────────────────────────────
FILES=()

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage ;;
    *) FILES+=("$arg") ;;
  esac
done

if [[ ${#FILES[@]} -eq 0 ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && FILES+=("$line")
  done
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Error: no file paths provided. Pipe from git diff or pass as arguments." >&2
  exit 1
fi

# ── Check prerequisites ──────────────────────────────────────────────────────
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install: https://stedolan.github.io/jq/download/" >&2
  exit 1
fi

DOCKER_OK=false
if docker info &>/dev/null 2>&1; then
  DOCKER_OK=true
fi

# ── Classify files into tiers ────────────────────────────────────────────────
declare -A TIER_SET
UNMAPPED=()

for raw_path in "${FILES[@]}"; do
  path="${raw_path#functions/}"

  # Skip test files, docs, config — these don't trigger verification
  if [[ "$path" =~ \.(test|spec)\.(js|ts)$ ]] || \
     [[ "$path" =~ ^test/ ]] || \
     [[ "$path" =~ ^test-integration/ ]] || \
     [[ "$path" =~ \.md$ ]] || \
     [[ "$path" =~ ^\.cursor/ ]] || \
     [[ "$path" =~ ^docs/ ]] || \
     [[ "$path" =~ ^node_modules/ ]] || \
     [[ "$path" =~ ^modules/ ]]; then
    continue
  fi

  matched=false

  # domain/services/riskEngine/* → unit + functional
  if [[ "$path" =~ ^domain/services/riskEngine/ ]]; then
    TIER_SET[unit]=1
    TIER_SET[functional]=1
    matched=true
  # domain/services/* → unit
  elif [[ "$path" =~ ^domain/services/ ]]; then
    TIER_SET[unit]=1
    matched=true
  fi

  # domain/repositories/* → unit + integration
  if [[ "$path" =~ ^domain/repositories/ ]]; then
    TIER_SET[unit]=1
    TIER_SET[integration]=1
    matched=true
  fi

  # application/routes/* or application/config/* → unit + functional-http
  if [[ "$path" =~ ^application/ ]]; then
    TIER_SET[unit]=1
    TIER_SET[functional-http]=1
    matched=true
  fi

  # providers/* → unit
  if [[ "$path" =~ ^providers/ ]]; then
    TIER_SET[unit]=1
    matched=true
  fi

  # infra/* → unit
  if [[ "$path" =~ ^infra/ ]]; then
    TIER_SET[unit]=1
    matched=true
  fi

  # db/schema/*, db/seed/* → integration
  if [[ "$path" =~ ^db/ ]]; then
    TIER_SET[integration]=1
    matched=true
  fi

  # index.js or top-level JS → unit
  if [[ "$path" =~ ^[^/]+\.js$ ]]; then
    TIER_SET[unit]=1
    matched=true
  fi

  if [[ "$matched" == "false" ]]; then
    UNMAPPED+=("$path")
  fi
done

# ── Build output ──────────────────────────────────────────────────────────────
RECOMMENDED=()
SKIPPED=()

for tier in unit functional functional-http integration; do
  if [[ -n "${TIER_SET[$tier]:-}" ]]; then
    if [[ "$tier" == "integration" && "$DOCKER_OK" == "false" ]]; then
      SKIPPED+=("{\"tier\":\"integration\",\"reason\":\"Docker not running\"}")
    else
      RECOMMENDED+=("$tier")
    fi
  fi
done

# If nothing was recommended (e.g. only unmapped files), default to unit
if [[ ${#RECOMMENDED[@]} -eq 0 && ${#FILES[@]} -gt 0 && ${#UNMAPPED[@]} -lt ${#FILES[@]} ]]; then
  RECOMMENDED+=("unit")
fi

# ── Emit JSON ─────────────────────────────────────────────────────────────────
REC_JSON=$(printf '%s\n' "${RECOMMENDED[@]}" | jq -R . | jq -s .)
SKIP_JSON=$(printf '%s\n' "${SKIPPED[@]:-}" | jq -s 'map(select(. != "") | fromjson)')
FILES_JSON=$(printf '%s\n' "${FILES[@]}" | jq -R . | jq -s .)
UNMAP_JSON=$(printf '%s\n' "${UNMAPPED[@]:-}" | jq -R 'select(. != "")' | jq -s .)

jq -n \
  --argjson recommended "$REC_JSON" \
  --argjson skipped "$SKIP_JSON" \
  --argjson changed_files "$FILES_JSON" \
  --argjson unmapped_files "$UNMAP_JSON" \
  '{recommended: $recommended, skipped: $skipped, changed_files: $changed_files, unmapped_files: $unmapped_files}'
