#!/usr/bin/env bash
# Usage: scripts/cursor-pack-verify.sh [--pack=NAME]
# Validate cursor pack registry entries, pack structure, release artifacts,
# subagents, rules, hooks, MCP templates, bundled skill artifacts (kind: skill),
# and common secret/path safety issues.
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

validate_supported_target() {
  local label="$1"
  local value="$2"

  case "$value" in
    project-cursor|user-cursor) ;;
    *) add_error "$label: unsupported target '$value'" ;;
  esac
}

validate_supported_install_policy() {
  local label="$1"
  local conflict_policy="$2"
  local mcp_policy="$3"

  case "$conflict_policy" in
    backup-and-overwrite) ;;
    *) add_error "$label: unsupported conflictPolicy '$conflict_policy'" ;;
  esac

  case "$mcp_policy" in
    none|example-only) ;;
    *) add_error "$label: unsupported mcpPolicy '$mcp_policy'" ;;
  esac
}

validate_supported_registry_policy() {
  local label="$1"
  local project_rules="$2"
  local mcp="$3"

  case "$project_rules" in
    none|project-only) ;;
    *) add_error "$label: unsupported installPolicy.projectRules '$project_rules'" ;;
  esac

  case "$mcp" in
    none|example-only) ;;
    *) add_error "$label: unsupported installPolicy.mcp '$mcp'" ;;
  esac
}

fingerprint_lines() {
  sort | tr '\n' ' '
}

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

validate_pack_skill_artifact() {
  local pack_dir="$1"
  local actual_path="$2"
  local artifact_json="$3"

  local artifact_id source_rel skill_id source_abs fm_name
  artifact_id=$(jq -r '.id' <<<"$artifact_json")
  source_rel=$(jq -r '.source' <<<"$artifact_json")
  skill_id=$(jq -r '.skillId' <<<"$artifact_json")
  source_abs="$pack_dir/$source_rel"

  if ! [[ "$skill_id" =~ ^[a-z0-9-]+$ ]]; then
    add_error "$actual_path/pack.json: artifact '$artifact_id' has invalid skillId '$skill_id'"
    return
  fi

  if [[ ! -d "$source_abs" ]]; then
    add_error "$actual_path/pack.json: skill artifact '$artifact_id' source must be a directory: $source_rel"
    return
  fi

  [[ -f "$source_abs/SKILL.md" ]] || add_error "$actual_path/pack.json: skill artifact '$artifact_id' missing SKILL.md under $source_rel"
  [[ -f "$source_abs/metadata.json" ]] || add_error "$actual_path/pack.json: skill artifact '$artifact_id' missing metadata.json under $source_rel"

  if [[ -f "$source_abs/metadata.json" ]]; then
    jq empty "$source_abs/metadata.json" >/dev/null 2>&1 || add_error "$source_rel/metadata.json: invalid JSON"
  fi

  if [[ -f "$source_abs/SKILL.md" ]]; then
    fm_name=$(awk '/^---$/{n++; next} n==1 && /^name:/{sub(/^name:[[:space:]]*/,""); print; exit}' "$source_abs/SKILL.md" | tr -d '\r')
    fm_name="${fm_name//\"/}"
    if [[ -z "$fm_name" ]]; then
      add_error "$source_rel/SKILL.md: missing name in YAML frontmatter (required for bundled skills)"
    elif [[ "$fm_name" != "$skill_id" ]]; then
      add_error "$source_rel/SKILL.md: frontmatter name '$fm_name' must match pack.json skillId '$skill_id'"
    fi
  fi
}

