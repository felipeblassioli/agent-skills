# Surface Selection

Use this skill only after confirming that a reusable skill is the right surface.

## Choose a skill when

- the agent needs reusable knowledge or a repeatable authoring workflow
- the behavior should be portable across repositories or user environments
- the task benefits from progressive disclosure through `SKILL.md`,
  `references/`, `assets/`, and optional `scripts/`
- the user wants an artifact that can be auto-invoked or explicitly invoked via
  `/skill-name`

## Do not choose a skill when

| Better surface | Choose it when |
|---|---|
| `.cursor/rules` | The guidance should persist at prompt level, apply always, apply intelligently, or attach to specific files in one repo |
| Command | The workflow is mostly a prompt macro or one-shot command interaction |
| Subagent | The work needs context isolation, longer parallel investigation, or a specialized execution role |
| Hook | The behavior must observe, block, modify, or enforce actions automatically at runtime |
| Cursor pack | The artifact bundles multiple runtime surfaces such as rules, hooks, subagents, or MCP examples |

## Decision test

Before authoring, ask:

1. What recurring job should this artifact own?
2. Why should that job live as a skill instead of another surface?
3. Should Cursor auto-apply it, or should it behave like a slash command?
4. What would be lost if this were just a command or rule?
5. What should remain intentionally outside this skill?

If the answers are weak or mostly about one repository's enforcement policy,
stop and recommend a different surface.

## Smells that mean "not a skill"

- "It should always apply everywhere in this repo."
- "It mostly blocks or enforces behavior."
- "It is really a bundle of rules, hooks, and agents."
- "It only wraps one canned prompt."
- "Its job is still unclear after discovery."
- "This must run before or after tool execution."
- "This should apply only to matching files."
