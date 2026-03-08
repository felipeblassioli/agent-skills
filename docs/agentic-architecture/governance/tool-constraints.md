# Governance Layer: Tool Constraints

This document defines **execution boundaries for tool usage** in repository work.
It complements existing governance sources (`AGENTS.md`, `.cursor/rules/`) by
providing a layer-level model for how tools should be constrained during task
execution.

## 1) Tool capability classes

### Read-only tools
Tools/actions that inspect state without changing files, history, or external
systems.

Typical examples:
- reading files, listing paths, searching text
- static analysis and dry-run inspections
- read-only browser inspection

Default posture: allowed as first step, but still scoped to the active task.

### Write-capable tools
Tools/actions that create, modify, or delete repository/external state.

Typical examples:
- editing files
- creating commits/branches/PR metadata
- running scripts that mutate generated artifacts

Default posture: allowed only after narrow investigation confirms necessity and
impact boundaries.

## 2) Side-effect boundaries

### Local side effects
Changes restricted to the working tree or local execution context.

Examples:
- markdown/code edits
- formatting outputs
- local cache/artifact generation

Constraint: prefer reversible operations and keep diffs minimal.

### External side effects
Changes outside the local repository/runtime.

Examples:
- opening/updating pull requests
- publishing/releasing/deploying
- API calls that mutate remote systems

Constraint: treat as higher control surface; require clear intent, explicit
scope, and stronger approval discipline.

## 3) Probe width: narrow vs broad impact

### Narrow probes (preferred default)
Targeted, low-blast-radius operations used to discover facts before acting.

Examples:
- inspect specific files/paths
- run focused checks
- patch only files directly in scope

### Broad-impact operations (controlled)
Operations with potentially wide or difficult-to-review effects.

Examples:
- repo-wide rewrites
- large generated changes
- mass file moves/renames

Constraint: run only when justified by task requirements and governance/risk
classification; document intent and expected impact before execution.

## 4) Approval-sensitive tool usage

Tool use should request explicit approval (or escalation path defined in
`approvals.md`) when any of the following is true:
- operation has external side effects,
- operation is high-risk or hard to reverse,
- operation scope is ambiguous or likely broader than requested,
- operation touches sensitive/security-relevant surfaces.

Low-risk, local, reversible operations may proceed under best-effort execution
if they remain within explicit task scope.

## 5) Relationship to existing governance sources

This file is a **governance-layer abstraction**, not a replacement for concrete
repository policy.

- `AGENTS.md` remains authoritative for repository-level operating constraints
  and workflow expectations.
- `.cursor/rules/` remains authoritative for rule-level behavioral constraints.
- This document maps those sources into a consistent tool-constraint model used
  across layered architecture docs.

## Non-goals

- Not a skill procedure manual.
- Not a primary-agent behavior profile.
- Not a complete restatement of repository policy sources.
