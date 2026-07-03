#!/usr/bin/env bash
# Usage: scripts/validate-skill.sh <skill-directory>
# Validates a Bond skill package against the Claude-first contract and common
# quality issues. Works for skills under skills/ and under
# plugins/<plugin>/skills/. Returns JSON with pass/fail results and findings.
#
# Contract (see docs/marketplace-governance.md):
# - SKILL.md frontmatter carries ONLY `name` + `description` (the Agent Skills
#   standard Claude reads); `allowed-tools` is also permitted.
# - Versioning/freshness metadata (version, date, source_contracts) lives in
#   metadata.json, NOT the frontmatter.
set -euo pipefail

SKILL_DIR="${1:?Usage: validate-skill.sh <skill-directory>}"
SKILL_DIR="${SKILL_DIR%/}"
SKILL_FILE="$SKILL_DIR/SKILL.md"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_ROOT="$(cd "$REPO_ROOT/.." && pwd)"
METADATA_FILE="$SKILL_DIR/metadata.json"
REGISTRY_FILE="$REPO_ROOT/skill-registry.json"
CHANGELOG_FILE="$SKILL_DIR/CHANGELOG.md"

errors=()
warnings=()

add_error() { errors+=("$1"); }
add_warning() { warnings+=("$1"); }

if [[ ! -f "$SKILL_FILE" ]]; then
  echo '{"pass":false,"errors":["SKILL.md not found"],"warnings":[]}'
  exit 1
fi

if [[ ! -f "$METADATA_FILE" ]]; then
  add_error "metadata.json not found at skill root"
fi

first_line=$(sed -n '1p' "$SKILL_FILE")
if [[ "$first_line" != "---" ]]; then
  add_error "SKILL.md must start with YAML frontmatter (---)"
fi

frontmatter=$(awk '/^---$/{n++; next} n==1{print} n>=2{exit}' "$SKILL_FILE")

# --- Frontmatter contract: name + description (Agent Skills standard) ---
name_value=$(echo "$frontmatter" | awk -F': *' '/^name:/{print $2; exit}' | tr -d '[:space:]')
if [[ -z "$name_value" ]]; then
  add_error "Missing required field: name"
