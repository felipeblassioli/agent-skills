---
name: prompt-audit
description: >-
  Adversarially reviews a draft prompt against a versioned rule set to find what
  will make it underperform — archetype mismatch, wrong prescription level for
  the target model, the Fable reasoning-echo trap, negatives that should be
  positives, unstated expectations, rejected params, and more — then returns
  tagged findings (rule_id + severity) plus a rewritten, --fix-style prompt. Use
  when asked to review / audit / critique / improve a prompt, check whether a
  prompt is good, tighten a system prompt, or before shipping a prompt to a
  model.
---

# prompt-audit

> **Requires** the bundled `prompt-audit-rules.md` (checks) and, for
> `requires_tier` rules, `~/.claude/model-profiles.md` (read via
> `model-recommender`). If the profiles file is absent, audit the
> model-independent rules and flag that tier-specific checks were skipped —
> never guess a model's posture.

Adversarial review of a draft prompt. The job is to find what will underperform,
not to praise. "Good prompt" is model-relative — several rules invert across
tiers — so audit against both the task's archetype and the target model's posture.

## The rules live in a file

Load the rule set from `prompt-audit-rules.md` (next to this SKILL.md) and parse
its ```yaml `rules` block. Each rule carries `id`, `requires_tier`, `severity`
(`block` | `warn` | `nit`), `fires_when`, `finding`, and `fix`. This skill does
not restate the checks — the file is the only rule source, so the audit can't
drift from it.

## Establish the target tier first (the dependency)

Rules with `requires_tier: true` need the target model's tier and profile:

1. If the user named a target model, use it. Otherwise **call `model-recommender`**
   on the prompt's underlying task to resolve its archetype → tier.
2. Load that tier's profile from `~/.claude/model-profiles.md` (apply its
   `meta.staleness_rule`; refresh or flag stale). The profile supplies
   `prescription_posture`, `subagent_posture`, `rejected_params`,
   `refusal_triggers`, etc. that several rules test against.

`requires_tier: false` rules are model-independent — evaluate them regardless.

## Evaluate honestly

For each rule, fire it only when its `fires_when` genuinely holds for this
prompt. Calibration is the whole point — a linter that flags everything is
worthless:

- Respect the severities as written (`block` / `warn` / `nit`); tag each finding
  at exactly the severity the rule assigns.
- A rule's `fires_when` is the gate, not a vibe. R4, for instance, targets
  *steering* negatives ("don't be verbose"); a genuine safety prohibition
  ("never force-push", "never merge") is not a steering negative — leave it.
- A well-written, outcome-oriented prompt should mostly pass. A couple of
  findings on a strong prompt is normal; wanting to gut it means the audit
  miscalibrated — recheck before reporting.

## Output contract

**Findings** — most severe first, one per fired rule:

```
[<rule_id> | <severity>]  span: "<the offending text, or location>"
why: <one line: why it underperforms for this task/model>
```

**Rewritten prompt** — `--fix` style: the corrected prompt with every finding
applied, ready to paste, then a short bullet changelog mapping each edit to its
`rule_id`.

Never rewrite silently: always show the findings that justify the rewrite. If no
rule fires, say the prompt is clean, name the archetype/tier it suits, and skip
the rewrite rather than inventing an edit.
