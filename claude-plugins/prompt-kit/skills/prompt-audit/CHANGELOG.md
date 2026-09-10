# Changelog

## 0.2.1 - 2026-09-09

### Fixed

- Keep R12 a draft/evidence check; report unavailable runtime information separately and accept legacy profiles.

- Keep R12 stable while checking effective model selection rather than requiring every call to override a matching agent definition.
- Clarify that audit block severity does not intercept runtime calls; correct top-level policy lookup.

Evidence: plugin `docs/evidence.md`, "Conservative routing corrections". New
behavioral cases are specifications; no with-skill versus baseline delta is claimed.

## 0.2.0 - 2026-09-09

### Added

- **R12 delegation-model-unset** (`block`). A prompt that delegates work without
  setting the call's `model`, or that puts a `tier_to_model` string where a
  `delegation_aliases` alias belongs. An unset field makes the subagent inherit the
  caller's model: observed in local history as four subagents running on the
  escalation tier because their orchestrator did — on briefs that already carried
  the method, i.e. units scoped enough to route down.
- **R13 context-assumed-not-carried** (`block`). A prompt written for a fresh
  session (handoff, subagent brief, restart) that refers to context only the
  authoring session has. A fresh context exists to re-derive independently, which
  needs premises stated, not gestured at.

### Changed

- R4 absorbed R11 (both prescribed the same fix for negative steering, including
  the length variants). R11's id is retired rather than reused so a recorded
  finding keeps its meaning.
- Rules now read posture from profile **fields** (`prescription_posture`,
  `subagent_posture`, `refusal_triggers`, `rejected_params`, `fallback`) instead of
  naming models. R3 reads its fallback target from `profile.fallback`; R9 reads
  `profile.rejected_params` and now also catches an `effort` value on a model whose
  `effort_range` is `none`.
- The `requires_tier` dependency resolves placement as well as tier, because R12
  and R13 only apply to prompts destined for another session.

## 0.1.0 - 2026-07-05

### Added

- Initial release. Adversarial prompt audit → tagged findings (rule_id +
  severity) + a `--fix`-style rewritten prompt.
- Checks loaded from the bundled `prompt-audit-rules.md` (R1–R11); no inline
  check catalog in the skill.
- `requires_tier` dependency: with no target model named, calls
  `model-recommender` to resolve the archetype → tier, then loads that tier's
  profile from `~/.claude/model-profiles.md`.
- Honest-threshold guidance (block/warn/nit; steering-negatives vs safety
  prohibitions) so the linter leaves good prompts intact.
- `evals/evals.json` (8 cases, incl. two calibration controls: don't-flag-
  prohibitions and don't-gut-a-clean-prompt) + a bootstrap baseline snapshot.
