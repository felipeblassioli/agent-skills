# Validation Scenarios for the Documentation System

Purpose: verify that the architecture improves behavior through **less, more
relevant context**, not through broader document loading.

Use these scenarios on real tasks. Treat failures as retrieval-discipline
failures first, then capability failures.

## 1) Small scoped edit in Cursor

**What is being tested**
- Local-first execution for a low-risk, file-scoped change.

**Minimum docs expected**
- `docs/agentic-architecture/governance/risk-levels.md` (quick risk check)
- Optional only if needed: `docs/agentic-architecture/README.md`

**Docs that should not be loaded by default**
- `docs/agentic-architecture/ROADMAP.md`
- Multiple layer families unrelated to the edit

**Good behavior**
- Agent starts from task-local files, classifies risk quickly, executes one
  bounded change, and runs a focused check.

**Failure / context sprawl signs**
- Opens many architecture docs before touching target files.
- Expands into multi-layer analysis for a simple edit.
- Mirrors long doc excerpts into prompt or notes.

**Signal/output to observe**
- Explicit "local context first" trace, limited doc reads, small diff, focused
  validation command.

## 2) Repo exploration / cold-start in terminal mode

**What is being tested**
- Bootstrap usefulness for rapid orientation without repo wandering.

**Minimum docs expected**
- `docs/agentic-architecture/README.md`
- `docs/agentic-architecture/memory/bootstrap.md`
- `docs/agentic-architecture/memory/memory-model.md`

**Docs that should not be loaded by default**
- `docs/agentic-architecture/ROADMAP.md`
- All governance + primary-agent docs upfront without task signal

**Good behavior**
- Agent runs a lightweight bootstrap, identifies high-signal paths/commands,
  records decision-shaping memory, then proposes bounded next steps.

**Failure / context sprawl signs**
- Aimless repo scans with no checkpoint.
- Premature implementation before bootstrap exit condition.
- Memory filled with trivia instead of reusable anchors.

**Signal/output to observe**
- Bootstrap artifact: layer classification, key paths, stable commands,
  constraints/caveats, and next checkpoint.

## 3) Moderate-risk bounded write

**What is being tested**
- Whether governance changes execution behavior when risk increases.

**Minimum docs expected**
- `docs/agentic-architecture/governance/risk-levels.md`
- `docs/agentic-architecture/governance/approvals.md`
- `docs/agentic-architecture/governance/tool-constraints.md`

**Docs that should not be loaded by default**
- Full memory family unless continuity issues require it
- Broad architecture docs unrelated to the write boundary

**Good behavior**
- Agent labels risk as moderate, surfaces approval/checkpoint language,
  narrows write scope first, then validates result.

**Failure / context sprawl signs**
- Treats write as routine low risk.
- No explicit approval/escalation checkpoint.
- Broad-impact operations before narrowing.

**Signal/output to observe**
- Progress update includes risk class, approval status, bounded plan, and
  post-write verification.

## 4) Ambiguous task that requires narrowing

**What is being tested**
- Explicit narrowing discipline and prevention of default overreach.

**Minimum docs expected**
- `docs/agentic-architecture/primary-agent/operating-manual.md`
- `docs/agentic-architecture/README.md`

**Docs that should not be loaded by default**
- Multiple layer docs before clarifying task intent
- Governance deep-dive unless risk is already elevated

**Good behavior**
- Agent states 2-3 plausible interpretations, narrows with assumptions or
  questions, selects one bounded path, and documents why.

**Failure / context sprawl signs**
- Commits to one interpretation without framing uncertainty.
- Drifts across layers without justification.
- Starts implementation while task meaning is still unstable.

**Signal/output to observe**
- Narrowing note with chosen interpretation, rejected alternatives, and
  immediate bounded next action.

## 5) Handoff / continuation using memory

**What is being tested**
- Whether memory reduces repeated work and supports clean reintegration.

**Minimum docs expected**
- `docs/agentic-architecture/memory/proactive-memory-practices.md`
- `docs/agentic-architecture/memory/session-memory-template.md`
- `docs/agentic-architecture/memory/repository-memory-template.md`

**Docs that should not be loaded by default**
- Full architecture corpus during handoff drafting
- Governance docs unless handoff includes unresolved risk actions

**Good behavior**
- Handoff captures only reusable decision-shaping state: current focus,
  constraints, paths/commands, open risks, next checkpoint.

**Failure / context sprawl signs**
- Bloated handoff with raw logs and redundant chronology.
- Missing key constraints causing rediscovery next session.
- No explicit "resume here" instruction.

**Signal/output to observe**
- Compact continuation package that allows a follow-up agent to act without
  broad rediscovery.

## Cross-scenario pass/fail criteria

A scenario passes only if:
- the agent used the **minimum relevant docs**,
- avoided default loading of unrelated document families,
- stopped retrieval when the next safe step became clear,
- and produced a bounded, testable action plan.

If behavior improves only after reading many docs, treat that as architecture
noise, not success.
