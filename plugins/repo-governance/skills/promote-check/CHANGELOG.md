# Changelog

All notable changes to this skill are documented in this file.

## 0.1.0 - 2026-07-06

### Added

- Initial `promote-check` skill: a **user-invoked** (`disable-model-invocation`)
  promotion preflight gate for the marketplace. Runs the bundled
  `scripts/promote-check.sh`, which chains four gates in order — `audit`
  (deterministic `skill-studio:skill-audit` findings via `audit-skill.sh`),
  `alignment` (`scripts/marketplace-consistency.sh`), `version`, and `changelog`
  — and emits a **go / no-go** verdict citing every failing gate. Exit `0` = go,
  `1` = no-go, `2` = usage/environment error.
- Audit-first: blocks promotion on any unresolved mechanical audit finding, not
  just a binary pass. Read-only and harness-agnostic (the driver has no Claude
  dependency and is reusable in CI).

### Notes

- The `alignment` gate reuses `scripts/marketplace-consistency.sh` (added in the
  `marketplace-consistency-reviewer` change, issue #120); that must be present in
  the repo for the gate to run.

### Source Contracts

- `plugins/skill-studio/skills/skill-audit/scripts/audit-skill.sh` — 2026-07-06
- `scripts/validate-skill.sh` — 2026-07-06
- `docs/marketplace-governance.md` — 2026-07-06
- `docs/ROADMAP.md` — 2026-07-06
- `plugins/repo-governance/skills/skill-maintainer/references/marketplace-maintenance.md` — 2026-07-06
