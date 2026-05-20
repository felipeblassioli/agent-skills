# Agent Reference

This document catalogs the Cursor subagents maintained in this repository's
installable Cursor packs.

Cursor pack manifests remain the source of truth for install behavior. This file
is only the agent catalog; pack discovery and installation live in
[`docs/cursor-packs.md`](./cursor-packs.md).

## Overview

This repository currently maintains **11 tracked Cursor pack agents** across
**5 packs**:

- **1 discovery agent** for exploring agentic artifact systems.
- **3 companion auditors** for Cursor setup, hook policy, and MCP configuration.
- **4 skill-creator agents** for intake, grading, comparison, and result
  analysis.
- **1 GCP log investigation agent**.
- **2 Node test-verifier agents**.

Most agents are read-only and optimized for bounded inspection so the parent
agent can keep its context focused on synthesis and decisions.

## Agent Files

```text
packs/<pack>/.cursor/agents/<agent>.md
```

Agent files use frontmatter to describe routing and execution constraints:

```yaml
---
name: agent-name
description: Use when ...
model: fast
readonly: true
background: false
---
```

Common fields:

- `name`: stable subagent identifier.
- `description`: activation and delegation criteria.
- `model`: model tier hint when the pack wants a cheaper or specialized agent.
- `readonly`: whether the agent should inspect rather than edit.
- `background`: whether the agent is suitable for async background execution.

## Agents by Pack

### Agentic Artifact Discovery

The `agentic-artifact-discovery` pack provides a cheap exploration agent for
understanding unfamiliar skill systems, workflow frameworks, subagent bundles,
and Claude-style plugins before the parent agent synthesizes findings.

| Agent | Model | Mode | Description |
| --- | --- | --- | --- |
| [`agentic-system-explorer`](../packs/agentic-artifact-discovery/.cursor/agents/agentic-system-explorer.md) | fast | read-only, foreground | Inventories and classifies agentic systems, extracting trigger, flow, artifact, and boundary evidence before synthesis. |

### Cursor Companion

The `cursor-companion` pack provides auditors for Cursor runtime setup. Use these
agents when reviewing installed `.cursor` assets, hook behavior, or MCP
configuration safety.

| Agent | Model | Mode | Description |
| --- | --- | --- | --- |
| [`cursor-pack-auditor`](../packs/cursor-companion/.cursor/agents/cursor-pack-auditor.md) | fast | read-only | Audits a project's Cursor setup for missing or conflicting subagents, rules, hooks, or MCP configuration. |
| [`hook-policy-reviewer`](../packs/cursor-companion/.cursor/agents/hook-policy-reviewer.md) | fast | read-only | Reviews Cursor hook policies, command blocking behavior, file-read protection, and lifecycle guardrails. |
| [`mcp-config-reviewer`](../packs/cursor-companion/.cursor/agents/mcp-config-reviewer.md) | fast | read-only | Reviews MCP server trust boundaries, environment interpolation, portability, and safe installation practices. |

### Cursor Skill Studio

The `cursor-skill-studio` pack (renamed from `cursor-skill-creator` in
0.3.0) provides helper and audit agents that back the three studio
bundled skills (`skill-studio-write`, `skill-studio-audit`,
`skill-studio-maintain`). The helpers below adapt source material into
Cursor-native skills and packs, then evaluate the outputs with bounded
evidence.

