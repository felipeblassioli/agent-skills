---
name: agentic-artifact-discovery
version: "0.1.0"
description: Portable discovery pack for explicitly mapping agentic artifacts with a bundled workflow skill and a reusable exploration subagent.
---

# Agentic Artifact Discovery

`agentic-artifact-discovery` packages a narrow runtime workflow for inspecting
agentic systems without turning generic repository analysis into the default.

The pack combines two layers:

- a bundled installed skill for explicit discovery requests and final synthesis
- a reusable exploration subagent for low-cost inventory and classification

It is intentionally opinionated about scope:

- investigate agentic artifacts only
- classify before synthesizing
- keep the bundled skill compact
- avoid persistent rules, hooks, and MCP configuration in the first release

## Profiles

- `lite`: installs the bundled discovery workflow and the exploration subagent

## Target support

- `project-cursor`: installs into a repository's `.cursor/` directory
- `user-cursor`: installs into `~/.cursor/`

The pack is user-global-friendly, but it can also be installed at project scope
when a single repository needs a local copy of the workflow.

## Included runtime assets

- `.cursor/agents/agentic-system-explorer.md`
- bundled installed skill at `.cursor/skills/agentic-artifact-discovery-workflow/`
  or `~/.cursor/skills/agentic-artifact-discovery-workflow/`

## What the bundled skill covers

The bundled workflow skill is the main entry point when the user wants to:

- understand how a skill ecosystem fits together
- map workflows, roles, and trigger points in an agentic framework
- inspect a Claude-style plugin or mixed agentic bundle before migration work
- identify the use cases and confusing surfaces inside a complex agent setup

The skill stays explicit-invocation-only and pushes detailed heuristics into
one-hop references and report templates bundled alongside it.

## What the subagent covers

The `agentic-system-explorer` subagent exists to:

- inventory relevant files without flooding the parent context
- classify surfaces into skills, workflows, subagents, commands, MCP or config,
  docs, and support files
- extract evidence for trigger points, actor boundaries, and end-to-end flows
- return structured findings that the bundled skill can synthesize

## What this pack does not do

This pack does not own:

- generic repository mapping
- code review or debugging
- direct skill import or migration execution
- pack installation or sync workflows
- MCP trust review as a primary task

## Validation Evidence

Durable validation material lives outside the bundled runtime surfaces so the
installed skill and subagent stay small.

- `guides/verification-and-diagnosis.md`: narrative interpretation of the
  validation work
- `verification-outputs/`: curated scenario evidence for real targets such as
  `tmp/BMAD-METHOD`

## Release Artifacts

- [CHANGELOG.md](CHANGELOG.md)
- [VERIFICATION.md](VERIFICATION.md)
- [RELEASE-POLICY.md](RELEASE-POLICY.md)
- [ROADMAP.md](ROADMAP.md)
- [guides/verification-and-diagnosis.md](guides/verification-and-diagnosis.md)
- [verification-outputs/README.md](verification-outputs/README.md)
