# Changelog

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
