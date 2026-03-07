# Layer: Memory

## Tiered Memory Model

This model separates working context from durable repository knowledge.

Memory is a decision-support system for repository execution continuity. It is
not an archive of everything observed, and it does not define persona,
governance, or skill definitions.

## Memory-Worthiness Rule
A fact is memory-worthy when it is likely to change future decisions by
improving safety, speed, or correctness.

Prefer storing facts that are:
- reusable across multiple steps/sessions,
- expensive or error-prone to rediscover,
- likely to shape planning, framing, handoff, or execution order.

Avoid storing facts that are:
- obvious from nearby files,
- one-off observations with no expected reuse,
- verbose logs, incidental outputs, or transient noise.

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
Cross-session shared conventions and recurring operational learnings that
consistently improve collaboration outcomes.

Tier 3 is **not** a catch-all long-term bucket. It does not absorb
primary-agent identity/behavior, governance policy, skill definitions, or other
layer-owned contracts.

**Belongs here**
- recurring integration pitfalls,
- stable handoff conventions,
- repeated decision rationales with long-term value,
- durable collaboration patterns that reduce repeated coordination overhead.

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
- useful beyond the current task,
- reduces repeated repo exploration.

### Repository → Long-lived collaboration
Promote when knowledge repeatedly influences collaboration outcomes across
multiple sessions or contributors.

Criteria:
- high reuse frequency,
- clear operational impact,
- low dependence on transient task context,
- improves recurring handoffs or planning quality.

## Proactive Update Checkpoints
Update memory without explicit request when new information changes decisions:
- after bootstrap, to lock initial navigation and constraints,
- after discovering a new blocker/constraint,
- after changing task direction or plan shape,
- after identifying a repeated lookup pattern (paths/commands/caveats),
- before handoff or session end.

Each update should answer: "What will this prevent us from re-discovering?"

## Operational Value Targets
Memory should actively improve:
- **Planning**: clearer next actions and dependencies.
- **Task framing**: better scoping from known constraints and landmarks.
- **Navigation**: faster return to key files/paths.
- **Handoff**: concise state transfer with less re-analysis.
- **Reuse**: repeated command/risk patterns captured once and reused.

## Memory Hygiene and Compactness
- Remove stale hypotheses once resolved.
- Mark invalidated entries rather than silently overwriting when traceability
  matters.
- Keep repository memory concise; avoid task-specific noise.
- Prune low-value entries that do not affect decisions.
- Prefer linked references (paths/commands) over narrative repetition.
- Periodically merge duplicate entries into a single higher-signal statement.

## Bootstrap Relationship
Bootstrap is the initialization path into this model:
- it creates first session-memory anchors,
- it determines what is known vs uncertain,
- it captures minimum facts needed to avoid duplicate exploration,
- it sets promotion candidates without prematurely making them durable.

A good bootstrap yields a clean Tier 1 state and a short candidate list for
Tier 2 promotion after verification.
