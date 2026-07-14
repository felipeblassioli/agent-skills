---
name: tailor-to-fable
description: >-
  Rewrites a prompt (or a rough idea) to maximize the escalation-tier model —
  Fable 5 today — on a hard, ambiguous, long-horizon problem. It commits to that
  target and applies the "un-prescribe and unleash a smarter collaborator"
  transform: state the problem and withhold the solution, strip scaffolding
  inherited from literal-following models, set explicit boundaries for long
  autonomous runs, avoid the reasoning-echo trap that silently drops you back to
  Opus, enable subagent orchestration, and set the run config (effort, thinking,
  fallback) instead of phrasing effort into words. Use when you type
  /tailor-to-fable, when you have already decided to run Fable 5, or when you ask
  to optimize / adapt / tune a prompt for Fable or "the smartest model" on a hard
  problem. To pick the model, use model-recommender; to shape any-tier intent,
  use smart-prompt; to critique a prompt, use prompt-audit.
---

# tailor-to-fable

> **Requires** `~/.claude/model-profiles.md` (read via `model-recommender`), the
> sibling skill `prompt-audit` (final gate), and the bundled
> `references/fable-playbook.md` (the transform moves + canonical snippet
> pointers). If the profiles file is absent, stop and ask the user to install it
> (see the prompt-kit README) — never guess Fable's posture or a model string.

The premise the user brings: **Fable 5 is a collaborator smarter than the author,
pointed at a problem too hard or too long for the deliberation tier.** You don't
micromanage a genius. So this skill does one directed thing — it takes a prompt
or a rough idea and rewrites it into the brief that gives that model the most
room to solve the problem *well*, with guardrails, without tripping the traps
that quietly demote it.

This is not routing (`model-recommender` decides the tier) and not general
shaping (`smart-prompt` routes a loose intent to whatever tier fits). Here the
target is fixed by assumption: the escalation-tier model. The whole job is to
tune the prompt to *that* model's posture.

## Resolve the target from the profile — never hardcode it

The command is named for Fable, but the posture facts are volatile, so read them:

1. Parse `~/.claude/model-profiles.md`. Take `tier_to_model.escalation` — the
   model this skill tailors to (today `claude-fable-5`). If that tier ever points
   elsewhere, tailor to *that* model's profile and note the name/target mismatch
   to the user.
2. Apply `meta.staleness_rule` to the resolved model's profile. If stale/missing,
   refresh per that rule before quoting a nuance; if you cannot refresh, proceed
   and **flag it stale** rather than guessing.
3. Every posture fact below (prescription level, subagent default, refusal
   triggers, effort/thinking defaults, rejected params, fallback) comes from that
   profile block. This skill states the *moves*; the profile states the *facts*.

## Two input modes

- **A prompt exists** → transform it: keep the intent, remove what throttles the
  target, add what it needs.
- **A rough idea** → elevate it into a full brief first (objective, constraints,
  evidence to gather, boundaries, output contract), *then* apply the same moves.
  Keep the altitude high — a rough idea for Fable should stay a well-framed
  problem, not become a step script.

## The transform (detail + snippet pointers in `references/fable-playbook.md`)

Apply each move only where the profile's fact holds and the input warrants it.
Load the playbook for the full rationale and the canonical snippet names.

- **Frame the problem, withhold the solution.** State goal, constraints, and the
  evidence to work from; delete prescribed HOW. (`prescription_posture: brief` —
  over-prescription degrades output.)
- **Strip inherited scaffolding.** Remove enumerated behaviour lists, "summarize
  every N tool calls," "think step by step / think hard," and step-locking — these
  are artifacts of prompting literal-following models and hold this one back.
- **Guard the long leash.** It runs long and can take unrequested actions, so
  state boundaries explicitly (what not to touch; what needs approval) and add one
  line telling it to audit its own progress claims against tool results.
- **Never ask it to echo reasoning.** "Show / explain / transcribe your reasoning
  as response text" can trip the `reasoning_extraction` refusal and cause a
  **silent fallback to `profile.fallback`** — you think you're on Fable but you're
  not. Cut it; surface progress via a send-to-user tool and read the adaptive
  thinking blocks.
- **Enable orchestration.** It spawns subagents readily — frame fan-out-able work
  as parallelisable and long-lived, and guard against over-delegating trivially
  direct work.
- **Give it a memory file.** For long runs, point it at a markdown file to record
  and reference lessons.
- **Set the run config, not worded effort.** Recommend `effort` high/xhigh (per
  `effort_default`), `thinking` adaptive (summarized-only — no extended-thinking
  budgets), remove any `rejected_params`, and configure `profile.fallback`. Effort
  is a parameter, not a phrase.
- **Coverage-first for review/finding tasks.** If the input is a review, ask for
  full coverage at the finding stage and move filtering downstream; "only
  high-severity" makes a literal follower drop recall.

**Refusal caution (honesty).** If the task sits in `profile.refusal_triggers`
territory (e.g. offensive-cyber, bio/life-sciences) — even benignly — Fable may
refuse and silently fall back. Flag this to the user; don't pretend the tailored
prompt guarantees a Fable run.

## Gate with prompt-audit, then emit

Run `prompt-audit` on the tailored prompt with the target set to the escalation
model. Its R2/R3/R8/R9/R10 encode these same Fable checks — let it confirm the
transform didn't reintroduce a trap (especially R3, the reasoning-echo block).
Apply its fixes. Never emit a prompt that trips a `block`.

## Output

```
Target:     escalation tier → <model>  (profile last_verified <date>[, STALE])
Run config: effort <high|xhigh>, thinking adaptive, fallback <profile.fallback> — <one line>
```

Then the tailored prompt in a fenced block, ready to paste or run.

Then **what changed and why** — a short bullet list mapping each edit to the
profile field or `prompt-audit` rule_id that justifies it. (This changelog is for
the human; it is not an instruction inside the prompt — so explaining reasoning
*here* is fine and does not trip R3.)

Then the audit note (`prompt-audit: clean`, or the fixes applied) and, if
relevant, the refusal caution.

## Composition (crisp boundaries)

- `model-recommender` — owns the tier decision. Often runs *before* this skill:
  it routes a hard task to the escalation tier, then this skill tailors the prompt
  for it. tailor-to-fable does not re-decide the tier.
- `smart-prompt` — shapes a loose intent for *whatever* tier fits and may not pick
  escalation. tailor-to-fable is the opposite move: target fixed, prompt tuned.
  If given a raw idea, borrow smart-prompt's slot discipline to frame it, then
  apply the Fable transform.
- `prompt-audit` — owns prompt critique; called here as the final gate so this
  skill authors prompts that pass the linter instead of duplicating its rules.
- All read `~/.claude/model-profiles.md`; this skill hardcodes no posture fact and
  no model string.
