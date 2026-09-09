# Changelog

## 0.2.0 - 2026-09-09

### Changed

- **Placement is now the first decision.** The skill answers `Where`
  (this session / delegate / fresh session) before tier and effort. Evidence from
  1151 local transcripts: the execution and recon tiers appear almost exclusively
  as subagents (Sonnet 5 — 9853 sidechain assistant messages vs 177 in a main
  loop; Haiku 4.5 — 2445 vs 0), and every sampled invocation of this skill was in
  fact asking what to hand a subagent, not what to run a chat on.
- Routing is driven by task characteristics plus observed execution signals rather
  than a static archetype list, and `consequence_override` lets reversibility
  raise or lower a tier the task shape suggested.
- Output contract: `Where` / `Verdict` / `Target` / `Prompt` / `Watch`. `Target`
  carries a model string for session work and a `delegation_aliases` alias for
  delegated work — never a string in the alias position.
- Staleness is now reported per half (`api_verified` / `prompting_verified`) so a
  profile with current API facts is not flagged wholesale.

### Added

- Mid-run mode: reads `execution_signals` to answer escalate / de-escalate /
  compact / hand off / restart, and requires `session_lifecycle.externalize`
  before the last three.
- A fired `escalate_when` plus distrust of the current framing routes to a **fresh
  session**, not to a higher tier in place — a long session defends its own earlier
  conclusions.
- De-escalation is called out as the under-used direction: after a diagnosis lands,
  the remainder usually has a stateable contract and is delegable.
- Emits the signal that would change the verdict, so a routing call stays
  reviewable instead of being a one-shot guess.

## 0.1.0 - 2026-07-05

### Added

- Initial release. Task → archetype → tier + effort verdict, then resolves the
  model string from `~/.claude/model-profiles.md` `tier_to_model`.
- Runtime parse of the shared `model-profiles.md` yaml blocks (`routing_rubric`,
  `tier_to_model`, per-model profiles, `meta.staleness_rule`); no inline routing
  data in the skill.
- Per-phase routing for multi-phase tasks (plan/implement/review).
- Graceful staleness: emits tier + effort and flags the model string as
  unresolved rather than guessing when the table is stale or the file is missing.
- `evals/evals.json` (6 cases) + a bootstrap baseline snapshot.
