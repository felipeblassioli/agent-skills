#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
SCRIPT="$REPO_ROOT/scripts/skill-directory-sync.sh"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "$haystack" != *"$needle"* ]] || fail "expected output not to contain: $needle"
}

LAST_STATUS=0
LAST_OUTPUT=""

run_cmd() {
  local output status
  set +e
  output="$($SCRIPT "$@" 2>&1)"
  status=$?
  set -e
  LAST_STATUS="$status"
  LAST_OUTPUT="$output"
}

run_expect_success() {
  run_cmd "$@"
  [[ "$LAST_STATUS" -eq 0 ]] || fail "expected success ($*), got status=$LAST_STATUS output=$LAST_OUTPUT"
  printf '%s' "$LAST_OUTPUT"
}

run_expect_failure() {
  local expected_status="$1"
  shift
  run_cmd "$@"
  [[ "$LAST_STATUS" -eq "$expected_status" ]] || fail "expected status=$expected_status ($*), got status=$LAST_STATUS output=$LAST_OUTPUT"
  printf '%s' "$LAST_OUTPUT"
}

make_skill() {
  local root="$1"
  local name="$2"
  mkdir -p "$root/$name"
  printf '# %s\n' "$name" >"$root/$name/SKILL.md"
}

test_help_and_targets() {
  local output
  output="$(run_expect_success help)"
  assert_contains "$output" "Usage:"
  assert_contains "$output" "diff"
  output="$(run_expect_success list-targets)"
  assert_contains "$output" "cursor"
  assert_contains "$output" "$HOME/.cursor/skills"
  assert_contains "$output" "claude"
  assert_contains "$output" "$HOME/.claude/skills"
  assert_contains "$output" "agents"
  assert_contains "$output" "$HOME/.agents/skills"
}

test_usage_errors() {
  local output
  output="$(run_expect_failure 2 unknown)"
  assert_contains "$output" "Unknown command"
  output="$(run_expect_failure 2 diff --from=/tmp/a)"
  assert_contains "$output" "--to is required"
}

test_diff_missing_source_and_missing_dest_behavior() {
  local tmp output
  tmp="$(mktemp -d)"
  output="$(run_expect_failure 4 diff --from="$tmp/missing" --to="$tmp/dest")"
  assert_contains "$output" "Source root not found"

  mkdir -p "$tmp/source"
  make_skill "$tmp/source" alpha
  output="$(run_expect_success diff --from="$tmp/source" --to="$tmp/dest")"
  assert_contains "$output" "missing-in-destination"
  [[ ! -e "$tmp/dest" ]] || fail "diff created destination root"
  rm -rf "$tmp"
}

test_root_safety_rules() {
  local tmp output
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/source" "$tmp/source/nested"
  make_skill "$tmp/source" alpha

  output="$(run_expect_failure 3 apply --from="$tmp/source" --to="$tmp/source" --yes)"
  assert_contains "$output" "same directory"

  output="$(run_expect_failure 3 apply --from="$tmp/source" --to="$tmp/source/nested" --yes)"
  assert_contains "$output" "contains the other"

  output="$(run_expect_failure 3 apply --from="$tmp/source" --to="$tmp/source/missing/.." --yes)"
  assert_contains "$output" "Refusing unresolved dot path components"
  rm -rf "$tmp"
}

test_diff_states_and_filters() {
  local tmp output
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/source" "$tmp/dest"
  make_skill "$tmp/source" missing
  make_skill "$tmp/source" identical
  cp -R "$tmp/source/identical" "$tmp/dest/identical"
  make_skill "$tmp/dest" destination-only
  printf 'x\n' >"$tmp/dest/missing"
  mkdir -p "$tmp/source/not-a-skill"
  ln -s "$tmp/nope" "$tmp/source/broken-link"
  ln -s "$tmp/nope" "$tmp/dest/broken-dest"

  output="$(run_expect_success diff --from="$tmp/source" --to="$tmp/dest")"
  assert_contains "$output" "destination-conflict-for-source"
  assert_contains "$output" "identical"
  assert_contains "$output" "destination-only"
  assert_contains "$output" "invalid-source-entry"
  assert_contains "$output" "broken-source-symlink"
  assert_contains "$output" "broken-destination-symlink"

  output="$(run_expect_success diff --from="$tmp/source" --to="$tmp/dest" --skill=identical)"
  assert_contains "$output" "identical"
  assert_not_contains "$output" "destination-only"

  output="$(run_expect_failure 2 diff --from="$tmp/source" --to="$tmp/dest" --skill=../bad)"
  assert_contains "$output" "--skill must be a skill name"
  rm -rf "$tmp"
}

