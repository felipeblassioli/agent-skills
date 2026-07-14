# Changelog

## 0.1.0 - 2026-07-14

### Added

- Initial release. `/tailor-to-fable <prompt or rough idea>` rewrites a prompt —
  or elevates a rough idea — to maximize the escalation-tier model (Fable 5
  today) on a hard, ambiguous, long-horizon problem.
- Resolves the target from `tier_to_model.escalation` and reads every posture
  fact from that model's profile in `~/.claude/model-profiles.md` at runtime;
  hardcodes no model string or per-model tip. Survives an escalation-tier model
  swap.
- The transform (durable technique) — eight moves: frame-not-prescribe, strip
  inherited scaffolding, guard the long leash (boundaries + progress-audit),
  never echo reasoning (the silent-fallback trap), enable orchestration, memory
  file, run-config-not-worded-effort, coverage-first review. Full rationale and
  canonical snippet pointers in `references/fable-playbook.md` (links to
  Anthropic's snippets; never inlines them).
- Composition: gates through `prompt-audit` (R2/R3/R8/R9/R10 encode the Fable
  checks) as the final linter; complements `model-recommender` (tier decision)
  and `smart-prompt` (any-tier shaping) without duplicating them.
- `evals/evals.json` (6 cases incl. the reasoning-echo trap, a rough-idea
  elevation, a rejected-params case, a refusal-caution case, and an
  anti-over-tailoring control) + a bootstrap baseline snapshot.
