# Layer: Memory

## Bootstrap Protocol (Cold Start)

## Purpose
Bootstrap is the minimum process an agent runs at session start to build enough
repository context to execute safely and efficiently.

Bootstrap initializes memory. It does **not** attempt to fully solve the active
task or pre-read the entire codebase.

## Exit Condition
Bootstrap is complete when the agent can provide a short, operational summary
containing:
- current goal as understood,
- relevant repository areas,
- immediate risks/constraints,
- first execution steps.

If this summary cannot be produced with confidence, bootstrap is not complete.

## Phased Flow

### Phase 0 — Confirm mission and constraints
- Parse the request and identify explicit scope boundaries.
- Classify the active task by layer before deeper reading:
  - primary agent,
  - memory,
  - governance,
  - skills,
  - repository architecture.
- Mark one primary layer and any secondary layers to guide reading priority.
- Identify environment constraints (tooling, permissions, branch state).
- Record unknowns that can block safe progress.

### Phase 1 — Repository orientation
- Identify top-level structure and key entry docs.
- Locate authoritative instructions (for example: `AGENTS.md`, local rules,
  contribution or workflow docs).
- Detect project type(s): scripts, packages, build systems, and docs ownership.

### Phase 2 — Task-relevant narrowing
- Select only the subtrees and files needed for the current task slice.
- Build a quick map of relevant paths, commands, and dependencies.
- Avoid broad scans not tied to the immediate objective.

### Phase 3 — Memory initialization
- Write session memory with stable facts, hypotheses, paths, and open questions.
- Capture durable facts for repository memory only when confidence is high.
- Mark assumptions explicitly to prevent accidental promotion to durable memory.

### Phase 4 — Ready-to-execute handoff
- Produce a short “bootstrap deliverable” (see below).
- Start implementation only after this deliverable is coherent.

## Recommended Reading Order
1. Request / trigger context.
2. Repository-level instructions (`AGENTS.md`, contribution docs, scripts docs).
3. Architecture entry docs for the relevant area (for example
   `docs/agentic-architecture/README.md` and targeted layer docs).
4. Task-specific files and nearby implementation context.

Read breadth-first first, then depth-first only in relevant zones.

## Safe Terminal Usage During Bootstrap
- Prefer read-only commands first (`pwd`, `git status`, targeted `rg`, `sed`).
- Avoid destructive or wide-impact commands during orientation.
- Avoid expensive full-repo traversal when a targeted query is sufficient.
- Validate assumptions with small probes before running build/test pipelines.
- Track every command that yields durable insight in session memory.

## Selective Browser Usage
Use browser tooling only when it materially improves repository understanding,
for example:
- validating behavior of a running app tied to the task,
- confirming UI flow context before editing UI files,
- checking local docs rendering when markdown/site output matters.

Do not browse as a default bootstrap step when terminal and code inspection are
sufficient.

## Bootstrap Deliverable
At bootstrap completion, produce a compact note with:
- **Goal snapshot**: interpreted task and in-scope boundaries.
- **Relevant map**: key files/dirs and why they matter.
- **Constraints**: tooling/rules/risks affecting execution.
- **Immediate plan**: first 2–4 concrete actions.
- **Open questions**: unresolved items requiring validation.

This note becomes the first anchor for session memory.

## Anti-patterns
- Treating bootstrap as full implementation.
- Reading everything before reading what matters.
- Promoting guesses to durable memory without verification.
- Mixing policy redesign or persona definition into memory bootstrap.
- Running broad writes or cleanup before understanding repository norms.
