# Source Decomposition Guide

Use this guide after the first-pass inspection of a source tree (mixed plugin
folder, external skill folder, or any pile of files the user wants converted
into Cursor-native artifacts).

Merged from the decomposition guides in `claude-plugin-to-cursor-pack` and the
deprecated `cursor-skill-creator-workflow` bundled skill.

## Goal

Map each source file into the smallest correct destination in this repository:

- `packs/<name>/` for installable Cursor runtime assets (`.cursor/`, guides,
  hooks, MCP examples).
- `packs/<name>/skills/<folder>/` plus `kind: "skill"` in `pack.json` when
  guidance should ship **with** the pack into Cursor skill discovery paths.
- `skills/<name>/` for reusable **repo-root** guidance (central registry /
  sync) that should be versioned and synced independently of any pack.
- `guides/` or `references/` under a pack for supporting docs.
- Excluded for Claude-only or non-source files.

## Heuristics

### Put it in a pack runtime when

- The file changes installed Cursor behavior.
- The file belongs under `.cursor/` (subagents, rules, hooks, MCP examples).
- The file is an MCP template meant to be staged or installed.
- The file is operational runtime configuration, not explanatory text.
- Helper prompts are better expressed as subagents than as skill prose.

### Put it in a skill when

- The file teaches a reusable workflow.
- The content has clear trigger scenarios.
- The guidance can stand alone without a large runtime bundle.
- The content should be discoverable through skill routing.

Then choose **repo-root** versus **pack-bundled**:

| Choice | Pick when |
|---|---|
| Repo-root `skills/<name>/` | The skill should be versioned in `skill-registry.json` and synced independently of any pack; it does not need `.cursor/` runtime assets to deliver value. |
| Pack-bundled `packs/<pack>/skills/<folder>/` | The skill is orientation or workflow tied to that pack's install and should ride along with `cursor-pack-sync.sh`; use a pack-scoped `skillId` to avoid colliding with registry skills under `~/.cursor/skills/`. |

### Put it in docs when

- The content is useful but too long or too specific for hot-path skill context.
- The file explains connectors, migration trade-offs, vendor context, or
  authoring policy.
- The file is helpful for humans but not needed for automatic routing.

### Exclude or redesign when

- The file is Claude-only metadata.
- The file depends on `claude -p` or assumes `.claude/commands/`.
- The file contains local settings paths that do not apply here.
- The file is a cache or generated artifact.
- The file assumes slash commands that have no direct Cursor equivalent.
- The file exists only for Claude UX rather than Cursor runtime behavior.

## MCP handling (default first pass)

- Classify live MCP JSON as `pack-runtime` only if it will be shipped as an
  example or template.
- Otherwise keep it as `docs-reference`.
- Call out trust, auth, and portability concerns explicitly.
- Never copy live `mcp.json` files; convert them to `mcp.example.json` with
  `${env:VAR}` placeholders.

## Skill-splitting guidance

Create separate skills when:

- Each workflow has distinct user triggers.
- Each workflow would be useful independently.
- Keeping them together would create routing noise.

Prefer one umbrella skill with references when:

- The workflows are tightly related.
- Each individual workflow is small.
- The main value is the decomposition decision, not direct execution.

## Common migration concerns

- Relative links that break after moving files.
- Placeholder conventions tied to Claude docs.
- Plugin manifests with no Cursor equivalent.
- Missing `metadata.json` and registry entries.
- Over-migrating docs into hot-path skill content.
- Repo-local skill references that will break after installation.
- Forgetting the repo-root `skills/<name>/` path and forcing everything into
  packs.
- Missing `metadata.json` for bundled skills.
- Over-migrating docs into strict rules.
- Direct copies of vendor-specific command UX.

## See Also

- `references/material-intake.md` for the row-by-row classification table.
- `references/pack-standard.md` for the pack contract details.
- `references/cursor-skill-standard.md` for skill frontmatter and directory
  rules.
- `assets/templates/adaptation-report.md` for the decomposition report
  template.
