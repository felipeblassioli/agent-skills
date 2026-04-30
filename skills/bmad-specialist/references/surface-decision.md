# Surface Decision

Use this guide when the user asks where a BMAD behavior should live.

## Decision Ladder

### `_bmad/_memory/`

Use when the behavior is:

- a standing project rule
- shared across multiple roles
- documentation or refinement doctrine
- something the team wants to preserve independent of one role prompt

Examples:

- refinement gauntlets
- source-of-truth rules
- durable standards

### `_bmad/_config/agents/*.customize.yaml`

Use when the behavior is:

- specific to one role
- about persona, menu items, custom prompts, or role-local memories
- not an ordered multi-step ceremony

Examples:

- analyst classification prompts
- PM story-scope checks
- role-specific reminders

### BMAD workflow/checklist

Use when the behavior is:

- a repeatable sequence of steps
- a refinement or readiness ceremony
- something multiple people should run the same way each time

Examples:

- refinement checklist
- readiness gate
- story intake ceremony

### Manifest CSVs

Use when the behavior is:

- about routing, registration, or discovery
- not just guidance, but runtime control data

Use carefully. These are control tables.

### Direct runtime edits

Use when:

- the change truly cannot be expressed through config, memory, customize files,
  or workflow/checklist assets

This is the most upgrade-fragile layer.

### Standalone skill

Use when the behavior is:

- reusable across multiple projects
- not dependent on one installed BMAD tree
- more of a knowledge/routing capability than a project-local runtime rule

## Heuristics

- Shared doctrine -> `_memory/`
- Role-local behavior -> `*.customize.yaml`
- Ordered repeatable ceremony -> workflow/checklist
- Cross-project reusable practice -> standalone skill
- Runtime routing control -> manifest CSV
- Unavoidable runtime surgery -> direct edit