test_digest_behavior() {
  local tmp output
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/source/alpha/ref" "$tmp/dest/alpha/ref"
  printf '# alpha\n' >"$tmp/source/alpha/SKILL.md"
  printf '# alpha\n' >"$tmp/dest/alpha/SKILL.md"
  printf 'same\n' >"$tmp/source/alpha/ref/a.md"
  printf 'same\n' >"$tmp/dest/alpha/ref/a.md"

  output="$(run_expect_success diff --from="$tmp/source" --to="$tmp/dest")"
  assert_contains "$output" "identical"

  printf 'ignore-a\n' >"$tmp/source/alpha/.DS_Store"
  printf 'ignore-b\n' >"$tmp/dest/alpha/.DS_Store"
  output="$(run_expect_success diff --from="$tmp/source" --to="$tmp/dest")"
  assert_contains "$output" "identical"

  printf 'readme-a\n' >"$tmp/source/alpha/README.md"
  printf 'readme-b\n' >"$tmp/dest/alpha/README.md"
  output="$(run_expect_success diff --from="$tmp/source" --to="$tmp/dest")"
  assert_contains "$output" "changed"
  rm -rf "$tmp"
}

test_apply_copy_preflight_and_write() {
  local tmp output
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/source/alpha"
  make_skill "$tmp/source" alpha

  output="$(run_expect_failure 3 apply --from="$tmp/source" --to="$tmp/dest")"
  assert_contains "$output" "--yes is required"

  output="$(run_expect_failure 3 apply --from="$tmp/source" --to="$tmp/dest" --skill=alpha --skill=missing --yes)"
  assert_contains "$output" "Selected skill is not a valid source skill"
  [[ ! -e "$tmp/dest" ]] || fail "failed preflight created destination root"

  output="$(run_expect_success apply --from="$tmp/source" --to="$tmp/dest" --mode=copy --yes)"
  assert_contains "$output" "Copied: 1"
  [[ -f "$tmp/dest/alpha/SKILL.md" ]] || fail "copy apply did not copy skill"
  rm -rf "$tmp"
}

test_apply_dry_run_makes_no_changes() {
  local tmp output
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/source"
  make_skill "$tmp/source" alpha

  output="$(run_expect_success apply --from="$tmp/source" --to="$tmp/dest" --mode=copy --dry-run)"
  assert_contains "$output" "Copied: 1"
  assert_contains "$output" "Planned actions:"
  assert_contains "$output" "copy"
  assert_contains "$output" "$tmp/source/alpha -> $tmp/dest/alpha"
  assert_contains "$output" "Dry run complete"
  [[ ! -e "$tmp/dest" ]] || fail "dry-run created destination root"
  rm -rf "$tmp"
}

test_apply_dry_run_shows_conflict_details() {
  local tmp output
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/source" "$tmp/dest"
  make_skill "$tmp/source" changed
  make_skill "$tmp/source" invalid-dest
  mkdir -p "$tmp/dest/changed"
  printf '# source\n' >"$tmp/source/changed/SKILL.md"
  printf '# destination\n' >"$tmp/dest/changed/SKILL.md"
  printf 'I am not a skill directory\n' >"$tmp/dest/invalid-dest"

  output="$(run_expect_success apply --from="$tmp/source" --to="$tmp/dest" --dry-run)"
  assert_contains "$output" "Conflicts:"
  assert_contains "$output" "changed"
  assert_contains "$output" "destination changed; add --overwrite --backup"
  assert_contains "$output" "from: $tmp/source/changed"
  assert_contains "$output" "to:   $tmp/dest/changed"
  assert_contains "$output" "invalid-dest"
  assert_contains "$output" "destination has invalid structure (invalid-destination-entry)"
  rm -rf "$tmp"
}

