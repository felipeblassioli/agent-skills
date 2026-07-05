# Changelog

## 0.1.0 - 2026-07-05

### Added

- Initial release. Shapes a loose intent into an executable agentic prompt:
  match an archetype → fill the universal slots → route the tier → self-check.
- `references/prompt-archetypes.md` — the validated catalog (yaml `catalog`
  block), seeded with five archetypes: `context-anchored-planning` (flagship,
  with a before/after example), `codebase-cartography`, `investigation-diagnosis`,
  `scoped-implementation`, `adversarial-review`. Archetypes name a
  model-recommender routing archetype + effort, never a model string.
- `references/growth-loop.md` — capture real wins to an external, never-committed
  ledger (`~/.claude/smart-prompt-ledger.md`); human-gated promotion of
  recurring, generalizable, sanitized cases into the public catalog + a
  regression eval.
- Composition: calls `model-recommender` for tier/effort and `prompt-audit` as a
  final gate; holds no inline routing data or rules.
- `evals/evals.json` (6 cases incl. a growth-loop dependency case and a
  don't-run-the-task control) + a bootstrap baseline snapshot.
