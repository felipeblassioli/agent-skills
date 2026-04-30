# Current Setup Audit

Use this guide when the user wants to inspect the BMAD setup that already
exists in a project before making changes.

## Goal

Answer:

- what is currently customized
- what is acting as durable policy
- what is merely an output artifact or exploratory note
- where duplication or wrong-layer logic exists
- what should change next

## Reading Order

Start with the smallest high-signal inventory:

1. `_bmad/_config/manifest.yaml`
2. `_bmad/core/config.yaml`
3. module-specific `config.yaml`
4. relevant `_bmad/_config/agents/*.customize.yaml`
5. relevant `_bmad/_memory/**`
6. one or two recent `_bmad-output/**` artifacts referenced by the user

## What To Extract

For each file or artifact, capture:

- purpose
- whether it is active runtime control, standing project doctrine, or generated
  output
- scope: one role, one workflow, or cross-project team behavior
- risk: low, medium, or high to modify

## Classification Rules

### Active runtime control

Usually:

- module `config.yaml`
- `_bmad/_config/agents/*.customize.yaml`
- manifest CSVs in `_bmad/_config/`

These shape actual behavior or routing.

### Durable project doctrine

Usually:

- `_bmad/_memory/**`
- standards sidecars
- explicit local checklists that the team treats as standing rules

These should explain recurring behavior or policy.

### Evidence or exploratory output

Usually:

- `_bmad-output/**`
- brainstorming sessions
- generated reports

Treat these as candidate evidence, not automatic authority. Promote them only
when the team has accepted the idea as durable behavior.

## Drift Signals

Look for:

- the same rule repeated across several `*.customize.yaml` files
- process doctrine living in role-specific prompts when it really applies to all
  roles
- outputs describing a process that never got promoted into `_memory/` or a
  workflow/checklist
- refinement or readiness rules that exist in chat artifacts but not in durable
  project memory
- routing or ceremony changes proposed in prose without a clear owner surface

## Output Expectation

The audit should end in a customization audit report, not just advice in chat.
