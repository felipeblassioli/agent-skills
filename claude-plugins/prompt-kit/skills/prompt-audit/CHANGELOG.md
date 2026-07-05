# Changelog

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
