---
title: Governed skill maintenance model
status: draft
date: 2026-04-30
owner: felipeblassioli
adr: 0002
---

# ADR-0002: Governed skill maintenance model

## Context

This repository is the personal source of truth for reusable Agent Skills and
installable Cursor packs. It already separates:

- root skills under `skills/<name>/`
- Cursor packs under `packs/<name>/`
- pack-bundled skills under `packs/<pack>/skills/<skillId>/`
- root skill versions in `skill-registry.json`
- pack versions in `cursor-pack-registry.json`

Cursor's Agent Skills model keeps the runtime contract intentionally small:
a skill is a directory with a required `SKILL.md`, required `name` and
`description` frontmatter, and optional `scripts/`, `references/`, and
`assets/` directories. Cursor discovers skills from project and user skill
directories, and agents progressively load supporting files only when needed.

This repository has grown beyond loose skill files. Recent work added:

- registry-driven releases for skills and packs
- pack-bundled skill support through `kind: "skill"` in `pack.json`
- Keep a Changelog files across many root skills
- pack release artifacts such as `CHANGELOG.md`, `VERIFICATION.md`,
  `RELEASE-POLICY.md`, and `ROADMAP.md`
- authoring doctrine for small hot paths, progressive disclosure, and
  skill-versus-pack boundaries

A private-platform skill governance model adds a useful discipline: treat each
skill as a versioned contract, not loose documentation. It requires synchronized
versions, changelogs, source-contract review, README usage prompts, registry
maintenance, and validation. That model is valuable, but it is more strict than
this repository should apply uniformly. Such a model suits a private platform
source of truth with source contracts for a specific deployment platform and
internal service behavior. This repository is a personal multi-surface registry
with portable skills, imported skills, pack-bundled skills, runtime packs,
subagents, rules, hooks, and MCP examples.

The missing decision is how much of that governance to adopt without
bloating skill hot paths or confusing root skills with pack-bundled skills.

## Decision

We will adopt a governed skill maintenance model based on this principle:

> A skill is a compact, versioned agent-behavior contract. Its hot path optimizes
> activation and routing. Its maintenance contract lives in metadata, changelog,
> README, registry entries, and validation evidence. A Cursor pack is a
> versioned runtime bundle; bundled skills are delivered by the pack but remain
> skill-shaped and are not registry skills unless intentionally promoted.

This creates two skill release tiers:

1. **Registry skills** under `skills/<name>/` are independently versioned,
   portable guidance units. Their release identity comes from
   `skill-registry.json` and `metadata.json`.
2. **Pack-bundled skills** under `packs/<pack>/skills/<skillId>/` are installed
   by a Cursor pack through `kind: "skill"` artifacts. They normally version
   with the pack and are not listed in `skill-registry.json` unless promoted.

Root skills and pack-bundled skills share the same skill semantics: compact
`SKILL.md`, optional one-hop supporting files, and progressive disclosure. They
do not share the same release authority by default.

## Scope

This ADR applies to:

- files under `skills/<name>/`
- bundled skills under `packs/<pack>/skills/<skillId>/`
- skill entries in `skill-registry.json`
- pack entries in `cursor-pack-registry.json`
- pack manifests that declare `kind: "skill"` artifacts
- skill and pack release documentation
- future validation scripts and authoring checklists

This ADR does not decide:

- the content of any individual skill
- whether a specific skill should be imported or deleted
- the exact implementation of future validators
- GitHub Release automation beyond the release-unit model already covered by
  ADR-0001
- a repository-wide versioning scheme

## Skill Package Model

Maintained root skills should use this package shape:

```text
skills/<name>/
├── SKILL.md
├── metadata.json
├── CHANGELOG.md
├── README.md
├── references/
├── assets/
└── scripts/
```

Only `SKILL.md` and `metadata.json` are hard requirements for all root skills.
`CHANGELOG.md` is expected for skills that are in `skill-registry.json` and
evolve over time. `README.md` is recommended for maintained, imported,
source-contract, or human-facing skills, but it should not be required for every
small skill.

The file responsibilities are:

