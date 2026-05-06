# Changelog

All notable changes to this skill will be documented in this file.

## [0.2.0] - 2026-05-06

### Changed

- Rebased the skill on the accepted four-layer testing strategy: colocated unit tests, contract/golden tests, in-process integration tests, and Playwright E2E flows.
- Replaced Jest/Testcontainers-first guidance in the hot path with Vitest/Playwright routing and in-memory integration defaults.
- Normalized maintainer metadata and README structure to the governed skill maintenance model.

### Added

- Added explicit contract/golden-file guidance as a first-class testing layer in the skill package.

### Validation

- Reviewed `SKILL.md`, `metadata.json`, `README.md`, and core references against `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`.
- Reviewed the tier model and canonical tools against `tmp/oncall-roster-ag/docs/adr/ADR-001-testing-strategy.md`.

### Source Contracts

- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md` reviewed 2026-05-06
- `tmp/oncall-roster-ag/docs/adr/ADR-001-testing-strategy.md` reviewed 2026-05-06