validate_pack_skill_artifacts() {
  local pack_dir="$1"
  local actual_path="$2"
  local pack_json="$3"

  local skill_count
  skill_count=$(jq '[.artifacts[] | select(.kind == "skill")] | length' "$pack_json")
  if [[ "$skill_count" -eq 0 ]]; then
    return 0
  fi

  local dup_skill_ids
  dup_skill_ids=$(jq -r '.artifacts[] | select(.kind == "skill") | .skillId' "$pack_json" | sort | uniq -d | sort -u)
  while IFS= read -r dup_id; do
    [[ -n "$dup_id" ]] || continue
    add_error "$actual_path/pack.json: duplicate skillId '$dup_id' across skill artifacts"
  done <<<"$dup_skill_ids"

  while IFS= read -r artifact_json; do
    [[ -n "$artifact_json" ]] || continue
    validate_pack_skill_artifact "$pack_dir" "$actual_path" "$artifact_json"
  done < <(jq -c '.artifacts[] | select(.kind == "skill")' "$pack_json")
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

  [[ -f "$pack_dir/README.md" ]] || add_error "$actual_path: missing required README.md"

  while IFS= read -r target_name; do
    [[ -n "$target_name" ]] || continue
    validate_supported_target "$actual_path/pack.json" "$target_name"
  done < <(jq -r '.targets[]?' "$pack_json")

  while IFS= read -r target_name; do
    [[ -n "$target_name" ]] || continue
    validate_supported_target "cursor-pack-registry.json:$pack_name" "$target_name"
  done < <(jq -r '.targets[]?' <<<"$registry_entry")

  validate_supported_install_policy \
    "$actual_path/pack.json" \
    "$(jq -r '.install.conflictPolicy // empty' "$pack_json")" \
    "$(jq -r '.install.mcpPolicy // empty' "$pack_json")"

  validate_supported_registry_policy \
    "cursor-pack-registry.json:$pack_name" \
    "$(jq -r '.installPolicy.projectRules // empty' <<<"$registry_entry")" \
    "$(jq -r '.installPolicy.mcp // empty' <<<"$registry_entry")"

  local registry_targets_fingerprint pack_targets_fingerprint
  registry_targets_fingerprint=$(jq -r '.targets[]' <<<"$registry_entry" | fingerprint_lines)
  pack_targets_fingerprint=$(jq -r '.targets[]' "$pack_json" | fingerprint_lines)
  [[ "$registry_targets_fingerprint" == "$pack_targets_fingerprint" ]] || add_error "$pack_name: registry targets do not match pack.json targets"

  local registry_profiles_fingerprint pack_profiles_fingerprint
  registry_profiles_fingerprint=$(jq -r '.profiles[]' <<<"$registry_entry" | fingerprint_lines)
  pack_profiles_fingerprint=$(jq -r '.profiles | keys[]' "$pack_json" | fingerprint_lines)
  [[ "$registry_profiles_fingerprint" == "$pack_profiles_fingerprint" ]] || add_error "$pack_name: registry profiles do not match pack.json profiles"

  local registry_default_profile pack_default_profile
  registry_default_profile=$(jq -r '.installPolicy.defaultProfile' <<<"$registry_entry")
  pack_default_profile=$(jq -r '.install.defaultProfile' "$pack_json")
  [[ "$registry_default_profile" == "$pack_default_profile" ]] || add_error "$pack_name: registry defaultProfile '$registry_default_profile' does not match pack.json defaultProfile '$pack_default_profile'"
  jq -e --arg profile "$pack_default_profile" '.profiles[$profile] != null' "$pack_json" >/dev/null || add_error "$actual_path/pack.json: defaultProfile '$pack_default_profile' is not declared in profiles"

  local registry_mcp_policy pack_mcp_policy
  registry_mcp_policy=$(jq -r '.installPolicy.mcp' <<<"$registry_entry")
  pack_mcp_policy=$(jq -r '.install.mcpPolicy' "$pack_json")
  [[ "$registry_mcp_policy" == "$pack_mcp_policy" ]] || add_error "$pack_name: registry installPolicy.mcp '$registry_mcp_policy' does not match pack.json mcpPolicy '$pack_mcp_policy'"

  local registry_project_rules expected_project_rules
  registry_project_rules=$(jq -r '.installPolicy.projectRules' <<<"$registry_entry")
  if jq -e '[.artifacts[] | select((.kind // "runtime") == "runtime") | select((.projectPath // "" | startswith(".cursor/rules")) or (.source == ".cursor/rules"))] | length > 0' "$pack_json" >/dev/null; then
    expected_project_rules="project-only"
  else
    expected_project_rules="none"
  fi
  [[ "$registry_project_rules" == "$expected_project_rules" ]] || add_error "$pack_name: registry installPolicy.projectRules '$registry_project_rules' does not match pack.json rule artifacts '$expected_project_rules'"

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

  while IFS=$'\t' read -r artifact_id target_name; do
    [[ -n "${artifact_id:-}" ]] || continue
    validate_supported_target "$actual_path/pack.json artifact '$artifact_id'" "$target_name"
  done < <(jq -r '.artifacts[] | .id as $id | .targets[] | "\($id)\t\(.)"' "$pack_json")

  local missing_project_paths
  missing_project_paths=$(jq -r '
    .artifacts[]
    | select((.kind // "runtime") == "runtime")
    | select((.targets | index("project-cursor")) != null)
    | select((.projectPath // "") == "")
    | .id
  ' "$pack_json")
  while IFS= read -r artifact_id; do
    [[ -n "$artifact_id" ]] || continue
    add_error "$actual_path/pack.json: runtime artifact '$artifact_id' targets project-cursor but is missing projectPath"
  done <<<"$missing_project_paths"

  local missing_user_paths
  missing_user_paths=$(jq -r '
    .artifacts[]
    | select((.kind // "runtime") == "runtime")
    | select((.targets | index("user-cursor")) != null)
    | select((.userPath // "") == "")
    | .id
  ' "$pack_json")
  while IFS= read -r artifact_id; do
    [[ -n "$artifact_id" ]] || continue
    add_error "$actual_path/pack.json: runtime artifact '$artifact_id' targets user-cursor but is missing userPath"
  done <<<"$missing_user_paths"

  local live_mcp_artifacts
  live_mcp_artifacts=$(jq -r '
    .artifacts[]
    | select((.kind // "runtime") == "runtime")
    | select(
        (.source == ".cursor/mcp.json")
        or (.projectPath == ".cursor/mcp.json")
        or (.userPath == "mcp.json")
      )
    | .id
  ' "$pack_json")
  while IFS= read -r artifact_id; do
    [[ -n "$artifact_id" ]] || continue
    add_error "$actual_path/pack.json: artifact '$artifact_id' attempts to install live MCP config; use .cursor/mcp.example.json with mcpPolicy example-only"
  done <<<"$live_mcp_artifacts"

  validate_pack_skill_artifacts "$pack_dir" "$actual_path" "$pack_json"

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
