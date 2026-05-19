# Roadmap

The pack is mid-migration per
[ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).
Each milestone below maps to one PR.

## In progress (0.3.0 — this release)

- Rename pack from `cursor-skill-creator` to `cursor-skill-studio`. **Done.**
- Add skeleton bundled-skill directories `skill-studio-write/`,
  `skill-studio-maintain/`, `skill-studio-audit/`. **Done.**
- Merge auditor subagents into the shared pool. **Done.**

## Next

- **0.4.0 (PR 2):** lift content from `skills/writing-cursor-skills`,
  `skills/create-skill-from-refs`, `skills/create-cursor-pack-from-refs`,
  `skills/external-skill-intake`, and `skills/claude-plugin-to-cursor-pack`
  into `skill-studio-write`. Stub the originals.
- **0.5.0 (PR 3):** lift content from `skills/audit-skill-for-cursor`,
  `skills/improving-agent-artifacts`, and
  `packs/skill-consistency-auditor/skills/skill-consistency-auditor-workflow`
  into `skill-studio-audit`. Stub the originals; mark the auditor pack
  deprecated.
- **0.6.0 (PR 4):** lift content from `skills/personal-skill-maintainer` and
  `skills/personal-pack-maintainer` into `skill-studio-maintain`. Stub the
  originals.
- **1.0.0 (PR 5):** finalize routing, update `docs/architecture.md`,
  `docs/agent-skills.md`, and root `AGENTS.md`. Full VERIFICATION matrix.
- **Post-1.0.0 (PR 6, one release later):** delete deprecated root skill
  directories and registry entries; move `packs/skill-consistency-auditor/`
  to `packs/.archive/`.

## Pre-existing follow-ups (kept from 0.2.0)

- Add a Cursor-native trigger-rate evaluation path if automatic skill
  activation needs to be measured in addition to output quality.
- Adapt the remaining Claude-only description-optimization flow into a
  Cursor-friendly orchestration path.
- Add more bundled templates for pack guides, rule stubs, and eval assertions.
- Add deeper smoke fixtures for multi-run skill comparisons with generated
  `comparison.json`, `skill_inventory.json`, and analyzer output.
- Validate the pack in a second repository after local verification to
  confirm installed-path assumptions hold outside this repo.