test_apply_dry_run_verbose_shows_file_diff() {
  local tmp output
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/source/alpha" "$tmp/dest/alpha"
  printf '# source\n' >"$tmp/source/alpha/SKILL.md"
  printf '# source-extra\n' >"$tmp/source/alpha/extra.md"
  printf '# destination\n' >"$tmp/dest/alpha/SKILL.md"
  printf 'obsolete\n' >"$tmp/dest/alpha/old.md"

  output="$(run_expect_success apply --from="$tmp/source" --to="$tmp/dest" --mode=copy --overwrite --backup --dry-run --verbose)"
  assert_contains "$output" "update"
  assert_contains "$output" "alpha"
  assert_contains "$output" "$tmp/source/alpha -> $tmp/dest/alpha"
  assert_contains "$output" "Files to change:"
  assert_contains "$output" "M SKILL.md"
  assert_contains "$output" "A extra.md"
  assert_contains "$output" "R old.md"

  rm -rf "$tmp"
}

test_apply_overwrite_and_backup() {
  local tmp output backup_dir
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/source/alpha" "$tmp/dest/alpha"
  printf '# src\n' >"$tmp/source/alpha/SKILL.md"
  printf '# dst\n' >"$tmp/dest/alpha/SKILL.md"
  printf 'stale\n' >"$tmp/dest/alpha/stale.md"

  output="$(run_expect_failure 3 apply --from="$tmp/source" --to="$tmp/dest" --yes)"
  assert_contains "$output" "--overwrite"

  output="$(run_expect_failure 3 apply --from="$tmp/source" --to="$tmp/dest" --overwrite --yes)"
  assert_contains "$output" "--backup"

  output="$(run_expect_success apply --from="$tmp/source" --to="$tmp/dest" --overwrite --backup --yes)"
  assert_contains "$output" "Updated: 1"
  backup_dir="$(printf '%s\n' "$output" | sed -n 's/^Backup directory: //p')"
  [[ -f "$backup_dir/backup-metadata.json" ]] || fail "missing backup metadata"
  [[ ! -e "$tmp/dest/alpha/stale.md" ]] || fail "overwrite left stale file"
  rm -rf "$tmp"
}

test_symlink_mode_and_destination_symlink_safety() {
  local tmp output
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/source/alpha" "$tmp/dest"
  printf '# source\n' >"$tmp/source/alpha/SKILL.md"
  output="$(run_expect_success apply --from="$tmp/source" --to="$tmp/dest" --mode=symlink --yes)"
  assert_contains "$output" "Copied: 1"
  [[ -L "$tmp/dest/alpha" ]] || fail "missing destination symlink"

  mkdir -p "$tmp/source/beta" "$tmp/external"
  printf '# beta\n' >"$tmp/source/beta/SKILL.md"
  printf '# external\n' >"$tmp/external/SKILL.md"
  ln -s "$tmp/external" "$tmp/dest/beta"
  output="$(run_expect_success apply --from="$tmp/source" --to="$tmp/dest" --mode=symlink --overwrite --backup --yes --skill=beta)"
  assert_contains "$output" "Updated: 1"
  [[ "$(cat "$tmp/external/SKILL.md")" == "# external" ]] || fail "external symlink target was modified"
  rm -rf "$tmp"
}

test_broken_nested_symlink_refusal() {
  local tmp output
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/source/alpha"
  make_skill "$tmp/source" alpha
  ln -s "$tmp/nope" "$tmp/source/alpha/bad-link"
  output="$(run_expect_failure 3 apply --from="$tmp/source" --to="$tmp/dest" --yes)"
  assert_contains "$output" "broken nested symlink"
  [[ ! -e "$tmp/dest" ]] || fail "refusal created destination root"
  rm -rf "$tmp"
}

test_help_and_targets
test_usage_errors
test_diff_missing_source_and_missing_dest_behavior
test_root_safety_rules
test_diff_states_and_filters
test_digest_behavior
test_apply_copy_preflight_and_write
test_apply_dry_run_makes_no_changes
test_apply_dry_run_shows_conflict_details
test_apply_dry_run_verbose_shows_file_diff
test_apply_overwrite_and_backup
test_symlink_mode_and_destination_symlink_safety
test_broken_nested_symlink_refusal

printf 'All tests passed\n'
