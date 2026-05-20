# Changelog

All notable changes to the `skill-consistency-auditor` pack will be documented in this file. For evidence of release testing, see `VERIFICATION.md`.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-05-19

### Deprecated
- Pack and bundled skill `skill-consistency-auditor-workflow` are deprecated
  and replaced by `skill-studio-audit` (Branch C — Installed portfolio audit)
  inside the `cursor-skill-studio` Cursor pack per
  [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

### Changed
- `pack.json` description prefixed with `[DEPRECATED]` and bundled-skill
  notes updated to point at the replacement. Pack still installs through
  this release for compatibility.
- `README.md` carries a deprecation banner directing users to
  `/skill-studio-audit`.
- `skills/skill-consistency-auditor-workflow/SKILL.md` is now a thin redirect
  stub with `disable-model-invocation: true`.
- `cursor-pack-registry.json` description prefixed with `[DEPRECATED]` and
  tagged `deprecated`.

### Notes
- The three helper subagents (`skill-overlap-clusterer`,
  `skill-architecture-checker`, `skill-consolidation-advisor`) remain
  functional inside this pack and are duplicated in `cursor-skill-studio`.
- The previously broken `assets/report-template.md` install path is now
  resolved inside `skill-studio-audit/assets/templates/portfolio-audit-report.md`.
- Scheduled to move to `packs/.archive/skill-consistency-auditor/` in the
  stub-removal PR per ADR-0005.

## [0.1.0] - 2026-05-19

### Added
- Initial release of the `skill-consistency-auditor` pack.
- Included `skill-consistency-auditor-workflow` bundled skill for explicit invocation.
- Added helper subagents for clustering, architecture checking, and consolidation advice.
