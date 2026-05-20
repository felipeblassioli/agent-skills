# Roadmap

The pack is mid-migration per
[ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).
Each milestone below maps to one PR.

## In progress (0.5.0 — this release)

- Lift content from `skills/audit-skill-for-cursor`,
  `skills/improving-agent-artifacts`, and
  `packs/skill-consistency-auditor/skills/skill-consistency-auditor-workflow`
  into `skill-studio-audit` (four branches: A/B/C/D). **Done.**
- Stub the two source root skills and the bundled auditor workflow
  (`disable-model-invocation: true`, redirect body, bumped registry/manifest
  versions with `[DEPRECATED]` description). **Done.**
- Mark `packs/skill-consistency-auditor/` deprecated in `pack.json`,
  `README.md`, `CHANGELOG.md`, and `cursor-pack-registry.json`. Pack still
  installs through this release. **Done.**
- Fix the broken `assets/report-template.md` install path by relocating the
  template under `skill-studio-audit/assets/templates/portfolio-audit-report.md`
  and updating `skill-consolidation-advisor`. **Done.**

## Shipped (0.4.0)

- Lifted the five write-side root skills into `skill-studio-write` and
  stubbed the originals.
- Relocated `recommendation-metadata.md` to
  `docs/specs/pack-recommendation-metadata.md`.
- Marked `cursor-skill-creator-workflow` deprecated in `pack.json` notes.

## Shipped (0.3.0)

- Renamed pack from `cursor-skill-creator` to `cursor-skill-studio`.
- Added skeleton bundled-skill directories for `skill-studio-write/`,
  `skill-studio-maintain/`, and `skill-studio-audit/`.
- Merged auditor subagents (`skill-overlap-clusterer`,
  `skill-architecture-checker`, `skill-consolidation-advisor`) into the
  shared pool.

## Next

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
