#!/usr/bin/env bash
# Usage: scripts/review-skill-pr.sh [--base=<branch>] [--format=json|markdown]
# Reviews the current branch for skill-PR quality gates.
set -euo pipefail

BASE="main"
FORMAT="json"

for arg in "$@"; do
  case "$arg" in
    --base=*)
      BASE="${arg#*=}"
      ;;
    --format=*)
      FORMAT="${arg#*=}"
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

if [[ "$FORMAT" != "json" && "$FORMAT" != "markdown" ]]; then
  echo "Invalid --format value: $FORMAT (expected json or markdown)" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if ! git rev-parse --verify "$BASE" >/dev/null 2>&1; then
  if git rev-parse --verify "origin/$BASE" >/dev/null 2>&1; then
    BASE="origin/$BASE"
  else
    echo "Base branch '$BASE' not found locally or as origin/$BASE" >&2
    exit 1
  fi
fi

changed_files=()
while IFS= read -r line; do
  [[ -n "$line" ]] && changed_files+=("$line")
done < <(git diff --name-only "$BASE"...HEAD)

touches_raw=""
removed_raw=""
for path in "${changed_files[@]}"; do
  case "$path" in
    skills/*/*)
      skill_name="${path#skills/}"
      skill_name="${skill_name%%/*}"
      skill_dir="skills/$skill_name"
      if [[ -d "$skill_dir" ]]; then
        touches_raw="${touches_raw}${skill_dir}"$'\n'
      else
        removed_raw="${removed_raw}${skill_dir}"$'\n'
      fi
      ;;
  esac
done

touched_lines=""
if [[ -n "$touches_raw" ]]; then
  touched_lines="$(printf '%s' "$touches_raw" | sort -u | sed '/^$/d')"
fi

removed_lines=""
if [[ -n "$removed_raw" ]]; then
  removed_lines="$(printf '%s' "$removed_raw" | sort -u | sed '/^$/d')"
fi

structural_results='[]'
while IFS= read -r skill_dir; do
  [[ -z "$skill_dir" ]] && continue
  skill_json="$(bash "skills/create-skill-from-refs/scripts/validate-skill.sh" "$skill_dir" 2>/dev/null || true)"
  if [[ -z "$skill_json" ]]; then
    skill_json="$(jq -n --arg skill "$(basename "$skill_dir")" '{
      pass: false,
      skill: $skill,
      errors: ["validate-skill.sh did not return output"],
      warnings: []
    }')"
  fi
  structural_results="$(jq -c --argjson item "$skill_json" '. + [$item]' <<<"$structural_results")"
done <<<"$touched_lines"

registry_json="$(
  bash "skills/skill-pr-review/scripts/check-registry-consistency.sh" \
    --registry "skill-registry.json" \
    --touched "$touched_lines" \
    --removed "$removed_lines"
)"

current_branch="$(git rev-parse --abbrev-ref HEAD)"
branch_ok=true
if ! [[ "$current_branch" =~ ^(feat|fix|refactor|docs|chore|build|ci|style)/[a-z0-9-]+$ ]]; then
  branch_ok=false
fi

commit_titles_json='[]'
commit_format_ok=true
commit_titles=()
while IFS= read -r line; do
  [[ -n "$line" ]] && commit_titles+=("$line")
done < <(git log --format=%s "$BASE"..HEAD)

for title in "${commit_titles[@]}"; do
  title_ok=true
  if ! [[ "$title" =~ ^(feat|fix|refactor|docs|chore|build|ci|style)(\([a-z0-9-]+\))?:\ .+ ]]; then
    title_ok=false
    commit_format_ok=false
  fi
  commit_titles_json="$(jq -c --arg t "$title" --argjson ok "$title_ok" '. + [{title: $t, valid: $ok}]' <<<"$commit_titles_json")"
done

structural_pass="$(jq -r 'all(.[]?; .pass == true)' <<<"$structural_results")"
registry_pass="$(jq -r '.pass' <<<"$registry_json")"
overall_pass=true
if [[ "$structural_pass" != "true" || "$registry_pass" != "true" || "$branch_ok" != "true" || "$commit_format_ok" != "true" ]]; then
  overall_pass=false
fi

result_json="$(
  jq -n \
    --arg base "$BASE" \
    --arg branch "$current_branch" \
    --argjson changedFiles "$(printf '%s\n' "${changed_files[@]}" | jq -R . | jq -s 'map(select(length > 0))')" \
    --argjson touchedSkills "$(printf '%s\n' "$touched_lines" | jq -R . | jq -s 'map(select(length > 0))')" \
    --argjson removedSkills "$(printf '%s\n' "$removed_lines" | jq -R . | jq -s 'map(select(length > 0))')" \
    --argjson structural "$structural_results" \
    --argjson registry "$registry_json" \
    --argjson branchOk "$branch_ok" \
    --argjson commitFormatOk "$commit_format_ok" \
    --argjson commitTitles "$commit_titles_json" \
    --argjson pass "$overall_pass" \
    '{
      pass: $pass,
      base: $base,
      branch: $branch,
      changed_files: $changedFiles,
      touched_skills: $touchedSkills,
      removed_skills: $removedSkills,
      structural: $structural,
      registry: $registry,
      pr_hygiene: {
        branch_name_valid: $branchOk,
        commit_titles_valid: $commitFormatOk,
        commit_titles: $commitTitles
      }
    }'
)"

if [[ "$FORMAT" == "json" ]]; then
  echo "$result_json"
  exit 0
fi

echo "## Skill PR Review"
echo
echo "- Pass: $(jq -r '.pass' <<<"$result_json")"
echo "- Base: $(jq -r '.base' <<<"$result_json")"
echo "- Branch: $(jq -r '.branch' <<<"$result_json")"
echo "- Touched skills: $(jq -r '.touched_skills | join(", ") // "none"' <<<"$result_json")"
echo "- Removed skills: $(jq -r '.removed_skills | join(", ") // "none"' <<<"$result_json")"
echo
echo "### PR hygiene"
echo "- Branch name valid: $(jq -r '.pr_hygiene.branch_name_valid' <<<"$result_json")"
echo "- Commit titles valid: $(jq -r '.pr_hygiene.commit_titles_valid' <<<"$result_json")"
echo
echo "### Structural"
jq -r '.structural[]? | "- \(.skill): pass=\(.pass), errors=\((.errors // []) | length), warnings=\((.warnings // []) | length)"' <<<"$result_json"
echo
echo "### Registry"
echo "- Pass: $(jq -r '.registry.pass' <<<"$result_json")"
jq -r '.registry.findings[]? | "- [\(.severity)] \(.message)"' <<<"$result_json"
