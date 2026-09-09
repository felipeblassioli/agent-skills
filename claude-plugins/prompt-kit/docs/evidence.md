# Evidence

Historical observations below retain their original wording. The final
"Conservative routing corrections" entry supersedes their causal savings claims,
universal inheritance assumptions and automatic escalation policy.

## 2026-07-05 — added third skill: smart-prompt (prompt authoring)

Added `smart-prompt`, completing the triad (author / route / critique). Design
decisions and the boundary that keeps it from overlapping `prompt-audit`:

- **Author vs critic.** `smart-prompt` is *generative* — it turns a loose intent
  (maybe not even a prompt) into a full agentic prompt by matching a validated
  archetype and filling universal slots. `prompt-audit` is *adversarial* — it
  critiques an existing prompt and fixes violations conservatively. The rule:
  audit critiques what exists; smart-prompt authors what's missing. They compose
  (smart-prompt runs prompt-audit as its final self-gate) rather than duplicate.
- **Durable/volatile, applied.** Method (the universal slots, how to match an
  archetype, the composition wiring) is embedded in SKILL.md; the archetype
  *catalog* is externalized to `references/prompt-archetypes.md` (parsed at
  runtime, `provenance: validated|candidate`). Archetypes name a
  `model-recommender` routing archetype + effort — **never a model string**
  (grep confirms zero `claude-*` strings in the skill).
- **Learn-from-use loop, shaped by the public/private boundary.** This repo is
  public, so raw captured cases (which can hold internal work) must not be
  committed. Capture writes to an external, never-committed ledger
  (`~/.claude/smart-prompt-ledger.md`, sanitized first); promotion into the
  bundled catalog is human-gated and generalizes the case + adds an `evals/`
  regression. See `references/growth-loop.md`.
- **Entry point.** Invocable as `/smart-prompt <intent>` via the skill mechanism
  and by natural-language trigger — no `commands/` dir (commands are deprecated).

**Validation:** catalog YAML parses under ruby psych (5 archetypes, all skeletons
are strings, routing archetypes valid); `metadata.json`/`evals.json` valid JSON;
mechanical `audit-skill.sh` → `spec_violations: []`, `metadata_valid: true`,
`changelog: true`, `evals.suite: true` (6 cases), `baseline_snapshot: true`,
description 629 chars; `claude plugin validate --strict` → ✔ passed; org-identifier
scan clean. Evidence is bootstrap-grade: one real trace (the flagship
`context-anchored-planning` case) executed; the other 5 cases and one real
capture→promotion round are the iteration-1 follow-up (recorded in the baseline).

## 2026-07-05 — skill-auditor pass + remediations (#1, #2)

Ran `bond-governance:skill-auditor` on both skills. Both **PASS** (spec-clean,
single-responsibility, lean, well-composed; `claude plugin validate --strict`
green). Warns were all either the deliberate external-file dependency or
Bond-marketplace governance gaps. Applied two fixes:

- **#1 loud dependency:** added a SessionStart guard
  (`hooks/check-model-profiles.sh` + `hooks/hooks.json`) that warns via
  `additionalContext` when `~/.claude/model-profiles.md` is missing (silent when
  present; both branches self-tested), plus a prominent **Requires** callout at
  the top of each `SKILL.md`.
- **#2 promotion governance:** added per-skill `metadata.json` (org-free author),
  `CHANGELOG.md`, and `evals/` (`evals.json` — 6 cases for model-recommender, 8
  for prompt-audit, incl. calibration controls — + an iteration-0 baseline).
  Re-audit confirms `metadata_valid`, `changelog`, and `evals.suite` now true;
  `baseline_snapshot` true.

**Honesty note on the baselines:** iteration-0 is a *bootstrap*. It records only
what was genuinely run (model-recommender: 6/6 deterministic traces against the
installed file; prompt-audit: the one real compile-plan dogfood → 1 soft R2, no
blocks). No baseline (without-skill) comparison was run and no pass-rate delta is
claimed — a full with-vs-baseline benchmark is the iteration-1 item. No numbers
were fabricated to satisfy the checker.

