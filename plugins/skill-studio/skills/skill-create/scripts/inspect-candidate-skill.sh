#!/usr/bin/env bash
# Usage: inspect-candidate-skill.sh <candidate-path> [expected-name]
# Description: Inspect a possible Agent Skill directory and classify whether it
# can be imported as-is, needs adaptation, or should be rejected — against the
# Claude-first contract (SKILL.md frontmatter = name + description only). Self-
# contained (bash + jq + find); no repo-specific paths.
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <candidate-path> [expected-name]" >&2
  exit 1
fi

CANDIDATE_INPUT="${1/#\~/$HOME}"
EXPECTED_NAME="${2:-}"

add_line() {
  local var_name="$1"
  local value="$2"
  if [[ -z "${!var_name:-}" ]]; then
    printf -v "$var_name" '%s' "$value"
  else
    printf -v "$var_name" '%s\n%s' "${!var_name}" "$value"
  fi
}

to_json_array() {
  local raw="${1:-}"
  if [[ -z "$raw" ]]; then
    jq -n '[]'
  else
    printf '%s\n' "$raw" | jq -R . | jq -s .
  fi
}

extract_frontmatter() {
  local file="$1"
  awk '
    /^---$/ { marker_count += 1; if (marker_count == 1) next; if (marker_count == 2) exit }
    marker_count == 1 { print }
  ' "$file"
}

extract_description() {
  local frontmatter="$1"
  awk '
    BEGIN { capture = 0; out = "" }
    /^description:[[:space:]]*/ {
      line = $0
      sub(/^description:[[:space:]]*/, "", line)
      if (line == "" || line ~ /^[>|]/) { capture = 1; next }
      print line
      exit
    }
    capture == 1 {
      if ($0 ~ /^[[:alpha:]_][[:alnum:]_-]*:[[:space:]]*/) { print out; exit }
      line = $0
      sub(/^[[:space:]]+/, "", line)
      if (line != "") { if (out != "") out = out " "; out = out line }
    }
    END { if (capture == 1 && out != "") print out }
  ' <<< "$frontmatter"
}

