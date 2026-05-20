# Roadmap

The pack is mid-migration per
[ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).
Each milestone below maps to one PR.

## In progress (0.6.0 — this release)

- Lift content from `skills/personal-skill-maintainer` and
  `skills/personal-pack-maintainer` into `skill-studio-maintain` (six
  branches: A root skill release, B pack release, C bundled-skill artifact,
  D promotion/demotion, E maturity & backlog, F install verification).
  **Done.**
- Stub the two source root skills (`disable-model-invocation: true`,
  redirect body, version bumped to `1.2.0` with `[DEPRECATED]` description
  and `deprecated` tag). **Done.**
- Merge the duplicate `bundled-skills.md` reference (it existed in both
  source skills) into a single bundled-skill reference. **Done.**
- Split the bundled-skill maintenance workflow for repo scripts/tools into
  its own reference (`script-tool-maintenance.md`) so future PRs can drop
  the source skills cleanly. **Done.**

## Shipped (0.5.0)

- Lifted `audit-skill-for-cursor`, `improving-agent-artifacts`, and the
  `skill-consistency-auditor-workflow` bundled skill into
  `skill-studio-audit`; stubbed the originals and marked the auditor pack
  deprecated.
- Fixed the broken `assets/report-template.md` install path by relocating
  it under `skill-studio-audit/assets/templates/portfolio-audit-report.md`.

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

- **1.0.0 (PR 5):** finalize routing, update `docs/architecture.md`,
  `docs/agent-skills.md`, root `AGENTS.md`, and any incoming references
  from `docs/specs/` and `docs/ADR/`. Full VERIFICATION matrix across the
  three studio bundled skills.
- **Post-1.0.0 (PR 6, one release later):** delete deprecated root skill
  directories (`writing-cursor-skills`, `create-skill-from-refs`,
  `create-cursor-pack-from-refs`, `external-skill-intake`,
  `claude-plugin-to-cursor-pack`, `audit-skill-for-cursor`,
  `improving-agent-artifacts`, `personal-skill-maintainer`,
  `personal-pack-maintainer`) and their registry entries; move
  `packs/skill-consistency-auditor/` to `packs/.archive/`; drop the legacy
  `cursor-skill-creator-workflow` bundled skill.

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