## 2026-07-05 — assets wired as runtime source; recursive self-audit

Wired `model-recommender` and `prompt-audit` to parse the yaml blocks in
`~/.claude/model-profiles.md` at runtime (routing rubric, `tier_to_model`,
profiles) and to load checks from `skills/prompt-audit/prompt-audit-rules.md`.
Removed the inline rubric/tier-map/check-catalog that previously lived in the
skills. Verified `opus-4.8.rejected_params` against the migration guide
(temperature/top_p/top_k non-default → 400; prefills → 400; `budget_tokens`
removed on 4.7+) and filled that one `unverified` field. Left Haiku's sparse
profile untouched — no dedicated prompting page exists to verify it from.

### Task 3 — self-audit results (R1–R11, Fable posture for R2/R3)

Targets: prompt-kit's own `model-recommender`/`prompt-audit` SKILL.md, and
loop-compiler's `compile-plan`, `execute-plan`, and three agents.

**Fired (fixed):**
- `[R4 | warn]` `model-recommender` SKILL.md — "Do not reconstruct the rubric or
  a model string from memory." → rewritten positive: "Source every archetype,
  tier, effort, and model value from the file."
- `[R4 | nit]` `prompt-audit` SKILL.md — redundant "Don't inflate." → folded into
  the positive "tag each finding at exactly the severity the rule assigns."

**Did NOT fire (and why — this is the calibration the rules demand):**
- loop-compiler is full of "never / do not" (≈15 across the agents + compile-plan)
  but every one is a **safety prohibition** (no branch/commit/merge/deploy, never
  invent a command, never touch the parent checkout, never overwrite a plan) —
  not a steering negative. R4 targets steering negatives ("don't be verbose"), so
  a calibrated audit leaves prohibitions intact.
