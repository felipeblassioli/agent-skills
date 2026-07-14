# model-profiles.example.md — EXAMPLE / template

> **This is an example, not the live file.** prompt-kit reads its routing source
> from **`~/.claude/model-profiles.md`** at runtime — deliberately outside the
> plugin so `model-recommender`, `prompt-audit`, `smart-prompt`, `tailor-to-fable`,
> and `loop-compiler` share one copy. To install: copy this file to
> `~/.claude/model-profiles.md`, set `meta.reviewer`, then apply
> `meta.staleness_rule` — the model strings (§ Tier → model) and per-model
> profiles are **volatile snapshots** captured on the `last_verified` dates below
> and go stale on the next model release. Refresh them against the canonical
> Anthropic pages in `meta.sources` before trusting a nuance; never ship the dates
> below as current without re-verifying.

Single source of truth for model routing and per-model prompting nuances.
Read by `prompt-kit` (`model-recommender`, `prompt-audit`, `smart-prompt`,
`tailor-to-fable`) and by `loop-compiler`.
Canonical home: `~/.claude/model-profiles.md`.

Parsing contract: consumers read every fenced ```yaml block below and merge them.
Prose is for humans; the yaml is the data. Model strings appear in exactly one place
(`tier_to_model`); everything else routes by tier, never by string.

## Meta + staleness rule

```yaml
meta:
  last_reviewed: 2026-07-05
  reviewer: <your-name>
  sources:
    general: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
    opus-4.8: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-4-8
    sonnet-5: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5
    fable-5:  https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5
    migration-guide: https://platform.claude.com/docs/en/about-claude/models/migration-guide

staleness_rule: |
  Before advising on a model, check its profile.last_verified.
  Refresh (fetch source_url, rewrite entry, bump last_verified) when ANY of:
    - the profile is missing
    - last_verified is older than 30 days
    - the resolved model string in tier_to_model no longer matches the profile key
      (i.e. a new model shipped into that tier)
  If you cannot refresh, emit the tier/effort verdict anyway and FLAG the profile
  as stale rather than guessing a nuance or a model string.
```

## Routing rubric (durable — archetype → tier + effort)

```yaml
routing_rubric:
  deliberation:
    when: ambiguous, high-leverage, low-volume, get-it-right-once (planning, architecture,
          breaking down work, review/judgment)
    tier: deliberation
    effort: high            # xhigh for coding/agentic deliberation
  execution:
    when: already-scoped, high-volume, on-rails (implementing a specified unit, routine edits)
    tier: execution
    effort: high            # xhigh only for the hardest scoped units
  recon:
    when: locate / read / summarize / cheap lookups
    tier: recon
    effort: low
  escalation:
    when: long-horizon, genuinely ambiguous, expensive-to-get-wrong, or beyond the
          deliberation tier's ceiling — NOT a default, reserve for real escalation
    tier: escalation
    effort: high            # low/medium on this tier can still beat prior xhigh
```

## Tier → model (THE ONLY place concrete strings live)

```yaml
tier_to_model:
  deliberation: claude-opus-4-8
  execution:    claude-sonnet-5
  recon:        claude-haiku-4-5-20251001
  escalation:   claude-fable-5
# Update this table on a model release; profiles below refresh via staleness_rule.
```

## Profile: Opus 4.8 (deliberation tier)

```yaml
opus-4.8:
  tier: deliberation
  source_url: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-4-8
  last_verified: 2026-07-05
  effort_default: high              # start xhigh for coding/agentic; >=high for intelligence-sensitive
  thinking_default: off            # enable with thinking:{type:"adaptive"}; triggering is steerable
  prescription_posture: explicit   # literal follower; won't generalize scope — state scope explicitly
  subagent_posture: spawns-fewer   # steer explicitly when you want fan-out
  verbosity: complexity-calibrated # length scales to judged complexity, not fixed
  rejected_params:                 # verified 2026-07-05 vs meta.sources.migration-guide (rejected == HTTP 400)
    - temperature (non-default)    # 400 on 4.8, same as 4.7
    - top_p (non-default)          # 400
    - top_k (non-default)          # 400
    - "thinking:{type:enabled, budget_tokens}"  # manual extended thinking removed on 4.7+; use effort
    - assistant prefill (last turn)             # 400 on 4.8
  refusal_triggers: []
  notes:
    - respects effort strictly, esp. low/medium — scopes to exactly what's asked (under-think risk on complex tasks at low)
    - fix shallow reasoning by raising effort (high/xhigh), not by prompting around it
    - favors reasoning over tool calls; raise effort to get more tool use (esp. knowledge work)
    - better default progress updates — remove old "summarize every N tool calls" scaffolding
    - persistent frontend house style (cream/serif/terracotta); give a concrete alt spec or ask it to propose options
    - interactive sessions burn more tokens (reasons after each user turn); specify task+intent+constraints upfront to maximize autonomy
    - code review — "only high-severity"/"be conservative" is now obeyed literally → measured recall drops; prompt for coverage at finding stage
    - at max/xhigh give a large max_tokens (start ~64k) for thinking + subagents/tool room
