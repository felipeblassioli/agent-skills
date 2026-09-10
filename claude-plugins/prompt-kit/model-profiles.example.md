# model-profiles.example.md — EXAMPLE / template

> **This is an example, not the live file.** prompt-kit reads its routing source
> from **`~/.claude/model-profiles.md`** at runtime — deliberately outside the
> plugin so `model-recommender`, `prompt-audit`, `smart-prompt`, `tailor-to-fable`,
> and `loop-compiler` share one copy. To install: copy this file to
> `~/.claude/model-profiles.md`, set `meta.reviewer`, then apply
> `staleness_rule`.
>
> Three kinds of content live below, and they go stale at different rates:
> - **Policy hypotheses** — `routing_rubric`, `execution_signals`, and
>   `context_cost_rule`. Re-evaluate them against outcomes, not just model releases.
> - **Harness snapshot** — `delegation_aliases`; recheck against the installed
>   Claude Code version and effective agent configuration.
> - **Volatile snapshots** — `tier_to_model`, `pricing`, and the per-model
>   profiles, captured on the `api_verified` / `prompting_verified` dates below.
>   Refresh them against the canonical Anthropic pages in `meta.sources` before
>   trusting a nuance; never ship the dates below as current without re-verifying.
>
> The plugin's SessionStart hook validates the **installed** copy on every session
> — it emits an advisory warning if YAML does not parse, a required block is
> missing, or a tier lacks a matching alias or profile. That is the drift guard for this template.


Single source of truth for model routing and per-model prompting nuances.
Read by `prompt-kit` (`model-recommender`, `prompt-audit`, `tailor-to-fable`) and by
`loop-compiler`. Canonical home: `~/.claude/model-profiles.md` (versioned in dotclaude).

Parsing contract: consumers read every fenced ```yaml block below and merge them.
Prose is for humans; the yaml is the data. Resolve models through `tier_to_model`,
then match the exact profile `model_id`.
Each profile also declares its `delegation_alias`; the guard checks those bindings.
`staleness_rule` and `context_cost_rule` are top-level keys, not children of `meta`.

## Meta + staleness rule

```yaml
meta:
  last_reviewed: 2026-09-09
  reviewer: TODO-set-your-name
  sources:
    general: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
    sonnet-5: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5
    fable-5-1: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1
    fable-5-1-whats-new: https://platform.claude.com/docs/en/models/fable-5-1/whats-new-fable-5-1
    opus-5: https://platform.claude.com/docs/en/models/opus-5/overview
    models-overview: https://platform.claude.com/docs/en/models/overview
    migration-guide: https://platform.claude.com/docs/en/about-claude/models/migration-guide

staleness_rule: |
  Profiles carry TWO dates, because they go stale at different rates and conflating
  them made every consumer flag "STALE" on a profile whose API facts were fine:
    - api_verified       : ids, context window, effort range, rejected params,
                           thinking defaults, pricing. Refresh at >90 days.
    - prompting_verified : posture/nuance notes. Refresh at >30 days, or when
                           tier_to_model resolves to an id with no matching model_id.
  Refresh = fetch the source, rewrite the affected keys, bump that date only.
  If you cannot refresh, emit the tier/effort verdict anyway and flag WHICH half is
  stale. Never guess a model string, a rejected param, or a nuance.
  A key marked `unverified` is a known gap, not a fact — say so rather than assert it.

context_cost_rule: |
  Measured over 1151 local Claude Code sessions (2026-07..09), list prices, cache-read
  rate verified only for fable-5-1 and derived elsewhere:
    - spend concentrates in a few long main-loop sessions: top 1% of sessions = 28%
      of spend, top 5% = 55%, top 25% = 90%.
    - in a long session cache READS dominate the bill, not output (Opus 5: ~60% of
      cost is re-reading the prefix).
    - marginal cost per assistant turn roughly doubles as the session grows: median
      ~$0.12/turn between 25-100 turns, ~$0.22/turn past 400.
    - the tier is a ~2x multiplier on top of that: median $0.33/turn on fable-5-1 vs
      $0.17 on opus-5, over sessions >=200 turns (n=6 vs n=125).
  These observations motivate placement experiments; they do not establish that
  delegation or restarting reduces total cost at equal quality. Task difficulty,
  worker usage, cache pricing, retries and rehydration confound the comparison.
  Compare verified completion, total usage and latency before claiming savings.
  List-price repricing is not a measured subscription bill. Revalidate on changes
  to pricing, harness context inheritance, model availability or task mix.
