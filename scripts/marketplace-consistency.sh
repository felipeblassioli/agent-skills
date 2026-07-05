#!/usr/bin/env bash
# marketplace-consistency.sh — deterministic cross-plugin / cross-registry drift
# check for the Claude-first marketplace. It answers the questions the per-skill
# validator (scripts/validate-skill.sh) cannot, because they span artifacts:
#
#   1. marketplace <-> plugin: every .claude-plugin/marketplace.json entry has a
#      matching plugins/<name>/.claude-plugin/plugin.json (name + source agree),
#      and every plugin.json on disk is listed in the marketplace. (bidirectional)
#   2. version alignment: for each real skill, metadata.json.version agrees with
#      the top CHANGELOG.md entry and, when the skill is registered, with its
#      skill-registry.json line.
#   3. overlap: no two skills across the tree share the same name (a promoted
#      skill silently duplicating an existing artifact).
#
# Read-only. Exits non-zero on drift so CI and the /promote-check gate (#121) can
# consume it. Harness-agnostic: no Claude dependency — the
# marketplace-consistency-reviewer subagent is just an ergonomic wrapper.
#
# Usage:
#   scripts/marketplace-consistency.sh [--json] [--plugin NAME] [--root DIR]
#
#   --json        emit findings as JSON ({clean, findings:[{code,location,detail}]})
#   --plugin NAME restrict marketplace/version checks to one plugin
#   --root DIR    repo root to check (default: git toplevel, else this script's ..)
#
# Exit: 0 = clean, 1 = drift found, 2 = usage/environment error.
set -euo pipefail

JSON=0
PLUGIN=""
ROOT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=1; shift ;;
    --plugin) PLUGIN="${2:-}"; shift 2 ;;
    --plugin=*) PLUGIN="${1#*=}"; shift ;;
    --root) ROOT="${2:-}"; shift 2 ;;
    --root=*) ROOT="${1#*=}"; shift ;;
    -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
    *) echo "marketplace-consistency: unknown argument '$1'" >&2; exit 2 ;;
  esac
done

command -v jq >/dev/null 2>&1 || { echo "marketplace-consistency: jq is required" >&2; exit 2; }

# --- Resolve repo root (cwd-independent) --------------------------------------
if [[ -z "$ROOT" ]]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null)" || ROOT=""
  [[ -n "$ROOT" ]] || ROOT="$(cd "$script_dir/.." && pwd)"
fi
[[ -d "$ROOT" ]] || { echo "marketplace-consistency: root '$ROOT' is not a directory" >&2; exit 2; }

MARKETPLACE="$ROOT/.claude-plugin/marketplace.json"
REGISTRY="$ROOT/skill-registry.json"

# findings accumulator: each entry is "code<TAB>location<TAB>detail"
findings=()
add() { findings+=("$1"$'\t'"$2"$'\t'"$3"); }

# Top CHANGELOG version: first "## ..." heading carrying a semver, skipping any
# "Unreleased" heading. Handles both `## 1.2.3 - date` and `## [1.2.3] - date`.
changelog_version() {
  grep -E '^##[[:space:]]' "$1" 2>/dev/null \
    | grep -viE 'unreleased' \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
    | head -1
}

# --- Check 1: marketplace <-> plugin.json (bidirectional) ---------------------
if [[ -f "$MARKETPLACE" ]]; then
  jq empty "$MARKETPLACE" 2>/dev/null || add "marketplace-parse" "$MARKETPLACE" "not valid JSON"

  # marketplace -> disk
  while IFS=$'\t' read -r mp_name mp_source; do
    [[ -n "$mp_name" ]] || continue
    [[ -n "$PLUGIN" && "$mp_name" != "$PLUGIN" ]] && continue
    src_dir="$ROOT/${mp_source#./}"
    pj="$src_dir/.claude-plugin/plugin.json"
    if [[ ! -d "$src_dir" ]]; then
      add "marketplace-source-missing" ".claude-plugin/marketplace.json → $mp_name" "source '$mp_source' does not exist"
    elif [[ ! -f "$pj" ]]; then
      add "plugin-manifest-missing" "$mp_source" "listed in marketplace but has no .claude-plugin/plugin.json"
    else
      pj_name="$(jq -r '.name // empty' "$pj")"
      [[ "$pj_name" == "$mp_name" ]] || \
        add "marketplace-name-mismatch" "${pj#"$ROOT"/}" "plugin.json name '$pj_name' != marketplace name '$mp_name'"
    fi
  done < <(jq -r '.plugins[]? | [.name, (.source // "")] | @tsv' "$MARKETPLACE")

  # disk -> marketplace
  while IFS= read -r pj; do
    [[ -n "$pj" ]] || continue
    pj_name="$(jq -r '.name // empty' "$pj")"
    [[ -n "$PLUGIN" && "$pj_name" != "$PLUGIN" ]] && continue
    listed="$(jq -r --arg n "$pj_name" '[.plugins[]?.name] | index($n) // empty' "$MARKETPLACE")"
    [[ -n "$listed" ]] || \
      add "plugin-not-in-marketplace" "${pj#"$ROOT"/}" "plugin '$pj_name' has a manifest but is not listed in marketplace.json"
  done < <(find "$ROOT/plugins" -maxdepth 3 -name plugin.json -path '*/.claude-plugin/*' 2>/dev/null | sort)
