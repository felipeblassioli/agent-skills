# Installed BMAD Runtime Map

This guide explains the project-local BMAD surface after installation.

## Core idea

In an installed project, the authoritative BMAD runtime lives under `_bmad/`.
Thin loader skills elsewhere may point into `_bmad/`, but `_bmad/` is the
primary tree to inspect when explaining or customizing behavior.

## High-signal areas

### `_bmad/_config/`

This is the main control and discovery area.

Important files:

- `manifest.yaml`: installed modules, versions, source type, and enabled IDEs
- `bmad-help.csv`: master routing catalog for workflows, commands, and output
  locations
- `agent-manifest.csv`: maps agent identities to installed agent prompt files
- `workflow-manifest.csv`: index of workflow surfaces
- `task-manifest.csv`: index of task-like helper surfaces
- `files-manifest.csv`: useful for drift or integrity awareness after edits
- `agents/*.customize.yaml`: project-local agent override layer

### `_bmad/core/config.yaml`

Shared runtime config such as:

- `user_name`
- `communication_language`
- `document_output_language`
- `output_folder`

### `_bmad/bmm/config.yaml`

Planning and implementation-specific locations such as:

- `planning_artifacts`
- `implementation_artifacts`
- `project_knowledge`
- duplicated core communication settings

### `_bmad/bmb/config.yaml`

Builder-oriented configuration, especially where BMB-generated artifacts land.

### `_bmad/core/`, `_bmad/bmm/`, `_bmad/bmb/`

These contain the installed agents, workflows, tasks, templates, and supporting
instructions. Edit here only when safer override layers cannot express the
behavior change you need.

### `_bmad/_memory/`

Project-local sidecars for persistent standards and conventions. This is a good
place to influence policy or style without rewriting every workflow.

## Runtime interaction model

Think of the installed BMAD surface in layers:

1. config and manifests
2. agent or help entry surfaces
3. workflow and task files
4. generated artifacts in `_bmad-output/`

`bmad-help.csv` and related manifests often matter more than folder names
because they define how the runtime routes users.

Generated artifacts in `_bmad-output/` are useful for understanding what the
team has been doing, but they are not automatically authoritative runtime
control. Treat them as evidence unless the team has promoted the behavior into a
durable surface such as `_memory/`, `*.customize.yaml`, or a workflow/checklist.

## Practical reading order

When trying to understand installed BMAD in a project:

1. `manifest.yaml`
2. module `config.yaml`
3. `bmad-help.csv`
4. the relevant `_memory/` files for standing local doctrine
5. the relevant `*.customize.yaml`
6. the specific agent or workflow file the user wants to change
7. recent `_bmad-output/**` artifacts only if they are part of the question

## Common misunderstanding

Do not assume every visible markdown file is equally authoritative.

In installed BMAD:

- manifests and config files often define the active behavior
- agent files shape persona and menus
- workflow files shape execution order
- `_memory/` can shape project-local conventions
