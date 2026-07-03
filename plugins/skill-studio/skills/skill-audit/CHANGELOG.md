# Changelog

## 0.2.0 - 2026-07-03

### Fixed

- **`audit-skill.sh` now flags `python`/`python3`-prefixed bare bundled-script
  calls.** The `relative_bundled_script_calls` cache-safety check matched only
  `(bash|sh|node|./)`, so `python3 scripts/x.py` invocations slipped through and
  the auditor reported `0` while real cache-unsafe calls existed (surfaced while
  promoting `gh-post-code-review`, #103/#114). Extended the runtime alternation to
  `(bash|sh|node|python|python3|deno|bun|./)`.

### Added

- **First regression test for `audit-skill.sh`:** `tests/test_rel_script_calls.sh`
  pins the runtime coverage — bare `bash`/`sh`/`node`/`python`/`python3`/`./`
  script calls are flagged, while `${CLAUDE_SKILL_DIR}` paths and markdown doc
  links are not. (The prior `tests/` suite only covered `skill_hot_path_audit.py`.)

## 0.1.0 - 2026-07-02

### Added

- Initial `skill-audit` skill in the `skill-studio` plugin: the read-only audit
  surface of the skill-authoring toolkit. Two branches from a compact intent
  router:
  - **A. Single-skill compliance audit** — run both bundled scripts, apply the
    archetype / four-principles / instruction-craft judgment, and write a scored
    report via `references/report-format.md`.
  - **B. Portfolio / overlap audit** — dispatch the three read-only subagents
    (`skill-overlap-clusterer`, `skill-architecture-checker`,
    `skill-consolidation-advisor`) for installed-directory cleanup, or the deep
    repo-first-party inventory → cluster A/B/C → arbiter methodology.
- **Merged from two audit surfaces.** Carries forward both scripts from the
  `cursor-skill-studio` pack's `skill-studio-audit` skill —
  `scripts/skill_hot_path_audit.py` (advisory token-economy / hot-path metrics
  and duplication buckets, character-based) and its `tests/` snapshot suite
  (fixtures + `run_audit_snapshot.sh`, still passing from the new location) —
  plus the pack's audit references (`single-skill-audit.md`,
  `platform-audit-lenses.md`, `portfolio-audit-workflow.md`,
  `repo-skills-overlap-audit.md`) and the `portfolio-audit-report.md` template.
- **Absorbed the `repo-governance:skill-auditor` doctrine.** The genericized
  judgment doctrine is carried in verbatim — `references/principles.md` (the four
  structural principles), `references/archetypes.md` (the ten-archetype model),
  `references/authoring-for-claude.md` (instruction craft), and
  `references/report-format.md` (the scored report structure) — together with the
  mechanical checker `scripts/audit-skill.sh`. The two scripts are complementary:
  the Python auditor for prompt-visible surface cost and duplication, the bash
  checker for package/wiring correctness (name/description limits,
  metadata/CHANGELOG presence, orphan/dangling references, gotchas-section
  presence, cross-package cache-copy hazards).
- **Reframed for Claude-first, self-contained install.** `platform-audit-lenses.md`
  now leads with the Claude / Claude Code lens (Cursor-IDE lens dropped, a short
  generic-markdown lens kept); every former repo-file dependency
  (`docs/architecture.md`, the overlap-audit spec) is inlined into the bundled
  references so an installed plugin never reaches outside its own tree.
  Improvement / eval content stays out — that is the sibling `skill-enhance`.

### Source Contracts

- https://code.claude.com/docs/en/skills (skill authoring guidance)
- https://agentskills.io (Agent Skills standard)