| Agent | Model | Mode | Description |
| --- | --- | --- | --- |
| [`skill-creator-bootstrapper`](../packs/cursor-skill-studio/.cursor/agents/skill-creator-bootstrapper.md) | fast | read-only | Classifies source trees and recommends the smallest correct artifact matrix before scaffolding a pack or bundled skill. |
| [`skill-creator-grader`](../packs/cursor-skill-studio/.cursor/agents/skill-creator-grader.md) | fast | read-only | Grades eval outputs against explicit expectations and records evidence in a structured grading result. |
| [`skill-creator-comparator`](../packs/cursor-skill-studio/.cursor/agents/skill-creator-comparator.md) | fast | read-only | Compares two candidate outputs blindly without inferring which skill or pack variant produced them. |
| [`skill-creator-analyzer`](../packs/cursor-skill-studio/.cursor/agents/skill-creator-analyzer.md) | fast | read-only | Analyzes benchmark or comparison results to identify patterns, interpretation, follow-up changes, and residual risks. |
| [`skill-creator-structural-auditor`](../packs/cursor-skill-studio/.cursor/agents/skill-creator-structural-auditor.md) | fast | read-only | Audits a candidate skill against the structural authoring contract before promotion. |
| [`skill-overlap-clusterer`](../packs/cursor-skill-studio/.cursor/agents/skill-overlap-clusterer.md) | fast | read-only | Backs `/skill-studio-audit` Branch C — clusters skills by overlap signal across installed surfaces. |
| [`skill-architecture-checker`](../packs/cursor-skill-studio/.cursor/agents/skill-architecture-checker.md) | fast | read-only | Backs `/skill-studio-audit` Branch C — validates installed skills against the pack/skill architecture contract. |
| [`skill-consolidation-advisor`](../packs/cursor-skill-studio/.cursor/agents/skill-consolidation-advisor.md) | fast | read-only | Backs `/skill-studio-audit` Branch C — recommends consolidation moves based on the clusterer and checker output. |

### GCP Log Investigation

The `gcp-log-investigation` pack provides a production-safe log reader for Google
Cloud workloads.

| Agent | Model | Mode | Description |
| --- | --- | --- | --- |
| [`log-reader`](../packs/gcp-log-investigation/.cursor/agents/log-reader.md) | composer-2 | read-only, foreground | Reads and analyzes Google Cloud application logs with discovery-first querying, trace correlation, redaction, and concise summaries. |

### Node Test Verifier

The `node-test-verifier` pack provides agents for adapting and running low-noise
Node/Jest verification workflows.

| Agent | Model | Mode | Description |
| --- | --- | --- | --- |
| [`test-verifier-bootstrapper`](../packs/node-test-verifier/.cursor/agents/test-verifier-bootstrapper.md) | inherited | foreground | Inspects a Node/Jest repository and creates or updates a repo-local verifier contract for later test runs. |
| [`test-verifier`](../packs/node-test-verifier/.cursor/agents/test-verifier.md) | inherited | read-only, foreground | Runs tier-aware Node and Jest verification with prerequisite checks, pass-fail-first summaries, and durable failure evidence. |

## When to Use Each Agent

| Task | Recommended agent |
| --- | --- |
| Explore an unfamiliar skill, workflow, or plugin-like source tree | `agentic-system-explorer` |
| Audit installed Cursor runtime assets in a project | `cursor-pack-auditor` |
| Review hook policy or blocking behavior | `hook-policy-reviewer` |
| Review MCP server safety and portability | `mcp-config-reviewer` |
| Classify source material before creating a skill or pack | `skill-creator-bootstrapper` |
| Grade an eval output against expectations | `skill-creator-grader` |
| Blind-compare two candidate outputs | `skill-creator-comparator` |
| Interpret benchmark or comparison results | `skill-creator-analyzer` |
| Investigate Google Cloud application logs | `log-reader` |
| Adapt the test-verifier pack to a Node/Jest repository | `test-verifier-bootstrapper` |
| Run low-noise Node/Jest verification | `test-verifier` |

## Model and Execution Strategy

The pack agents favor cheaper, bounded delegation:

- **Fast read-only agents** handle inventory, classification, audits, grading, and
  comparison.
- **Foreground agents** are used when results should return directly to the
  parent before the next decision.
- **Inherited-model agents** defer model selection where repository-specific
  verification may need the caller's current execution context.

Use the primary agent for final synthesis, trade-off decisions, and edits. Use
pack agents for narrow evidence gathering, noisy verification, or specialist
audits.

## Related Documents

- [Cursor Pack Catalog](./cursor-packs.md)
- [Cursor Pack Specification](./specs/cursor-pack-specification.md)
- [Agentic Skill and Pack Authoring Specification](./specs/agentic-skill-pack-authoring.md)
- [Pack Authoring Checklist](./specs/pack-authoring-checklist.md)
