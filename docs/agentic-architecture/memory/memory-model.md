# Layer: Memory

## Tiered Memory Model

This model separates working context from durable repository knowledge.

Memory supports execution continuity. It does not define persona, governance,
or skill definitions.

## Tiers

### Tier 0: Ephemeral reasoning
Transient internal reasoning while interpreting a step.

**Belongs here**
- short-lived thought chains,
- immediate comparisons/options,
- tentative interpretation before externalization.

**Does not belong here**
- facts that must be recoverable later,
- commands/paths needed by future steps.

Retention target: single step.

### Tier 1: Session memory (short-term working cache)
Structured notes for the current session.

**Belongs here**
- stable facts discovered this session,
- active hypotheses and validation status,
- important paths/commands,
- current risks, blockers, and next checkpoints.

Retention target: current session lifecycle.

### Tier 2: Repository memory (stable repository knowledge)
Durable, low-churn knowledge about how the repository works.

**Belongs here**
- stable architecture landmarks,
- canonical build/test workflows,
- persistent constraints and caveats,
- high-signal paths and entry points.

Retention target: multi-session until repository changes invalidate entries.

### Tier 3: Long-lived collaboration memory
Cross-session collaboration patterns and recurring operational learnings shared
across contributors or repeated engagements.

Tier 3 is **not** a catch-all for long-term behavior. It does not absorb
primary-agent identity/behavior, governance policy, skill definitions, or any
other contracts owned by other layers.

**Belongs here**
- recurring integration pitfalls,
- stable handoff conventions,
- repeated decision rationales with long-term value.

**Does not belong here**
- primary-agent identity, role, or operating behavior,
- governance rules, policy, or approval logic,
- skill definitions or skill-specific workflow contracts,
- ownership contracts already defined by other architecture layers.

Retention target: long horizon, reviewed periodically for relevance.

## Promotion Rules

### Ephemeral → Session
Promote when information is needed after the current micro-step.

Criteria:
- likely reused later in session,
- affects safety, correctness, or efficiency,
- externally observable (file, command result, constraint).

### Session → Repository
Promote only verified, low-volatility information.

Criteria:
- confirmed by authoritative sources or repeated observation,
- expected to remain valid across sessions,
- useful beyond the current task.

### Repository → Long-lived collaboration
Promote when knowledge repeatedly influences collaboration outcomes across
multiple sessions or contributors.

Criteria:
- high reuse frequency,
- clear operational impact,
- low dependence on transient task context.

## Proactive Memory Updates
Update memory at natural checkpoints:
- after bootstrap,
- after discovering a major constraint,
- after changing task direction,
- before handoff or session end.

When updating, prioritize signal over volume: record what changes decisions.

## Memory Hygiene and Pruning
- Remove stale hypotheses once resolved.
- Mark invalidated entries rather than silently overwriting when traceability
  matters.
- Keep repository memory concise; avoid task-specific noise.
- Periodically demote or delete entries that no longer match repository reality.
- Prefer linked references (paths/commands) over narrative repetition.

## Bootstrap Relationship
Bootstrap is the initialization path into this model:
- it creates first session-memory anchors,
- it determines what is known vs uncertain,
- it sets promotion candidates without prematurely making them durable.

A good bootstrap yields a clean Tier 1 state and a short candidate list for
Tier 2 promotion after verification.