- `SKILL.md`: agent hot path. It contains the trigger surface, applicability
  gate, anti-triggers, short procedure, and routing to the next useful
  reference, script, or asset. It should not carry long maintenance history.
- `metadata.json`: machine-readable maintenance metadata. It carries `version`,
  `author`, `date`, `abstract`, and optional source-contract or provenance
  fields. New or normalized skills should prefer ISO-style dates; older
  month-style values may remain until those skills are refreshed.
- `CHANGELOG.md`: human-readable release history. It records notable changes by
  version, using Keep a Changelog style.
- `README.md`: human usage and maintainer guide. It contains useful prompts,
  maintenance notes, validation commands, and links to related skills, packs, or
  specs.
- `references/`: detailed guidance that should not live in the hot path.
- `assets/`: copyable templates, examples, checklists, or static resources.
- `scripts/`: deterministic tools that replace repeated prose instructions.

The default `SKILL.md` frontmatter for this repository remains aligned with
Cursor's skill contract:

```yaml
---
name: skill-name
description: Use when ...
---
```

`version`, `last_reviewed`, and `source_contracts` should not be mandatory in
`SKILL.md` frontmatter. They are allowed only when they materially improve
routing or provenance for a specific skill. The default version authority is
`metadata.json` plus the relevant registry.

## Pack-Bundled Skill Model

Pack-bundled skills keep the same skill package semantics, but their release
authority is different.

Minimum bundled skill shape:

```text
packs/<pack>/skills/<skillId>/
├── SKILL.md
└── metadata.json
```

Pack-bundled skills should follow these rules:

- `pack.json` declares them with `kind: "skill"` and an explicit `skillId`.
- `skillId` should be pack-scoped, such as
  `cursor-companion-pack-overview`, to reduce collisions in shared Cursor skill
  discovery paths.
- `SKILL.md` frontmatter `name` must match `skillId`.
- The pack README documents where bundled skills install for project and user
  targets.
- The pack changelog records bundled skill changes as pack changes.
- The bundled skill is not added to `skill-registry.json` unless it is promoted
  to a root skill.

Promotion from bundled skill to root skill is an explicit maintenance decision.
Promotion requires:

- copying or moving the skill to `skills/<name>/`
- assigning independent version authority in `skill-registry.json`
- adding or updating `CHANGELOG.md`
- ensuring `metadata.json` matches the promoted release version
- deciding whether the pack should continue bundling it or depend on separate
  skill sync

This prevents a pack from silently creating a second registry system for skills.

## Versioning Model

Skill versions use semantic versioning based on agent-visible behavior.

- **Patch**: wording clarifications, typo fixes, metadata-only corrections,
  safer examples, or validation/documentation improvements that do not change
  when or how an agent uses the skill.
- **Minor**: new supported workflow, source contract, review path, safety check,
  template, reference, or script that expands the skill without breaking prior
  behavior.
- **Major**: activation boundary changes, removed guidance, changed default
  behavior, changed confirmation policy, or safety policy changes that may
  invalidate previous agent behavior.

Root skill version authority:

- `skill-registry.json`
- `skills/<name>/metadata.json`
- latest `skills/<name>/CHANGELOG.md` entry when the skill has a changelog
- optional `SKILL.md` frontmatter `version` only if the skill already uses it

Pack version authority:

- `cursor-pack-registry.json`
- `packs/<pack>/pack.json`
- pack release docs for human evidence

Pack-bundled skill version authority:

- the containing pack version by default
- bundled skill `metadata.json` for local provenance
- independent SemVer only after promotion to `skills/<name>/`

This extends ADR-0001 rather than replacing it. ADR-0001 decides how release
units are tagged and published. This ADR decides what maintenance evidence each
skill-shaped artifact should carry before it reaches that release path.

## Changelog Model

Root skill changelogs should be concise and behavior-focused.

Recommended shape:

```markdown
# Changelog

All notable changes to this skill will be documented in this file.

## [1.1.0] - 2026-04-30

### Added

- Added ...

### Changed

- Changed ...

### Validation

- `bash scripts/skill-sync.sh --skill=<name> --dry-run`

### Source Contracts

- `path/to/source.md` reviewed 2026-04-30
```

