---
title: Consolidate the skill-authoring surface into cursor-skill-studio
status: proposed
date: 2026-05-19
owner: felipeblassioli
adr: 0005
---

# ADR-0005: Consolidate the skill-authoring surface into `cursor-skill-studio`

## Context

This repository currently exposes the skill-authoring lifecycle across nine
root skills and two Cursor packs. A consistency audit (clusterer +
architecture-checker + consolidation-advisor) of those eleven artifacts found:

- Multiple HIGH-severity router collisions between greenfield create, audit,
  and improve skills that share the same trigger vocabulary.
- A FAIL-level doctrine drift on `audit-skill-for-cursor` (registry text claims
  auto-invocation while `SKILL.md` sets `disable-model-invocation: true`).
- A FAIL-level install-correctness gap in `skill-consistency-auditor-workflow`
  (asset path broken after pack install).
- A fan-out hub problem on `cursor-skill-creator-workflow`, which re-implements
  specialist workflows instead of routing to them.
- Doc gaps and progressive-disclosure strain on the create-from-refs skills.

The split made sense historically because each skill was authored or imported
at different times and packs had not yet matured. Now that
`packs/cursor-skill-creator` exists with a full helper subagent pool, eval
loop, and review UI, the natural delivery channel for the entire authoring
lifecycle is one pack with shaped entry points.

ADR-0001 defines registry-driven releases. ADR-0002 defines the governed
maintenance model. ADR-0003 defines artifact maturity. ADR-0004 defines
cross-runtime packaging. None of them prescribe how many entry points the
skill-authoring lifecycle should have.

## Decision

Consolidate the skill-authoring lifecycle into a single Cursor pack,
`cursor-skill-studio`, with three bundled workflow skills and one shared
subagent pool.

### Pack

- Rename `packs/cursor-skill-creator/` → `packs/cursor-skill-studio/`.
- Update `pack.json` (`name: cursor-skill-studio`) and bump to `1.0.0` at the
  end of the migration. Interim PRs use plain semver bumps (`0.3.0`, `0.4.0`,
  `0.5.0`) because `cursor-pack-registry.schema.json` requires
  `^[0-9]+\.[0-9]+\.[0-9]+$`.
- Update `cursor-pack-registry.json` with the new name and a deprecation alias
  for `cursor-skill-creator` for one release.
- Keep the two existing rules; rename the routing rule to
  `10-skill-studio-routing.mdc`.

### Bundled workflow skills

| Bundled skill ID | Job | Replaces |
| --- | --- | --- |
| `skill-studio-write` | Create new root skills or packs; adapt external sources; intake | `writing-cursor-skills`, `create-skill-from-refs`, `create-cursor-pack-from-refs`, `external-skill-intake`, `claude-plugin-to-cursor-pack`, the existing `cursor-skill-creator-workflow` |
| `skill-studio-maintain` | Governance, registry, versioning, release artifacts | `personal-skill-maintainer`, `personal-pack-maintainer` |
| `skill-studio-audit` | Single-skill audit, portfolio audit, improve-existing diagnostic | `audit-skill-for-cursor`, `improving-agent-artifacts`, the `skill-consistency-auditor-workflow` bundled skill |

Each bundled skill keeps a small `SKILL.md` hot path and routes heavy material
into its own `references/`, `assets/`, and `scripts/` per ADR-0002 and the
skill-authoring checklist.

### Shared subagent pool

The pack's `.cursor/agents/` becomes a single shared pool:

- existing: `skill-creator-bootstrapper`, `skill-creator-grader`,
  `skill-creator-analyzer`, `skill-creator-comparator`,
  `skill-creator-structural-auditor`
- merged in: `skill-overlap-clusterer`, `skill-architecture-checker`,
  `skill-consolidation-advisor`

All three bundled workflows may call any subagent. Subagents stay read-only
unless explicitly noted.

### Root skill deprecations

The following root skills are deprecated as part of this ADR and removed from
`skill-registry.json` at the end of the migration:

- `skills/writing-cursor-skills`
- `skills/create-skill-from-refs`
- `skills/create-cursor-pack-from-refs`
- `skills/external-skill-intake`
- `skills/claude-plugin-to-cursor-pack`
- `skills/audit-skill-for-cursor`
- `skills/improving-agent-artifacts`
- `skills/personal-skill-maintainer`
- `skills/personal-pack-maintainer`

For one release window, each deprecated skill keeps a stub `SKILL.md` that
points to the equivalent bundled skill in `cursor-skill-studio`. After that
window the stub directories are deleted and the registry entries are removed.

### Pack deprecation

