#!/usr/bin/env bash
# Usage: scripts/cursor-pack-verify.sh [--pack=NAME]
# Validate cursor pack registry entries, pack structure, release artifacts,
# subagents, rules, hooks, MCP templates, and common secret/path safety issues.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/lib-cursor-pack.sh
source "$SCRIPT_DIR/lib-cursor-pack.sh"

FILTER_PACK=""

for arg in "$@"; do
  case "$arg" in
    --pack=*) FILTER_PACK="${arg#--pack=}" ;;
    --help)
      echo "Usage: $0 [--pack=NAME]"
      exit 0
      ;;
    *)
      cursor_pack_die "Unknown option: $arg"
      ;;
  esac
done

cursor_pack_require_file "$CURSOR_PACK_REGISTRY"

errors=()
warnings=()
packs_checked=0

add_error() { errors+=("$1"); }
add_warning() { warnings+=("$1"); }

validate_subagent() {
  local file="$1"
  local rel="${file#$CURSOR_PACK_REPO_ROOT/}"
  local first_line frontmatter
  first_line=$(sed -n '1p' "$file")
  [[ "$first_line" == "---" ]] || add_error "$rel: subagent file must start with YAML frontmatter"
  frontmatter=$(awk '/^---$/{n++; next} n==1{print} n>=2{exit}' "$file")

  local name_line desc_line model_line readonly_line background_line
  name_line=$(printf '%s\n' "$frontmatter" | awk -F': *' '/^name:/{print $2; exit}')
  desc_line=$(printf '%s\n' "$frontmatter" | awk -F': *' '/^description:/{print $2; exit}')
  model_line=$(printf '%s\n' "$frontmatter" | awk -F': *' '/^model:/{print $2; exit}')
  readonly_line=$(printf '%s\n' "$frontmatter" | awk -F': *' '/^readonly:/{print $2; exit}')
  background_line=$(printf '%s\n' "$frontmatter" | awk -F': *' '/^background:/{print $2; exit}')

  [[ -n "$name_line" ]] || add_error "$rel: missing subagent name in frontmatter"
  [[ -n "$desc_line" ]] || add_error "$rel: missing subagent description in frontmatter"

  if [[ -n "$model_line" ]] && ! [[ "$model_line" =~ ^(fast|inherit|[A-Za-z0-9._:-]+)$ ]]; then
    add_error "$rel: invalid model value '$model_line'"
  fi

  if [[ -n "$readonly_line" ]] && ! [[ "$readonly_line" =~ ^(true|false)$ ]]; then
    add_error "$rel: readonly must be true or false"
  fi

  if [[ -n "$background_line" ]] && ! [[ "$background_line" =~ ^(true|false)$ ]]; then
    add_error "$rel: background must be true or false"
  fi
}

validate_rule() {
  local file="$1"
  local rel="${file#$CURSOR_PACK_REPO_ROOT/}"
  local first_line frontmatter description
  first_line=$(sed -n '1p' "$file")
  [[ "$first_line" == "---" ]] || add_error "$rel: rule must start with YAML frontmatter"
  frontmatter=$(awk '/^---$/{n++; next} n==1{print} n>=2{exit}' "$file")
  description=$(printf '%s\n' "$frontmatter" | awk -F': *' '/^description:/{print $2; exit}')

  [[ -n "$description" ]] || add_error "$rel: missing rule description in frontmatter"

  local line_count
  line_count=$(wc -l < "$file" | tr -d '[:space:]')
  if [[ "$line_count" -gt 500 ]]; then
    add_error "$rel: rule exceeds 500 lines ($line_count)"
  fi
}