```

## Routing rubric (experimental policy)

```yaml
routing_rubric:
  # Decide placement and capability independently. Placement-first is a procedure,
  # not a proven ranking of their cost effects (see context_cost_rule).
  where:
    # These three keys are the values consumers emit verbatim as `Where:`.
    session: >
      The work IS the judgment (framing an unclear problem, weighing trade-offs,
      owning the final answer), or the next decision depends on evidence you must
      read yourself.
    delegate: >
      The unit has a stateable contract (inputs, done-condition, how it is verified)
      and its intermediate reading is not needed later in the session. Locating,
      reading, summarizing, mechanical edits across known files, independent
      verification. Specify whether the child inherits history and what it returns.
      A separate worker can limit parent context growth; total savings are unproven.
    fresh_session: >
      The problem is already framed but the framing is suspect, or an independent
      re-derivation is worth more than continuing. Preserve the selected tier unless
      capability evidence independently justifies changing it — see session_lifecycle.hand_off and .restart.
  tier:
    recon:
      when: isolated, reversible, pattern-following; locate / read / summarize; no design choice
      effort: none         # the current recon profile does not support an effort parameter
    execution:
      when: >
        bounded multi-file integration or debugging with a known target state; the
        contract is stateable and failure is caught by a command you can name
      effort: high          # xhigh only for the hardest scoped unit
    deliberation:
      when: >
        consequential judgment, unclear framing, architecture, adversarial diagnosis,
        final ownership/review — and the default for a session's main loop
      effort: xhigh         # high when the deliverable itself is long prose
    escalation:
      when: >
        After reassessment, evidence indicates the selected tier cannot meet the
        task contract; OR the expected cost of an error warrants stronger capability
        up front; OR the user explicitly requests this tier. Duration or repeated
        failure alone is insufficient. A fresh derivation can use the same tier.
      effort: high          # low/medium here can still beat a lower tier at xhigh
  consequence_override: >
    Reversibility, not difficulty, sets the floor. Persistent state, published
    contracts, credentials, concurrency, destructive or outward-facing operations →
    deliberation or above regardless of task shape. Bounded, reversible work with a
    strong verifier is a candidate for a lower tier. Reapply this floor after every de-escalation; a named test command alone
    does not prove the relevant failure is covered.
```

## Execution signals (observable — what changes a routing decision mid-run)

```yaml
execution_signals:
  reassess_when:
    - the same defect survives two independent fix attempts
    - the user repeats or disputes a constraint
    - load-bearing premises remain unverified and the cost of error is high
    - an autonomous run passes roughly one hour without a verifiable checkpoint
  reassess: >
    Inspect the failed verification and locate the source of the disputed constraint
    (user request, repository policy, or an agent assumption). Correct invented or
    superseded boundaries. Distinguish missing evidence, tooling/dependency failure,
    weak verification, and framing problems from a capability limit. If unresolved,
    state what evidence is missing; uncertainty alone does not mandate a higher tier.
  escalate_when:
    - reassessment identifies a capability limit relevant to the task contract
    - the cost of error justifies stronger capability before attempting the work
    - the user explicitly requests the escalation tier
  de_escalate_when:         # the under-used direction — check it after every diagnosis
    - the unknown resolved — there is now a stateable contract and a verification command
    - the remaining work repeats a pattern already established in this session
    - you are narrating procedure rather than deciding anything
  session_lifecycle:
    externalize: >
      Before compacting, handing off or restarting, write durable state (decisions,
      verified facts, constraint sources, open questions) to a file. Re-reading a state file is
      not wasted work — it is the mechanism that makes long and restarted runs
      survivable, and it is cheap next to re-deriving.
    keep: >
      Constraints are holding, corrections are rare, and the accumulated context is
      itself the asset (a diagnosis built step by step).
    compact: >
      The session's conclusions still matter but its evidence does not — long tool
      output, superseded attempts. Compact when the transcript is mostly evidence
      already spent.
    hand_off: >
      You want a different model, or an independent re-derivation, on a problem this
      session has already framed. Emit a self-contained brief into a FRESH session,
      preserving the chosen tier.
      Change capability only with a separate reason; require explicit history
      isolation in harnesses whose workers or forks inherit the transcript.
    restart: >
      Reassessment finds accumulated assumptions obstruct independent investigation.
      Start from source-anchored facts and labelled hypotheses; preserve the tier
      unless separately justified. A fresh brief can also bias the recipient, so
      permit confirmation, refutation, no additional defect, or inconclusive findings.