`packs/skill-consistency-auditor/` is folded into
`cursor-skill-studio.skill-studio-audit`. The pack is marked deprecated in
`cursor-pack-registry.json` for one release, then moved to
`packs/.archive/skill-consistency-auditor/`.

## Consequences

### Positive

- Discovery surface drops from 11 routing entry points to 3, eliminating the
  HIGH-severity router collisions documented in the audit.
- One install gets the full authoring lifecycle; subagents are shared across
  workflows so the helper pool does not duplicate.
- Release authority is unified: one `pack.json` version, one CHANGELOG, one
  VERIFICATION matrix per release.
- The hub problem disappears; the bundled write workflow can directly call
  specialist subagents instead of re-implementing specialist hot paths.
- The audit FAILs are fixed during migration (registry alignment and the
  broken report-template path become non-issues because both move into the
  pack).

### Negative

- Loss of per-skill versioning granularity. Mitigated by per-section entries
  in the pack CHANGELOG.
- Bundled skills are not registered in `skill-registry.json` by default
  (per ADR-0002). Mitigated by an explicit `docs/agent-skills.md` catalog
  entry that points to the pack-bundled skills.
- External users who installed `cursor-skill-creator@0.2.0` need to re-install
  under the new name. Mitigated by:
  - keeping a deprecation alias in `cursor-pack-registry.json` for one release
  - `cursor-pack-sync.sh` backup behavior on conflict
  - explicit migration notes in `packs/cursor-skill-studio/VERIFICATION.md`
- Subagent count in the pack grows from 5 to 8. Mitigated by keeping all new
  subagents read-only and on the `fast` model except the advisor.

### Neutral

- `react-best-practices-build` and other build tooling are unaffected.
- ADR-0001, ADR-0002, ADR-0003, and ADR-0004 remain authoritative; this ADR
  applies them to a specific consolidation.

## Migration plan

Each phase is a single PR with an isolated scope.

1. **PR 1 — rename + skeleton.** Rename pack folder and `pack.json`; bump to
   `0.3.0`; add empty `skills/skill-studio-write|maintain|audit/`
   directories; copy the three auditor subagents into `.cursor/agents/`.
   Existing `cursor-skill-creator-workflow` keeps working.
2. **PR 2 — `skill-studio-write`.** Lift content from the five write-side
   root skills into the new bundled skill. Add deprecation stubs to those
   root skills.
3. **PR 3 — `skill-studio-audit`.** Lift content from the two audit-side
   root skills plus `skill-consistency-auditor-workflow`. Stub the originals.
   Mark `packs/skill-consistency-auditor` deprecated in its README and in
   `cursor-pack-registry.json`.
4. **PR 4 — `skill-studio-maintain`.** Lift content from the two maintainer
   root skills. Stub the originals.
5. **PR 5 — release.** Bump pack to `1.0.0`. Update `docs/agent-skills.md`,
   `docs/architecture.md`, root `AGENTS.md`, and `cursor-pack-registry.json`.
   Land the full `VERIFICATION.md` matrix.
6. **PR 6 — stub removal (one release later).** Delete the deprecated root
   skill directories and their `skill-registry.json` entries. Move
   `packs/skill-consistency-auditor` to `packs/.archive/`.

## Alternatives considered

### Alternative A: Keep the current split and only add anti-triggers

Land Phase 1 + Phase 2 from the audit report (FAIL fixes plus the top-five
anti-trigger description edits) and stop. Lower migration cost but the
router-collision and hub problems persist, the maintainer split keeps drifting,
and the discovery surface stays at 11 entry points.

### Alternative B: Two packs (`cursor-skill-studio` + `skill-consistency-auditor`)

Keep portfolio audit isolated from write/maintain. Cleaner audit scope but the
single-skill audit job has no clear home and `skill-studio-audit` would need
to call across pack boundaries, defeating the install-cost benefit.

### Alternative C: One bundled skill with three internal modes

Reduces the surface to one entry point but weakens routing signal precisely
where the audit identified the worst collisions (write vs audit vs improve).

The decision picks the three-bundled-skill shape because the audit's
collisions cluster on the write/maintain/audit boundary, which is the
boundary that benefits most from explicit routing in `SKILL.md` frontmatter.

## See also

- `docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md`
- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`
- `docs/ADR/ADR-0003-artifact-maturity-model.md`
- `docs/ADR/ADR-0004-cross-runtime-agent-packaging-model.md`
- `docs/architecture.md`
- `docs/specs/agentic-skill-pack-authoring.md`
- `docs/specs/skill-authoring-checklist.md`
- `docs/specs/pack-authoring-checklist.md`
- `packs/cursor-skill-creator/README.md`
- `packs/skill-consistency-auditor/README.md`
