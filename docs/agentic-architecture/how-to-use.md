# How to Use This Documentation System

Purpose: route quickly, load less context, and execute safely with only the docs
that matter for the current task.

## Core routing rule (all modes)

Treat layer classification as a **working routing hypothesis**:

1. Identify the **likely primary layer**.
2. Note any **secondary layer(s)** that may matter.
3. Load only the minimum docs needed for the primary layer first.
4. Reclassify if local evidence points elsewhere.

Classification is not permanent truth and is not one-layer-only. It is a way to
decide what to read first.

Architecture docs are for routing/constraints, not default reading.

## Code navigation strategy (operational)

1. Start from the requested task and nearest relevant file(s), not broad repo
   exploration.
2. Inspect local code, tests, and adjacent files first.
3. Widen only when local evidence is insufficient to explain behavior.
4. Widen deliberately to high-signal control surfaces: nearby config, scripts,
   tests, workspace/build files.
5. Use architecture docs to resolve routing or constraints, not as the first
   stop for every task.
6. Persist only decision-shaping memory (paths, commands, constraints, caveats)
   that prevents repeated lookup.

Local-first does **not** mean local-only forever. It means widen by evidence,
not by habit.

## A) Cursor / IDE mode

Default stance: highly local, reactive, file-local context dominates.

### Expected behavior

- Start from open/target files and task-local diffs.
- Use architecture docs only when local context does not clarify routing,
  risk, or ownership.
- Avoid bootstrap-style broad exploration by default.
- Stop doc loading once the next safe step is clear.

### Minimal doc loading pattern

- Low-risk local edit: usually no architecture docs or only a quick
  `governance/risk-levels.md` check.
- If risk/approval uncertainty appears: add `governance/approvals.md`.
- If continuity across multiple steps is needed: add
  `memory/session-memory-template.md`.
- If layer ownership is unclear: consult `docs/agentic-architecture/README.md`.

Broad architecture loading in IDE mode is usually a failure mode.

## B) Terminal / autonomous mode

Default stance: broader exploration is allowed, but must be bounded and
selective.

### Expected behavior

1. Run lightweight bootstrap (`memory/bootstrap.md`).
2. Classify likely primary/secondary layers and load only relevant docs.
3. Initialize compact memory anchors for reuse.
4. Use governance (`governance/risk-levels.md`, `governance/approvals.md`) as
   execution gates when risk increases.
5. Explore broadly only with explicit checkpoints; avoid aimless wandering.

### Bounded exploration pattern

- Start with narrow probes.
- Expand only when blockers persist.
- Record reusable findings once.
- Re-check risk before any broader or write-capable action.

## What not to do

- Do not load `ROADMAP.md` by default for ordinary task execution.
- Do not load all layer docs “just in case.”
- Do not turn small edits into architecture exercises.
- Do not mirror full docs into prompts when a short local summary is enough.
- Do not treat initial layer classification as permanent truth.

## Practical loop (both modes)

1. Classify likely primary + secondary layers.
2. Load minimum relevant docs.
3. Execute smallest safe next step.
4. Store only decision-shaping facts.
5. Reclassify and widen only if new evidence requires it.
