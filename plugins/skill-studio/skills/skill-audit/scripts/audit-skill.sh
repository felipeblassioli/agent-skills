#!/usr/bin/env bash
# audit-skill.sh — deterministic best-practice signals for marketplace skills.
#
# Usage:
#   audit-skill.sh <skill-dir>        audit one skill package
#   audit-skill.sh --all [repo-root]  sweep plugins/*/skills/* and skills/*
#                                     (repo-root defaults to the marketplace repo root)
#
# Emits a JSON object on stdout: { "audited": N, "skills": [ {...}, ... ] }.
# This reports MECHANICAL signals only. The judgment dimensions — archetype fit,
# single-responsibility, description quality — are for the model (see
# references/archetypes.md and references/principles.md).
set -uo pipefail

audit_one() {
  dir="${1%/}"
  skill_md="$dir/SKILL.md"
  meta="$dir/metadata.json"

  folder="$(basename "$dir")"
  case "$dir" in
    plugins/*/skills/*|*/plugins/*/skills/*) plugin="$(basename "$(dirname "$(dirname "$dir")")")" ;;
    *) plugin="(skills/ legacy)" ;;
  esac

  if [[ ! -f "$skill_md" ]]; then
    jq -n --arg p "$dir" --arg s "$folder" --arg pl "$plugin" \
      '{path:$p, skill:$s, plugin:$pl, error:"SKILL.md not found"}'
    return
  fi

  fm="$(awk '/^---$/{n++; next} n==1{print} n>=2{exit}' "$skill_md")"
  name="$(printf '%s\n' "$fm" | awk -F': *' '/^name:/{print $2; exit}' | tr -d '[:space:]')"
  desc="$(printf '%s\n' "$fm" | awk '
    /^description:/{ s=$0; sub(/^description:[[:space:]]*/,"",s); if(s!=">-"&&s!="|"&&s!=">"){d=s}; f=1; next }
    f && /^[[:space:]]+/{ t=$0; sub(/^[[:space:]]+/,"",t); d=(d=="")?t:d" "t; next }
    f{ exit }
    END{ print d }')"
  desc_chars=${#desc}
  lines="$(wc -l < "$skill_md" | tr -d '[:space:]')"
  legacy="$(printf '%s\n' "$fm" | grep -oE '^(version|last_reviewed|source_contracts|compatibility):' | sed 's/:$//' | paste -sd, -)"

  refs=0
  heavy='[]'
  if [[ -d "$dir/references" ]]; then
    refs="$(find "$dir/references" -type f -name '*.md' | wc -l | tr -d '[:space:]')"
    # A large reference (> 300 lines) is fine if it carries a table of contents
    # (context-efficiency principle). Flag only heavy refs that LACK a TOC, so
    # the signal is actionable rather than just "this file is big".
    heavy="$(find "$dir/references" -type f -name '*.md' -print0 \
      | while IFS= read -r -d '' f; do
          n="$(wc -l < "$f" | tr -d '[:space:]')"
          if [[ "$n" -gt 300 ]] && ! grep -qiE '^#{1,2}[[:space:]]+(contents|table of contents)' "$f"; then
            printf '%s\n' "$(basename "$f"):$n lines (no TOC)"
          fi
        done | jq -R . | jq -s 'map(select(. != ""))')"
  fi
  [[ -z "$heavy" ]] && heavy='[]'

  # Progressive-disclosure wiring (context-efficiency principle): Claude only
  # loads a reference if SKILL.md points to it, so a reference whose basename
  # never appears in SKILL.md is an ORPHAN — shipped but unreachable.
  orphan_refs='[]'
  if [[ -d "$dir/references" ]]; then
    orphan_refs="$(find "$dir/references" -type f -name '*.md' -print0 \
      | while IFS= read -r -d '' f; do
          b="$(basename "$f")"
          grep -qF "$b" "$skill_md" || printf '%s\n' "$b"
        done | jq -R . | jq -s 'map(select(. != ""))')"
  fi
  [[ -z "$orphan_refs" ]] && orphan_refs='[]'

  # DANGLING pointers: an in-skill relative .md link in SKILL.md whose target is
  # missing (a broken progressive-disclosure pointer). Cross-package ../.. links
  # are reported separately under cache_copy_hazards, so skip any ../, /, http link.
  dangling="$(grep -oE '\]\([^)#:]+\.md\)' "$skill_md" 2>/dev/null \
    | sed 's/^](//;s/)$//' \
    | while IFS= read -r rel; do
        case "$rel" in ../*|/*|http*) continue ;; esac
        [[ -f "$dir/$rel" ]] || printf '%s\n' "$rel"
      done | sort -u | jq -R . | jq -s 'map(select(. != ""))')"
  [[ -z "$dangling" ]] && dangling='[]'

  scripts_n=0
  nonexec='[]'
  rel_calls=0
  if [[ -d "$dir/scripts" ]]; then
    scripts_n="$(find "$dir/scripts" -type f | wc -l | tr -d '[:space:]')"
    nonexec="$(find "$dir/scripts" -type f -name '*.sh' -print0 \
      | while IFS= read -r -d '' f; do
          if [[ ! -x "$f" ]]; then basename "$f"; fi
        done | jq -R . | jq -s 'map(select(. != ""))')"
    # Run-invocations of a bundled script via a relative path break after the
    # install cache-copy. Match command forms (bash/sh/node/python/deno/bun/./ + scripts/...)
    # across common script extensions, keep whole lines so the CLAUDE_* filter
    # can see a correct ${CLAUDE_SKILL_DIR} prefix, and exclude those. Only
    # model-facing files count: SKILL.md and references/ — human docs
    # (README.md, CHANGELOG.md) carry example commands, not runtime
    # instructions. Markdown link hrefs (](scripts/...)) are doc navigation and
    # are not matched.
    rel_calls="$(grep -rhE '(bash |sh |node |python3? |deno |bun |\./)scripts/[A-Za-z0-9_.-]+\.(sh|py|mjs|cjs|js|mts|ts)' "$dir" --include='*.md' --exclude=README.md --exclude=CHANGELOG.md 2>/dev/null \
      | grep -vE 'CLAUDE_(SKILL_DIR|PLUGIN_ROOT)' | grep -c .)"
  fi
  [[ -z "$nonexec" ]] && nonexec='[]'
  [[ -z "$rel_calls" ]] && rel_calls=0

  xlinks="$(grep -rhoE '\]\(\.\./\.\.[^)]*\)' "$dir" --include='*.md' 2>/dev/null \
    | sed 's/^](//;s/)$//' | sort -u | jq -R . | jq -s 'map(select(. != ""))')"
  [[ -z "$xlinks" ]] && xlinks='[]'

  has_meta=false; meta_ok=false; meta_version=""
  if [[ -f "$meta" ]]; then
    has_meta=true
    if jq empty "$meta" >/dev/null 2>&1; then
      meta_ok=true
      meta_version="$(jq -r '.version // ""' "$meta")"
    fi
  fi
  has_changelog=false; [[ -f "$dir/CHANGELOG.md" ]] && has_changelog=true
  has_readme=false; [[ -f "$dir/README.md" ]] && has_readme=true

  # A skill's highest-signal content is usually a gotchas section (failure points
  # the model would otherwise trip on). Presence-only neutral signal across
  # SKILL.md + references; QUALITY and whether absence matters (by archetype) are
  # the model's judgment.
  gpat='^#{1,4}[[:space:]]+(gotchas?|pitfalls?|caveats?|footguns?|common (mistakes|errors|pitfalls)|known issues|surprises|things that (will )?bite)'
  gotchas=false
  if grep -qiE "$gpat" "$skill_md" 2>/dev/null \
     || { [[ -d "$dir/references" ]] && grep -rqiE "$gpat" "$dir/references" --include='*.md' 2>/dev/null; }; then
    gotchas=true
  fi

  # Evidence: an evals/evals.json test suite and a committed baseline snapshot
  # (see docs/marketplace-governance.md "Evals & evidence"). Raw runs live in
  # .work/ and are not part of the package.
  has_evals=false; eval_count=0; has_baseline=false
  if [[ -f "$dir/evals/evals.json" ]]; then
    has_evals=true
    if jq empty "$dir/evals/evals.json" >/dev/null 2>&1; then
      eval_count="$(jq '(.evals // []) | length' "$dir/evals/evals.json" 2>/dev/null || echo 0)"
    fi
  fi
  [[ -z "$eval_count" ]] && eval_count=0
  if [[ -d "$dir/evals/baselines" ]] && [[ -n "$(find "$dir/evals/baselines" -type f -name '*.md' 2>/dev/null)" ]]; then
    has_baseline=true
  fi

  jq -n \
    --arg path "$dir" --arg skill "$folder" --arg plugin "$plugin" \
    --arg name "$name" --argjson desc_chars "$desc_chars" \
    --argjson lines "$lines" --arg legacy "${legacy:-}" \
    --argjson refs "$refs" --argjson heavy "$heavy" \
    --argjson orphan_refs "$orphan_refs" --argjson dangling "$dangling" \
    --argjson scripts_n "$scripts_n" --argjson nonexec "$nonexec" \
    --argjson rel_calls "$rel_calls" --argjson xlinks "$xlinks" \
    --argjson has_meta "$has_meta" --argjson meta_ok "$meta_ok" --arg meta_version "$meta_version" \
    --argjson has_changelog "$has_changelog" --argjson has_readme "$has_readme" \
    --argjson gotchas "$gotchas" \
    --argjson has_evals "$has_evals" --argjson eval_count "$eval_count" --argjson has_baseline "$has_baseline" \
    '{
      path: $path, skill: $skill, plugin: $plugin,
      frontmatter: {
        name: $name,
        name_matches_folder: ($name == $skill),
        description_chars: $desc_chars,
        legacy_fields: (if $legacy == "" then null else $legacy end)
      },
      context_efficiency: {
        skill_md_lines: $lines,
        references: $refs,
        heavy_references_without_toc: $heavy,
        orphan_references: $orphan_refs,
        dangling_skill_links: $dangling,
        scripts: $scripts_n,
        non_executable_scripts: $nonexec,
        relative_bundled_script_calls: $rel_calls
      },
      cache_copy_hazards: { cross_package_relative_links: $xlinks },
      content: { gotchas_section: $gotchas },
      package: {
        metadata_json: $has_meta, metadata_valid: $meta_ok, metadata_version: $meta_version,
        changelog: $has_changelog, readme: $has_readme
      },
      evals: {
        suite: $has_evals, eval_count: $eval_count, baseline_snapshot: $has_baseline
      }
    }'
}

targets=()
if [[ "${1:-}" == "--all" ]]; then
  root="${2:-$(cd "$(dirname "$0")/../../../../.." && pwd)}"
  while IFS= read -r d; do [[ -n "$d" ]] && targets+=("$d"); done < <(
    { find "$root/plugins" -type f -name SKILL.md 2>/dev/null
      find "$root/skills" -type f -name SKILL.md 2>/dev/null; } | sed 's#/SKILL.md$##' | sort -u
  )
else
  targets+=("${1:?Usage: audit-skill.sh <skill-dir> | --all [repo-root]}")
fi

for d in "${targets[@]}"; do audit_one "$d"; done \
  | jq -s --argjson n "${#targets[@]}" '{audited: $n, skills: .}'
