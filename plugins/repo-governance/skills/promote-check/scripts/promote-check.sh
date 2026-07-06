#!/usr/bin/env bash
# promote-check.sh — promotion preflight gate for the agent-skills marketplace.
#
# Given a candidate skill directory, run the promotion gates in order and emit a
# go / no-go verdict that CITES the failing gate(s). Audit-first: a promotion
# must FIX everything the audit surfaces, not merely pass a binary.
#
# Gates, in order (issue #121):
#   audit     — deterministic mechanical findings from skill-studio's
#               audit-skill.sh: name↔folder mismatch, orphan/dangling references,
#               non-executable scripts, relative bundled-script calls,
#               cross-package relative links, missing/invalid metadata. ANY such
#               unresolved finding blocks.
#   alignment — scripts/marketplace-consistency.sh --plugin <plugin> (the #120
#               helper): marketplace ↔ plugin.json ↔ metadata ↔ CHANGELOG ↔
#               registry drift for the candidate's plugin.
#   version   — metadata.json carries a non-empty version.
#   changelog — CHANGELOG.md exists and its top entry matches the metadata version.
#
# Read-only. Harness-agnostic: no Claude dependency — the promote-check skill is a
# thin user-facing wrapper. Reusable in CI.
#
# Usage: promote-check.sh <skill-dir> [--json]
# Exit:  0 = go, 1 = no-go, 2 = usage/environment error.
set -uo pipefail

JSON=0
SKILL_DIR=""
for arg in "$@"; do
  case "$arg" in
    --json) JSON=1 ;;
    -h|--help) sed -n '2,26p' "$0"; exit 0 ;;
    -*) echo "promote-check: unknown option '$arg'" >&2; exit 2 ;;
    *) SKILL_DIR="${arg%/}" ;;
  esac
done

[[ -n "$SKILL_DIR" ]] || { echo "promote-check: usage: promote-check.sh <skill-dir> [--json]" >&2; exit 2; }
[[ -d "$SKILL_DIR" ]] || { echo "promote-check: '$SKILL_DIR' is not a directory" >&2; exit 2; }
[[ -f "$SKILL_DIR/SKILL.md" ]] || { echo "promote-check: '$SKILL_DIR' has no SKILL.md" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "promote-check: jq is required" >&2; exit 2; }

ROOT="$(git -C "$SKILL_DIR" rev-parse --show-toplevel 2>/dev/null)" || ROOT=""
[[ -n "$ROOT" ]] || { echo "promote-check: '$SKILL_DIR' is not inside a git repo (cannot locate governance tools)" >&2; exit 2; }

AUDIT="$ROOT/plugins/skill-studio/skills/skill-audit/scripts/audit-skill.sh"
CONSISTENCY="$ROOT/scripts/marketplace-consistency.sh"

