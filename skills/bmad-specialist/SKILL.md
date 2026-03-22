---
name: bmad-specialist
description: Use when the user needs to audit or customize an installed BMAD project, inspect current `_bmad/` customizations, align the team on refinement behavior, or decide whether a BMAD change belongs in memory, agent overrides, workflow/checklists, or a reusable skill.
disable-model-invocation: true
---

# BMAD Specialist

Use this skill when the real target is an installed BMAD project runtime under
`_bmad/`, including its current customizations, project-local doctrine,
generated outputs, and team process.

## Applicability Gate

Use this skill when ANY of the following are true:

- the user wants to understand how `_bmad/` works in a project
- the user wants to audit the current BMAD setup before changing it
- the user wants to change BMAD outputs, language, project knowledge, or local
  behavior
- the user wants to customize a BMAD agent, menu, prompt, or memory
- the user wants to tune a BMAD workflow or decide which installed file to edit
- the user wants to review `_bmad-output/` artifacts and decide whether they are
  durable policy, candidate ideas, or disposable evidence
- the user wants to ask the team how refinement currently works and compare that
  answer against the installed BMAD customizations
- the user wants to know whether a BMAD behavior change should become
  `_memory/`, `*.customize.yaml`, a BMAD workflow/checklist, or a standalone
  skill
- the user wants to know what is safe versus risky to modify in an installed
  BMAD tree

Do NOT use this skill when:

- the task is about BMAD source-repo maintenance or BMAD package development
- the task is generic repository mapping unrelated to installed BMAD behavior
- the task is debugging a broken BMAD install or runtime failure
- the task is importing BMAD assets into this repository or creating a new pack
- the task is generic code review

## Routing Table

| Question | Route to |
|---|---|
| "How is installed BMAD organized?" | [references/runtime-map.md](references/runtime-map.md) |
| "Audit my current BMAD customizations" | [references/current-setup-audit.md](references/current-setup-audit.md) |
| "Ask the team how refinement currently works" | [references/team-alignment-interview.md](references/team-alignment-interview.md) |
| "Use BMAD role perspectives to inspect this setup" | [references/panel-mode.md](references/panel-mode.md) |
| "What file should I edit for this customization?" | [assets/quickref/customization-surfaces.md](assets/quickref/customization-surfaces.md) |
| "How do I customize BMAD behavior in this project?" | [references/customization-playbook.md](references/customization-playbook.md) |
| "Should this become memory, customize, workflow, or skill?" | [references/surface-decision.md](references/surface-decision.md) |
| "What is safe to edit versus risky?" | [references/behavior-modification-safety.md](references/behavior-modification-safety.md) |
| "Produce a durable audit artifact" | [assets/templates/customization-audit-report.md](assets/templates/customization-audit-report.md) |

## Procedure

1. Confirm the target is an installed `_bmad/` project surface, not the BMAD
   source repository.
2. Identify the primary job:
   - explain runtime structure
   - audit the current setup
   - ask alignment questions about refinement or delivery behavior
   - decide the correct customization surface
   - propose a concrete BMAD behavior change
3. Read only the smallest matching reference first.
4. When the user wants an audit, follow the audit loop:
   - inventory active runtime control files and recent outputs
   - interview the user or team about actual behavior
   - optionally run a focused BMAD-role panel
   - iterate on conflicts or gaps
   - write a customization audit report
5. Prefer safer override layers first:
   - module `config.yaml`
   - `_bmad/_config/agents/*.customize.yaml`
   - `_bmad/_memory/`
6. Suggest manifest CSV edits or direct runtime file edits only when the lower
   layers cannot express the change cleanly.

## Audit Loop

Use this loop when the request sounds like:

- "analyze my current BMAD setup"
- "review our customizations"
- "ask the team how refinement works"
- "should this be a skill or workflow?"

### Phase 1. Inventory

Read enough to understand the live setup:

- `_bmad/_config/manifest.yaml`
- `_bmad/core/config.yaml`
- module-specific `config.yaml`
- relevant `_bmad/_config/agents/*.customize.yaml`
- relevant `_bmad/_memory/**`
- one or two recent `_bmad-output/**` artifacts when they are part of the
  question

Treat `_bmad-output/**` as evidence of behavior or process ideas, not automatic
runtime authority.

### Phase 2. Team Alignment Interview

Ask a short guided set of questions when the user wants team/process alignment.
Prefer:

- current source of truth
- what must happen before work is ready
- what is a standing rule versus a one-off decision
- how brainstorming ideas become durable behavior
- whether the problem is local to one role or shared across many roles

### Phase 3. BMAD-Role Panel

When one perspective is not enough, launch focused readonly subagents using the
installed BMAD role files plus matching customization files as briefing
material.

Default panel:

- Analyst: identify invariants, missing durable rules, and output-vs-policy drift
- PM: identify scope/process placement and whether a recurring behavior deserves
  workflow/checklist codification
- Scrum Master: identify readiness gates, refinement sequence, and operational
  checklist needs

Optional panel:

- Tech Writer: when the result should become durable standards or a report
- Dev: when the customization changes implementation flow or handoff
- UX: when the refinement process depends on proof artifacts or user-flow
  evidence

Ask narrow questions. Do not run broad party-mode style debate by default.

### Phase 4. Synthesis

Classify each meaningful behavior into one of:

- `_memory/`
- `*.customize.yaml`
- BMAD workflow/checklist
- manifest CSV
- direct runtime edit
- standalone reusable skill

Then write a customization audit report using the template.

## Report Contract

When this skill performs a setup audit, produce a durable report that covers:

- current customization
- what is already done
- why it exists
- evidence
- current effect
- problems, duplication, or drift
- recommended owner surface
- proposed change
- expected outcome before and after
- risk and open questions

## Confirmation Policy

Do not edit installed BMAD files without explicit user approval. When the user
asks to change behavior, explain the safest candidate surfaces first and call
out upgrade or reinstall risks before proposing edits.

## Related Skills

- `engineering-debug` or `systematic-debugging` when BMAD is failing rather than
  needing explanation
- `cursor-skill-creator` when the real task is authoring a new skill or pack
- `nested-agents-routing` when the real task is organizing repo-local AI
  guidance rather than customizing installed BMAD
