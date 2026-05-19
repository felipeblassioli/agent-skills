# Changelog

All notable changes to `cursor-skill-studio` (formerly `cursor-skill-creator`)
will be documented in this file.

The format is based on Keep a Changelog and this project follows SemVer.

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
