# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
as recorded in `metadata.json` (or `assets/metadata.json` / registry) for this skill.

## 1.1.0 - 2026-07-03

### Changed

- **Graduated into the `code-quality` plugin** as `code-quality:typescript-quality`
  (moved from the Cursor-era `skill-registry.json`). Passed the
  `skill-studio:skill-audit` promotion gate. See `docs/ADR/ADR-0008` and
  `docs/ROADMAP.md` (Phase 1, #103).
- Removed the legacy `compatibility:` frontmatter field — the Claude skill contract
  is `name` + `description` only.

### Added

- **Gotchas section** in `SKILL.md` — severity calibration (MEDIUM not blocker),
  validate-at-the-boundary, the `any` escape hatches, deep/error-object PII redaction,
  and OTel context propagation.
- **Evaluation suite** (`evals/evals.json`) — routing/classification fixtures mapping
  planted TypeScript quality issues to the correct rule, plus a non-TypeScript control.

## [1.0.0] - 2026-03-20

### Added

- Added `CHANGELOG.md`. Earlier releases are summarized from git history and `metadata.json` only.