# Candidate plugin (for the alignment scope): plugins/<plugin>/skills/<skill>.
abs_dir="$(cd "$SKILL_DIR" && pwd)"
rel="${abs_dir#"$ROOT"/}"
plugin=""
case "$rel" in
  plugins/*/skills/*) plugin="$(printf '%s' "$rel" | awk -F/ '{print $2}')" ;;
esac

# Top CHANGELOG version: first "## ..." heading carrying a semver, skipping
# "Unreleased". Handles `## 1.2.3 - date` and Keep-a-Changelog `## [1.2.3]`.
changelog_version() {
  grep -E '^##[[:space:]]' "$1" 2>/dev/null | grep -viE 'unreleased' \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

# Gate results: parallel arrays gate/status/detail.
gates=(); statuses=(); details=()
record() { gates+=("$1"); statuses+=("$2"); details+=("$3"); }

# --- Gate 1: audit ------------------------------------------------------------
if [[ ! -f "$AUDIT" ]]; then
  echo "promote-check: audit tool not found at $AUDIT" >&2; exit 2
fi
audit_json="$(bash "$AUDIT" "$SKILL_DIR" 2>/dev/null)" || audit_json=""
if ! printf '%s' "$audit_json" | jq -e '.skills[0]' >/dev/null 2>&1; then
  echo "promote-check: audit produced no parseable result for '$SKILL_DIR'" >&2; exit 2
fi
audit_findings="$(printf '%s' "$audit_json" | jq -r '
  .skills[0] as $s | [
    (if $s.frontmatter.name_matches_folder == false then "name \"\($s.frontmatter.name)\" does not match folder" else empty end),
    (if ($s.context_efficiency.orphan_references|length) > 0 then "orphan references: \($s.context_efficiency.orphan_references|join(", "))" else empty end),
    (if ($s.context_efficiency.dangling_skill_links|length) > 0 then "dangling SKILL.md links: \($s.context_efficiency.dangling_skill_links|join(", "))" else empty end),
    (if ($s.context_efficiency.non_executable_scripts|length) > 0 then "non-executable scripts: \($s.context_efficiency.non_executable_scripts|join(", "))" else empty end),
    (if ($s.context_efficiency.relative_bundled_script_calls) > 0 then "relative bundled-script calls (cache-unsafe): \($s.context_efficiency.relative_bundled_script_calls)" else empty end),
    (if ($s.cache_copy_hazards.cross_package_relative_links|length) > 0 then "cross-package relative links: \($s.cache_copy_hazards.cross_package_relative_links|join(", "))" else empty end),
    (if $s.package.metadata_json == false then "metadata.json missing" else empty end),
    (if $s.package.metadata_valid == false then "metadata.json is not valid JSON" else empty end)
  ] | .[]')"
if [[ -n "$audit_findings" ]]; then
  record "audit" "fail" "$audit_findings"
else
  record "audit" "pass" "no unresolved mechanical findings"
fi

# --- Gate 2: alignment --------------------------------------------------------
if [[ ! -f "$CONSISTENCY" ]]; then
  echo "promote-check: consistency helper not found at $CONSISTENCY (depends on #120)" >&2; exit 2
fi
align_args=(--json)
[[ -n "$plugin" ]] && align_args+=(--plugin "$plugin")
align_json="$(bash "$CONSISTENCY" "${align_args[@]}" 2>/dev/null)" || align_json=""
if printf '%s' "$align_json" | jq -e '.clean == true' >/dev/null 2>&1; then
  record "alignment" "pass" "no marketplace/registry drift${plugin:+ (plugin: $plugin)}"
else
  align_detail="$(printf '%s' "$align_json" | jq -r '(.findings // []) | map("[\(.code)] \(.location): \(.detail)") | join("; ")' 2>/dev/null)"
  [[ -n "$align_detail" && "$align_detail" != "null" ]] || align_detail="consistency helper reported drift"
  record "alignment" "fail" "$align_detail"
fi

# --- Gate 3: version ----------------------------------------------------------
meta="$SKILL_DIR/metadata.json"
meta_version=""
if [[ -f "$meta" ]] && jq empty "$meta" >/dev/null 2>&1; then
  meta_version="$(jq -r '.version // empty' "$meta")"
fi
if [[ -n "$meta_version" ]]; then
  record "version" "pass" "metadata.json version $meta_version"
else
  record "version" "fail" "metadata.json has no version"
fi

# --- Gate 4: changelog --------------------------------------------------------
if [[ ! -f "$SKILL_DIR/CHANGELOG.md" ]]; then
  record "changelog" "fail" "CHANGELOG.md not found"
else
  cl_version="$(changelog_version "$SKILL_DIR/CHANGELOG.md")"
  if [[ -z "$cl_version" ]]; then
    record "changelog" "fail" "CHANGELOG.md has no versioned entry"
  elif [[ -n "$meta_version" && "$cl_version" != "$meta_version" ]]; then
    record "changelog" "fail" "top CHANGELOG version '$cl_version' != metadata version '$meta_version'"
  else
    record "changelog" "pass" "top entry $cl_version"
  fi
fi

# --- Verdict ------------------------------------------------------------------
failed=()
for i in "${!gates[@]}"; do [[ "${statuses[$i]}" == "fail" ]] && failed+=("${gates[$i]}"); done

if [[ "$JSON" == "1" ]]; then
  out="$(for i in "${!gates[@]}"; do
    printf '%s\t%s\t%s\n' "${gates[$i]}" "${statuses[$i]}" "${details[$i]}"
  done | jq -R -s --arg skill "$rel" '
    split("\n") | map(select(length>0) | split("\t") | {gate:.[0], status:.[1], detail:.[2]}) as $g
    | {skill:$skill, verdict:(if ($g | map(select(.status=="fail")) | length)==0 then "go" else "no-go" end),
       failing_gates: ($g | map(select(.status=="fail") | .gate)), gates:$g}')"
  printf '%s\n' "$out"
else
  echo "## Promotion preflight — $rel"
  for i in "${!gates[@]}"; do
    mark="ok"; [[ "${statuses[$i]}" == "fail" ]] && mark="FAIL"
    printf '  [%-4s] %-9s — %s\n' "$mark" "${gates[$i]}" "${details[$i]}"
  done
  if [[ ${#failed[@]} -eq 0 ]]; then
    echo "VERDICT: go"
  else
    echo "VERDICT: no-go — failing gate(s): ${failed[*]}"
  fi
fi

[[ ${#failed[@]} -eq 0 ]] || exit 1
exit 0
