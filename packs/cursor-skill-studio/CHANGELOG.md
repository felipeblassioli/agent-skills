# Changelog

All notable changes to `cursor-skill-creator` will be documented in this file.

The format is based on Keep a Changelog and this project follows SemVer.

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
