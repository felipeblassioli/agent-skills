# Evidence

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
