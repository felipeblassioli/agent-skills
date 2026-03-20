# Decomposition Guide

Use this guide after the first-pass inspection.

## Goal

Map each source file into the smallest correct destination in this repository:

- `packs/<name>/` for installable Cursor runtime assets (`.cursor/`, guides, etc.)
- `packs/<name>/skills/<folder>/` plus `kind: "skill"` in `pack.json` when
  guidance should ship **with** the pack into Cursor skill discovery paths
- `skills/<name>/` for reusable **repo-root** guidance (central registry / sync)
- `guides/` or `references/` under a pack for supporting docs
- excluded for Claude-only or non-source files

## Heuristics

### Put it in a pack when

- the file changes installed Cursor behavior
- the file belongs under `.cursor/`
- the file is an MCP template meant to be staged or installed
- the file is operational runtime configuration, not just explanatory text

### Put it in a skill when

- the file teaches a reusable workflow
- the content has clear trigger scenarios
- the guidance can stand alone without a large runtime bundle
- the content should be discoverable through skill routing

Then choose **repo-root** `skills/<name>/` versus **pack-bundled**
`packs/<pack>/skills/<folder>/`:

- Prefer **repo-root** when the skill should be versioned in `skill-registry.json`
  and synced independently of any pack.
- Prefer **pack-bundled** when the skill is orientation or workflow tied to that
  pack's install and should ride along with `cursor-pack-sync.sh`, using a
  **pack-scoped** `skillId` to avoid colliding with registry skills under
  `~/.cursor/skills/`.

### Put it in docs when

- the content is useful but too long or too specific for hot-path skill context
- the file explains connectors, migration tradeoffs, or vendor context
- the file is helpful for humans but not needed for automatic routing

### Exclude or rewrite when

- the file is Claude-only metadata
- the file contains local settings paths that do not apply here
- the file is a cache or generated artifact
- the file assumes slash commands that have no direct Cursor equivalent

## MCP handling

Default first pass:

- classify live MCP JSON as `pack-runtime` only if it will be shipped as an example or template
- otherwise keep it as `docs-reference`
- call out trust, auth, and portability concerns explicitly

## Skill splitting guidance

Create separate skills when:

- each workflow has distinct user triggers
- each workflow would be useful independently
- keeping them together would create routing noise

Prefer one umbrella skill with references when:

- the workflows are tightly related
- each individual workflow is small
- the main value is the decomposition decision, not direct execution

## Common migration concerns

- relative links that break after moving files
- placeholder conventions tied to Claude docs
- plugin manifests with no Cursor equivalent
- missing `metadata.json` and registry entries
- over-migrating docs into hot-path skill content
