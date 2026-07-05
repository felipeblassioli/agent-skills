# prompt-audit-rules.md

Rule set for the `prompt-audit` skill. Adversarial by design: the job is to find what
will underperform, not to praise. Audit against the archetype the task calls for AND the
posture of the target model — several nuances INVERT across tiers, so "good prompt" is
model-relative, not absolute.

Dependency: rules marked `requires_tier: true` need the target tier first. If the user
didn't name a model, call `model-recommender` to resolve archetype → tier, then load that
tier's profile from `~/.claude/model-profiles.md` before evaluating those rules.

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
      Target is Fable/escalation AND the prompt enumerates many discrete behaviors or is
      heavily prescriptive; OR target is Opus/Sonnet AND the prompt relies on the model
      generalizing scope it never stated.
    finding: Prescription level is wrong for the target model's posture.
    fix: >
      Fable: collapse enumerated rules into one brief high-level instruction; remove
      instructions inherited from older, more-prescriptive skills.
      Opus/Sonnet: state scope explicitly ("apply to every section, not just the first") —
      they follow literally and will not generalize.

  - id: R3-reasoning-echo-trap
    requires_tier: true
    severity: block
    fires_when: >
      Target is Fable AND the prompt instructs the model to show / echo / transcribe /
      explain its reasoning as response text.
    finding: >
      Can trigger the reasoning_extraction refusal on Fable and cause silent fallback to
      Opus 4.8 — you think you're running Fable but you're not.
    fix: >
      Remove the show-your-reasoning instruction. If you need reasoning visibility, read the
      adaptive thinking blocks, and surface progress via a send-to-user tool instead.

  - id: R4-negatives-to-positives
    requires_tier: false
    severity: warn
    fires_when: The prompt steers with "don't X" / "avoid X" instructions.
    finding: Negative instructions steer worse than positive directives or positive examples.
    fix: Rewrite each "don't X" as the positive behavior you want, ideally with a short example.

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
      Opus (spawns fewer): explicitly authorize fan-out for independent items / multi-file reads.
      Fable (spawns readily): prefer async orchestration + long-lived subagents; guard against
      over-delegation of trivially-direct work.

  - id: R9-rejected-params
    requires_tier: true
    severity: block
    fires_when: >
      The prompt/harness sets a parameter the target rejects — e.g. non-default
      temperature/top_p/top_k or manual extended-thinking budgets on Sonnet 5.
    finding: Will 400 on the target model.
    fix: >
      Remove the rejected params (see profile.rejected_params). For output/design variety on
      Sonnet 5, use "propose N options first" instead of temperature.

  - id: R10-review-literal-filtering
    requires_tier: true
    severity: warn
    fires_when: >
      A review/finding task instructs "only report high-severity" / "be conservative" /
      "don't nitpick".
    finding: >
      Literal-following models obey this at the finding stage → measured recall drops even as
      bug-finding improves.
    fix: >
      Ask for coverage at the finding stage (report everything with confidence + severity),
      and move filtering/ranking to a separate downstream step.

  - id: R11-verbosity-via-negatives
    requires_tier: false
    severity: nit
    fires_when: The prompt reduces length via "be concise" / "don't over-explain".
    finding: Verbosity is now complexity-calibrated; blunt negatives steer poorly.
    fix: Give a short positive example of the target concision level instead of a prohibition.
```

## Self-consistency check (dogfood)

Run this rule set against the `loop-compiler` bootstrap prompt. Expected: it was written
outcome-oriented, so a calibrated audit should mostly pass it — flagging at most one or two
`R5`/`R2` items — not rewrite it wholesale. If it wants to gut the brief, the audit (or the
severity thresholds) is miscalibrated; record that in `evidence.md`.
