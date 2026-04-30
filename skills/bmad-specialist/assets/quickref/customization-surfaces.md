# BMAD Customization Surfaces Quickref

| Goal | Best surface | Why | Risk |
|---|---|---|---|
| Change output folders | module `config.yaml` | Native runtime setting | low |
| Change communication language | module `config.yaml` | Centralized default | low |
| Add local project conventions | `_bmad/_memory/` | Reusable policy layer | low |
| Add cross-role refinement doctrine | `_bmad/_memory/` | Shared standing rule, not one role's prompt | low |
| Adjust agent persona | `_bmad/_config/agents/*.customize.yaml` | Project-local override layer | low-medium |
| Add agent menu items | `_bmad/_config/agents/*.customize.yaml` | Appends without rewriting base file | low-medium |
| Add local prompt handlers | `_bmad/_config/agents/*.customize.yaml` | Safer than editing installed agent markdown | low-medium |
| Add repeatable refinement ceremony | BMAD workflow/checklist | Ordered shared process belongs in a repeatable flow | low-medium |
| Promote a cross-project practice | standalone skill | Reusable knowledge outside one installed BMAD tree | medium |
| Change workflow routing | manifest CSVs in `_bmad/_config/` | Routing data lives here | medium-high |
| Change workflow sequence or templates | installed workflow files under `_bmad/` | Direct behavior change | high |
| Change base agent activation logic | installed agent files under `_bmad/` | Deep runtime surgery | high |

## Rule of thumb

Prefer:

1. `config.yaml`
2. `_memory/`
3. `*.customize.yaml`
4. workflow/checklist
5. manifest CSVs
6. direct edits to installed runtime files
