---
title: Adopt a Claude-first plugin marketplace alongside the Cursor-era registry
status: accepted
date: 2026-07-02
owner: felipeblassioli
adr: 0006
---

# ADR-0006: Adopt a Claude-first plugin marketplace alongside the Cursor-era registry

## Context

This repository distributes agent skills through a **Cursor-era registry model**:
`skill-registry.json` and `cursor-pack-registry.json` are the catalogs; units live
under `skills/<name>/` and `packs/<name>/`; deployment copies them to discovery
paths (`~/.cursor/skills/`, `~/.agents/skills/`, `~/.claude/skills/`) via
`scripts/skill-sync.sh` and `scripts/cursor-pack-sync.sh`; releases run through
`release-units.yml`. ADR-0001..0005 govern this surface.

Since that model was built, Claude Code gained a **native plugin marketplace**:
a `.claude-plugin/marketplace.json` catalog whose plugins live under
`plugins/<plugin>/` (each with `.claude-plugin/plugin.json` and `skills/<skill>/`),
installed and updated in-place through `/plugin marketplace add` and
`/plugin install`. This channel brings three things the registry model does not:

- native, git-based install/update from inside Claude Code (no copy-to-path sync);
- a lean skill package contract (`SKILL.md` frontmatter = `name` + `description`
  only; versioning/freshness in `metadata.json`) with first-class evals and
  source-contract tracking;
- a tier + promotion model (sandbox → official) with a single accountable owner
  per plugin.

There is concrete work that wants this channel now: a set of **GCP observability
skills** (Cloud Error Reporting triage, Cloud Logging noise triage, error → trace
→ code root-cause) and a **governance plugin** (skill-auditor + skill-maintainer).
This mirrors a Cursor-first → Claude-first migration already proven out in a
private team marketplace (prior art), adapted here for personal, public use.

The tension: the registry model is mature and carries ~40 skills and several
Cursor packs. A wholesale migration would be large and risky, and is not required
to start shipping plugins.

## Decision

Adopt the Claude-first plugin marketplace as an **additive, coexisting layer** —
not a replacement — and draw an explicit boundary between the two models.

### New surface (this ADR governs it)

- Catalog: `.claude-plugin/marketplace.json` (marketplace `name: agent-skills`).
- Units: `plugins/<plugin>/` — `.claude-plugin/plugin.json`, `skills/<skill>/`
  (`SKILL.md` + `metadata.json` + `CHANGELOG.md` + optional
  `references/`/`assets/`/`scripts/`/`evals/`), and optional `commands/`.
- Two plugins at launch: `blassioli` (sandbox tier — GCP observability) and
  `repo-governance` (governance/meta-tooling).
- Governance docs: `docs/marketplace-governance.md`, `docs/versioning.md`,
  `docs/releasing.md`, `docs/review-checklist.md`, `docs/source-contracts.md`.
- Tooling: `scripts/validate-skill.sh`, `release-skill.sh`, `release-plugin.sh`,
  `extract-changelog.sh`, `test-validate-skill.sh`.
- CI: `.github/workflows/release-skill.yaml` (**plugins-only trigger**) and
  `release-plugin.yaml`.

### The coexistence boundary

| Concern | Cursor-era model (ADR-0001..0005) | Claude-first marketplace (this ADR) |
|---|---|---|
| Catalog | `skill-registry.json`, `cursor-pack-registry.json` | `.claude-plugin/marketplace.json` |
| Units | `skills/<name>/`, `packs/<name>/` | `plugins/<plugin>/{skills,commands,…}` |
| Distribute | `skill-sync.sh` / `cursor-pack-sync.sh` (copy to discovery paths) | `/plugin marketplace add` + `/plugin install` (git-based) |
| Release | `release-units.yml` | `release-skill.yaml` / `release-plugin.yaml` |
| Version source | registry entry + `metadata.json`/`SKILL.md` | `metadata.json` (frontmatter = `name` + `description` only) |

Rules that keep the two from colliding:

- The marketplace governs **only** `plugins/*` and `.claude-plugin/marketplace.json`.
  The legacy `skills/` and `packs/` are untouched and keep their own tooling.
- `release-skill.yaml` triggers **only** on `plugins/*/skills/*/metadata.json`, so
  it never fires on the ~40 registry skills under `skills/`.
- `validate-skill.sh` tolerates `skill-registry.json`: it cross-checks a version
  only when the skill folder name is a registry key, which plugin skills are not.
- Plugin skills are **not** listed in `skill-registry.json` (consistent with
  ADR-0002's stance on bundled skills).

### Identity and public-repo posture

The marketplace is personal and public: owner `Felipe Blassioli`
(`felipeblassioli@gmail.com`), repo `github.com/felipeblassioli/agent-skills`.
The first plugins were **genericized** before landing — internal project ids,
hostnames, org names, and internal library references were removed. Two skills
from the prior-art source were intentionally excluded on confidentiality grounds:
a library-migration skill tied to an internal package ecosystem (dropped) and an
ArgoCD app-doctor skill whose core feature is inherently tied to an internal
deploy convention (deferred).

## Consequences

### Positive

- The GCP observability and governance work is installable now via native Claude
  Code plugin flows, with evals and source-contract discipline.
- Zero disruption to the existing registry and Cursor packs; ADR-0001..0005 stay
  authoritative for that surface.
- A clear, mechanically-enforced boundary (scoped CI trigger, registry-tolerant
  validator) prevents the two release paths from interfering.

### Negative

- Two distribution models live in one repo, which is cognitive overhead.
  Mitigated by this ADR plus pointers in `CLAUDE.md` and
  `docs/guides/governance-workflow.md`, and a one-sentence rule of thumb: new
  Claude-installable plugins → marketplace; everything already under `skills/` /
  `packs/` → registry.
- Some conceptual duplication (two release pipelines, two version-metadata
  conventions). Accepted: they have disjoint triggers and disjoint file trees.

### Neutral

- Whether to eventually migrate legacy `skills/`/`packs/` into the plugin model is
  **deferred** to a future ADR. This decision neither commits to nor precludes it.
- Demotion/removal of a plugin skill follows the same flow as promotion, in reverse
  (see `docs/marketplace-governance.md`).

## Alternatives considered

### Alternative A: Full migration to Claude-first now

Port all 40 skills and the Cursor packs into plugins and retire the registry.
Rejected for this change: high cost and risk for no immediate benefit to the work
that motivated it; the prior-art migration took a dedicated decision record and
many staged PRs. Left open as a possible future ADR.

### Alternative B: Stay Cursor-only; publish nothing as plugins

Keep the registry as the sole model. Rejected: forgoes native Claude install/update
and the evals/source-contract governance, and leaves the GCP work unshippable as
plugins.

### Alternative C: A separate repository for the marketplace

Host `plugins/` + marketplace elsewhere. Rejected: fragments governance docs and
tooling that are naturally shared, and the goal is explicitly to consolidate this
work in `agent-skills`.

## See also

- `docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md`
- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`
- `docs/ADR/ADR-0003-artifact-maturity-model.md`
- `docs/ADR/ADR-0004-cross-runtime-agent-packaging-model.md`
- `docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md`
- `docs/marketplace-governance.md`
- `docs/versioning.md`
- `docs/releasing.md`
- `docs/review-checklist.md`
- `docs/source-contracts.md`
- `docs/guides/governance-workflow.md`
