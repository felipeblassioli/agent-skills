# Changelog

## 2.0.0 - 2026-06-14

### Changed

- **BREAKING:** Repackaged as the `repo-governance` plugin and renamed the skill
  to `skill-maintainer` (`/repo-governance:skill-maintainer`). Migrated from the
  Cursor-era `skills/skill-maintainer/` to `plugins/repo-governance/`.
- Reframed all guidance to the Claude-first marketplace model: plugins,
  `.claude-plugin/marketplace.json`, `plugin.json`, the `name` + `description`
  frontmatter contract (governance moves to `metadata.json`), tiers (official vs
  sandbox), and sandbox → traction → promote.
- `SKILL.md` frontmatter reduced to `name` + `description`.
- Validation guidance now leads with `claude plugin validate --strict`.

### Added

- `references/governance.md` — ported from `.cursor/rules/skill-governance.mdc`
  (which is removed), updated to the Claude-first package shape and
  composing-by-name.
- Routing to `docs/marketplace-governance.md`.

### Removed

- `references/registry-maintenance.md`, replaced by
  `references/marketplace-maintenance.md`; `skill-registry.json` is now documented
  as legacy / being retired.

### Source Contracts

- `docs/marketplace-governance.md`
- `docs/ADR/ADR-0006-adopt-claude-first-plugin-marketplace.md`
- `docs/versioning.md`
- `docs/releasing.md`
- `docs/review-checklist.md`
- `scripts/validate-skill.sh`
- `.claude-plugin/marketplace.json`

## 1.1.0 - 2026-05-04

### Added

- Added `docs/releasing.md` as the canonical release procedure: tag taxonomy
  (`<skill-name>/v<version>`), automated release workflow path, manual
  fallback via `scripts/release-skill.sh`, release-notes authoring rules,
  and "When Not To Cut A Release".
- Added `scripts/extract-changelog.sh` to extract a single version's section
  from a skill `CHANGELOG.md` for use as GitHub Release notes.
- Added `scripts/release-skill.sh` to validate, extract notes, and publish a
  GitHub Release for one skill, idempotent against existing tags.
- Added `.github/workflows/release-skill.yaml` to detect bumped
  `metadata.json` versions on `main` and auto-publish each affected skill.
- Added a Release step (step 7) to `references/workflow.md` and a Release
  Readiness section to `references/quality-gate.md` and
  `docs/review-checklist.md`.
- Added a release routing entry, an Apply When trigger, and a Procedure step
  to `SKILL.md` covering release publication.

### Changed

- Updated `docs/versioning.md` with the tag taxonomy and a "Release Rule"
  pointing maintainers to `docs/releasing.md`.
- Updated `docs/README.md` to link the new `docs/releasing.md` entry.
- Refreshed `last_reviewed`, metadata `date`, and `source_contracts[].reviewed_at`
  for the governance files touched in this release.

### Source Contracts

- `README.md`
- `docs/README.md`
- `docs/versioning.md`
- `docs/releasing.md`
- `docs/review-checklist.md`
- `scripts/validate-skill.sh`
- `scripts/release-skill.sh`
- `scripts/extract-changelog.sh`
- `.github/workflows/release-skill.yaml`
- `skill-registry.json`

## 1.0.0 - 2026-04-30

### Added

- Added `skill-maintainer` for creating, updating, versioning, validating,
  and registering this marketplace's skill packages.
- Added human prompt examples for create, update, version, registry maintenance,
  and quality review workflows.
- Added references for package workflow, registry maintenance, and quality gates.

### Source Contracts

- `README.md`
- `docs/README.md`
- `docs/source-contracts.md`
- `docs/versioning.md`
- `docs/review-checklist.md`
- `.cursor/rules/skill-governance.mdc`
- `scripts/validate-skill.sh`
- `skill-registry.json`