validate_hook_config() {
  local file="$1"
  local pack_dir="$2"
  local rel="${file#$CURSOR_PACK_REPO_ROOT/}"

  jq empty "$file" >/dev/null 2>&1 || add_error "$rel: invalid JSON"

  local commands
  commands=$(jq -r '
    .hooks // {}
    | to_entries[]
    | .value[]
    | select(.command != null)
    | .command
  ' "$file")

  while IFS= read -r command; do
    [[ -n "$command" ]] || continue
    case "$command" in
      .cursor/hooks/*)
        local hook_path="$pack_dir/$command"
        [[ -f "$hook_path" ]] || add_error "$rel: referenced hook script not found: $command"
        [[ -x "$hook_path" ]] || add_error "$rel: referenced hook script is not executable: $command"
        ;;
      ./hooks/*|hooks/*)
        local normalized="${command#./}"
        local hook_path="$pack_dir/.cursor/$normalized"
        [[ -f "$hook_path" ]] || add_error "$rel: referenced user hook script not found: $command"
        [[ -x "$hook_path" ]] || add_error "$rel: referenced user hook script is not executable: $command"
        ;;
      *)
        add_warning "$rel: hook command is not pack-local and should be reviewed: $command"
        ;;
    esac
  done <<<"$commands"
}

validate_mcp_example() {
  local file="$1"
  local rel="${file#$CURSOR_PACK_REPO_ROOT/}"

  jq empty "$file" >/dev/null 2>&1 || add_error "$rel: invalid JSON"

  local hardcoded_secret_count
  hardcoded_secret_count=$(jq '[.. | scalars | select(type == "string") | select(test("(sk-[A-Za-z0-9]{10,}|AIza[0-9A-Za-z_-]{10,}|ghp_[A-Za-z0-9]{10,}|AIza|ya29\\.)"))] | length' "$file")
  if [[ "$hardcoded_secret_count" != "0" ]]; then
    add_error "$rel: contains values that look like hardcoded secrets"
  fi

  local env_refs
  env_refs=$(jq '[.. | scalars | select(type == "string") | select(test("\\$\\{env:"))] | length' "$file")
  if [[ "$env_refs" == "0" ]]; then
    add_warning "$rel: does not contain env interpolation placeholders"
  fi
}

validate_release_artifacts() {
  local pack_dir="$1"
  local rel_dir="${pack_dir#$CURSOR_PACK_REPO_ROOT/}"
  local changelog_file verification_file policy_file roadmap_file

  changelog_file="$pack_dir/CHANGELOG.md"
  verification_file="$pack_dir/VERIFICATION.md"
  policy_file="$pack_dir/RELEASE-POLICY.md"
  roadmap_file="$pack_dir/ROADMAP.md"

  [[ -f "$changelog_file" ]] || add_error "$rel_dir: missing release artifact CHANGELOG.md"
  [[ -f "$verification_file" ]] || add_error "$rel_dir: missing release artifact VERIFICATION.md"
  [[ -f "$policy_file" ]] || add_error "$rel_dir: missing release artifact RELEASE-POLICY.md"
  [[ -f "$roadmap_file" ]] || add_error "$rel_dir: missing release artifact ROADMAP.md"

  [[ -s "$changelog_file" ]] || add_warning "$rel_dir/CHANGELOG.md: file is empty"
  [[ -s "$verification_file" ]] || add_warning "$rel_dir/VERIFICATION.md: file is empty"
  [[ -s "$policy_file" ]] || add_warning "$rel_dir/RELEASE-POLICY.md: file is empty"
  [[ -s "$roadmap_file" ]] || add_warning "$rel_dir/ROADMAP.md: file is empty"

  if [[ -f "$changelog_file" ]] && ! rg -q 'VERIFICATION\.md' "$changelog_file"; then
    add_warning "$rel_dir/CHANGELOG.md: should point readers to VERIFICATION.md"
  fi

  if [[ -f "$verification_file" ]] && ! rg -q '^(## |### )?Diagnosis\b|residual risks|Outcome' "$verification_file"; then
    add_warning "$rel_dir/VERIFICATION.md: should capture diagnosis, outcome, or residual risks"
  fi

  if [[ -f "$policy_file" ]] && ! rg -q 'CHANGELOG\.md' "$policy_file"; then
    add_warning "$rel_dir/RELEASE-POLICY.md: should mention CHANGELOG.md"
  fi

  if [[ -f "$policy_file" ]] && ! rg -q 'VERIFICATION\.md' "$policy_file"; then
    add_warning "$rel_dir/RELEASE-POLICY.md: should mention VERIFICATION.md"
  fi

  if [[ -f "$policy_file" ]] && ! rg -q 'ROADMAP\.md' "$policy_file"; then
    add_warning "$rel_dir/RELEASE-POLICY.md: should mention ROADMAP.md"
  fi
}

scan_pack_for_safety_issues() {
  local pack_dir="$1"
  local rel_dir="${pack_dir#$CURSOR_PACK_REPO_ROOT/}"

  if rg -n '/Users/|/home/|C:\\\\Users\\\\|felipe\\.blassioli' "$pack_dir" >/dev/null 2>&1; then
    add_warning "$rel_dir: contains machine-specific absolute paths or personal usernames"
  fi

  if rg -n '(sk-[A-Za-z0-9]{10,}|ghp_[A-Za-z0-9]{10,}|AIza[0-9A-Za-z_-]{10,}|ya29\.[A-Za-z0-9._-]+)' "$pack_dir" >/dev/null 2>&1; then
    add_error "$rel_dir: contains strings that look like real credentials"
  fi
}

validate_pack() {
  local pack_name="$1"
  local registry_entry pack_dir pack_json
  registry_entry=$(cursor_pack_registry_entry "$pack_name")
  pack_dir=$(cursor_pack_path "$pack_name")
  pack_json="$pack_dir/pack.json"

  ((packs_checked+=1))

  cursor_pack_require_dir "$pack_dir"
  cursor_pack_require_file "$pack_json"

  jq empty "$pack_json" >/dev/null 2>&1 || add_error "packs/$pack_name/pack.json: invalid JSON"

  local registry_version pack_version
  registry_version=$(jq -r '.version' <<<"$registry_entry")
  pack_version=$(jq -r '.version' "$pack_json")
  [[ "$registry_version" == "$pack_version" ]] || add_error "$pack_name: registry version $registry_version does not match pack.json version $pack_version"

  local registry_path actual_path
  registry_path=$(jq -r '.path' <<<"$registry_entry")
  actual_path="${pack_dir#$CURSOR_PACK_REPO_ROOT/}"
  [[ "$registry_path" == "$actual_path" ]] || add_error "$pack_name: registry path $registry_path does not match actual path $actual_path"

  local pack_name_field
  pack_name_field=$(jq -r '.name' "$pack_json")
  [[ "$pack_name_field" == "$pack_name" ]] || add_error "$pack_name: pack.json name '$pack_name_field' does not match registry key"

  jq -e '
    .name != null and
    .version != null and
    .description != null and
    .author != null and
    (.targets | length > 0) and
    (.profiles | length > 0) and
    (.artifacts | length > 0)
  ' "$pack_json" >/dev/null || add_error "$actual_path/pack.json: missing required top-level fields"

  local missing_sources
  missing_sources=$(jq -r '.artifacts[].source' "$pack_json" | while IFS= read -r source; do
    [[ -e "$pack_dir/$source" ]] || echo "$source"
  done)
  while IFS= read -r missing; do
    [[ -n "$missing" ]] || continue
    add_error "$actual_path/pack.json: artifact source missing: $missing"
  done <<<"$missing_sources"

  local invalid_profiles
  invalid_profiles=$(jq -r '
    . as $pack
    | .artifacts[]
    | .id as $id
    | .profiles[]
    | select($pack.profiles[.] == null)
    | "\($id)\t\(.)"
  ' "$pack_json")
  while IFS=$'\t' read -r artifact_id profile_name; do
    [[ -n "${artifact_id:-}" ]] || continue
    add_error "$actual_path/pack.json: artifact '$artifact_id' references unknown profile '$profile_name'"
  done <<<"$invalid_profiles"

  local invalid_targets
  invalid_targets=$(jq -r --argjson registry_targets "$(jq '.targets' <<<"$registry_entry")" '
    .artifacts[]
    | .id as $id
    | .targets[]
    | select(($registry_targets | index(.)) == null)
    | "\($id)\t\(.)"
  ' "$pack_json")
  while IFS=$'\t' read -r artifact_id target_name; do
    [[ -n "${artifact_id:-}" ]] || continue
    add_error "$actual_path/pack.json: artifact '$artifact_id' references target '$target_name' not allowed by registry"
  done <<<"$invalid_targets"

  validate_release_artifacts "$pack_dir"

  if [[ -d "$pack_dir/.cursor/agents" ]]; then
    while IFS= read -r file; do
      validate_subagent "$file"
    done < <(rg --files "$pack_dir/.cursor/agents" -g '*.md')
  fi

  if [[ -d "$pack_dir/.cursor/rules" ]]; then
    while IFS= read -r file; do
      validate_rule "$file"
    done < <(rg --files "$pack_dir/.cursor/rules" -g '*.mdc')
  fi

  if [[ -f "$pack_dir/.cursor/hooks.project.json" ]]; then
    validate_hook_config "$pack_dir/.cursor/hooks.project.json" "$pack_dir"
  fi

  if [[ -f "$pack_dir/.cursor/hooks.user.json" ]]; then
    validate_hook_config "$pack_dir/.cursor/hooks.user.json" "$pack_dir"
  fi

  if [[ -f "$pack_dir/.cursor/mcp.example.json" ]]; then
    validate_mcp_example "$pack_dir/.cursor/mcp.example.json"
  fi

  scan_pack_for_safety_issues "$pack_dir"
}

packs=$(jq -r '.packs | keys[]' "$CURSOR_PACK_REGISTRY")

for pack_name in $packs; do
  if [[ -n "$FILTER_PACK" && "$pack_name" != "$FILTER_PACK" ]]; then
    continue
  fi
  validate_pack "$pack_name"
done

if [[ "$packs_checked" -eq 0 ]]; then
  cursor_pack_die "No packs matched the current filter."
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
  --argjson checked "$packs_checked" \
  --argjson errors "$errors_json" \
  --argjson warnings "$warnings_json" \
  '{
    pass: $pass,
    packsChecked: $checked,
    errors: $errors,
    warnings: $warnings
  }'