The `Validation` section is recommended when the release includes meaningful
behavior, packaging, or registry changes. The `Source Contracts` section is
recommended when a skill teaches behavior derived from external docs, platform
repos, workflow files, APIs, or private operational conventions.

Pack changelogs remain richer pack-level release documents and should point
readers to `VERIFICATION.md` for evidence. Bundled skill changes are recorded in
the pack changelog unless the skill has been promoted to the root registry.

## README Model

Root skill `README.md` files are human-facing and should not duplicate the
`SKILL.md` body.

Recommended shape:

```markdown
# <Skill Name>

Short purpose.

## When To Use

Human prompt examples.

## What This Skill Maintains

Package files, source contracts, references, scripts, and registry expectations.

## Release And Validation

Commands and expected evidence.

## Related Skills Or Packs

Routing notes and links.
```

README files are most valuable when a future maintainer needs to know how to
use, update, or validate a skill without loading a long agent hot path. They are
less valuable for tiny self-contained skills, so they should remain recommended
rather than universally required.

Pack README files keep their current role: explain pack purpose, targets,
profiles, install shape, runtime assets, bundled skills, and release artifacts.
They should not duplicate every bundled skill body.

## Source Contracts

Some skills are derived from source material that may drift. Examples include:

- platform docs
- workflow definitions
- chart values
- API references
- operational runbooks
- external repositories
- imported skill sources

For those skills, source contracts should be recorded in:

- `metadata.json`, when machine-readable provenance is useful
- the relevant `CHANGELOG.md` release entry
- `README.md`, when maintainers need clear review prompts
- `SKILL.md`, only when the source contract materially affects agent routing or
  the skill's safe use

This borrows that source-contract discipline without making every skill hot
path carry private-platform governance fields.

## Rationale

This model preserves the strongest part of that governance model: skills are
maintained contracts, not loose notes. It also respects the shape of this
repository and Cursor's skill standard.

Keeping `SKILL.md` small is essential because skill descriptions and hot paths
are part of context architecture. The agent needs trigger accuracy and routing
more than it needs release history in the main file. Maintenance details still
matter, but they belong in files loaded by maintainers, validators, or release
automation.

The model also avoids treating pack-bundled skills as a second root registry.
Packs are runtime bundles. A bundled skill can teach orientation or workflow for
that bundle, but it should not automatically become an independently synced
global skill. Explicit promotion keeps ownership, versioning, and collision
risks understandable.

Finally, the model is incremental. Existing skills already have
`metadata.json`; many now have `CHANGELOG.md`; packs already have richer release
artifacts. This ADR tightens expectations without requiring a disruptive
repository-wide migration.

## Consequences

### Positive

- Root skills get a clear maintenance contract without bloating `SKILL.md`.
- Pack-bundled skills stay compatible with Cursor discovery while preserving
  pack-level release ownership.
- Future maintainers have obvious homes for agent guidance, human prompts,
  release history, source contracts, references, assets, and scripts.
- Source-contract skills can adopt source-contract freshness evidence where it
  adds value.
- ADR-0001's registry-driven release model remains intact.
- Skill and pack validators can grow from explicit policy rather than implicit
  taste.

### Negative

- The model introduces more documentation expectations for maintained skills.
- Some older skills may need normalization to fully match the package model.
- README files can become stale if maintainers duplicate content from
  `SKILL.md` instead of linking and summarizing.
- Pack-bundled skill versioning may surprise maintainers who expect every skill
  directory to have independent SemVer.

### Neutral

- Not every skill needs a README immediately.
- Not every skill needs source contracts.
- `SKILL.md` frontmatter remains intentionally lighter than that private
  governance model.
- Validation scripts will likely need follow-up changes to enforce the parts of
  this ADR that are deterministic.

