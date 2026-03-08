# Validation Scenarios for the Documentation System

Purpose: verify behavior improvement through **less, more relevant context**,
not through broad doc loading.

Use these scenarios as adversarial checks for retrieval discipline.

## 1) Small scoped edit in Cursor

**What is being tested**
- Local-first execution in IDE mode for a low-risk, file-scoped change.

**Minimum docs expected**
- Usually none beyond local files.
- Optional quick check: `docs/agentic-architecture/governance/risk-levels.md`.

**Docs that should not be loaded by default**
- `docs/agentic-architecture/ROADMAP.md`.
- Memory/governance/primary-agent families beyond the immediate need.

**Why this should work if architecture helps**
- Routing discipline should keep work in file-local context and prevent
  over-processing for small edits.

**How it fails if architecture is used poorly**
- Agent preloads architecture docs before touching target files.
- Agent expands into multi-layer analysis for a simple local change.

**Signs of context sprawl / retrieval failure**
- Many doc reads, little code-local inspection.
- Large prompt notes with copied architecture content.

**Signal/output to observe**
- Small diff, focused validation command, explicit local-first trace.

## 2) Repo exploration / cold-start in terminal mode

**What is being tested**
- Whether bootstrap reduces search entropy and repo wandering.

**Minimum docs expected**
- `docs/agentic-architecture/README.md`.
- `docs/agentic-architecture/memory/bootstrap.md`.
- `docs/agentic-architecture/memory/memory-model.md`.

**Docs that should not be loaded by default**
- `docs/agentic-architecture/ROADMAP.md`.
- Unrelated layer docs before task routing is clear.

**Why this should work if architecture helps**
- Bootstrap should produce high-signal paths/commands quickly and constrain
  exploration with checkpoints.

**How it fails if architecture is used poorly**
- Agent performs broad tree sweeps without a checkpoint or hypothesis.
- Agent starts implementation before bootstrap exit condition is met.

**Signs of context sprawl / retrieval failure**
- Long command history with no reusable summary.
- Memory captures trivia instead of decision-shaping anchors.

**Signal/output to observe**
- Compact bootstrap artifact: likely primary/secondary layers, key paths,
  stable commands, constraints, next checkpoint.

## 3) Moderate-risk bounded write

**What is being tested**
- Whether governance visibly changes behavior when risk increases.

**Minimum docs expected**
- `docs/agentic-architecture/governance/risk-levels.md`.
- `docs/agentic-architecture/governance/approvals.md`.
- `docs/agentic-architecture/governance/tool-constraints.md`.

**Docs that should not be loaded by default**
- Full architecture set unrelated to the write boundary.
- Full memory set unless continuity/handoff is required.

**Why this should work if architecture helps**
- Risk classification should force explicit checkpoints and narrower operations.

**How it fails if architecture is used poorly**
- Agent treats moderate-risk write as routine low-risk work.
- Agent performs broad-impact operations before narrowing or approvals.

**Signs of context sprawl / retrieval failure**
- No explicit risk label.
- No approval status in progress updates.

**Signal/output to observe**
- Progress note includes risk class, approval/checkpoint state, bounded write
  plan, and post-write verification.

## 4) Ambiguous task that requires narrowing

**What is being tested**
- Whether routing reduces overreach when intent is unclear.

**Minimum docs expected**
- `docs/agentic-architecture/primary-agent/operating-manual.md`.
- `docs/agentic-architecture/README.md` (for layer routing boundaries).

**Docs that should not be loaded by default**
- Multiple layer docs before forming explicit interpretations.
- Governance deep dive unless risk is already elevated.

**Why this should work if architecture helps**
- Layer routing + narrowing discipline should produce a bounded hypothesis
  before execution.

**How it fails if architecture is used poorly**
- Agent jumps to implementation without clarifying ambiguity.
- Agent drifts across layers without justification.

**Signs of context sprawl / retrieval failure**
- Many docs loaded while task meaning remains undefined.
- No written rationale for chosen interpretation.

**Signal/output to observe**
- Short narrowing record: candidate interpretations, chosen path, rejected
  alternatives, next bounded step.

## 5) Handoff / continuation using memory

**What is being tested**
- Whether memory reduces repeated exploration and enables clean reintegration.

**Minimum docs expected**
- `docs/agentic-architecture/memory/proactive-memory-practices.md`.
- `docs/agentic-architecture/memory/session-memory-template.md`.
- `docs/agentic-architecture/memory/repository-memory-template.md`.

**Docs that should not be loaded by default**
- Full architecture corpus while drafting handoff.
- Governance docs unless unresolved risk actions must be handed off.

**Why this should work if architecture helps**
- Selective memory should preserve decision-shaping state and avoid rediscovery.

**How it fails if architecture is used poorly**
- Handoff is bloated with raw logs or missing key reusable constraints.
- Follow-up agent must re-explore basic paths/commands.

**Signs of context sprawl / retrieval failure**
- Large chronology dump, weak “resume here” guidance.
- Missing stable commands, risk notes, or next checkpoint.

**Signal/output to observe**
- Compact continuation package that allows immediate next action with minimal
  rediscovery.

## Cross-scenario pass criteria

A scenario passes only if:
- unnecessary layer docs were not loaded,
- routing reduced search entropy,
- bootstrap (terminal mode) reduced repo wandering,
- memory reduced repeated exploration,
- governance changed behavior when risk increased,
- architecture docs improved retrieval discipline instead of adding noise.