else
  folder_name=$(basename "$SKILL_DIR")
  if [[ "$name_value" != "$folder_name" ]]; then
    add_error "name '$name_value' does not match folder name '$folder_name'"
  fi
  if [[ ${#name_value} -gt 64 ]]; then
    add_error "name exceeds 64 characters (${#name_value})"
  fi
  if ! echo "$name_value" | grep -qE '^[a-z0-9-]+$'; then
    add_error "name contains invalid characters (allowed: lowercase, digits, hyphens)"
  fi
fi

desc_value=$(echo "$frontmatter" | awk -F': *' '/^description:/{print $2; exit}')
if [[ -z "$desc_value" ]]; then
  desc_multiline=$(echo "$frontmatter" | awk '/^description:/{found=1; next} found && /^  /{print; next} found{exit}')
  if [[ -z "$desc_multiline" ]]; then
    add_error "Missing required field: description"
  fi
fi

# Governance fields belong in metadata.json. Claude ignores extra frontmatter
# keys, so flag stragglers as warnings rather than failing the package.
for legacy in version last_reviewed source_contracts compatibility; do
  if echo "$frontmatter" | grep -qE "^${legacy}:"; then
    add_warning "SKILL.md frontmatter has legacy field '$legacy'; move it to metadata.json (Claude reads only name + description)"
  fi
done

line_count=$(wc -l < "$SKILL_FILE" | tr -d '[:space:]')
if [[ "$line_count" -gt 500 ]]; then
  add_error "SKILL.md exceeds 500 lines ($line_count lines)"
elif [[ "$line_count" -gt 400 ]]; then
  add_warning "SKILL.md is $line_count lines (approaching 500-line limit)"
fi

while IFS= read -r dir; do
  file_count=$(find "$dir" -type f | wc -l | tr -d '[:space:]')
  if [[ "$file_count" -eq 0 ]]; then
    add_warning "Empty directory: ${dir#$SKILL_DIR/}"
  fi
done < <(find "$SKILL_DIR" -mindepth 1 -type d)

# Broken intra-skill markdown references. Skip URLs, anchors, and paths that use
# ${CLAUDE_*} variables (cache-safe script references resolved at runtime).
body=$(awk '/^---$/{n++; next} n>=2{print}' "$SKILL_FILE")
while IFS= read -r ref; do
  if [[ -z "$ref" ]]; then
    continue
  fi
  case "$ref" in
    http://*|https://*|mailto:*|\#*|*'${'*)
      continue
      ;;
  esac
  ref_path="$SKILL_DIR/$ref"
  if [[ ! -e "$ref_path" ]]; then
    add_error "Broken reference in SKILL.md: $ref (file not found)"
  fi
done < <(echo "$body" | grep -oE '\]\([^)]+\)' | sed 's/\](//;s/)$//' || true)

if [[ -d "$SKILL_DIR/scripts" ]]; then
  while IFS= read -r script; do
    if [[ ! -x "$script" ]]; then
      add_warning "Script not executable: ${script#$SKILL_DIR/}"
    fi
  done < <(find "$SKILL_DIR/scripts" -type f -name '*.sh')
fi

metadata_version=""
if [[ -f "$METADATA_FILE" ]]; then
  if ! jq empty "$METADATA_FILE" >/dev/null 2>&1; then
    add_error "metadata.json is not valid JSON"
  else
    for field in version author date abstract; do
      field_value=$(jq -r ".${field} // empty" "$METADATA_FILE")
      if [[ -z "$field_value" ]]; then
        add_error "metadata.json missing required field: $field"
      fi
    done

    metadata_version=$(jq -r '.version // empty' "$METADATA_FILE")

    metadata_source_contract_count=$(jq '.source_contracts // [] | length' "$METADATA_FILE")
    if [[ "$metadata_source_contract_count" -gt 0 ]]; then
      mapfile -t invalid_source_contracts < <(
        jq -r '
          .source_contracts[]
          | select((.path // "") == "" or (.reviewed_at // "") == "")
          | @json
        ' "$METADATA_FILE"
      )
      for invalid_source_contract in "${invalid_source_contracts[@]}"; do
        add_error "source_contracts entries require path and reviewed_at: $invalid_source_contract"
      done

      # Provenance paths often live in other repos or move over time; a missing
      # local path is a warning, not a failure.
      mapfile -t source_contract_paths < <(jq -r '.source_contracts[] | .path // empty' "$METADATA_FILE")
      for source_contract_path in "${source_contract_paths[@]}"; do
        case "$source_contract_path" in
          http://*|https://*)
            continue
            ;;
        esac

        if [[ ! -e "$REPO_ROOT/$source_contract_path" && ! -e "$WORKSPACE_ROOT/$source_contract_path" ]]; then
          add_warning "source_contracts path not found locally: $source_contract_path"
        fi
      done
    fi
  fi
fi

# CHANGELOG must carry an entry for the metadata.json version.
if [[ ! -f "$CHANGELOG_FILE" ]]; then
  add_error "CHANGELOG.md not found at skill root"
elif [[ -n "$metadata_version" ]] && ! grep -qE "^## ${metadata_version}( |$)" "$CHANGELOG_FILE"; then
  add_error "CHANGELOG.md missing entry for version $metadata_version"
fi

# Optional registry consistency for skills still tracked in skill-registry.json
# (the Cursor-era own-skill registry; plugin skills are not listed there).
if [[ -f "$REGISTRY_FILE" ]]; then
  folder_name=$(basename "$SKILL_DIR")
  registry_version=$(jq -r ".skills[\"$folder_name\"].version // empty" "$REGISTRY_FILE")
  if [[ -n "$registry_version" && -n "$metadata_version" && "$metadata_version" != "$registry_version" ]]; then
    add_error "metadata.json version '$metadata_version' does not match registry version '$registry_version'"
  fi
fi

pass=true
if [[ ${#errors[@]} -gt 0 ]]; then
  pass=false
fi

if [[ ${#errors[@]} -gt 0 ]]; then
  errors_json=$(printf '%s\n' "${errors[@]}" | jq -R . | jq -s .)
else
  errors_json='[]'
fi

if [[ ${#warnings[@]} -gt 0 ]]; then
  warnings_json=$(printf '%s\n' "${warnings[@]}" | jq -R . | jq -s .)
else
  warnings_json='[]'
fi

jq -n \
  --argjson pass "$pass" \
  --argjson errors "$errors_json" \
  --argjson warnings "$warnings_json" \
  --arg lines "$line_count" \
  --arg name "${name_value:-}" \
  --arg folder "$(basename "$SKILL_DIR")" \
  '{
    pass: $pass,
    skill: $folder,
    name_field: $name,
    lines: ($lines | tonumber),
    errors: $errors,
    warnings: $warnings
  }'
