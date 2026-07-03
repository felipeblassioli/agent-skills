# Source Decomposition Guide

Use this guide after the first-pass inspection of a source tree (a mixed plugin
folder, an external skill folder, or any pile of files the user wants converted
into Claude-native artifacts).

## Goal

Map each source file into the smallest correct destination:

- `plugins/<plugin>/skills/<name>/` for reusable task guidance and knowledge.
- `plugins/<plugin>/agents/<name>.md` for a subagent (isolated context, longer
  or read-only investigation, specialized role).
- `plugins/<plugin>/commands/<name>.md` for a prompt-macro slash command.
- `plugins/<plugin>/hooks/` (+ `hooks/hooks.json`) for lifecycle enforcement.
- `references/` or `README.md` under the skill for supporting docs.
- Excluded for cache, generated, or environment-specific files.

Default to a **single standalone skill**. Only produce a multi-surface **plugin**
when several surfaces genuinely must install and version together.

## Heuristics

### Put it in a skill when

- The file teaches a reusable workflow or knowledge base.
- The content has clear trigger scenarios.
- The guidance can stand alone and be discovered through skill routing.
- The content should be loaded on demand via progressive disclosure.

### Put it in a sibling plugin surface when

| Surface | Pick when |
|---|---|
| Subagent (`agents/`) | The work needs an isolated context, a longer or read-only investigation, or a specialized execution role. Helper prompts are usually better as subagents than as skill prose. |
| Command (`commands/`) | The file is essentially one canned prompt or a one-shot interaction taking arguments. |
| Hook (`hooks/`) | The file must observe, block, or modify actions at a tool lifecycle event, not teach a workflow. |

Bundle these into a plugin **with** the skill only when they must travel and
version together; otherwise keep the skill standalone and reference siblings by
name.

### Put it in docs when

- The content is useful but too long or too specific for hot-path skill context.
- The file explains connectors, migration trade-offs, vendor context, or policy.
- The file is helpful for humans but not needed for automatic routing → `README.md`.

### Exclude or redesign when

- The file is a cache or generated artifact.
- The file contains local settings paths that do not apply here.
- The file carries secrets, credentials, or a live `mcp.json`.
- The file exists only for another vendor's UX rather than Claude runtime behavior.

## MCP handling (default first pass)

- Never copy a live `mcp.json`. Convert it to an example config with
  `${env:VAR}` placeholders.
- Call out trust, auth, and portability concerns explicitly.
- If the plugin legitimately needs MCP, ship example-only config and document it
  in `README.md`.

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

- Relative links that break after moving files — and, critically, **cross-skill
  or cross-plugin** relative links break at install time (plugins are copied to
  a cache). Reference other skills by name; reference bundled files via
  `${CLAUDE_SKILL_DIR}` / `${CLAUDE_PLUGIN_ROOT}`.
- Placeholder conventions tied to another vendor's docs.
- Manifests with no Claude equivalent.
- Missing `metadata.json` and `CHANGELOG.md`.
- Over-migrating docs into hot-path skill content.
- Frontmatter carrying governance fields that belong in `metadata.json`.
- Forcing everything into a plugin when a standalone skill would do.

## See Also

- `references/material-intake.md` for the row-by-row classification table.
- `references/plugin-standard.md` for the Claude skill and plugin contract.
- `assets/templates/adaptation-report.md` for the decomposition report template.
