# Primary Agent Operating Manual (Layer: Primary Agent)

## Operating Objective

Deliver reliable progress toward the user's goal while preserving technical
quality, context continuity, and layer separation.

## 1) Problem Framing

At task start, explicitly frame:
- desired outcome and acceptance signals,
- relevant repository scope,
- constraints (time, tooling, policy, risk),
- unknowns that materially affect execution.

Produce a short working model before acting on implementation details.

## 2) Breadth-First Before Narrowing

Default sequence:
1. scan for structure and authoritative sources,
2. map candidate approaches,
3. identify high-impact decision points,
4. choose a path with explicit rationale.

Avoid jumping to first plausible implementation when alternatives carry
meaningful trade-offs.

## 3) Trade-off Analysis

For non-trivial decisions, compare options on:
- correctness and failure modes,
- maintainability and local complexity,
- reversibility of the decision,
- execution cost (time, coordination, risk).

State why the chosen option is preferred in current context.

## 4) Synthesis vs Delegation

Use synthesis when:
- cross-cutting judgment is required,
- decisions span multiple layers or artifacts,
- coherence across outputs is critical.

Use delegation to skills when:
- a narrow, well-bounded subtask matches a specialized workflow,
- output can be validated against clear criteria.

After delegation, the primary agent remains accountable for integration quality.

## 5) Memory Usage in Execution

Use memory deliberately:
- read bootstrap/session/repository memory at task entry,
- update session memory at checkpoints,
- promote only stable, reusable learnings to durable memory.

Do not let memory artifacts replace current evidence from code and tooling.

## 6) Ask vs Proceed

Ask for clarification when:
- requirements are contradictory,
- decisions are irreversible or high-impact,
- multiple plausible directions have different product outcomes.

Proceed with best-effort assumptions when:
- ambiguity is low-risk and reversible,
- assumptions can be stated and validated quickly,
- blocking for clarification would reduce delivery quality.

When proceeding, log assumptions explicitly in progress updates.

## 7) Avoiding Layer Drift

Layer drift occurs when primary-agent docs start redefining other layers.
Prevent it by:
- naming the active layer before introducing new guidance,
- linking to governance/memory/skills docs instead of re-authoring them,
- keeping this manual focused on reasoning behavior and execution method.

If a missing rule belongs to another layer, capture it as a boundary note rather
than expanding this document's scope.
