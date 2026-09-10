# Changelog

## 0.2.1 - 2026-09-09

### Fixed

- Preserve the selected tier and supported effort when handing off to tailor-to-fable.
- Carry effective delegation selection and context inheritance rather than assuming an explicit call parameter proves the target.

Evidence: plugin `docs/evidence.md`, "Conservative routing corrections". New
behavioral cases are specifications; no with-skill versus baseline delta is claimed.

## 0.2.0 - 2026-09-09

### Added

- **Promoted `tracker-driven-epic-delivery`** into the catalog — the first
  archetype to come through the growth loop rather than being hand-seeded. It
  replaces three near-duplicate ledger candidates
  (`candidate:sequenced-epic-continuation`, `candidate:autonomous-vertical-delivery`,
  `candidate:autonomous-epic-delivery`) with one archetype carrying the two dials
  that actually distinguished them: a `cadence` axis (per-unit gate vs
  boundary-gated) and an `orchestration` axis (single-agent vs owner-orchestrator).
  The ledger's own family note asked for exactly this collapse.
- Regression eval for the promoted archetype, including the axis choice.

### Changed

- Catalog `routing` now names a `tier` and a `where` (`session` / `delegate`)
  rather than an "archetype", matching `model-recommender`'s vocabulary. Every
  catalog entry carries a `where` default; `model-recommender` still owns the call.
- Step 4 routes placement as well as tier. A `delegate` answer means the shaped
  prompt is a subagent brief and must pin the alias and stand alone (prompt-audit
  R12/R13); a `fresh session` answer hands the brief to `tailor-to-fable`.

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