else
  add "marketplace-missing" ".claude-plugin/marketplace.json" "marketplace manifest not found"
fi

# --- Check 2 & 3: per-skill version alignment + name overlap ------------------
declare -a search_roots=()
if [[ -n "$PLUGIN" ]]; then
  search_roots=("$ROOT/plugins/$PLUGIN")
else
  search_roots=("$ROOT/plugins" "$ROOT/skills")
fi

seen_names=""   # newline-delimited "name<TAB>path" for overlap detection
while IFS= read -r skill_md; do
  [[ -n "$skill_md" ]] || continue
  case "$skill_md" in */fixtures/*) continue ;; esac
  dir="$(dirname "$skill_md")"
  name="$(basename "$dir")"
  rel="${dir#"$ROOT"/}"

  # overlap: same skill name seen at a different path
  prev_path="$(printf '%s\n' "$seen_names" | awk -F'\t' -v n="$name" '$1==n {print $2; exit}')"
  if [[ -n "$prev_path" ]]; then
    add "skill-name-overlap" "$rel" "duplicate skill name '$name' also at '$prev_path'"
  fi
  seen_names+="$name"$'\t'"$rel"$'\n'

  # version alignment (only when a metadata.json exists at the skill root)
  meta="$dir/metadata.json"
  [[ -f "$meta" ]] || continue
  jq empty "$meta" 2>/dev/null || { add "metadata-parse" "$rel/metadata.json" "not valid JSON"; continue; }
  mv="$(jq -r '.version // empty' "$meta")"
  if [[ -z "$mv" ]]; then
    add "metadata-version-missing" "$rel/metadata.json" "no version field"
    continue
  fi

  if [[ -f "$dir/CHANGELOG.md" ]]; then
    cv="$(changelog_version "$dir/CHANGELOG.md")"
    if [[ -n "$cv" && "$cv" != "$mv" ]]; then
      add "changelog-version-drift" "$rel/CHANGELOG.md" "top CHANGELOG version '$cv' != metadata.json version '$mv'"
    fi
  fi

  if [[ -f "$REGISTRY" ]]; then
    rv="$(jq -r --arg n "$name" '.skills[$n].version // empty' "$REGISTRY" 2>/dev/null || true)"
    if [[ -n "$rv" && "$rv" != "$mv" ]]; then
      add "registry-version-drift" "$rel/metadata.json" "skill-registry.json version '$rv' != metadata.json version '$mv'"
    fi
  fi
done < <(find "${search_roots[@]}" -name SKILL.md 2>/dev/null | sort)

# --- Report -------------------------------------------------------------------
if [[ "$JSON" == "1" ]]; then
  printf '%s\n' "${findings[@]:-}" | jq -R -s '
    split("\n") | map(select(length>0) | split("\t") | {code:.[0], location:.[1], detail:.[2]})
    | {clean: (length==0), count: length, findings: .}'
else
  if [[ ${#findings[@]} -eq 0 ]]; then
    echo "marketplace-consistency: clean${PLUGIN:+ (plugin: $PLUGIN)}"
  else
    echo "marketplace-consistency: ${#findings[@]} drift finding(s):" >&2
    for f in "${findings[@]}"; do
      IFS=$'\t' read -r code loc detail <<< "$f"
      printf '  - [%s] %s — %s\n' "$code" "$loc" "$detail" >&2
    done
  fi
fi

[[ ${#findings[@]} -eq 0 ]] || exit 1
exit 0
