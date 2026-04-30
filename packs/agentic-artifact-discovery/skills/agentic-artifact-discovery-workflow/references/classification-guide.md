# Classification Guide

Use this guide when the target shape is not obvious from the path name alone.

## System-shape labels

Choose one primary label:

- `skill-system`: mostly reusable skill guidance with related metadata,
  references, or supporting scripts
- `workflow-system`: mostly staged procedures, orchestration loops, or role-based
  process flows
- `plugin-bundle`: plugin-shaped package with manifests, commands, integrations,
  and mixed guidance
- `mixed-agentic-system`: two or more of the above are first-class surfaces

## Artifact categories

Use these categories consistently in reports:

- `skills`: `SKILL.md`, skill metadata, skill-local references or assets
- `workflow`: staged process docs, execution loops, plan flows, or command
  sequences
- `subagent`: dedicated helper role prompts with bounded responsibilities
- `command`: explicit slash-command entry points or command-like prompts
- `mcp-config`: `.mcp.json`, connector manifests, example config, or integration
  declarations
- `docs`: READMEs, concept docs, guides, and human-facing explanations
- `support`: scripts, validators, build files, tests, metadata, and generators

## Cheap-first reading order

Start from the highest-signal surfaces:

1. top-level README or overview doc
2. manifests such as `plugin.json`, `.mcp.json`, `pack.json`, or metadata files
3. `SKILL.md` and subagent prompt files
4. workflow docs and command definitions
5. support scripts and tests only when they clarify the main flow

## Flow extraction heuristics

Look for evidence of:

- entry points a user or parent agent triggers directly
- helper surfaces that run only after a primary surface
- transitions between planning, execution, review, and verification
- boundaries between guidance, runtime capability, and support code

## Ambiguity signals

Flag ambiguity when:

- one file appears to own multiple unrelated jobs
- commands, skills, and subagents overlap without clear routing
- docs promise behavior that runtime artifacts do not clearly support
- the artifact mixes migration, discovery, and implementation into one surface

## Anti-drift check

Stop and restate the boundary if the investigation starts drifting into:

- generic repository mapping
- implementation review
- bug diagnosis
- import or migration execution