- `story-implementer` (which runs under Fable on `fable-escalation` units) has a
  5-rule list. R2 did **not** fire: those are boundary guardrails ("stay inside
  the unit", "match the codebase", worktree discipline) that Fable's own profile
  explicitly recommends ("can take unrequested actions… state boundaries
  explicitly"), not the behavior-enumeration that degrades Fable.
- No `[R3]` anywhere: the skills emit verdicts/findings/reports (conclusions),
  never "show/echo/explain your reasoning as response text."
- No `[R7]`: no "summarize every N tool calls" scaffolding in any file.
- `diff-reviewer` already satisfies `[R10]` unprompted (coverage-first,
  "findings ranked most-severe first", adversarial) — the rule set and the
  existing agent agree without coordination.

**Surprise worth recording:** the hard part of the recursive audit was *not
inventing findings*. A naive linter that flagged every negative and every
enumerated rule would have produced dozens of false positives and gutted a
working plugin (loop-compiler). The honest thresholds (steering-negatives only;
guardrails ≠ over-prescription) leave loop-compiler essentially clean — which is
exactly the dogfood expectation. Second surprise: the audit fired on **my own**
freshly-written prompt-kit skills (2× R4), so the tool is not sycophantic toward
its author.

### Acceptance dry-runs

- **`model-recommender("build loop-compiler")`** → building a plugin from scratch
  matches `routing_rubric.deliberation.when` (ambiguous, high-leverage,
  get-it-right-once); it is within Opus's ceiling, so *not* escalation. Coding/
  agentic ⇒ effort `xhigh` (per the rubric's deliberation-effort condition).
  `tier_to_model[deliberation]` = `claude-opus-4-8`.
  **Verdict: deliberation / claude-opus-4-8 / xhigh.** ✔ matches acceptance.

- **`prompt-audit` on the loop-compiler bootstrap prompt** → no file literally
  named/containing a "bootstrap prompt" exists in the loop-compiler repo (grep:
  none), so the operative outcome-oriented loop-compiler prompt —
  `skills/compile-plan/SKILL.md` — was used as the target. Result: **1 finding**
  (a soft `[R2]` — the 7 explicit steps could collapse to a briefer instruction
  under a Fable target), no `block`s, rewrite not warranted. ≤2 findings, does
  not gut. ✔ matches acceptance. (If a distinct bootstrap prompt is stored
  elsewhere, re-run against it.)

### Surprise — the provided `model-profiles.md` didn't parse as strict YAML

Wiring it as the *runtime* source (not a copy) meant validating it actually
parses. It didn't: `opus-4.8.notes` had `- code review: "only high-severity"/…`
— a quoted scalar after an implicit `code review:` key — which is a **hard
parse error** in any compliant YAML loader (ruby psych, pyyaml, js-yaml, yq),
failing the whole `opus-4.8` block. Three more note bullets (`stop_reason
max_tokens: …`, `effort mapping: …`, `long autonomous runs: …`) parsed but as
single-key **mappings** instead of strings, silently mis-shaping `notes`. Fixed
all four by replacing the offending `: ` with ` — ` (meaning preserved). After
the fix: all 7 yaml blocks parse, and every profile's `notes[]` is a plain
string. Lesson: "the yaml is the data" only holds if the yaml actually loads —
colons inside unquoted sequence items are the classic trap; validate on install.

### Task 4 — drift closed (cross-repo)

loop-compiler carried a routing copy (readiness → model/effort). Replaced it with
readiness → **tier**, resolving model+effort from `~/.claude/model-profiles.md`:
- `skills/compile-plan/references/readiness-taxonomy.md` — decision table now
  names tiers; model/effort resolved from the shared file.
- `skills/compile-plan/SKILL.md` — Step 4 now emits `tier` and points at
  `~/.claude/model-profiles.md`.
- `skills/compile-plan/references/artifact-schema.md` — added a `tier` field;
  `model`/`effort` are documented as *resolved from* the file, not hardcoded.
Agent frontmatter (`recon: haiku`, `story-implementer: sonnet`, `diff-reviewer:
opus`) stays — Claude Code requires a `model:` — now documented as mirrors of the
tiers. Edits made in the separate `~/personal/felipeblassioli/loop-compiler` repo;
not committed.

## 2026-09-09 — rebuilt routing on measured session evidence

Source: 1171 local Claude Code transcripts (`~/.claude/projects/**/*.jsonl`), of
which 1151 carry priceable usage, plus 660 subagent transcripts. Prices are list
prices from the bundled `claude-api` reference; the cache-read rate is verified
only for the escalation-tier model and derived (10% of input) elsewhere, so all
absolute dollars are estimates while the *ratios* are robust. Session ids are
omitted — they map to private work.

### What the corpus says, before any policy change

1. **The execution and recon tiers exist almost only as subagents.** The
   execution-tier model shows 9853 subagent assistant messages against 177 in a
   main loop; the recon-tier model shows 2445 against **zero**. Main-loop routing
   is in practice a choice between the deliberation and escalation tiers.
   *Consequence:* routing advice phrased as "run this on X" answered a question
   nobody was asking. Every sampled invocation of `model-recommender` was really
   asking what to hand a subagent. Hence `routing_rubric.where` and
   `delegation_aliases`.

2. **Cost concentrates in a few long sessions, and cache reads dominate them.**
   Top 1% of sessions = 28% of spend, top 5% = 55%, top 25% = 90%. In a long
   deliberation-tier session ~60% of the bill is re-reading the prefix, not output.
   Median cost per assistant turn roughly doubles with length: ~$0.12 between 25
   and 100 turns, ~$0.22 past 400. The tier is a ~2x multiplier on top of that
   (median $0.33/turn escalation vs $0.17 deliberation over sessions ≥200 turns,
   n=6 vs n=125).
   *Consequence:* the dominant cost variable is turn count and context length, not
   model choice. Encoded as `meta.context_cost_rule`, which the rubric leans on to
   answer `where` before `tier`.

3. **A delegating session's fan-out can cost more than the session.** In the one
   fully traced handoff, the main loop cost ~$42 and its four subagents ~$102.

4. **The one mechanically-avoidable overpay: an unset `model` on delegation.**
   Of 660 subagent transcripts, 378 ran a premium tier. Splitting by `agentType`
   separates a deliberate choice from an inherited one — a named agent type may
   pin a premium model in its own definition, but `general-purpose` and `Explore`
   have no such definition, so their model came from the caller:

   | delegated runs | tier actually used | cost | at execution tier | delta |
   |---|---|---|---|---|
   | 296 `general-purpose` | premium (inherited) | $829 | $309 | **$519** |
   | 35 `Explore` (read-only search) | premium (inherited) | $188 | $75 | **$113** |
   | 82 named agent types | premium (may be deliberate) | $444 | $177 | not claimed |

   $632 of avoidable spend across 331 runs from one omitted parameter — ~2% of
   measured spend, but 100% deterministic to catch. Hence `delegation_aliases`
   (the Agent `model` field is an alias enum, not a model id) and prompt-audit
   **R12** at severity `block`. The four traced instances were call-site sweeps and
   a numeric re-derivation — all with a stateable contract, i.e. execution/recon
   work that had merely inherited upward.

5. **Steering is rare; capability is not the bottleneck.** 21 distinct
   corrections in 2048 human turns (~1%) after de-duplicating fork-copied turns
   and reading each match by hand. An earlier keyword-only pass reported 7–9% by
   matching benign task language ("wrong", "revert", "stop"). Recorded because the
   inflated number would have justified policy the evidence does not support.

6. **A hypothesis that did not survive.** "The escalation tier duplicates
   investigation" — 56–59% repeat-read rate — dissolved on inspecting *what* was
   re-read: its own scratchpad state files, its own transcript, and harness-spilled
   `tool-results/*.txt`. Excluding those, repository re-reads were 0.8% at the
   deliberation tier. Externalized-state re-hydration is what made a multi-day run
   survivable, not waste. This is why `session_lifecycle` makes `externalize` the
   precondition for compact/hand off/restart instead of treating re-reading as a
   cost to remove.

### Counterfactuals — what the revised policy would have routed

Six real sessions, spanning the required outcomes. "Would have" is a judgement
about routing, not a re-run; none of these were replayed.

| # | task shape (observed) | actual | revised policy | effect |
|---|---|---|---|---|
| 1 | five tasks in one prefix: "how do I run X locally", replicate a named exemplar's proxy config, debug a hanging dev server, add uniform error handling, then three adversarial review passes. 598 turns, 311 shell calls, 0 delegation, $149 | one deliberation-tier session throughout | recon→delegate; exemplar replication→delegate execution; the two failed dev-server fixes fire `escalate_when` but framing is trusted → raise in place; error handling→delegate execution; the three review turns→**this session, deliberation** | **cheaper**: the mechanical bulk leaves the premium prefix, and the review turns start from a short one. Same-tier floor for the reviews is deliberate, not a saving |
| 2 | a defect investigation the author no longer trusted — two published conclusions already retracted | framed at the deliberation tier, then handed by hand to a fresh escalation-tier session with a ~200-line brief; that session reframed the defect upstream, found a third error, refuted two premises | `escalate_when` fires (≥2 unverified load-bearing premises, high cost of being wrong) + framing distrusted → **`where: fresh session`** + M9 brief | **escalation, endorsed.** The policy reaches the decision the author reached by instinct, and additionally blocks the four inherited-tier subagents (R12) — the traced $77 overpay on that one session |
| 3 | multi-week repository engagement. 5598 turns, 287 user turns, **70 auto-compactions**, 6 delegations, $1843 (its fork family ~$5.3k ≈ 17% of all measured spend). Opened with a lookup | escalation tier for the whole run | escalation tier **kept** (long-horizon autonomous work is the rubric's own second clause); opening lookup delegated; 70 auto-compactions read as the `compact` signal firing unattended → deliberate `externalize` + `restart` boundaries | **premium, endorsed** — with a lifecycle bound. Extrapolating the cost/length curve, holding sessions near the 400-turn band rather than 5598 moves the per-turn rate from $0.33 toward $0.22. **This is an extrapolation, not a measurement** |
| 4 | adversarial PR re-review with explicit distrust of both the author's replies and a second reviewer. 143 turns, $57 | escalation tier — and `model-recommender` ran **58 times** in that session without preventing it | `deliberation` — "adversarial diagnosis, final ownership/review" is the deliberation clause verbatim; escalation needs a *fired signal*, and "this is hard / I don't trust it" is not one | **cheaper**: $57 → ~$28. The instructive part is that the old rubric had no signal test, so invoking the skill 58 times could not catch it |
| 5 | observability audit → proof pass → smallest patch sequence. 3 user turns, 450 turns, 226 shell calls, 0 delegation, $111 | deliberation tier throughout | turn 0 deliberation (correct); turns 1–2 fire `de_escalate_when` — the user says "the diagnosis is sufficient, implement the smallest patch sequence", which *is* the signal — → drop a tier **and delegate** the patch sequence | **cheaper**: the user performed the de-escalation in prose and the tooling ignored it. This is the case the `de_escalate_when` list exists for |
| 6 | "deliver this epic end to end, 6 child issues, one PR each, make every call yourself". 544 turns, 199 shell calls, 0 delegation, $224 | escalation tier, single agent, no delegation | matches the newly promoted `tracker-driven-epic-delivery` archetype: deliberation-tier owner at xhigh, `cadence: boundary-gated` (stated in the request), `orchestration: owner-orchestrator` with each unit's alias pinned | **cheaper and better-shaped** — but see the limitation below |

### Where the policy is wrong or unproven

- **`escalate_when` cannot distinguish "the context lost a constraint" from "the
  constraint was wrong".** In counterfactual 6 the user asked the same question
  twice ("why is human review needed? we can keep stacking PRs"), which trips
  *"you have restated the same constraint twice"*. But the repetition was the user
  disputing a boundary the run had invented, not the run forgetting one. The signal
  would have fired and recommended escalation where the correct action was to fix
  the boundary list. Stated as a known false-positive; not fixed, because the
  distinguishing evidence (who owns the constraint) is not mechanically available.
- **The handoff's value is confounded.** The one traced escalation handoff changed
  four things at once: model, a fresh context, adversarial framing, and independent
  re-derivation. Its result cannot be attributed to the model. The policy therefore
  routes on *task shape and signals*, and the escalation clause says "worth an
  independent second derivation" rather than "the model is smarter".
- **Delegated-unit quality is unmeasured.** Every "cheaper" counterfactual assumes
  a delegated execution-tier unit returns the same verified result. The units in
  question had named verification commands, which is the tier's own contract, but
  no A/B was run.
- **Cache-read pricing is verified for one model only**; the others are derived.
  Ratios survive this, absolute dollars are estimates.
- **Named-agent premium runs are not claimed as waste.** 82 runs, $444: their
  definitions may pin a premium model deliberately. Only the 331 runs with no
  definition to pin one are counted as inherited.

### Mechanism vs proof

Configured **and regression-tested against synthetic breakage**: the SessionStart
guard now fails on a non-parsing yaml block, a missing required block, a list item
that silently became a map, a tier with no alias, and a tier with no profile — six
injected defects, each caught, and silent on the clean file. Two of those defects
were **live in the shipped file**: the escalation profile's `rejected_params` did
not parse at all, and two `notes` items parsed as maps. So "the yaml is the data"
had been false in practice, and no consumer could see it.

Configured but **not proven in use**: R12/R13, the `where` axis, the execution
signals, the promoted archetype, and every eval case added today. They encode
measured history; they have not yet routed a live session.

Deliberately **not** added: staleness warnings in the hook. Dates age daily and
some gaps cannot be closed (a model with no published prompting page), so a
boot-time staleness warning fires forever and trains the reader to ignore the hook.
Staleness stays in `meta.staleness_rule`, evaluated when a skill is about to quote
a nuance — the only moment it can change an outcome. The same reasoning split
`last_verified` into `api_verified` / `prompting_verified`: three of four profiles
have an open prompting gap and current API facts, and one flag for both made the
flag meaningless.


## 2026-09-09 — Conservative routing corrections

Reviewed against PR #135 head `9d62ec76dae91ce22609c6a2a91ac6ed86c7dfec`.
The transcript corpus was not reanalyzed. Its reported dollar deltas are
counterfactual list-price estimates, not demonstrated savings or subscription
billing. Incorrect cache-rate assumptions can affect ratios as well as absolute
values. Correction frequency does not measure undetected defects. Placement,
model, task difficulty, verification and retries must be separated experimentally.

### Changes and boundaries

- Fresh-session handoffs preserve the chosen tier and supported effort. They do
  not automatically select escalation or require another defect to exist.
- R12 checks effective model selection, including intentional named-agent
  definitions. It is an audit-output rule, not an Agent-call interception hook.
- Repeated failures or disputed constraints trigger reassessment of authority,
  evidence, verification and tooling. A capability change requires its own reason;
  de-escalation retains the consequence floor.
- Consumers use top-level `staleness_rule` and `context_cost_rule`. Profiles now
  declare exact `model_id` and `delegation_alias` identities. The installed file
  must be updated separately; this change did not modify it or `loop-compiler`.
- Provider-specific runtime behavior and the next experiment are documented in
  [portability.md](portability.md). Codex integration is not implemented.

### Deterministic validation

The original hook silently accepted prose-only profiles, mismatched aliases and
model mappings without matching profiles in isolated review fixtures. The
regression suite exercises the actual hook through its optional fixture path,
without modifying the installed profile or calling a model.

- `python3 claude-plugins/prompt-kit/hooks/tests/test-model-profiles.py` — 19 tests
  passed: clean example; missing/empty/prose-only input; empty and unclosed fences;
  malformed YAML; missing policy blocks; policy path mismatch; accidental map
  notes; missing/mismatched aliases; missing/duplicate/wrong-tier profiles; changed
  model identity; and unavailable yq. Each invocation is bounded to five seconds.
- `bash scripts/validate-skill.sh claude-plugins/prompt-kit/skills/<skill>` for
  all four skills — `pass: true`, no errors or warnings.
- `bash scripts/marketplace-consistency.sh` — `marketplace-consistency: clean`.
- `claude plugin validate --strict claude-plugins/prompt-kit` — validation passed
  on installed Claude Code 2.1.201. This checks packaging, not live routing.
- Fenced YAML and JSON parse checks — 10 YAML blocks and 10 JSON files parsed.
- `bash -n claude-plugins/prompt-kit/hooks/check-model-profiles.sh` and
  `git diff --check` — passed.

### Independent behavioral smoke exercise

One fresh Codex subagent read the revised skills and committed example fixture,
without the prior review conclusions, installed profiles or external access.
It exercised three separate requests while the implementation was reviewed:

| Request | Observed output |
|---|---|
| Fresh investigation on the same deliberation model at high effort | Preserved tier and effort, wrote an isolated handoff, labelled the hypothesis unverified and permitted no defect/inconclusive findings |
| Named inventory-reader with a matching definition and verified precedence, no call override | Did not fire R12 or force an override; distinguished configured selection from execution and omitted unsupported recon effort |
| Repeated correction of an agent-invented human-review prerequisite | Retracted the invented boundary, kept the current session and did not recommend a stronger model |

These are synthetic instruction-following smoke results on a Codex subagent,
not Claude runtime exercises, an executed full eval suite, a without-skill
comparison, or a provider compatibility certification. No cost or quality delta
is claimed. The smoke scenarios have corresponding cases in the updated eval
specifications; repeatability and effects on real work remain unverified.
