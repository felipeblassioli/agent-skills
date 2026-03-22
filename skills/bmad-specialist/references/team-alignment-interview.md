# Team Alignment Interview

Use this guide when the user wants the skill to ask the team how refinement or
delivery behavior currently works before recommending BMAD changes.

## Interview Goal

Learn the real operating process, then compare it against:

- `_bmad/_memory/**`
- agent customization files
- workflow/checklist assets
- generated outputs that may contain unpromoted ideas

## Question Set

Ask only the minimum set needed. Prefer short direct questions.

### Source of truth

- What is the current source of truth for refinement status?
- Which rules are authoritative in docs or `_memory/`, and which only live in
  chat or local habit?

### Readiness and refinement

- What must be true before work is marked ready?
- Is there a checklist or gauntlet today? Where is it written?
- Which failures most often force rework?

### Scope and ownership

- Is this rule shared across all BMAD roles, or only one role?
- Is the behavior a standing policy, or a temporary local experiment?

### Promotion and durability

- When a brainstorming session or output artifact suggests a better process, how
  is it promoted into durable behavior?
- Should the result become memory, role customization, workflow/checklist, or a
  reusable skill?

## Interpretation Rules

- Shared standing rules usually belong in `_bmad/_memory/` or a shared
  workflow/checklist.
- Role-specific tone, menu, or prompt behavior usually belongs in
  `*.customize.yaml`.
- Repeatable ceremony with ordered steps usually belongs in a BMAD
  workflow/checklist.
- Cross-project reusable capability may justify a standalone skill.

## Use With Panel Mode

If answers remain ambiguous, run a narrow BMAD-role panel and ask each role to
judge the same behavior from its own perspective.