## Alternatives Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| Adopt the private-platform governance exactly | Strong consistency, explicit source freshness, strict validation | Adds `version`, `last_reviewed`, and source-contract fields to every hot path; overfits a private platform repo; treats all skills as equally source-contract-heavy | Too heavy for a personal multi-surface skill and pack registry |
| Keep only Cursor's minimum skill shape | Maximum portability, low friction, simple authoring | No durable maintenance contract; changelog and README usage become optional folklore; source drift is easy to miss | Too weak for a repository that already has registries, releases, packs, and imported skills |
| Treat pack-bundled skills as normal root skills | One versioning model for every skill directory | Creates duplicate release ownership; increases collision risk in `~/.cursor/skills`; undermines `kind: "skill"` as a pack delivery channel | Confuses delivery mechanism with release authority |
| Require README and CHANGELOG for every skill immediately | Uniform maintainer experience | Creates busywork for tiny or experimental skills; encourages boilerplate and stale docs | Better as an expectation for maintained registry skills, not a universal hard gate |
| Use Changesets or package-manager releases for skills | Familiar release workflow for package monorepos | Poor fit for directory-based skills and packs that already have registries; duplicates ADR-0001's release authority | Deferred unless the repo becomes workspace-package oriented |

## Implementation Notes

Adopt this model in phases.

### Phase 1: Document the contract

- Link this ADR from `docs/specs/agentic-skill-pack-authoring.md`.
- Update `docs/specs/skill-authoring-checklist.md` with the root skill package
  model.
- Update `docs/specs/pack-authoring-checklist.md` with bundled skill release
  authority and promotion rules.
- Update `README.md` release documentation to point from skills and packs to
  this ADR.

### Phase 2: Normalize high-value skills

- Prioritize skills in `skill-registry.json` that are actively maintained,
  imported, or source-contract-derived.
- Ensure they have `metadata.json`, `CHANGELOG.md`, and, where useful,
  `README.md`.
- Move long guidance out of `SKILL.md` into one-hop `references/`.
- Add source-contract notes only where there is real drift risk.

### Phase 3: Strengthen validation

- Extend or replace the existing skill validator so it can check:
  - `SKILL.md` has valid required frontmatter
  - `metadata.json` exists and has valid JSON
  - registry skill versions match `metadata.json`
  - `CHANGELOG.md` has a matching current version for maintained root skills
  - broken local references are reported
  - script executability warnings remain visible
- Keep judgment-heavy checks, such as trigger quality and source-contract
  interpretation, in review checklists rather than shell scripts.

### Phase 4: Clarify promotion workflow

- Add a short guide for promoting a pack-bundled skill to a root skill.
- Require promotion PRs to state whether the pack keeps bundling the skill,
  removes it, or references the root skill instead.
- Check for `skillId` collisions between pack-bundled skills and root skill
  sync targets.

### Phase 5: Add release evidence where useful

- Keep pack `VERIFICATION.md` files as the richer evidence surface.
- For root skills, keep validation evidence lightweight unless the skill is
  safety-critical or source-contract-heavy.
- Include changelog sections in generated skill release notes when available.

## Validation Strategy

This ADR should be considered implemented when:

- new maintained root skills follow the package model
- new pack-bundled skills declare explicit `kind: "skill"` artifacts and
  pack-scoped `skillId` values
- authoring checklists reflect the release-authority split
- validators enforce deterministic structure without policing subjective prose
- at least one maintained root skill and one pack-bundled skill are reviewed
  against the model as examples

## References

- ADR-0001: `docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md`
- Cursor Agent Skills docs: `.cursor/refs/cursor/Agent Skills  Cursor Docs 3.md`
- `docs/specs/agentic-skill-pack-authoring.md`
- `docs/specs/skill-authoring-checklist.md`
- `docs/specs/pack-authoring-checklist.md`
- `docs/specs/release-workflow.md`
- `README.md`
- `skill-registry.json`
- `cursor-pack-registry.json`
- `cursor-pack.schema.json`
- `scripts/skill-version.sh`
- `scripts/cursor-pack-version.sh`
- `scripts/cursor-pack-verify.sh`
- Private-platform skill governance model (internal reference; not part of this
  public repository)

## Changelog

| Date | Author | Change |
|------|--------|--------|
| 2026-04-30 | felipeblassioli | Initial draft |
