---
name: model-recommender
description: >-
  Recommends which Claude model and effort level to run for a task. Classifies
  the task into an archetype → tier + effort using the rubric in
  ~/.claude/model-profiles.md, then resolves today's model string from that
  file's tier_to_model. Use when deciding which model to use, routing a task or
  phase to a model, picking an effort level, choosing between
  Opus/Sonnet/Haiku/Fable, or when a task spans plan/implement/review phases
  that each want a different model.
---

# model-recommender

> **Requires `~/.claude/model-profiles.md`.** This skill reads the routing
> rubric, tier→model table, and per-model profiles from that file at runtime. If
> it is absent, stop and ask the user to install it (see the prompt-kit README);
> never guess a model string from memory.

Turn a task description into a model + effort recommendation. Emit the durable
verdict (archetype + tier + effort) first, then resolve the model string. All
routing data lives in one file — this skill is procedure only. It states no
archetype definitions, no tier→model mapping, and no model strings of its own;
read them from the file each run so this and `prompt-audit` never disagree.

## Source of truth

`~/.claude/model-profiles.md`. It is prose plus fenced ```yaml blocks — parse
the yaml. The blocks this skill uses:

- `routing_rubric` — each archetype's `when` (how to classify), `tier`, and `effort`.
- `tier_to_model` — the tier → concrete model string. The only place a string lives.
- the per-model profiles (keyed by model, e.g. `opus-4.8`) — behavioral deltas.
- `meta.staleness_rule` — when to refresh a profile before trusting it.

If the file is missing, say so and stop — it is a hard dependency (install it at
`~/.claude/model-profiles.md`). Source every archetype, tier, effort, and model
value from the file.

## Procedure

1. **Parse** `~/.claude/model-profiles.md`.
2. **Classify** the task into one `routing_rubric` archetype by matching its
   `when`. If it's a mix, split it by phase (below) instead of averaging.
   `escalation` is reserved — pick it only when the task genuinely exceeds the
   deliberation tier's ceiling, never as a default for "hard."
3. **Take** that archetype's `tier` and `effort` from the rubric. This is the
   durable verdict — emit it even if the model table turns out stale. Where the
   rubric's `effort` carries a condition (e.g. "xhigh for coding/agentic"), apply
   it to this task.
4. **Apply `meta.staleness_rule`** to the profile for the resolved tier's model.
   If stale/missing, refresh per that rule before quoting nuances; if you cannot
   refresh, flag it stale.
5. **Resolve** the model string from `tier_to_model[tier]`. If the table is
   unreadable or the string can't be verified, emit the tier + effort and say
   the model string is unresolved — never guess one.
6. **Surface** the one or two profile deltas that change how to prompt this model
   for this task.

## Phased tasks

If the task spans phases, route each phase through the rubric independently and
emit one line per phase. `routing_rubric.deliberation.when` covers planning and
review/judgment; `execution.when` covers implementing a specified unit — so the
usual shape is plan → deliberation, implement → execution, review → deliberation.

## Output format

Single task:

```
Verdict: <archetype> → <tier> tier, effort <effort> — <one-line reason>
Model:   <tier_to_model[tier]>  (profile last_verified <date>[, STALE])
Prompt:  <1–2 profile deltas relevant to this task>
```

Phased task — one line per phase (`<archetype>, <effort> — <why> → <model>`).

## Rules

- Emit tier + effort for every recommendation; that is the durable part.
- Read the model string only from `tier_to_model`. When you can't verify it,
  stop at the tier and flag it — a guessed string is worse than none.
- One-line reason. Recommend one tier; skip the tiers you didn't pick.
