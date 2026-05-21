# Roadmap

ADR-0005 migration is complete as of 1.1.0
([decision record](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md)).
The pack now has only forward-looking work; the migration milestones
below are kept for context.

## Shipped (1.2.0)

- **Gotchas + lean Confirmation Policy.** Added project-specific
  Gotchas sections to all three studio bundled skills (the single
  highest-leverage best-practice from agentskills.io) and removed the
  duplicate top-level Confirmation Policy blocks. Net effect: more
  actionable density, fewer competing instructions.

## Shipped (1.1.0)

- **PR 6 of ADR-0005 — final cleanup.** Deleted the nine deprecated
  root-skill stub directories and unregistered them from
  `skill-registry.json`; moved the deprecated `skill-consistency-auditor`
  pack to `packs/.archive/` and removed it from
  `cursor-pack-registry.json`; dropped the legacy
  `cursor-skill-creator-workflow` bundled skill from this pack;
  repointed the public link in `skills/gh-post-code-review/README.md`.

## Shipped (1.0.0)

- **PR 5 of ADR-0005 — documentation finalize.** Updated
  `docs/agent-skills.md`, `docs/architecture.md`, `docs/cursor-packs.md`,
  the root `README.md`, `.cursor/rules/30-pr-workflow.mdc`,
  `.github/copilot-instructions.md`,
  `.github/instructions/skills.instructions.md`,
  `.github/pull_request_template.md`, ADR-0003 / ADR-0004, the
  `pack-recommendation-metadata` / `skill-overlap-audit` /
  `claude-plugin-export-from-packs` / `artifact-maintenance-workflow`
  specs, and the `blassioli-code-reviewer` skill cross-references to
  route through `cursor-skill-studio` and the three studio bundled
  skills instead of the deprecated root names. **Done.**
- Promoted pack maturity to **stable**: `pack.json` 1.0.0, refreshed
  description, release artifacts updated, full verification matrix run on
  both targets and profiles. **Done.**
- Verified the live in-pack routing line in
  `skill-studio-write/references/import-paths.md` (line 62) and the See
  Also block in `skill-studio-write/SKILL.md` no longer name the
  deprecated root skills as the active path. **Done.**

## Shipped (0.6.0)

- Lifted `personal-skill-maintainer` and `personal-pack-maintainer` into
  `skill-studio-maintain` (six intent branches); stubbed both source
  skills; merged duplicate `bundled-skills.md`; split repo
  scripts/tools maintenance into `script-tool-maintenance.md`.

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

- **Description tightening (Proposal 3 from the best-practices review).**
  Trim the three studio bundled-skill descriptions by ~40% — lead with
  user intent instead of an implementation enumeration, drop the
  redundant `Invoke explicitly via /skill-studio-X` clause. Land as
  its own PR so the trigger-surface diff is isolated. Evidence: the
  `skill_hot_path_audit.py` self-audit currently fires `long_description`
  (warn) and `procedural_description` (info) on all three studio
  routers; that is the calibration baseline this slice is expected to
  cite (see spec D3).
- Watch for downstream installs that still reference the removed
  artifacts (PR 6) and respond with `cursor-pack-sync.sh` migration
  guidance rather than reintroducing the deprecated names.
- Optionally promote `docs/specs/pack-recommendation-metadata.md` to a
  first-class advisory surface once the MCP recommendation server lands.

## Pre-existing follow-ups (kept from 0.2.0)

- Add a Cursor-native trigger-rate evaluation path if automatic skill
  activation needs to be measured in addition to output quality.
- ~~Adapt the remaining Claude-only description-optimization flow into a
  Cursor-friendly orchestration path.~~ (Replaced by `skill_hot_path_audit.py` token-economy audit)
- Add more bundled templates for pack guides, rule stubs, and eval assertions.
- Add deeper smoke fixtures for multi-run skill comparisons with generated
  `comparison.json`, `skill_inventory.json`, and analyzer output.
- Validate the pack in a second repository after local verification to
  confirm installed-path assumptions hold outside this repo.
