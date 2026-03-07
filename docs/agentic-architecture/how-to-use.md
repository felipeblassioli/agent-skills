# How to Use This Documentation System

Purpose: apply the current architecture docs with minimal context and clear
layer routing, so work stays focused and avoids document sprawl.

## Start rule (all modes)

1. Classify the task by **primary layer** (primary agent, memory, governance,
   skills, repository architecture).
2. Load only that layer’s core document(s) first.
3. Add one secondary layer only if the task demands it.
4. Stop loading docs once you have enough to execute safely.

If a task can be completed with local code context + one layer doc, do not load
more architecture files.

## A) Using within Cursor / IDE agent

Use this mode for local, scoped edits where code context is already visible.

### Fast routing sequence

1. Identify task type from the prompt:
   - **Behavior/collaboration choice** → `primary-agent/*`
   - **Context retention/reuse** → `memory/*`
   - **Risk/approval/tool limits** → `governance/*`
   - **Delegating to a specialized capability** → `skills/*`
   - **Finding where things live in repo** → `repository-architecture/*`
2. Read at most one doc family deeply at first.
3. Open code paths directly related to the requested change.

### Most useful docs for local/scoped work

- `governance/risk-levels.md` and `governance/approvals.md` before any
  moderate/high-impact change.
- `memory/session-memory-template.md` for in-session continuity on multi-step
  edits.
- `repository-architecture/navigation.md` only when file discovery is unclear.

### When **not** to load more docs

Do not broaden context when:
- the request is a small file edit with clear acceptance criteria,
- risk level is low and no approval boundary is crossed,
- existing open files already provide enough implementation context.

### Avoiding context noise in IDE mode

- Prefer file-level excerpts over opening full architecture sets.
- Treat architecture docs as routing + constraints, not reading backlog.
- Keep temporary notes in session memory; do not mirror entire docs into prompt.

## B) Using an autonomous/terminal agent

Use this mode for repository exploration, multi-step execution, and bounded
changes where the agent must self-route.

### Bootstrap sequence (lightweight)

1. Read `docs/agentic-architecture/README.md` for layer boundaries.
2. Classify primary/secondary layers for the active task.
3. Read the minimum layer docs needed:
   - memory-heavy start: `memory/bootstrap.md`, `memory/memory-model.md`
   - execution safety: `governance/risk-levels.md`, `governance/approvals.md`
   - discovery: `repository-architecture/ai-doc-index.md` or `navigation.md`
4. Initialize compact session memory (facts, paths, commands, risks, open
   questions).
5. Begin bounded exploration (narrow probes before broad operations).

### Memory + governance used together

- Use memory to track decision-shaping facts (stable paths, commands,
  constraints, caveats).
- Use governance to decide what can run now vs what needs approval/escalation.
- At each checkpoint: update memory if new facts change decisions, then verify
  risk/approval status before next action.

### Docs to read before broader execution

Before significant repo actions, confirm:
- memory update discipline (`memory/proactive-memory-practices.md`),
- approval thresholds (`governance/approvals.md`),
- impact class (`governance/risk-levels.md`).

### Keeping context relevant (without loading everything)

- Load docs by decision need, not by folder completeness.
- Prefer short summaries in working memory over repeated re-reading.
- Promote only reusable facts to repository memory; leave trivia out.

### How current docs support bounded exploration

- Layer boundaries prevent drift across identity/memory/governance/skills.
- Memory docs reduce repeated lookups during navigation and handoff.
- Governance docs constrain tool usage and approval handling.
- Repository architecture docs provide faster entry points for cold starts.

## Practical usage pattern (both modes)

1. Route by layer.
2. Load minimum docs.
3. Execute smallest safe step.
4. Record only reusable, decision-shaping memory.
5. Re-check risk/approval before expanding scope.

This keeps execution efficient while preserving continuity and control.
