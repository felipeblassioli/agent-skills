---
name: model-recommender
description: >-
  Recommends where work runs and which tier and supported effort it needs, using
  ~/.claude/model-profiles.md. Use when choosing a model or effort, before
  delegating through Task/Agent, splitting work into phases, or reassessing a
  stuck investigation. Handles "which model?", "delegate this?", "escalate?", and
  "start fresh?". Separates placement from capability and checks Claude model selection.
---

# model-recommender

> **Requires `~/.claude/model-profiles.md`.** If absent or invalid, report the
> unavailable routing data; never guess a model or prompt posture.

This is experimental routing advice, not a model switcher or an Agent-call
interceptor. Read policy and model data from the shared file each invocation.
A recommendation does not authorize delegation or external actions.

## Source of truth

Parse every fenced `yaml` block and merge the top-level mappings. Use:

- `routing_rubric.where`, `.tier`, and `.consequence_override`.
- `execution_signals` (see legacy compatibility below): `.escalate_when`,
  `.de_escalate_when`, and `.session_lifecycle`.
- `tier_to_model`, `delegation_aliases`, and the target profile resolved below.
- **Top-level** `staleness_rule` and `context_cost_rule`; neither is under `meta`.

**Profile compatibility.** If any profile declares `model_id` or
`delegation_alias`, require both on every profile and resolve exactly one matching
`model_id`; check its tier and alias. Partial adoption is invalid. If none declares
these fields, accept the legacy format: resolve the proposed target from
`tier_to_model` and its unique tier profile as a candidate. Before using its
settings or prompt posture, verify that the profile key and cited model source
identify that target. Tier membership alone is not identity proof. If unresolved,
emit the placement/tier/proposed target but mark profile identity unverified and
withhold profile-derived effort/settings/posture. Do not invent identity fields.

The `reassess_when` and `reassess` fields may both be absent in legacy files;
use their `escalate_when` events as **reassessment triggers**, applying step 3
below. If either new field exists, require both. No shared-file rewrite is needed.
Parsing or inconsistent bindings remain defects; surrounding prose is no substitute.

## Procedure

1. **Placement.** Match `routing_rubric.where`: `session`, `delegate`, or
   `fresh_session`. Keep this independent of tier. For delegation, establish a
   bounded contract, verification, permitted actions, context inheritance and
   expected return. A worker does not automatically have a fresh context; check
   the harness. Placement-first does not mean placement always saves more money.
2. **Tier.** Match the work and apply `consequence_override`. Split mixed work by
   phase. A stateable contract makes lower-tier execution a candidate only when
   the verifier covers the relevant failures. Preserve an explicit user choice.
3. **Reassess signals.** A `reassess_when` event prompts investigation, not automatic
   escalation. Apply `execution_signals.reassess` when present: trace constraint authority,
   failed checks, evidence gaps and tooling failures before attributing a problem
   to model capability. Change tier only for evidenced capability limits, the tier
   rubric/consequence floor, or an explicit user choice. Legacy duration/repetition
   triggers are not capability evidence. A costly decision may warrant stronger
   capability up front.
4. **Profile and effort.** Resolve the profile as above and apply `staleness_rule`.
   Flag only the unverifiable half (`api_verified` or `prompting_verified`), and
   withhold unsupported nuances. Choose effort supported by that profile; when
   `effort_range: none`, emit `not supported` and omit the runtime parameter.
   Effort names and price/quality trade-offs are not comparable across models.
5. **Effective target.** Session work, including fresh sessions, resolves through
   `tier_to_model[tier]`. For advice, use supplied or available definition/schema
   evidence; otherwise label the selection a proposal and name the runtime check
   still needed. Before dispatch, check the selected definition, installed schema,
   relevant defaults and version-specific precedence. If the definition resolves to the intended model, name the
   definition and keep that selection. Otherwise propose a supported explicit call
   value from `delegation_aliases[tier]`. Omission may inherit the parent, but does
   not always do so. If effective resolution is unknown or conflicts with policy,
   report it unresolved; do not claim a call parameter guarantees the model used.
   When executed, verify the actual model in available task/usage metadata before
   attributing usage or savings. Do not start a paid run just to give advice.
6. **Watch.** Name the observation that would change the decision and what it would
   trigger: reassessment, a different placement, or a different capability tier.

## Mid-run

- Suspect framing that warrants independent re-derivation after reassessment → recommend `fresh_session`, preserving the
  selected tier unless a separate capability reason justifies a change.
- Evidenced capability limit with useful, trusted context → recommend a higher tier in place.
- Resolved uncertainty or repetitive remainder → recommend the lowest tier and
  placement supported by verifier coverage, **reapplying the consequence floor**.
- If reassessment supports none of these changes, keep the current route and
  correct the identified premise, evidence or tooling problem. Emit one decision.
- Before compacting, handing off or restarting, externalize decisions, constraints
  with their sources, evidence references, open questions and retracted hypotheses.
  `tailor-to-fable` writes a handoff at the selected tier; its name is not a request
  to escalate. Permit confirmation, refutation, no additional defect, or an
  inconclusive result. A fresh context does not guarantee independence or savings.

## Output

```
Where:   session | delegate | fresh_session — <reason>
Verdict: <tier> tier, effort <supported value | not supported | unverified> — <reason>
Target:  <session model | effective agent definition | proposed call value | unresolved>
Context: <inherited history or isolated brief; required evidence and return contract>
Prompt:  <verified profile delta, or unavailable>
Watch:   <observation and the reassessment or routing change it warrants>
```

For delegation, `Target` identifies the source of effective selection and whether
it is verified configuration, a proposal, or observed execution. Do not equate
these states. For phased work, emit one compact record per phase.

Use `context_cost_rule` as an experimental hypothesis. Report parent context,
all-agent usage, verification/rework and elapsed time separately; retrospective
list-price repricing is neither measured savings nor an actual subscription bill.
