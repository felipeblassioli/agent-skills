# Decomposition Guide

Use this guide after the first-pass inspection of a source tree.

## Goal

Map each source file into the smallest correct destination:

- `packs/<name>/` for installable Cursor runtime
- `packs/<name>/skills/<folder>/` for bundled installed skills
- `skills/<name>/` for standard repo-root skills that should be versioned and
  synced independently
- `guides/` or `references/` for human-facing support material
- excluded for Claude-only or non-source files

## Heuristics

### Put it in pack runtime when

- it changes installed Cursor behavior
- it belongs under `.cursor/`
- it defines helper prompts that are better as subagents than skill prose

### Put it in a bundled skill when

- it teaches a reusable workflow
- it has clear trigger scenarios
- it should install with the pack rather than live only in the repo

### Put it in a standard repo-root skill when

- the source is already mostly skill guidance plus references or scripts
- it does not need `.cursor/` runtime assets to deliver value
- it should be versioned in `skill-registry.json` and synced independently of a
  pack
- bundling it into a pack would add delivery overhead without adding capability

### Put it in docs when

- it is useful but too long for the skill hot path
- it explains migration trade-offs or authoring policy

### Exclude or redesign when

- it depends on `claude -p`
- it assumes `.claude/commands/`
- it exists only for Claude UX rather than Cursor runtime behavior
- it is generated output or cache

## Common concerns

- repo-local skill references that will break after installation
- forgetting the repo-root `skills/<name>/` path and forcing everything into
  packs
- missing `metadata.json` for bundled skills
- over-migrating docs into strict rules
- direct copies of vendor-specific command UX
