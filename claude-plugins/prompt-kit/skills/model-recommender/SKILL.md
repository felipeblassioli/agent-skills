---
name: model-recommender
description: >-
  Decides WHERE a piece of work should run and on WHICH tier + effort — this
  session, a delegated subagent, or a fresh session — using the rubric and
  execution signals in ~/.claude/model-profiles.md, then resolves today's model
  string (for a session) or the Agent-tool model alias (for a subagent). Use when
  deciding which model to use, before delegating to a subagent or Task/Agent call,
  when picking an effort level, when choosing between Opus/Sonnet/Haiku/Fable, when
  a task spans plan/implement/review phases, or mid-run when asking whether to
  escalate, de-escalate, compact, hand off, or restart a session.
---

# model-recommender

> **Requires `~/.claude/model-profiles.md`.** This skill reads the routing rubric,
> execution signals, tier→model table, delegation aliases, and per-model profiles
> from that file at runtime. If it is absent, stop and ask the user to install it
> (see the prompt-kit README); never guess a model string from memory.

Turn a piece of work into a placement decision. All routing data lives in one
file — this skill is procedure only. It states no tier definitions, no
tier→model mapping, and no model strings of its own; read them from the file each
run so this, `prompt-audit` and `tailor-to-fable` never disagree.

## Source of truth

`~/.claude/model-profiles.md`. It is prose plus fenced ```yaml blocks — parse the
yaml, and merge every block. The blocks this skill uses:

- `routing_rubric.where` — `session` / `delegate` / `fresh_session`. **Answer this first.**
- `routing_rubric.tier` — each tier's `when` and `effort`.
- `routing_rubric.consequence_override` — the reversibility floor, which outranks task shape.
- `execution_signals` — `escalate_when` / `de_escalate_when` / `session_lifecycle`.
- `tier_to_model` — tier → model string. For work that runs as a session.
- `delegation_aliases` — tier → Agent-tool `model` alias. For delegated work.
- the per-model profiles — behavioral deltas.
- `meta.staleness_rule` and `meta.context_cost_rule`.

## Procedure

1. **Parse** the file. If a ````yaml` block fails to parse, say so and stop —
   reading the surrounding prose instead turns routing data into a guess.
2. **Where.** Match `routing_rubric.where`. This is the larger lever and the
   commoner question: most real invocations are "what should I hand this
   subagent?", not "what should I run this chat on". Per
   `meta.context_cost_rule`, delegating also keeps the unit's tokens out of the
   session prefix, which makes every later turn cheaper regardless of tier.
3. **Tier + effort.** Match `routing_rubric.tier`. Then apply
   `consequence_override` — reversibility sets the floor and outranks the task's
   apparent difficulty in both directions. If the work is a mix, split it by phase
   rather than averaging.
4. **Escalation is a verdict about a stuck run, not about difficulty.** Pick it
   only against `routing_rubric.tier.escalation.when` or a fired
   `execution_signals.escalate_when`. "This looks hard" is not a signal.
5. **Staleness.** Apply `meta.staleness_rule` to the resolved profile. Flag only
   the half (`api_verified` / `prompting_verified`) that aged out; a blanket STALE
   flag on a profile whose API facts are current is noise.
6. **Resolve the target** for the placement chosen in step 2:
   - runs as a session → `tier_to_model[tier]`
   - delegated → `delegation_aliases[tier]`, passed as the Agent/Task call's
     `model`. These are **different value spaces**: a `tier_to_model` string is
     invalid in that field, and leaving it null makes the subagent inherit the
     caller's model. Never emit a delegation recommendation without the alias.
   If the table is unreadable, emit the tier + effort and say the target is
   unresolved — never guess one.
7. **Name the signal that would flip this**, from `execution_signals`. A verdict
   nobody can revise is a verdict nobody re-checks.

## Mid-run: already in a session

When the question is "should I escalate / start over / keep going", the answer is
still a `where` decision — read `execution_signals` first and name the observed
signal, not a hunch.

- A fired `escalate_when` **and** distrust of the current framing →
  `where: fresh_session`. Per `session_lifecycle.hand_off`, do not raise the tier
  inside a session whose framing you distrust: the transcript defends its earlier
  conclusions. Hand off to a fresh session instead (`tailor-to-fable` writes the
  brief).
- A fired `escalate_when` on framing you still trust → raise the tier in place.
- Any `de_escalate_when` → drop a tier, and check whether the remainder is now
  delegable. This is the under-used direction: after a diagnosis lands, the fix is
  usually execution-tier work with a stateable contract.
- `session_lifecycle.externalize` is a precondition for compact, hand off, and
  restart — say which file the durable state goes to. Restarting without it throws
  the work away; with it, re-reading the state file is what makes the restart cheap.

## Output format

```
Where:   session | delegate | fresh_session — <why; name the fired signal if mid-run>
Verdict: <tier> tier, effort <effort> — <one-line reason>
Target:  <tier_to_model[tier]>  |  Agent(model: "<delegation_aliases[tier]>")
Prompt:  <1–2 profile deltas that change how to prompt this target for this task>
Watch:   <the execution_signal that would change this decision>
```

`Target:` carries the model string when the work runs as a session and the alias
when it is delegated — never both, and never a string in the alias position.
Note the profile's `last_verified` half if you flagged one stale.

Phased task — one line per phase: `<phase>: <where>, <tier>, <effort> — <why> → <target>`.

## Rules

- Emit `Where` before `Verdict`; placement is the decision with the larger effect.
- Emit tier + effort for every recommendation; that is the durable part, valid even
  if the model table turns out stale.
- Read model strings only from `tier_to_model` and aliases only from
  `delegation_aliases`. When you cannot verify one, stop at the tier and say so —
  a guessed target is worse than none.
- One-line reason. Recommend one placement; skip the ones you didn't pick.
