---
title: Registry-driven releases for skills and packs
status: draft
date: 2026-03-08
owner: felipeblassioli
adr: 0001
---

# ADR-0001: Registry-driven releases for skills and packs

## Context

This repository contains many independently versioned skills under `skills/`
and installable Cursor packs under `packs/`. The current repository already
tracks versions in `skill-registry.json` and `cursor-pack-registry.json`, and
it already provides local version bump and validation tooling for both artifact
types.

At the same time, the repository does not yet have a shared release contract
for GitHub Releases. There is no release workflow, no ADR directory, and no
Changesets baseline. The repository is also not a root npm workspace, which
makes an immediate package-centric release solution a poor fit for the current
shape of the repo.

The release strategy therefore needs to support:

- independent evolution of skills and packs
- explicit version authority in existing registry files
- module-scoped GitHub Releases
- a reviewable release PR process
- lightweight skill releases and richer pack releases

## Decision

We will use a registry-driven, independently versioned release model for skills
and Cursor packs.

Each released unit will receive:

- one module-scoped Git tag
- one GitHub Release tied to that tag
- one archive asset generated from the released directory

The canonical tag formats are:

- `skill-<name>@<version>`
- `pack-<name>@<version>`

The version source of truth remains the repository registries and the local
artifact manifests. GitHub Releases are the publication record, not the version
calculation engine.

## Rationale

This option best matches the repository as it exists today.

The registries already express the unit boundaries and versions for both skills
and packs, so reusing them avoids inventing a parallel source of truth. Packs
already maintain committed release documents and have a dedicated verification
script, which makes them well suited to richer GitHub Release bodies. Skills
already have independent versions and sync semantics, but they do not yet have
pack-style release artifacts, so a lighter release format is more appropriate.

We also considered immediate Changesets adoption, but the repository does not
yet behave like a standard workspace monorepo. Changesets is strong when the
release units are package-like and workspace-native; using it now would require
adapting directory-based skills and packs into a model they do not naturally
fit. The current registries already solve identity and version ownership with
less operational overhead.

## Consequences

### Positive

- Release identity remains aligned with existing repository metadata.
- Skills and packs can evolve without forcing repo-wide version bumps.
- GitHub Releases become useful, searchable records per released unit.
- Pack releases can include richer evidence without imposing the same burden on
  every skill immediately.

### Negative

- Release automation is custom rather than off-the-shelf.
- Skills and packs follow intentionally different release-note depth.
- Maintainers must keep tag creation disciplined and version metadata aligned.

### Neutral

- Changesets remains a future option rather than an immediate dependency.
- Release PRs introduce an extra control point, but they also make batching and
  review explicit.

## Alternatives considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| Repo-wide versioning | Simple release numbering and one release surface | Couples unrelated skills and packs, noisy changelogs | Does not match independent evolution in the registries |
| GitHub Releases only | Minimal tooling, easy to start | Version intent becomes ad hoc and metadata drift is more likely | Existing registries already hold version truth |
| Full Changesets adoption now | Strong release PR model for package workspaces | Poor fit for directory-based skills and packs without extra translation | Deferred until the repo becomes more workspace-like |

## Implementation notes

- Document the release strategy in `docs/specs/release-workflow.md`.
- Add scripts to resolve tagged release units, validate them, generate archive
  assets, and build release notes.
- Add a GitHub Actions workflow that reacts to `skill-*` and `pack-*` tags.
- Update contributor-facing docs so release PRs include release-unit and
  validation information for both skills and packs.

## References

- `README.md`
- `skill-registry.json`
- `cursor-pack-registry.json`
- `scripts/skill-version.sh`
- `scripts/skill-sync.sh`
- `scripts/cursor-pack-version.sh`
- `scripts/cursor-pack-verify.sh`
- `docs/specs/release-workflow.md`

## Changelog

| Date | Author | Change |
|------|--------|--------|
| 2026-03-08 | felipeblassioli | Initial draft |
