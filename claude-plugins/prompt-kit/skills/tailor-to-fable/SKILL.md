---
name: tailor-to-fable
description: >-
  Tailors prompts to the explicitly selected escalation-tier profile, or writes
  a self-contained fresh-session handoff preserving model-recommender's selected
  tier and effort. Use for /tailor-to-fable, explicit escalation-tier tailoring,
  or an independent investigation brief. Handoff mode does not imply escalation.
---

# tailor-to-fable

> **Requires** `~/.claude/model-profiles.md` (read via `model-recommender`), the
> sibling skill `prompt-audit` (final gate), and the bundled
> `references/fable-playbook.md` (the transform moves + canonical snippet
> pointers). If the profiles file is absent, stop and ask the user to install it
> (see the prompt-kit README) — never guess Fable's posture or a model string.

Two modes share the brief-writing procedure. **Explicit escalation tailoring**
uses `tier_to_model.escalation`. **Fresh-session handoff** preserves the tier and
supported effort selected by `model-recommender` or explicitly requested by the
user. The skill name is not authority to upgrade a handoff's model.

## Resolve the target

1. Select the mode before resolving a profile. A handoff uses
   `tier_to_model[selected_tier]`; if no tier was selected, ask `model-recommender`
   to choose it. A fresh session can use the same model as the current session.
2. Match the target to the profile's exact `model_id`. Stop target-specific
   tailoring when the profile is absent or inconsistent.
3. Apply the top-level `staleness_rule`. Withhold unavailable posture facts and
   flag the affected half rather than inventing a nuance.
4. Apply each move only when its profile field and the receiving harness support
   it. Handoff mode must not inherit escalation-specific thinking, fallback,
   prescription or orchestration settings. If effort is unsupported, omit it.

## Three input modes

- **A prompt exists** → transform it: keep the intent, remove what throttles the
  target, add what it needs.
- **A rough idea** → elevate it into a full brief first (objective, constraints,
  evidence to gather, boundaries, output contract), *then* apply the same moves.
  Keep the altitude high — a rough idea for this tier should stay a well-framed
  problem, not become a step script.
- **A stuck investigation in the current session** → this is the handoff case, and
  it is a different output: a self-contained brief for a **fresh** session (M9),
  written to a file. Reach for it when `model-recommender` answered
  `where: fresh_session` after reassessment of the current framing.
  Preserve its selected tier and supported effort;
  the point of the handoff is an independent re-derivation, so the brief must state
  its premises rather than gesture at them (prompt-audit R13 blocks the omission).

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
- **Enable orchestration, with each subagent's tier pinned.** It spawns subagents
  readily — frame fan-out-able work as parallelisable and long-lived, say what is
  small enough to do directly, and identify each unit's effective model under the
  installed harness. Keep
  matching named-agent definitions; otherwise propose a supported call value from
  `delegation_aliases[tier]`. Confirm actual model metadata when executed. An
  omitted parameter does not always mean inheritance (prompt-audit R12).
- **Give it a memory file.** For long runs, point it at a markdown file to record
  and reference lessons.
- **Set the run config, not worded effort.** Recommend `effort` high/xhigh (per
  `effort_default`), `thinking` adaptive (summarized-only — no extended-thinking
  budgets), remove any `rejected_params`, and configure `profile.fallback`. Effort
  is a parameter, not a phrase.
- **Coverage-first for review/finding tasks.** If the input is a review, ask for
  full coverage at the finding stage and move filtering downstream; "only
  high-severity" makes a literal follower drop recall.
- **Independent premise check, for a handoff.** State retracted conclusions as
  history, not as proof another defect exists. Label premises `verified` or
  `assumed`, cite their sources, and request independent checks. Accept confirmation,
  refutation, no additional defect, or an inconclusive result. (M9.)

**Refusal caution (honesty).** If the task sits in `profile.refusal_triggers`
territory (e.g. offensive-cyber, bio/life-sciences) — even benignly — Fable may
refuse and silently fall back. Flag this to the user; don't pretend the tailored
prompt guarantees a Fable run.

## Gate with prompt-audit, then emit

Run `prompt-audit` on the tailored prompt with the resolved target for the
selected mode. Its R2/R3/R8/R9/R10 encode these same escalation-tier checks, R12 checks
effective delegated model selection, and R13 catches a handoff brief that leans on context the
fresh session will not have. Let it confirm the transform didn't reintroduce a trap
(especially R3, the reasoning-echo block). Apply its fixes. Never emit a prompt
that trips a `block`.

## Output

```
Target:     <selected tier> → <model> (api_verified <date>, prompting_verified <date>[, STALE])
Run config: <only profile-verified settings supported by the receiving harness>
Delegation: <effective selection source per unit; proposed or execution-verified>
Context:    <fresh brief without inherited transcript, or explicit inheritance>
```

Then the tailored prompt in a fenced block, ready to paste or run. For the handoff
mode, write the brief to a file instead and give the path — it is externalized
state, and pasting it into this session defeats the purpose.

Then **what changed and why** — a short bullet list mapping each edit to the
profile field or `prompt-audit` rule_id that justifies it. (This changelog is for
the human; it is not an instruction inside the prompt — so explaining reasoning
*here* is fine and does not trip R3.)

Then the audit note (`prompt-audit: clean`, or the fixes applied) and, if
relevant, the refusal caution.

## Composition (crisp boundaries)

- `model-recommender` — owns the placement and tier decision. Runs *before* this
  skill: it answers `where` (`session` / `delegate` / `fresh_session`) and the tier,
  then handoff mode writes the brief for that tier. tailor-to-fable does not re-decide
  either; a `where: fresh_session` answer is what selects the M9 handoff mode.
- `smart-prompt` — shapes a loose intent for *whatever* tier fits and may not pick
  escalation. Explicit escalation tailoring fixes its target; handoff mode preserves the routed target.
  If given a raw idea, borrow smart-prompt's slot discipline to frame it, then
  apply the Fable transform.
- `prompt-audit` — owns prompt critique; called here as the final gate so this
  skill authors prompts that pass the linter instead of duplicating its rules.
- All read `~/.claude/model-profiles.md`; target-specific moves require verified
  profile fields and harness support.
