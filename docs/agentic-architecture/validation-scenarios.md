# Validation Scenarios for the Documentation System

Purpose: evaluate whether the current architecture docs improve real agent
behavior in day-to-day repository work.

Use these as lightweight scenario checks, not formal benchmark suites.

## 1) Small scoped edit in Cursor

**What is being tested**
- Fast layer routing and minimal context loading for a low-risk local change.

**Docs expected to be used**
- `docs/agentic-architecture/README.md`
- `docs/agentic-architecture/governance/risk-levels.md`
- Optional: `docs/agentic-architecture/memory/session-memory-template.md`

**Good behavior**
- Agent classifies task quickly, loads only needed docs, edits target files,
  runs a narrow check, and reports succinctly.

**Failure behavior**
- Agent loads multiple unrelated layer docs, over-explores the repo, or adds
  unnecessary process overhead for a small change.

**Signal/output to observe**
- Short execution trace with explicit layer classification, limited files
  touched, and one focused validation command.

## 2) Repo exploration / cold-start in terminal mode

**What is being tested**
- Bootstrap quality, bounded exploration, and early memory initialization.

**Docs expected to be used**
- `docs/agentic-architecture/memory/bootstrap.md`
- `docs/agentic-architecture/repository-architecture/navigation.md`
- `docs/agentic-architecture/memory/memory-model.md`

**Good behavior**
- Agent follows phased bootstrap, identifies high-signal paths/commands, stores
  compact session memory, and avoids broad indexing.

**Failure behavior**
- Agent performs large unfocused scans, captures trivia, or starts implementing
  before finishing minimal bootstrap.

**Signal/output to observe**
- A concise bootstrap deliverable: primary layer guess, key paths, stable
  commands, risks, and open questions.

## 3) Moderate-risk bounded write

**What is being tested**
- Governance-aware execution for reversible writes with clear boundaries.

**Docs expected to be used**
- `docs/agentic-architecture/governance/risk-levels.md`
- `docs/agentic-architecture/governance/approvals.md`
- `docs/agentic-architecture/governance/tool-constraints.md`

**Good behavior**
- Agent identifies moderate risk, states assumptions, confirms approval posture,
  performs limited writes, and validates outcomes.

**Failure behavior**
- Agent treats write as low-risk by default, skips approval checkpoint language,
  or executes broad-impact commands without narrowing.

**Signal/output to observe**
- Progress update showing risk class, approval/escalation status, bounded
  operation plan, and post-change verification.

## 4) Ambiguous task that requires narrowing

**What is being tested**
- Problem framing discipline and layer-drift prevention under uncertainty.

**Docs expected to be used**
- `docs/agentic-architecture/primary-agent/operating-manual.md`
- `docs/agentic-architecture/README.md`
- Optional: `docs/agentic-architecture/repository-architecture/ai-doc-index.md`

**Good behavior**
- Agent proposes 2–3 plausible interpretations, narrows scope with explicit
  assumptions/questions, and avoids premature broad execution.

**Failure behavior**
- Agent commits to one interpretation without framing uncertainty, or drifts
  into unrelated layers/docs.

**Signal/output to observe**
- Clear narrowing note: chosen interpretation, rejected alternatives, and why.

## 5) Handoff / continuation using memory

**What is being tested**
- Continuity quality across sessions and delegation/reintegration readiness.

**Docs expected to be used**
- `docs/agentic-architecture/memory/proactive-memory-practices.md`
- `docs/agentic-architecture/memory/session-memory-template.md`
- `docs/agentic-architecture/memory/repository-memory-template.md`

**Good behavior**
- Agent records decision-shaping facts, unresolved questions, and next
  checkpoints so a follow-up can resume without rediscovery.

**Failure behavior**
- Handoff is either too sparse (missing key constraints) or bloated with raw
  logs and low-value detail.

**Signal/output to observe**
- Handoff artifact with reusable paths/commands, current task focus,
  assumptions, risks, and immediate next action.

## How to run this guide in practice

- Pick a real PR task matching one scenario.
- Check whether observed behavior matches “good behavior” and signal criteria.
- Record one improvement note per scenario failure (do not redesign layers in
  this pass).

If repeated failures cluster in one layer, refine that layer docs before adding
new architecture surface.
