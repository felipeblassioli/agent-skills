# Changelog

All notable changes to this skill will be documented in this file.

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