```

## Tier bindings (checked against profile identity snapshots)

```yaml
tier_to_model:
  deliberation: claude-opus-5
  execution:    claude-sonnet-5
  recon:        claude-haiku-4-5-20251001
  escalation:   claude-fable-5-1
# Update this table on a model release; profiles below refresh via staleness_rule.

delegation_aliases:
  # Claude-specific call targets, not a universal provider API. Check the installed
  # tool schema before use. A named agent may already select the intended model;
  # defaults, version-specific precedence and organizational restrictions can alter
  # the effective target. The guard checks profile agreement, not live availability.
  recon:        haiku
  execution:    sonnet
  deliberation: opus
  escalation:   fable

pricing:                    # $/MTok, list. cache_read verified only where noted.
  claude-opus-5:             { in: 5,  out: 25, cache_read: 0.50 }   # cache_read derived
  claude-sonnet-5:           { in: 2,  out: 10, cache_read: 0.20 }   # cache_read derived
  claude-haiku-4-5-20251001: { in: 1,  out: 5,  cache_read: 0.10 }   # cache_read derived
  claude-fable-5-1:          { in: 10, out: 50, cache_read: 0.25 }   # verified
```

## Profile: Opus 5 (deliberation tier)

```yaml
opus-5:
  model_id: claude-opus-5
  delegation_alias: opus
  tier: deliberation
  source_url: https://platform.claude.com/docs/en/models/opus-5/overview
  api_verified: 2026-09-09
  prompting_verified: null          # no dedicated Opus 5 prompting page captured yet
  context_window: 1M
  effort_range: low|medium|high|xhigh|max
  effort_default: xhigh             # Claude Code's own default for coding/agentic work
  thinking_default: adaptive-on     # ON by default. thinking:{type:"disabled"} is accepted
                                    # only at effort <= high, and has two known failure modes
  rejected_params:
    - temperature / top_p / top_k (non-default)
    - "thinking:{type:enabled, budget_tokens}"
  fast_mode: "beta fast-mode-2026-02-01 — same model, faster output, priced $10/$50"
  refusal_triggers: []
  notes:
    # Generation-wide behaviours, carried forward and re-checked against the general
    # prompting page — NOT quoted from an Opus 5 page. Do not attribute these to Opus 5
    # specifically until prompting_verified is set.
    - literal follower — state scope explicitly; it will not generalise scope you did not state
    - fix shallow reasoning by raising effort, not by prompting around it
    - code review — "only high-severity" is obeyed literally and drops recall; ask for
      coverage at the finding stage and filter downstream
    - subagent_posture unverified for Opus 5; the prior generation spawned fewer than asked,
      so authorise fan-out explicitly rather than assuming it
    - at xhigh/max give a large max_tokens (start ~64k) for thinking + tool room
```

## Profile: Sonnet 5 (execution tier)

```yaml
sonnet-5:
  model_id: claude-sonnet-5
  delegation_alias: sonnet
  tier: execution
  source_url: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5
  api_verified: 2026-09-09
  prompting_verified: 2026-07-05
  context_window: 1M
  effort_range: low|medium|high|xhigh|max
  effort_default: high              # xhigh for the hardest scoped units
  thinking_default: adaptive-on     # disable with thinking:{type:"disabled"}
  prescription_posture: explicit    # literal follower — state scope explicitly
  verbosity: complexity-calibrated
  rejected_params:
    - temperature / top_p / top_k (non-default)
    - "thinking:{type:enabled, budget_tokens}"
    - mid-conversation system messages
  refusal_triggers: []
  notes:
    - new tokenizer emits ~30% more tokens for the same text → 4.6-tuned max_tokens may truncate
    - watch for near-all-thinking then a truncated answer with stop_reason max_tokens —
      raise max_tokens or drop to medium
    - effort names are not comparable across models; match by observed thinking length
    - with thinking disabled it reaches for tools less; nudge explicitly if you rely on tool calls
    - temperature is gone, so "propose N options before building" is THE lever for variety
    - same review literal-filtering caveat as Opus (coverage at finding, filter downstream)
    - as the delegation workhorse it self-verifies well — give it the verification command,
      not a description of the verification
