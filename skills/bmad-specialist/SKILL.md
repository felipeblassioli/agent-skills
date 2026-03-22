---
name: bmad-specialist
description: Explain how installed BMAD works inside a project and guide safe customization of its runtime behavior when the user needs help with `_bmad/`, agent overrides, workflow tuning, outputs, or project-local BMAD behavior changes.
disable-model-invocation: true
---

# BMAD Specialist

Use this skill when the user wants to understand or customize an installed BMAD
project runtime without treating the BMAD source repository as the main target.

## Applicability Gate

Use this skill when ANY of the following are true:

- the user wants to understand how `_bmad/` works in a project
- the user wants to change BMAD outputs, language, project knowledge, or local
  behavior
- the user wants to customize a BMAD agent, menu, prompt, or memory
- the user wants to tune a BMAD workflow or decide which installed file to edit
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
| "What file should I edit for this customization?" | [assets/quickref/customization-surfaces.md](assets/quickref/customization-surfaces.md) |
| "How do I customize BMAD behavior in this project?" | [references/customization-playbook.md](references/customization-playbook.md) |
| "What is safe to edit versus risky?" | [references/behavior-modification-safety.md](references/behavior-modification-safety.md) |

## Procedure

1. Confirm the user is asking about an installed `_bmad/` project surface.
2. Identify the target behavior:
   - runtime structure
   - outputs or language
   - agent customization
   - workflow behavior
   - safety or upgrade durability
3. Load only the reference or quickref needed for that question.
4. Prefer safer override layers first:
   - module `config.yaml`
   - `_bmad/_config/agents/*.customize.yaml`
   - `_bmad/_memory/`
5. Only suggest direct edits under `_bmad/core/`, `_bmad/bmm/`, or `_bmad/bmb/`
   when the user truly needs behavior changes that override layers cannot cover.

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
