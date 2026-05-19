# Changelog

All notable changes to `cursor-skill-studio` (formerly `cursor-skill-creator`)
will be documented in this file.

The format is based on Keep a Changelog and this project follows SemVer.

## [0.4.0] - 2026-05-19

### Added

- New bundled skill `skill-studio-write` consolidates the five write-side root
  skills into one explicit-only authoring surface (`disable-model-invocation:
  true`) with six intent branches:
  - Branch A — Greenfield skill (was `skills/writing-cursor-skills`)
  - Branch B — Skill from reference material (was `skills/create-skill-from-refs`)
  - Branch C — Pack from reference material (was `skills/create-cursor-pack-from-refs`)
  - Branch D — External skill intake (was `skills/external-skill-intake`)
  - Branch E — Claude-plugin adaptation (was `skills/claude-plugin-to-cursor-pack`)
  - Branch F — Eval / comparison loop (lifted from `cursor-skill-creator-workflow`)
- 13 merged references (greenfield discovery, surface selection, Cursor skill
  standard, skill archetypes, skill quality checklist, material intake, pack
  standard, pack archetypes, pack quality checklist, source decomposition,
  candidate review, import paths, eval loop) and 20+ asset templates including
  archetype scaffolds and the pack template family.
- Pack-bundled scripts: `validate-skill.sh`, `validate-pack.sh` (rewritten to
  locate the repo root via `git rev-parse` or `AGENT_SKILLS_REPO`),
  `inspect-candidate-skill.sh`, `bootstrap_skill_comparison.py`,
  `aggregate_benchmark.py`, and the eval review UI under `eval-viewer/`.
- Pack manifest gains a second bundled-skill artifact entry
  (`bundled-skill-studio-write`) targeting both `project-cursor` and
  `user-cursor` in `lite` and `strict` profiles.
- `docs/specs/pack-recommendation-metadata.md` (relocated from
  `skills/create-cursor-pack-from-refs/references/recommendation-metadata.md`)
  so the future advisory-MCP schema grows as a durable spec rather than a
  hot-path skill reference.

### Deprecated

- `skills/writing-cursor-skills`, `skills/create-skill-from-refs`,
  `skills/create-cursor-pack-from-refs`, `skills/external-skill-intake`, and
  `skills/claude-plugin-to-cursor-pack` are now stub-and-redirect skills.
  `SKILL.md` bodies were replaced with a thin redirect to
  `/skill-studio-write`; each skill carries `disable-model-invocation: true`
  (closing the auto-invocation collision that intake and Claude-plugin skills
  previously had). Reference files, asset templates, and scripts remain in
  place for one release window so existing links keep resolving; full removal
  is scheduled for the stub-removal PR per ADR-0005.
- The previous bundled `cursor-skill-creator-workflow` skill is marked
  deprecated in `pack.json` notes. It still installs in 0.4.0 to avoid
  breaking existing installs; removal target is 0.5.0.
- `skill-registry.json` entries for the five stubs gained a `deprecated` tag
  and a `[DEPRECATED — replaced by ...]` description prefix; versions were
  bumped (writing-cursor-skills `1.1.0`→`1.2.0`; the other four
  `1.0.x`→`1.1.0`).

### Changed

- `cursor-pack-registry.json` `cursor-skill-studio` entry bumped to `0.4.0`
  and description updated to reflect the new bundled skill.
- `cursor-skill-creator-workflow` `pack.json` notes rewritten to flag the
  deprecation explicitly.

### Verification

- See [VERIFICATION.md](VERIFICATION.md) for the 0.4.0 validation matrix.

## [0.3.0] - 2026-05-19

### Changed

- **Pack renamed** from `cursor-skill-creator` to `cursor-skill-studio` to
  reflect its new scope: the full skill lifecycle (write, maintain, audit).
  Source tree moved from `packs/cursor-skill-creator/` to
  `packs/cursor-skill-studio/`. Registry key in `cursor-pack-registry.json`
  renamed accordingly. Per ADR-0005.
- Routing rule renamed from `10-skill-creator-routing.mdc` to
  `10-skill-studio-routing.mdc`.

### Added

- Skeleton bundled-skill directories `skills/skill-studio-write/`,
  `skills/skill-studio-maintain/`, and `skills/skill-studio-audit/`.
  Content is lifted from the deprecated root skills in PRs 2-4 of the
  ADR-0005 migration.
- Auditor subagents merged in from `packs/skill-consistency-auditor/`:
  `skill-overlap-clusterer`, `skill-architecture-checker`,
  `skill-consolidation-advisor`. The auditor pack will be archived in PR 6
  per ADR-0005.

### Notes

- The existing `cursor-skill-creator-workflow` bundled skill keeps working
  during the migration; it is replaced by `skill-studio-write` in PR 2.
- Users who installed `cursor-skill-creator@0.2.0` need to re-install under
  the new pack name; no functional regressions in this release.

### Verification

- See [VERIFICATION.md](VERIFICATION.md) for the 0.3.0 validation matrix.

## [0.2.0] - 2026-05-19

### Added

- First-class skill-vs-skill comparison workflow in the bundled installed skill.
- Source-level structural auditor subagent for comparing skill package shape,
  trigger quality, hot-path size, resources, safety, and repository fit.
- Deterministic `bootstrap_skill_comparison.py` workspace setup script.
- Skill comparison guide and JSON schema references for comparison manifests,
  blind comparison results, structural inventories, and final analysis output.

### Changed

- Expanded grader, comparator, analyzer, strict rules, README, and evaluation
  guide to separate behavioral evidence from source-maintainability evidence.

### Verification

- See [VERIFICATION.md](VERIFICATION.md) for validation commands, outcomes, and
  residual risks.

## [0.1.0] - 2026-03-20

### Added

- Initial `cursor-skill-creator` pack scaffold.
- Bundled `cursor-skill-creator-workflow` installed skill.
- Helper subagents for bootstrap, grading, analysis, and blind comparison.
- Strict project rules for authoring workflow discipline.
- Evaluation and review toolkit assets bundled with the installed skill.

### Verification

- See [VERIFICATION.md](VERIFICATION.md) for validator output and residual risks.
