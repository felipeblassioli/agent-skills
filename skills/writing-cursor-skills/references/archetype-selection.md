# Archetype Selection

Choose the smallest archetype that fits the approved skill contract.

## Archetypes

| Archetype | Use when | Typical `SKILL.md` role |
|---|---|---|
| Knowledge Hub | The skill mainly routes domain questions to focused references | Dispatcher |
| Tool Runner | The skill mainly chooses and runs deterministic scripts or commands | Controller |
| Workflow Executor | The skill mainly follows a sequential procedure end to end | Playbook |
| Hybrid | One dominant archetype needs a narrow secondary pattern | Dispatcher with explicit limits |

## Selection rules

- Start from one dominant archetype.
- Use Hybrid only when one secondary behavior is clearly necessary.
- If the skill needs multiple equally strong archetypes, re-check whether the
  skill actually contains multiple jobs.

## File-tree rules

Scaffold only what the archetype justifies:

| Path | Create when |
|---|---|
| `SKILL.md` | Always |
| `references/` | The skill needs on-demand doctrine or focused explanations |
| `assets/` | The skill benefits from copyable templates, checklists, or quick references |
| `scripts/` | Deterministic execution or compact machine-readable output is required |

## Default section set

| Section | Knowledge Hub | Tool Runner | Workflow Executor |
|---|:---:|:---:|:---:|
| Applicability Gate | yes | yes | optional |
| Routing or Decision Table | yes | yes | no |
| Numbered Workflow | optional | optional | yes |
| Procedure | yes | yes | implicit |
| Confirmation Policy | yes | optional | yes |

## Anti-bloat rules

- Do not create `assets/` or `scripts/` "just in case".
- Do not create README placeholders for empty directories.
- Keep references one link deep from `SKILL.md`.
- If `SKILL.md` starts becoming a dump, move detail into references.
