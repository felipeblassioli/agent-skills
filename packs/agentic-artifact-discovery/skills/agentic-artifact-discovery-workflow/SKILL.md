---
name: agentic-artifact-discovery-workflow
description: Use when explicitly investigating a skill system, workflow framework, subagent bundle, Claude-style plugin, or mixed agentic artifact to understand its roles, trigger points, flows, and use cases.
disable-model-invocation: true
---

# Agentic Artifact Discovery Workflow

Use this bundled skill to understand an agentic artifact without collapsing
discovery, migration, review, and generic repository mapping into one workflow.

## Use This Skill For

- understanding how a skill ecosystem fits together
- mapping workflows, roles, and trigger points in an agentic framework
- inspecting a Claude-style plugin or mixed agentic bundle before follow-on work
- identifying user-facing surfaces, helper surfaces, and use cases in a complex
  agent setup

Do not use this skill for:

- generic repository architecture mapping
- code review or bug hunting
- debugging runtime failures
- importing or migrating skills or packs
- installation or sync workflows
- MCP trust review as the primary task

## Core Model

- this skill is the explicit user-facing entry point
- the `agentic-system-explorer` subagent handles cheap inventory and
  classification first
- the parent workflow synthesizes the final explanation
- detailed heuristics live one hop away from the hot path

## Inputs Required

Minimum input:

- one or more target paths

Useful optional input:

- what is confusing about the system
- whether the focus is skills, workflows, plugins, or mixed artifacts
- whether the user wants a broad overview or a flow-focused explanation

## Workflow

1. Confirm the target path or paths.
2. Read [references/classification-guide.md](references/classification-guide.md)
   when the target shape is not obvious.
3. Delegate inventory and classification to the installed
   `agentic-system-explorer` subagent.
4. Read [references/report-shape.md](references/report-shape.md) before writing
   the final explanation.
5. Use [assets/templates/discovery-report.md](assets/templates/discovery-report.md)
   when a stable structured report is useful.
6. Synthesize:
   - artifact inventory
   - actor and role map
   - trigger and invocation matrix
   - flow narrative
   - use-case matrix
   - ambiguities and overloaded surfaces
   - recommended next step

## Routing

If the target looks like a skill tree or workflow framework:

- prioritize `SKILL.md`, agent prompts, workflow definitions, metadata, and
  supporting docs

If the target looks like a Claude-style plugin:

- prioritize `.claude-plugin/plugin.json`, `.mcp.json`, top-level README files,
  command descriptions, and skill-like folders

If the target mixes several agentic surfaces:

- classify it as `mixed-agentic-system`
- explain the major surfaces separately before connecting them into one flow

## Bundled Resources

- `references/classification-guide.md`: artifact taxonomy and discovery heuristics
- `references/report-shape.md`: expected final output shape
- `assets/templates/discovery-report.md`: reusable structured report template

## Common Mistakes

- treating generic repository structure as the primary story
- skipping classification and jumping straight to a narrative
- mixing discovery with migration recommendations too early
- over-reading support code before confirming the main user-facing surfaces
- ignoring anti-triggers and letting the workflow drift into review or debugging
