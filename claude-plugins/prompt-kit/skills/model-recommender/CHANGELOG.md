# Changelog

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
