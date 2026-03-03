#!/usr/bin/env bash
# Usage:
#   scripts/check-registry-consistency.sh \
#     --registry skill-registry.json \
#     --touched "$(printf '%s\n' skills/foo skills/bar)" \
#     --removed "$(printf '%s\n' skills/old-skill)"
#
# Validates registry entry existence and version parity against metadata.json.
set -euo pipefail

REGISTRY="skill-registry.json"
TOUCHED=""
REMOVED=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --registry)
      REGISTRY="${2:-}"
      shift 2
      ;;
    --touched)
      TOUCHED="${2:-}"
      shift 2
      ;;
    --removed)
      REMOVED="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "$REGISTRY" ]]; then
  jq -n --arg registry "$REGISTRY" '{
    pass: false,
    findings: [
      {
        id: "REGISTRY_FILE_MISSING",
        severity: "CRITICAL",
        message: ("Registry file not found: " + $registry)
      }
    ]
  }'
  exit 0
fi

findings='[]'
pass=true

append_finding() {
  local id="$1"
  local severity="$2"
  local message="$3"
  findings="$(jq -c --arg id "$id" --arg severity "$severity" --arg message "$message" '. + [{id: $id, severity: $severity, message: $message}]' <<<"$findings")"
  if [[ "$severity" == "CRITICAL" || "$severity" == "HIGH" ]]; then
    pass=false
  fi
}

if [[ -n "$TOUCHED" ]]; then
  while IFS= read -r skill_dir; do
    [[ -z "$skill_dir" ]] && continue
    skill_name="$(basename "$skill_dir")"

    if ! jq -e --arg s "$skill_name" '.skills[$s]' "$REGISTRY" >/dev/null; then
      append_finding "REGISTRY_ENTRY_MISSING_${skill_name}" "HIGH" "Missing registry entry for touched skill '$skill_name'."
      continue
    fi

    metadata_path="$skill_dir/metadata.json"
    if [[ ! -f "$metadata_path" ]]; then
      append_finding "METADATA_MISSING_${skill_name}" "CRITICAL" "Missing metadata.json for touched skill '$skill_name'."
      continue
    fi

    metadata_version="$(jq -r '.version // empty' "$metadata_path" 2>/dev/null || true)"
    if [[ -z "$metadata_version" ]]; then
      if ! jq empty "$metadata_path" >/dev/null 2>&1; then
        append_finding "METADATA_JSON_INVALID_${skill_name}" "CRITICAL" "metadata.json is invalid JSON for '$skill_name'."
        continue
      fi
    fi
    registry_version="$(jq -r --arg s "$skill_name" '.skills[$s].version // empty' "$REGISTRY")"
    if [[ -z "$metadata_version" ]]; then
      append_finding "METADATA_VERSION_MISSING_${skill_name}" "HIGH" "metadata.json has no version for '$skill_name'."
    elif [[ "$metadata_version" != "$registry_version" ]]; then
      append_finding "VERSION_MISMATCH_${skill_name}" "HIGH" "Version mismatch for '$skill_name': metadata.json=$metadata_version, registry=$registry_version."
    fi

    tags_count="$(jq -r --arg s "$skill_name" '.skills[$s].tags // [] | length' "$REGISTRY")"
    if [[ "$tags_count" -eq 0 ]]; then
      append_finding "TAGS_EMPTY_${skill_name}" "MEDIUM" "Registry entry for '$skill_name' has no tags."
    fi
  done <<<"$TOUCHED"
fi

if [[ -n "$REMOVED" ]]; then
  while IFS= read -r skill_dir; do
    [[ -z "$skill_dir" ]] && continue
    skill_name="$(basename "$skill_dir")"
    if jq -e --arg s "$skill_name" '.skills[$s]' "$REGISTRY" >/dev/null; then
      append_finding "REMOVED_SKILL_STILL_REGISTERED_${skill_name}" "HIGH" "Removed skill '$skill_name' still exists in skill-registry.json."
    fi
  done <<<"$REMOVED"
fi

jq -n \
  --argjson pass "$pass" \
  --argjson findings "$findings" \
  '{pass: $pass, findings: $findings}'
