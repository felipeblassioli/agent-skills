# Behavior Modification Safety

This guide helps decide whether a BMAD change is low-risk, medium-risk, or
high-risk in an installed project.

## Safer customization layers

These are the first places to look.

### Module config

Files:

- `_bmad/core/config.yaml`
- `_bmad/bmm/config.yaml`
- `_bmad/bmb/config.yaml`

Good for:

- output paths
- communication settings
- project knowledge location

Risk:

- low to medium
- usually stable, but still versioned installer output

### Agent customization files

Files:

- `_bmad/_config/agents/*.customize.yaml`

Good for:

- persona adjustments
- extra memories
- appended menu items
- custom prompts

Risk:

- low to medium
- best installed-project override layer for agent behavior

### Memory sidecars

Files:

- `_bmad/_memory/**`

Good for:

- persistent local conventions
- style rules
- standards injection

Risk:

- low
- strong choice when behavior should change through guidance rather than
  workflow surgery

## Medium-risk layers

### Manifest CSVs

Files:

- `_bmad/_config/bmad-help.csv`
- `_bmad/_config/agent-manifest.csv`
- `_bmad/_config/workflow-manifest.csv`
- `_bmad/_config/task-manifest.csv`

Good for:

- routing behavior
- workflow registration
- output-location expectations

Risk:

- medium to high
- these files behave like runtime control tables, so column mistakes can break
  discovery or routing

## High-risk layers

### Direct edits to installed agents and workflows

Files under:

- `_bmad/core/`
- `_bmad/bmm/`
- `_bmad/bmb/`

Good for:

- step ordering changes
- template changes
- behavior the override layers cannot express

Risk:

- high
- can diverge from upstream behavior
- may be overwritten or become hard to reapply after reinstall or upgrade

## Practical safety rules

1. Prefer override layers before forking installed runtime files.
2. If the change is about tone, menu, memory, or local prompts, try
   `*.customize.yaml` first.
3. If the change is about project conventions, try `_memory/` before editing
   multiple workflows.
4. If the change is about outputs or knowledge paths, try `config.yaml` first.
5. If the change requires direct runtime edits, record exactly what changed so it
   can be re-applied later.

## When to warn strongly

Warn the user clearly when:

- they want to edit manifest CSVs without understanding the contract
- they want to edit base agent or workflow files for something an override layer
  can already handle
- they assume installed `_bmad/` edits are guaranteed to survive reinstall
