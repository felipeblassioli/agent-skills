# Customization Playbook

Use this guide to map a desired BMAD behavior change to the best installed
project surface.

## Change outputs or artifact locations

Start with module config:

- `_bmad/core/config.yaml`
- `_bmad/bmm/config.yaml`
- `_bmad/bmb/config.yaml`

Typical uses:

- change the root output folder
- redirect planning artifacts
- redirect implementation artifacts
- change project knowledge location

## Change language or communication defaults

Prefer module `config.yaml` values such as:

- `communication_language`
- `document_output_language`
- `user_name`

This is usually safer than editing every agent prompt.

## Customize an agent persona or behavior

Prefer `_bmad/_config/agents/*.customize.yaml`.

That layer supports:

- override agent name
- replace persona fields
- add critical actions
- add persistent memories
- append menu items
- add custom prompts

Use this first when the change is about local project behavior rather than
forking the installed agent definition.

## Add project-specific standards or style rules

Prefer `_bmad/_memory/`.

This is appropriate for:

- documentation standards
- recurring project conventions
- persistent local preferences

It is a better first move than copying the same rule into multiple workflows.

## Change workflow sequence or ceremony

This usually means editing installed workflow files under `_bmad/core/`,
`_bmad/bmm/`, or `_bmad/bmb/`.

Examples:

- change checklists
- adjust templates
- shorten a workflow
- alter step ordering

Do this only after confirming the change cannot be expressed by config,
customize files, or memory sidecars.

## Change routing or discovery behavior

Look at `_bmad/_config/bmad-help.csv` and related manifest CSVs.

This is the right area when the user wants to change:

- workflow discovery
- routing order
- output-location expectations
- workflow bindings to commands or agents

Treat CSV edits carefully because these files behave like runtime control data.

## Practical decision ladder

When a user asks to modify BMAD behavior, prefer this order:

1. module `config.yaml`
2. `_bmad/_config/agents/*.customize.yaml`
3. `_bmad/_memory/`
4. manifest CSVs
5. direct edits to installed workflow or agent files

The deeper you go, the more upgrade-fragile the customization becomes.
