---
name: claude-plugin-to-cursor-pack
description: Evaluates a Claude-style plugin or plugin-like folder and recommends how to adapt it into this repository's Cursor-native artifacts. Use when inspecting `.claude-plugin`, `.mcp.json`, plugin manifests, bundled workflow prompts, or mixed guidance and runtime folders and deciding whether the result should become a Cursor pack, one or more skills, companion docs, or a combination.
---

# Claude Plugin To Cursor Pack

Review a Claude-style plugin before converting it into this repository.

This skill exists to prevent mixed plugin bundles from being copied into `packs/`
or `skills/` without first deciding which files are:

- Cursor runtime assets
- reusable skill guidance
- optional docs or references
- Claude-only metadata or settings
- cache or non-source artifacts that should be ignored

## Applicability Gate

Use this skill when ANY of the following are true:

- the user wants to convert a Claude plugin into this repository
- the source contains `.claude-plugin/plugin.json`
- the source contains `.mcp.json` plus workflow markdown or `SKILL.md` files
- the source mixes MCP config, prompt docs, and skill-like content
- the user wants a recommendation before deciding between `packs/` and `skills/`

Do NOT use this skill when:

- the source is already a normal repo-local skill under `skills/`
- the source is already a normal repo-local pack under `packs/`
- the user only wants to sync or install an existing pack
- the task is generic skill improvement without Claude-plugin migration concerns

## Inputs Required

Minimum input:

- candidate plugin path

Useful optional input:

- desired target name
- whether the goal is analysis only or eventual import
- whether MCP entries should become live config, example config, or docs only
- whether slash-command workflows should become skills, docs, subagents, or be dropped
- whether the user wants the narrowest possible MVP or a fuller migration plan

## Question Flow

Ask only enough questions to choose the highest-leverage decomposition.

Prefer one question at a time. Prefer multiple choice when practical.

Cover these in order:

1. Is the desired output recommendation only, pack-first, skill-first, or mixed pack plus companion skills?
2. Should MCP definitions become installable example config, documentation only, or candidate live config after separate trust review?
3. Should workflow prompts become individual skills, a single umbrella skill with references, or docs only?
4. Should Claude-only metadata and settings be dropped, preserved in docs, or mapped into repo metadata where meaningful?
5. Does the user want an MVP recommendation or a full migration plan?

## Routing Table

- For improvement-first recommendation style, follow `improving-agent-artifacts`
- For final report formatting, use [assets/templates/adaptation-report.md](assets/templates/adaptation-report.md)
- For decomposition rules, read [references/decomposition-guide.md](references/decomposition-guide.md)
- For skill import normalization after the plan is approved, use `external-skill-intake` and `skill-registry`

## Procedure

1. Inspect the candidate root cheaply before reading many files.
2. Identify whether the source contains a Claude plugin manifest, MCP configuration, skill or prompt directories, docs, and runtime-only or cache artifacts.
3. Classify each file or subtree into one of: `pack-runtime`, `skill-guidance`, `docs-reference`, `claude-only`, `ignore`.
4. Read only the minimum files needed to determine manifest fields worth preserving, MCP trust and portability concerns, whether the skill layout is already reusable, and whether links or placeholders will break after migration.
5. Recommend the smallest correct destination shape: `packs/<name>/` only, `skills/<name>/` only, pack plus one or more companion skills, or pack or skill plus optional docs only.
6. Default to NOT recommending both a pack and skills unless the source clearly contains both runtime assets and reusable guidance.
7. For any MCP config, explicitly state whether it should become installable example config, documentation-only example, or excluded pending trust review.
8. For any skill-like docs, explicitly state whether they should become separate standard skills, one umbrella skill with references, or supporting docs outside hot-path skill content.
9. Identify blocking migration concerns such as Claude-only command conventions, path assumptions that break after sync, auth or trust risks in MCP definitions, missing metadata for repo-native skills, and vendor-specific cache or settings files.
10. Present a concise adaptation report using [assets/templates/adaptation-report.md](assets/templates/adaptation-report.md).

## Classification Rules

### `pack-runtime`

Use for files that affect installed Cursor runtime behavior, such as `.cursor/` runtime assets, hook config, subagents, and MCP example config intended for installation or staging.

### `skill-guidance`

Use for reusable task guidance that belongs in `skills/<name>/`, such as workflow `SKILL.md` files, reusable prompt instructions, and compact operational guidance that can stand alone.

### `docs-reference`

Use for files that help humans or support a skill, but should not sit on the hot path: migration notes, connector docs, long examples, product README material.

### `claude-only`

Use for Claude-specific metadata or settings that do not map cleanly to Cursor-native artifacts: `.claude-plugin/plugin.json`, Claude-local settings paths, slash-command framing that exists only for Claude UX.

### `ignore`

Use for non-source or ephemeral artifacts: cache directories, `.DS_Store`, generated temp files.

## Recommendation Policy

- Prefer skill-first when the source is mostly guidance.
- Prefer pack-first when the source includes real runtime assets that should be installed.
- Prefer docs-only for vendor-specific behavior that should not become reusable hot-path context.
- Prefer MCP templates over live MCP config in the first migration pass.
- Prefer separate skills only when the workflows have distinct triggers and reusable value.
- Prefer one umbrella skill plus references when the workflows are tightly related and small enough to avoid routing noise.
- Do not recommend both a skill and a pack unless both are clearly needed.

## Output Contract

Return a concise report with candidate path, source shape summary, manifest classification, MCP classification, skill layout classification, runtime-only versus guidance split, recommended destination paths, blocking concerns, and smallest viable migration plan.

Use the structure in [assets/templates/adaptation-report.md](assets/templates/adaptation-report.md).

## Confirmation Policy

- Do not import or create files on inspection alone.
- Do not treat MCP URLs as safe live config without explicit trust review.
- Do not preserve Claude-specific command UX unless there is a clear Cursor equivalent.
- Do not recommend a large pack when a skill plus docs would solve the problem more cleanly.
