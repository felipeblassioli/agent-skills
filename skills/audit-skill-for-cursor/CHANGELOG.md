# Changelog

All notable changes to this skill will be documented in this file.

## [1.2.0] - 2026-05-19

### Deprecated
- Skill is deprecated and replaced by `skill-studio-audit` (Branch A —
  Single-skill compliance audit) inside the `cursor-skill-studio` Cursor
  pack per
  [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

### Changed
- `SKILL.md` is now a thin redirect stub with
  `disable-model-invocation: true`. Reference files under `references/` remain
  in place for one release window so existing links keep resolving. Scheduled
  for full removal in the stub-removal PR per ADR-0005.
- `metadata.json` carries `deprecated: true` and a `replacedBy` pointer.

## [1.1.0] - 2026-05-05

### Added
- Added Context Litmus Test to `SKILL.md` to rigorously evaluate skills.
- Added cheap-agent-first delegation requirements for mechanical tasks.
- Included strict output schema constraints to prevent chatty agent outputs.

### Changed
- Expanded `description` and `Overview` to explicitly highlight token discipline, the One-Hop Rule, and cheap-agent-first delegation.

## [1.0.1] - 2026-05-05

### Changed
- Bumped version to `1.0.1`.

## [1.0.0] - 2026-05-05

### Changed
- Refactored `SKILL.md` into a lean, context-efficient index (ADR-0002 compliant).
- Moved heavy audit and improvement logic to `references/audit-procedure.md`.

### Added
- Added `metadata.json` for proper skill governance.
- Added explicit best practice references: `anthropic-best-practices.md`, `cursor-best-practices.md`, `codex-best-practices.md`.
- Added this `CHANGELOG.md` and `README.md` to adhere to ADR-0002 governance model.

### Validation
- `bash scripts/skill-sync.sh --skill=audit-skill-for-cursor --dry-run`