# Resolve the candidate to a directory that contains a SKILL.md. Handles:
#  - a direct skill directory (has SKILL.md)
#  - a plugin tree: <root>/plugins/*/skills/<expected>/SKILL.md
#  - a legacy tree: <root>/skills/<expected>/SKILL.md
#  - a project with a single discoverable skill under skills/
resolve_candidate_dir() {
  local input_path="$1"
  local expected_name="$2"

  if [[ -f "$input_path/SKILL.md" ]]; then
    RESOLVED_SOURCE_SHAPE="direct-skill-dir"
    RESOLVED_DIR="$input_path"
    return 0
  fi

  if [[ -n "$expected_name" ]]; then
    if [[ -f "$input_path/skills/$expected_name/SKILL.md" ]]; then
      RESOLVED_SOURCE_SHAPE="repo-folder"
      RESOLVED_DIR="$input_path/skills/$expected_name"
      return 0
    fi
    local plugin_hit
    plugin_hit=$(find "$input_path/plugins" -mindepth 3 -maxdepth 3 -type d \
      -path "*/skills/$expected_name" 2>/dev/null | head -1 || true)
    if [[ -n "$plugin_hit" && -f "$plugin_hit/SKILL.md" ]]; then
      RESOLVED_SOURCE_SHAPE="plugin-with-skill"
      RESOLVED_DIR="$plugin_hit"
      return 0
    fi
  fi

  # Fall back: exactly one skill discoverable under a skills/ dir.
  local -a skill_dirs=()
  while IFS= read -r d; do
    [[ -f "$d/SKILL.md" ]] && skill_dirs+=("$d")
  done < <(find "$input_path" -type d -name skills -prune -exec find {} -mindepth 1 -maxdepth 1 -type d \; 2>/dev/null || true)

  if [[ ${#skill_dirs[@]} -eq 1 ]]; then
    RESOLVED_SOURCE_SHAPE="repo-folder"
    RESOLVED_DIR="${skill_dirs[0]}"
    return 0
  fi

  return 1
}

if [[ ! -e "$CANDIDATE_INPUT" ]]; then
  jq -n --arg path "$CANDIDATE_INPUT" '{
    candidatePath: $path,
    classification: "reject",
    blockingIssues: ["Candidate path does not exist"],
    adaptationNeeds: [],
    warnings: [],
    recommendedNextStep: "reject-or-rework"
  }'
  exit 0
fi

RESOLVED_SOURCE_SHAPE="unknown"
RESOLVED_DIR=""
blocking_issues=""
adaptation_needs=""
warnings=""

if ! resolve_candidate_dir "$CANDIDATE_INPUT" "$EXPECTED_NAME"; then
  add_line blocking_issues "Could not resolve a skill directory from the provided path"
  if [[ -d "$CANDIDATE_INPUT/skills" || -d "$CANDIDATE_INPUT/plugins" ]]; then
    add_line adaptation_needs "Pass an expected skill name when the source contains multiple skills"
  fi
  jq -n \
    --arg path "$CANDIDATE_INPUT" \
    --arg source_shape "$RESOLVED_SOURCE_SHAPE" \
    --argjson blocking "$(to_json_array "$blocking_issues")" \
    --argjson adapt "$(to_json_array "$adaptation_needs")" \
    '{
      candidatePath: $path,
      sourceShape: $source_shape,
      classification: "reject",
      blockingIssues: $blocking,
      adaptationNeeds: $adapt,
      warnings: [],
      recommendedNextStep: "reject-or-rework"
    }'
  exit 0
fi

resolved_dir="$RESOLVED_DIR"
skill_md="$resolved_dir/SKILL.md"
frontmatter="$(extract_frontmatter "$skill_md")"
name_field="$(printf '%s\n' "$frontmatter" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
description_field="$(extract_description "$frontmatter")"
folder_name="$(basename "$resolved_dir")"
detected_name="$folder_name"

if [[ -n "$name_field" ]]; then
  detected_name="$name_field"
else
  add_line blocking_issues "Missing required frontmatter field: name"
fi

if [[ -z "$description_field" ]]; then
  add_line blocking_issues "Missing required frontmatter field: description"
fi

if [[ -n "$name_field" && ! "$name_field" =~ ^[a-z0-9-]+$ ]]; then
  add_line blocking_issues "Frontmatter name is not lowercase hyphenated text"
fi

if [[ -n "$name_field" && "$name_field" != "$folder_name" ]]; then
  add_line adaptation_needs "Folder name does not match frontmatter name"
fi

if [[ -n "$EXPECTED_NAME" && -n "$name_field" && "$EXPECTED_NAME" != "$name_field" ]]; then
  add_line adaptation_needs "Expected name does not match detected frontmatter name"
fi

# Governance fields in frontmatter are a Claude-contract violation -> adapt.
for legacy in version last_reviewed source_contracts compatibility disable-model-invocation; do
  if printf '%s\n' "$frontmatter" | grep -qE "^${legacy}:"; then
    add_line adaptation_needs "Frontmatter carries '$legacy'; move governance to metadata.json"
  fi
done

if [[ ! -f "$resolved_dir/metadata.json" ]]; then
  add_line adaptation_needs "metadata.json is missing"
fi

if [[ ! -f "$resolved_dir/CHANGELOG.md" ]]; then
  add_line adaptation_needs "CHANGELOG.md is missing"
fi

skill_lines="$(wc -l < "$skill_md" | tr -d '[:space:]')"
if [[ "$skill_lines" -gt 500 ]]; then
  add_line adaptation_needs "SKILL.md exceeds 500 lines"
elif [[ "$skill_lines" -gt 350 ]]; then
  add_line warnings "SKILL.md is getting large for a hot-path routing file"
fi

references_count=0
assets_count=0
scripts_count=0
[[ -d "$resolved_dir/references" ]] && references_count="$(find "$resolved_dir/references" -type f | wc -l | tr -d '[:space:]')"
[[ -d "$resolved_dir/assets" ]] && assets_count="$(find "$resolved_dir/assets" -type f | wc -l | tr -d '[:space:]')"
if [[ -d "$resolved_dir/scripts" ]]; then
  scripts_count="$(find "$resolved_dir/scripts" -type f | wc -l | tr -d '[:space:]')"
  while IFS= read -r script_path; do
    if [[ ! -x "$script_path" ]]; then
      add_line warnings "Script is not executable: ${script_path#$resolved_dir/}"
    fi
  done < <(find "$resolved_dir/scripts" -type f -name '*.sh')
fi

classification="ready"
next_step="import-as-is"

if [[ -n "$blocking_issues" ]]; then
  classification="reject"
  next_step="reject-or-rework"
elif [[ -n "$adaptation_needs" ]]; then
  classification="adapt"
  next_step="copy-and-normalize"
fi

suggested_name="$detected_name"
[[ -z "$suggested_name" ]] && suggested_name="$folder_name"

jq -n \
  --arg path "$CANDIDATE_INPUT" \
  --arg resolved_dir "$resolved_dir" \
  --arg source_shape "$RESOLVED_SOURCE_SHAPE" \
  --arg folder_name "$folder_name" \
  --arg detected_name "$detected_name" \
  --arg description "$description_field" \
  --arg suggested_dest "plugins/<plugin>/skills/$suggested_name" \
  --arg classification "$classification" \
  --arg next_step "$next_step" \
  --argjson blocking "$(to_json_array "$blocking_issues")" \
  --argjson adapt "$(to_json_array "$adaptation_needs")" \
  --argjson warnings_json "$(to_json_array "$warnings")" \
  --argjson references_count "$references_count" \
  --argjson assets_count "$assets_count" \
  --argjson scripts_count "$scripts_count" \
  --argjson skill_lines "$skill_lines" \
  '{
    candidatePath: $path,
    resolvedSkillDir: $resolved_dir,
    sourceShape: $source_shape,
    folderName: $folder_name,
    detectedName: $detected_name,
    description: $description,
    suggestedDestination: $suggested_dest,
    classification: $classification,
    recommendedNextStep: $next_step,
    blockingIssues: $blocking,
    adaptationNeeds: $adapt,
    warnings: $warnings_json,
    files: {
      skillMdLines: $skill_lines,
      references: $references_count,
      assets: $assets_count,
      scripts: $scripts_count
    }
  }'