```

## Profile: Sonnet 5 (execution tier)

```yaml
sonnet-5:
  tier: execution
  source_url: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5
  last_verified: 2026-07-05
  effort_default: high             # xhigh for the hardest coding/agentic units
  thinking_default: adaptive-on    # change from 4.6; disable with thinking:{type:"disabled"}
  prescription_posture: explicit   # literal follower, same as Opus — state scope explicitly
  subagent_posture: unspecified    # more agentic + self-verifies; spawning default not called out in guidance
  verbosity: complexity-calibrated
  rejected_params:                 # all return HTTP 400
    - temperature (non-default)
    - top_p (non-default)
    - top_k (non-default)
    - "thinking:{type:enabled, budget_tokens}"   # manual extended thinking removed
  refusal_triggers: []
  notes:
    - new tokenizer emits ~30% more tokens for the same text → 4.6-tuned max_tokens may truncate
    - watch for near-all-thinking then truncated answer with stop_reason max_tokens — raise max_tokens or drop to medium
    - effort mapping — S5 medium ≈ S4.6 high; S5 high ≈ S4.6 max (match by observed thinking length, not effort name)
    - with thinking disabled it reaches for tools less; nudge explicitly if you rely on tool calls
    - temperature is gone, so "propose N options before building" is THE lever for design/output variety
    - same code-review literal-filtering caveat as Opus (prompt for coverage, filter downstream)
```

## Profile: Fable 5 (escalation tier)

```yaml
fable-5:
  tier: escalation
  source_url: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5
  last_verified: 2026-07-05
  effort_default: high             # xhigh for most capability-sensitive; medium/low fine for routine
  thinking_default: adaptive-only  # summarized-only thinking output; no extended-thinking budgets
  prescription_posture: brief      # INVERTS from Opus/Sonnet — steer with a short instruction; over-prescription DEGRADES output
  subagent_posture: spawns-readily # INVERTS from Opus — prefer async orchestration + long-lived subagents; guard over-delegation
  verbosity: runs-long             # longer turns by default (minutes/hours); can over-deliberate at high effort on routine work
  rejected_params:
    - extended-thinking budgets     # not supported
    # sampling-param behavior: verify against the Fable/Mythos intro page before asserting
  refusal_triggers:
    - reasoning_extraction          # "show/echo/explain your reasoning as response text" → refusal → SILENT fallback to Opus 4.8
    - offensive-cyber               # exploits/malware/attack tooling; benign security work can also trip it
    - bio-life-sciences             # lab methods / molecular mechanisms; beneficial tasks can also trip it
  fallback: claude-opus-4-8         # configure server/client-side fallback for the above
  notes:
    - built for the hardest/longest/most-ambiguous work; testing only on easy tasks undersells it
    - strong instruction following — a brief instruction beats enumerating behaviors one by one
    - skills tuned for prior models are often TOO prescriptive here and can degrade output; review and remove older instructions
    - long autonomous runs — instruct it to audit progress claims against tool results (kills fabricated status)
    - can take unrequested actions (drafting, defensive git backups); state boundaries explicitly
    - performs well with a place to write/reference lessons (a markdown memory file)
    - ready-made snippets (anti-overplanning, anti-refactor, progress-audit, boundaries, autonomy) live at source_url — link, don't inline
```

## Profile: Haiku 4.5 (recon tier)

```yaml
haiku-4.5:
  tier: recon
  source_url: null                 # no dedicated per-model prompting page captured yet
  last_verified: 2026-07-05
  effort_default: low
  thinking_default: unverified
  prescription_posture: explicit   # assume literal following like the rest of the current generation; VERIFY
  subagent_posture: n/a            # used as a leaf worker, not an orchestrator
  verbosity: unverified
  rejected_params: unverified
  refusal_triggers: []
  notes:
    - SPARSE PROFILE — populated by role (cheap locate/read/summarize), not from a dedicated page
    - do not assert Haiku-specific nuances until a source page is captured; flag stale on use
```
