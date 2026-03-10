# Compatibility with `vercel-labs/skills`

## Status

Accepted

## Purpose

Clarify how this repository relates to the open `vercel-labs/skills` ecosystem,
what parts are directly compatible with `npx skills`, and which repository
features are intentionally custom to this project.

## Short answer

This repository is partially compatible with `vercel-labs/skills`.

- Standard skills in recognized discovery paths are compatible.
- The repository-specific registries are not part of the `vercel-labs/skills`
  contract.
- Cursor packs are a custom artifact type and are not installable through
  `npx skills`.

## Compatible surfaces

### Standard skill package format

The repository stores most reusable skills under `skills/<name>/` with a
`SKILL.md` file that uses standard skill frontmatter:

- `name`
- `description`

This is the core contract used by `vercel-labs/skills` for discovery and
installation. Additional frontmatter fields such as `license`,
`compatibility`, or nested `metadata` may be present, but they are repository
extensions rather than requirements of the shared skill format.

### Discovery paths that align with `vercel-labs/skills`

The following repository locations align with the discovery model used by
`vercel-labs/skills`:

- `skills/`
- `.agents/skills/`

As a result, consumers using the public installer can treat this repository as
a source of standard skills and install compatible skills directly from the
public GitHub repository.

### Public install expectation

For standard skills, the expected public compatibility model is:

```bash
npx skills add felipeblassioli/agent-skills
```

Consumers should expect `npx skills` to discover valid skills from supported
skill locations and install them using the installer behavior defined by
`vercel-labs/skills`.

## Not compatible surfaces

### `skill-registry.json` is repository-specific

`skill-registry.json` is the source of truth for this repository's own
maintenance workflow:

- version ownership
- target mapping
- tags
- optional custom path overrides
- release-unit identity for this repository's scripts and release process

`vercel-labs/skills` does not consume this registry as part of discovery or
installation. Its installer discovers skills from files and directories, not
from this registry.

That means fields such as these are meaningful locally but are not part of the
portable public skill contract:

- `version`
- `scope`
- `targets`
- `tags`
- `path`

### `cursor-pack-registry.json` is repository-specific

`cursor-pack-registry.json` defines a separate release and installation model
for Cursor packs. This registry is used only by this repository's own pack
tooling.

It is not part of the shared skill format and is ignored by `vercel-labs/skills`.

### `packs/` are not standard skills

Directories under `packs/<name>/` are installable Cursor runtime bundles, not
standard skills. They may include:

- subagents
- project rules
- hook configuration
- MCP example configuration
- guides and pack-specific release artifacts

These packs are intentionally managed by this repository's custom pack tooling:

- `scripts/cursor-pack-verify.sh`
- `scripts/cursor-pack-sync.sh`
- `scripts/cursor-pack-restore.sh`
- `scripts/cursor-pack-version.sh`

They are not expected to be installable through `npx skills`.

## Practical implications

### What `npx skills` can do

`npx skills` can treat this repository as a public source of standard skills
and install skills that live in supported discovery paths and provide valid
`SKILL.md` metadata.

### What `npx skills` cannot do

`npx skills` does not:

- honor this repository's registries as source of truth
- use registry target mappings
- understand pack manifests such as `pack.json`
- install or restore Cursor packs
- apply pack profiles such as `lite` or `strict`
- enforce this repository's release conventions

### Discovery may be broader than the registry

Because `vercel-labs/skills` is discovery-based rather than registry-based, a
public installer may discover valid skills that exist in supported paths even
if they are not the primary release surface described by this repository's own
registries and scripts.

Maintainers should therefore treat filesystem layout as part of the public
compatibility contract, not only the registry files.

## Recommended maintainer guidance

When documenting or discussing compatibility, use this framing:

1. This repository publishes standard skills that are compatible with the open
   `vercel-labs/skills` ecosystem.
2. This repository also defines custom registries and Cursor packs that extend
   beyond the shared ecosystem contract.
3. Standard skill installation and repository-local pack installation should be
   explained as separate workflows.

## Relationship summary

The clean mental model is:

- `vercel-labs/skills` sees this repository as a collection of discoverable
  standard skills.
- This repository sees itself as a curated registry of versioned skills plus a
  separate system for installable Cursor packs.

Both statements are true, but they operate at different layers.

## References

- [felipeblassioli/agent-skills](https://github.com/felipeblassioli/agent-skills)
- [vercel-labs/skills](https://github.com/vercel-labs/skills)
- `README.md`
- `skill-registry.json`
- `cursor-pack-registry.json`
- `docs/specs/release-workflow.md`
