# Release Workflow Specification

## Status

Draft

## Purpose

Define a release workflow for this repository in which skills and Cursor packs
evolve independently, versions remain registry-driven, and GitHub Releases act
as the public release record for each released unit.

## Background

This repository already tracks independent versions in:

- `skill-registry.json`
- `cursor-pack-registry.json`

It also already provides local version bump and validation tooling:

- `scripts/skill-version.sh`
- `scripts/skill-sync.sh`
- `scripts/cursor-pack-version.sh`
- `scripts/cursor-pack-verify.sh`
- `scripts/cursor-pack-sync.sh`

What the repository does not yet have is a shared release contract for:

- tag naming
- release-unit boundaries
- release PR batching
- GitHub Release creation
- release asset generation

## Goals

- Keep skills and packs independently versioned.
- Preserve the registry files as the version source of truth.
- Support one GitHub Release per released skill or pack.
- Keep pack releases richer than skill releases, matching current repo maturity.
- Make the release path reviewable through a release PR.
- Avoid requiring a root npm workspace or immediate Changesets adoption.

## Non-goals

- Introduce one repository-wide version.
- Publish every skill and pack on every merge.
- Require all skills to maintain full changelog artifacts immediately.
- Turn the repository into an npm workspace just to support release tooling.

## Release Units

### Canonical release units

The repository recognizes these release units:

- `skills/<name>`
- `packs/<name>`

`packages/<name>` may become releasable later, but they are not part of the
initial release contract unless explicitly onboarded.

### Release identity source

Release unit identity comes from the registries:

- Skills: `skill-registry.json`
- Packs: `cursor-pack-registry.json`

Skill releases must resolve to one entry in `skill-registry.json`.
Pack releases must resolve to one entry in `cursor-pack-registry.json`.

## Version Authority

### Skills

For a skill release, the release version must match:

- `skill-registry.json`
- `skills/<name>/metadata.json`
- `skills/<name>/SKILL.md` frontmatter when a `version:` field exists

### Packs

For a pack release, the release version must match:

- `cursor-pack-registry.json`
- `packs/<name>/pack.json`

## Tagging Convention

Use module-scoped tags so GitHub Releases remain unambiguous inside a shared
repository.

### Tag format

- Skills: `skill-<name>@<version>`
- Packs: `pack-<name>@<version>`

### Examples

- `skill-tdd-classicist@1.1.0`
- `skill-gcp-opentelemetry-nodejs@1.2.0`
- `pack-cursor-companion@0.2.0`

## Release Policy By Artifact Type

### Packs

Packs receive the full release treatment:

- module-scoped tag
- one GitHub Release per tag
- one versioned archive asset
- release body derived from committed pack release docs

Each maintained pack should keep these committed files:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `RELEASE-POLICY.md`
- `ROADMAP.md`

### Skills

Skills receive a lightweight release treatment:

- module-scoped tag
- one GitHub Release per tag
- optional versioned archive asset
- release body generated from registry metadata and release context

Skills do not need pack-style changelog artifacts in phase 1.

## GitHub Release Contract

### Skill release body

A skill release body should include:

- skill description
- targets from the registry
- source path
- concise release framing
- validation expectations

### Pack release body

A pack release body should include:

- pack description
- supported targets
- supported profiles
- the changelog section for the released version when available
- a pointer to `VERIFICATION.md`

### Release assets

Release assets should be tarball archives by default:

- `skill-<name>-<version>.tar.gz`
- `pack-<name>-<version>.tar.gz`

The asset should contain the released directory under a stable top-level folder:

- `skill-<name>/...`
- `pack-<name>/...`

## Release PR Process

### Feature PRs

Feature PRs may change skill content, pack content, tooling, or docs. They do
not need to create tags directly.

### Release PRs

Release PRs are the batching point. A release PR should:

- contain version bumps only for the units being released
- avoid unrelated feature edits
- include validation evidence for every released unit
- state the exact tags that will be created after merge

### Skill validation inside release PRs

At minimum:

- `bash scripts/skill-sync.sh --skill=<name> --dry-run`

If a skill-specific validator exists, maintainers may include it as additional
evidence.

### Pack validation inside release PRs

At minimum:

- `bash scripts/cursor-pack-verify.sh --pack=<name>`
- dry-run installs for supported target and profile combinations relevant to the
  release

## Automation Flow

### Trigger

GitHub Actions should react to pushed tags matching:

- `skill-*`
- `pack-*`

### Steps

1. Parse the tag into release kind, name, and version.
2. Validate that the tagged unit exists and that its version matches registry
   metadata.
3. Run release-specific verification.
4. Build a module-scoped archive asset.
5. Generate release notes.
6. Create or update the GitHub Release for that tag.

## Changesets Position

Changesets is deferred for now.

### Why it is not phase 1

This repository's primary release units are directory-based skills and Cursor
packs, not standard npm workspace packages. Immediate Changesets adoption would
add translation overhead without solving the core release problem better than
the existing registries.

### Revisit Changesets when

- the repository adopts a real root workspace model
- `packages/` becomes a first-class release surface
- skills or packs become package-like release units that Changesets can manage
  directly

## Acceptance Criteria

The strategy is implemented successfully when:

- a maintainer can create `skill-<name>@<version>` for a versioned skill
- a maintainer can create `pack-<name>@<version>` for a versioned pack
- the workflow validates the tagged unit before release publication
- the workflow uploads one archive asset per released unit
- the GitHub Release body is specific to the released unit type
- the strategy does not require a repo-wide version or a root npm workspace
