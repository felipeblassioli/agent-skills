# Surface Selection

Use a skill only after confirming that a reusable skill is the right surface.
Claude plugins can bundle several surfaces together; pick the smallest one that
owns the job.

## Choose a skill when

- the agent needs reusable knowledge or a repeatable workflow
- the behavior should be portable and discoverable via progressive disclosure
  through `SKILL.md`, `references/`, `assets/`, and optional `scripts/`
- the task benefits from being auto-invoked by description match, or invoked
  explicitly as `/<plugin>:<skill>`

## Do not choose a skill when

| Better surface | Choose it when |
|---|---|
| Subagent (`agents/`) | The work needs context isolation, longer parallel investigation, or a specialized read-only/execution role |
| Command (`commands/`) | The workflow is mostly a prompt macro or one-shot slash-command interaction with arguments |
| Hook (`hooks/`) | The behavior must observe, block, modify, or enforce actions automatically at a tool lifecycle event |
| Plugin (a bundle) | The artifact ships multiple surfaces together — one or more skills plus agents, commands, or hooks — under one installable manifest |

A single-surface job → author just that surface. Only reach for a **plugin**
when several surfaces must install and version as a unit.

## Decision test

Before authoring, ask:

1. What recurring job should this artifact own?
2. Why should that job live as a skill instead of another surface?
3. Should it be auto-invoked by description, or behave like a slash command?
4. What would be lost if this were just a command, subagent, or hook?
5. What should remain intentionally outside this skill?

If the answers are weak or mostly about enforcing behavior at runtime, stop and
recommend a different surface.

## Smells that mean "not a skill"

- "It mostly blocks or enforces behavior." → hook
- "It is really a bundle of skills, agents, and commands." → plugin
- "It only wraps one canned prompt." → command
- "It needs its own isolated context and long investigation." → subagent
- "Its job is still unclear after discovery." → return to discovery
- "This must run before or after tool execution." → hook

## See Also

- `references/skill-archetypes.md` — once a skill is confirmed, pick its shape.
- `references/plugin-standard.md` — the plugin layout when several surfaces
  must ship together.
