---
name: cursor-skill-creator
description: >-
  Create Cursor skills through Socratic discovery, boundary clarification,
  strict scope control, and quality-gated scaffolding. Use when the user wants
  to create or refactor a Cursor skill, define a skill's job and triggers, or
  turn best practices into a reusable skill package. Invoke explicitly via
  /cursor-skill-creator.
disable-model-invocation: true
---

# Cursor Skill Creator

Create high-quality Cursor skills without jumping straight into scaffolding.

This skill is strict by default:

- challenge vague scope
- prefer the smallest viable skill
- require explicit anti-triggers when overlap is likely
- reject empty scaffolding and generic filler
- pause for approval at each phase

## Applicability Gate

Apply this skill when ANY of the following are true:

- the user wants to create a new Cursor skill
- the user wants to refactor an existing Cursor skill for better auto-invocation
- the user needs help defining a skill's job, scope, triggers, and anti-triggers
- the user wants a quality-gated authoring flow for `SKILL.md`, `metadata.json`,
  and supporting files

Do NOT apply when:

- the task is mainly distilling a large set of user-provided documents, code, or
  URLs into a skill package
  - use `create-skill-from-refs` if available
- the artifact should really be a Cursor pack, subagent, rule, hook, or command
  rather than a skill
  - use the surface-selection process in
    [references/surface-selection.md](references/surface-selection.md)
- the user only wants to install, sync, list, or version existing skills
  - use repository registry or sync workflows directly

## Routing Table

| Need | Route to |
|---|---|
| Decide whether this should be a skill at all | [references/surface-selection.md](references/surface-selection.md) |
| Handle Cursor-specific frontmatter, scope, and invocation behavior | [references/cursor-specifics.md](references/cursor-specifics.md) |
| Run the discovery interview and define the skill contract | [references/socratic-discovery.md](references/socratic-discovery.md) |
| Choose the right skill archetype and lean file tree | [references/archetype-selection.md](references/archetype-selection.md) |
| Validate quality, boundaries, and packaging decisions | [references/quality-gate.md](references/quality-gate.md) |
| Present or fill the authoring contract | [assets/templates/skill-contract.md](assets/templates/skill-contract.md) |

## Procedure

1. **Start with surface selection.** Confirm the artifact should be a skill, not
   a rule, hook, subagent, command, or pack.
2. **Lock Cursor-specific behavior early.** Decide whether the skill lives in
   `.cursor/skills/` or `~/.cursor/skills/`, whether it should auto-invoke, and
   whether it is a fresh skill or a migration from a Cursor rule or command.
3. **Run a Socratic intake.** Clarify the recurring job, intended users,
   triggers, anti-triggers, in-scope behavior, out-of-scope behavior, and likely
   sibling overlaps.
4. **Write the skill contract before any files.** Use the contract template and
   restate the boundary in one sentence.
5. **Choose the smallest fitting archetype.** Use a Knowledge Hub, Tool Runner,
   Workflow Executor, or a narrow Hybrid only when justified.
6. **Scaffold only justified files.** Create `SKILL.md` plus only the
   `references/`, `assets/`, and `scripts/` content that has a clear purpose.
7. **Keep `SKILL.md` lean.** It should act as a dispatcher with an applicability
   gate, routing or workflow structure, and a confirmation policy.
8. **Run the quality gate before sign-off.** Validate description precision,
   anti-triggers, overlap boundaries, direct links, Cursor-specific frontmatter,
   and packaging completeness.

## Authoring Rules

- Write the `description` in third person and include both WHAT the skill does
  and WHEN to use it.
- Use `disable-model-invocation: true` when the skill should behave like a
  slash command rather than an auto-invoked skill.
- Ask explicitly whether the skill belongs in project scope (`.cursor/skills/`)
  or user scope (`~/.cursor/skills/`).
- Include concrete trigger phrases a user would actually say.
- Add anti-triggers when the skill could overlap with sibling skills.
- If the skill is being migrated from a Cursor rule or command, preserve the
  original invocation semantics unless the user asks to change them.
- Do not create empty directories or placeholder files without a near-term use.
- Prefer references and assets over bloating `SKILL.md`.
- Prefer instructions over scripts unless deterministic execution is necessary.
- If two distinct jobs emerge, split them into sibling skills instead of forcing
  a vague umbrella skill.

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
