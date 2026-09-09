# prompt-audit-rules.md

Rule set for the `prompt-audit` skill. Adversarial by design: the job is to find what
will underperform, not to praise. Audit against the archetype the task calls for AND the
posture of the target model — several nuances INVERT across tiers, so "good prompt" is
model-relative, not absolute.

Dependency: rules marked `requires_tier: true` need the target tier first. If the user
didn't name a model, call `model-recommender` to resolve the placement and tier, then load
that tier's profile from `~/.claude/model-profiles.md` before evaluating those rules. Rules
read posture from **profile fields** (`prescription_posture`, `subagent_posture`,
`refusal_triggers`, `rejected_params`, `fallback`), never from a model name — the same
prompt is good for one posture and bad for the other, and the names change.

Rule ids are stable and never renumbered; `R11` was merged into `R4` and its id retired
rather than reused, so a finding recorded against an id keeps its meaning.

`block` is an audit-output severity enforced through skill instructions, not a
deterministic runtime gate. The SessionStart hook validates profile structure only.

Output contract: emit findings (each: rule_id, severity, span, why) AND a rewritten prompt
(`--fix` style). Severity ∈ {block, warn, nit}. Never silently rewrite without showing findings.

```yaml
rules:

  - id: R1-archetype-mismatch
    requires_tier: true
    severity: block
    fires_when: >
      The prompt's shape contradicts the task archetype: a deliberation task written as
      step-by-step edits (throttling a model you want thinking), or an execution task left
      open-ended (a worker with no rails).
    finding: Prompt shape does not match the work's archetype.
    fix: >
      Deliberation → goal + acceptance criteria + constraints, leave the HOW open.
      Execution → tight scope + explicit acceptance + verification command, no latitude.

  - id: R2-prescription-posture
    requires_tier: true
    severity: warn
    fires_when: >
      profile.prescription_posture is `brief` AND the prompt enumerates many discrete
      behaviors or is heavily prescriptive; OR the posture is `explicit` AND the prompt
      relies on the model generalizing scope it never stated.
    finding: Prescription level is wrong for the target model's posture.
    fix: >
      posture `brief`: collapse enumerated rules into one high-level instruction; remove
      instructions inherited from older, more-prescriptive skills.
      posture `explicit`: state scope outright ("apply to every section, not just the
      first") — a literal follower will not generalize scope you did not state.

  - id: R3-reasoning-echo-trap
    requires_tier: true
    severity: block
    fires_when: >
      `reasoning_extraction` is in profile.refusal_triggers AND the prompt instructs the
      model to show / echo / transcribe / explain its reasoning as response text.
    finding: >
      Can trigger the reasoning_extraction refusal and cause a SILENT fallback to
      profile.fallback — the run looks like the tier you chose but is not.
    fix: >
      Remove the show-your-reasoning instruction. If you need reasoning visibility, read the
      adaptive thinking blocks, and surface progress via a send-to-user tool instead.

  - id: R4-negatives-to-positives
    requires_tier: false
    severity: warn
    fires_when: >
      The prompt steers with "don't X" / "avoid X" — including the length variants
      ("be concise", "don't over-explain") that used to be their own rule.
    finding: >
      Negative instructions steer worse than positive directives or examples. Length in
      particular is complexity-calibrated now, so a blunt prohibition mostly suppresses
      content you wanted.
    fix: >
      Rewrite each "don't X" as the positive behavior you want. For length, give a short
      example at the target concision instead of a prohibition.

  - id: R5-unstated-expectations
    requires_tier: false
    severity: warn
    fires_when: >
      The prompt assumes above-and-beyond behavior the current generation won't supply
      unless asked (implicit thoroughness, implicit scope, implicit output shape).
    finding: Relies on "helpful guessing" that literal-following models no longer do.
    fix: Make the implicit explicit — required depth, scope, and output format stated outright.

  - id: R6-effort-not-wording
    requires_tier: true
    severity: warn
    fires_when: >
      The prompt tries to induce deeper reasoning through wording ("think very hard",
      "be extremely thorough") instead of the effort lever.
    finding: Reasoning depth is an effort-parameter decision, not a prompt-phrasing one.
    fix: >
      Recommend raising effort (high/xhigh) rather than prompting around shallow reasoning.
      Keep low effort only for latency; if so, add one targeted "this needs multi-step
      reasoning" line.

  - id: R7-stale-scaffolding
    requires_tier: false
    severity: nit
    fires_when: >
      The prompt forces interim status ("summarize progress every N tool calls") or other
      scaffolding that current models handle by default.
    finding: Likely-redundant scaffolding; current models give better progress updates unprompted.
    fix: Remove it and re-measure; add explicit update format back only if calibration is off.

  - id: R8-orchestrator-subagent-posture
    requires_tier: true
    severity: warn
    fires_when: The prompt is an orchestrator brief and the target's subagent posture is non-default.
    finding: Delegation guidance doesn't match the model's spawning default.
    fix: >
      subagent_posture `spawns-fewer` or unverified: explicitly authorize fan-out for
      independent items / multi-file reads rather than assuming it.
      `spawns-readily`: prefer async orchestration + long-lived subagents; guard the other
      way, against over-delegating trivially-direct work.

  - id: R9-rejected-params
    requires_tier: true
    severity: block
    fires_when: >
      The prompt/harness sets a parameter in profile.rejected_params — non-default
      temperature/top_p/top_k, manual extended-thinking budgets, forced tool_choice,
      assistant prefill, or an `effort` value on a model whose effort_range is `none`.
    finding: Will 400 on the target model.
    fix: >
      Remove them — they return HTTP 400. For output/design variety, "propose N options
      first" replaces the temperature knob that no longer exists.

  - id: R10-review-literal-filtering
    requires_tier: true
    severity: warn
    fires_when: >
      A review/finding task instructs "only report high-severity" / "be conservative" /
      "don't nitpick".
    finding: >
      A literal follower obeys this at the finding stage → measured recall drops even as
      bug-finding improves.
    fix: >
      Ask for coverage at the finding stage (report everything with confidence + severity),
      and move filtering/ranking to a separate downstream step.

  # Keep the R12 id stable; its invariant is effective selection, not call syntax.
  - id: R12-delegation-model-unset
    requires_tier: true
    severity: block
    fires_when: >
      A delegated unit has no established effective model selection, its effective
      model conflicts with the intended tier, or the proposed call value is invalid
      for the installed harness schema. An omitted call parameter alone is not a
      violation when a named agent definition resolves to the intended model.
    finding: >
      The effective delegated model is unresolved, mismatched, or invalid. Defaults,
      agent definitions, restrictions and version-specific precedence can change it;
      a call parameter is not proof of which model will run.
    fix: >
      Inspect the selected definition and applicable harness resolution rules. Keep
      a matching intentional definition; otherwise propose a supported explicit call
      value using delegation_aliases for Claude. If resolution is unavailable, state
      that gap. Verify the actual model in task/usage metadata when the run executes.
      Reapply consequence_override before lowering capability; a bounded brief alone
      does not establish safety or verifier coverage.

  - id: R13-context-assumed-not-carried
    requires_tier: false
    severity: block
    fires_when: >
      The prompt is written for a fresh session (a handoff brief, a subagent task, a
      restart) but refers to context only the authoring session has — "as we discussed",
      "the file you read earlier", "the same approach as before", an unnamed `it`/`this`,
      or a conclusion whose evidence is not restated.
    finding: >
      The receiving session cannot resolve the reference and will either re-derive it
      differently or invent it. This is the failure mode a handoff exists to avoid: the
      point of a fresh context is independent re-derivation, which needs the premises
      stated, not gestured at.
    fix: >
      Make the brief self-contained: name every file by path, restate each load-bearing
      constraint and premise in full, and mark which premises are verified versus assumed.
      Then re-read it as if you had never seen the original session.
```

## Self-consistency check (dogfood)

Run this rule set against the `loop-compiler` bootstrap prompt. Expected: it was written
outcome-oriented, so a calibrated audit should mostly pass it — flagging at most one or two
`R5`/`R2` items — not rewrite it wholesale. If it wants to gut the brief, the audit (or the
severity thresholds) is miscalibrated; record that in `evidence.md`.