```

## Profile: Fable 5.1 (escalation tier)

```yaml
fable-5-1:
  model_id: claude-fable-5-1
  delegation_alias: fable
  tier: escalation
  source_url: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1
  api_verified: 2026-09-09
  prompting_verified: 2026-09-08
  context_window: 1M
  effort_range: low|medium|high|xhigh|max
  effort_default: high              # medium ~= Fable 5 at lower cost; low often beats
                                    # smaller models at higher effort. Re-sweep per model.
  thinking_default: adaptive-always-on   # cannot be disabled; display defaults to "omitted"
                                    # ("summarized" available; "updates" = beta
                                    # thinking-display-updates-2026-08-18)
  prescription_posture: brief       # INVERTS from Opus/Sonnet — a short instruction beats
                                    # enumerating behaviours
  subagent_posture: spawns-readily  # dispatch freely; do NOT block the lead on each subagent
  verbosity: runs-long              # minutes-to-hours turns; denser prose, LESS chat formatting
  rejected_params:
    # NEW in 5.1: forced tool choice is gone — auto|none only
    - "tool_choice:{type:any}"
    - "tool_choice:{type:tool}"
    - "thinking:{type:enabled, budget_tokens}"
    - "thinking:{type:disabled}"
    - assistant prefill (last turn)
    - temperature / top_p / top_k (non-default)
  refusal_triggers:                 # fewer false positives at 5.1 than at 5
    - reasoning_extraction          # "show/echo/explain your reasoning as response text"
                                    # -> refusal -> SILENT fallback to `fallback`
    - bio-life-sciences
    # NOTE 5.1: finding vulnerabilities in source code IS permitted
  fallback: claude-opus-5           # permitted 5.1 targets: claude-opus-5, claude-opus-4-8
                                    # (server-side: betas ["server-side-fallback-2026-07-01"])
  notes:
    - built for the hardest/longest/most-ambiguous work; testing only on easy tasks undersells it
    - 5.1 vs 5 regressions to prompt around — parallel tool calls MORE variable (add a batching
      line); FEWER progress updates in long runs; whole-file rewrites over targeted edits;
      unmarked quotations when summarising sources; answers from memory at low effort
    - remove old "hold findings for the final response" lines AND old anti-formatting rules —
      5.1 already under-narrates and under-formats; those rules suppress what you want
    - skills tuned for prior models are often TOO prescriptive here and can degrade output
    - long autonomous runs — instruct it to audit progress claims against tool results
    - can take unrequested actions and refactors; state boundaries + "keep changes to the task"
    - performs well with a place to write/reference lessons (a markdown memory file)
    - conversation history must be APPEND-ONLY — editing system/tools/earlier turns
      invalidates thinking blocks (400, or dropped with thinking-binding-controls-2026-08-01
      plus prefix_mismatch_behavior "drop_block")
    - at xhigh/max it can draft a long deliverable in thinking then rewrite it — run
      long-output work at high
    - ready-made snippets (anti-overplanning, anti-refactor, progress-audit, boundaries,
      autonomy, finish-the-whole-task, delivering-work) live at source_url — link, don't inline
```

## Profile: Haiku 4.5 (recon tier)

```yaml
haiku-4.5:
  model_id: claude-haiku-4-5-20251001
  delegation_alias: haiku
  tier: recon
  source_url: null                  # no dedicated prompting page exists for this model
  api_verified: 2026-09-09
  prompting_verified: null
  context_window: 200K              # the only current model NOT at 1M — a large brief
                                    # or a big file dump will not fit; scope recon units
  effort_range: none                # `effort` ERRORS on this model (400)
  thinking_default: "thinking:{type:enabled, budget_tokens: N}"   # still the old shape here
  prescription_posture: unverified  # assume literal following like the rest of the
                                    # generation, but do not assert Haiku-specific nuance
  subagent_posture: n/a             # leaf worker, never an orchestrator
  refusal_triggers: []
  notes:
    - API facts verified; PROMPTING nuances are a known gap. Route by role (cheap
      locate/read/summarize), and give it a contract, not a posture-tuned prompt.
    - the two levers that differ from the rest of the lineup — no `effort`, 200K context —
      are the ones that actually break a delegation. Check them before delegating.
```
