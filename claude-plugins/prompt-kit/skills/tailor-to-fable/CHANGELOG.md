# Changelog

## 0.2.0 - 2026-09-09

### Added

- **M9 — handoff brief.** A third input mode: a stuck investigation in the current
  session becomes a self-contained brief for a *fresh* session, written to a file.
  Derived from the one that worked in local history: it reframed a defect upstream,
  found a third error, and refuted two of the author's premises. Its load-bearing
  parts are the adversarial premise (state your own retracted conclusions, then ask
  it to assume another error exists), premises labelled `verified` / `assumed`, the
  confound that already fooled you once, the leaning marked as the thing you most
  want challenged, and open items annotated with their reachability.
- Subagent tiers must be pinned. Authorising fan-out from the escalation tier with
  `model` unset runs every delegated unit on that tier — observed four times in one
  run. M5 now requires an explicit `delegation_aliases[tier]` per call, and the
  output block carries a `Delegation` line.

### Changed

- No model name is hardcoded anywhere, including the skill description and the
  prose framing: the target is whatever `tier_to_model.escalation` resolves to. The
  skill keeps its name because that is what gets typed.
- Gates on the new prompt-audit R12 (unpinned subagent tier) and R13 (a handoff
  leaning on context the fresh session lacks) in addition to R2/R3/R8/R9/R10.
- Target line reports `api_verified` and `prompting_verified` separately.

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
