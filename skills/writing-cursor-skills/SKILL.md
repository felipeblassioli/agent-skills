---
name: writing-cursor-skills
description: >-
  Create context-efficient Cursor skills through Socratic discovery, boundary clarification,
  progressive disclosure, and quality-gated scaffolding. Use when the user wants
  to create or refactor a Cursor skill, define a skill's job and triggers, enforce
  cheap-agent-first delegation, or turn best practices into a reusable skill package.
  Invoke explicitly via /writing-cursor-skills.
disable-model-invocation: true
---

# Writing Cursor Skills

Author high-quality, context-efficient Cursor skills without jumping straight into scaffolding.

This skill treats authoring as **context architecture**. It is strict by default:

- challenge vague scope and chatty outputs
- enforce the "One-Hop Rule" for progressive disclosure
- prefer the smallest viable skill (under 500 lines for the hot-path `SKILL.md`)
- require explicit anti-triggers when overlap is likely
- pause for approval at each phase

## Applicability Gate

Apply this skill when ANY of the following are true:

- the user wants to create a new Cursor skill
- the user wants to refactor an existing Cursor skill for better context efficiency
- the user needs help defining a skill's job, scope, triggers, and anti-triggers
- the user wants a quality-gated authoring flow for `SKILL.md`, `metadata.json`,
  and supporting files

Do NOT apply when:

- the task is mainly distilling a large set of user-provided documents, code, or
  URLs into a skill package (use `create-skill-from-refs` instead)
- the artifact should really be a Cursor pack, subagent, rule, hook, or command (use `references/surface-selection.md`)
- the user only wants to install, sync, list, or version existing skills

## Routing Table

| Need | Route to |
|---|---|
| Decide whether this should be a skill at all | [references/surface-selection.md](references/surface-selection.md) |
| Handle Cursor-specific frontmatter, scope, and invocation behavior | [references/cursor-specifics.md](references/cursor-specifics.md) |
| Run the discovery interview and define the skill contract | [references/socratic-discovery.md](references/socratic-discovery.md) |
| Choose the right skill archetype and lean file tree | [references/archetype-selection.md](references/archetype-selection.md) |
| Validate quality, context efficiency, and packaging decisions | [references/quality-gate.md](references/quality-gate.md) |
| Present or fill the authoring contract | [assets/templates/skill-contract.md](assets/templates/skill-contract.md) |

## Procedure

1. **Start with surface selection.** Confirm the artifact should be a skill, not a rule, hook, subagent, command, or pack.
2. **Lock Cursor-specific behavior early.** Decide whether the skill lives in `.cursor/skills/` or `~/.cursor/skills/`.
3. **Run a Socratic intake.** Clarify the recurring job, intended users, triggers, and anti-triggers.
4. **Write the skill contract before any files.** Use the contract template.
5. **Choose the smallest fitting archetype.** Use a Knowledge Hub, Tool Runner, Workflow Executor, or a narrow Hybrid only when justified.
6. **Scaffold only justified files.** Create `SKILL.md` plus only the `references/`, `assets/`, and `scripts/` content that has a clear purpose.
7. **Keep `SKILL.md` lean and context-efficient.** It should act as a dispatcher. 
   - Move heavy, domain-specific details to `references/` (keep references exactly one hop away).
   - Replace complex manual validation with deterministic python/bash `scripts/`.
8. **Run the quality gate before sign-off.** Validate description precision, context cost, cheap-agent delegation, direct links, and packaging completeness.

## Authoring Rules for Context Efficiency

- **Default to "The Agent is Already Smart"**: Skip introductory explanations. Only add context the agent actually needs to complete the specific task.
- **Strict Output Shapes**: Constrain outputs to JSON or strict bulleted lists to prevent token waste from conversational "chatty" responses.
- **Cheap-Agent-First**: Delegate repository exploration, blind comparisons, and grading to subagents using `model: fast` and `readonly: true`.
- **Progressive Disclosure**: Keep `SKILL.md` strictly focused on routing and triggers.
- Ask explicitly whether the skill belongs in project scope (`.cursor/skills/`) or user scope (`~/.cursor/skills/`).

## Confirmation Policy

Do NOT write files until the current phase is approved.

Pause after each phase and ask for confirmation:

1. Surface decision
2. Skill contract
3. Archetype and file tree
4. `SKILL.md` draft and supporting files
5. Quality-gate results and final package

## Output Contract

For every phase, present:

- proposed file operations
- proposed diffs or scaffolding plan
- open questions or risks
- a single explicit proceed/stop question
