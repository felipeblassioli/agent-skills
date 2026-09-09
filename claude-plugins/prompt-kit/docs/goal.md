# Goal

## Purpose

Codify, as four Claude Code skills, the model-routing and prompt-quality judgment
I currently apply by hand in chat — so the decisions are consistent, fast, and
survive model releases without editing.

- **model-recommender** — work in, placement + tier + effort out (`this session` /
  `delegate` / `fresh session`), then the model string or the Agent-tool alias.
- **smart-prompt** — loose intent in, a full agentic prompt out, archetype-matched.
- **prompt-audit** — draft prompt in, adversarial findings + a rewritten prompt out.
- **tailor-to-fable** — a prompt, a rough idea, or a stuck investigation in; an
  escalation-tier brief out (or a self-contained handoff brief for a fresh session).

All four read one shared reference, `~/.claude/model-profiles.md`, which is also
consumed by the `loop-compiler` plugin. The reference is the single point of
model-version churn; the skills carry only durable technique.

## Design constraints

1. **Durable vs volatile split.** Cross-model prompting technique is embedded in
   the skills. Per-model deltas and concrete model strings live only in
   `model-profiles.md` and self-refresh. A concrete `claude-*` id appears in
   exactly one place (`tier_to_model`), and the Agent-tool alias in exactly one
   other (`delegation_aliases`) — they are different value spaces and neither is
   valid in the other's position.
2. **Agreement by construction.** All four apply the same rubric and the same
   execution signals from the same file, so their verdicts cannot contradict.
3. **Graceful staleness, scoped.** The skills always emit tier + effort (durable)
   even when the model table is stale or unreachable. Profiles carry separate
   `api_verified` and `prompting_verified` dates so only the half that aged out
   gets flagged — a blanket STALE flag on current API facts is noise, and noise is
   ignored.
4. **No rot on release.** Nothing outside the profiles file names a model or a
   per-model tip; those sections refresh from canonical Anthropic pages per the
   staleness rule. Eval assertions name lookup paths, never model strings.
5. **Routing by task shape and observed signals, not a model ranking.** The rubric
   answers *where* work runs before *which tier*, and `execution_signals` says what
   observable event would change that answer in either direction.

## Definition of done

- [x] `~/.claude/model-profiles.md` exists with the routing rubric, execution
      signals, `tier_to_model` (only location of a model id), `delegation_aliases`,
      pricing, and per-model profiles with `source_url` + split verification dates.
- [x] Plugin has `.claude-plugin/plugin.json`, `skills/`, and `README.md`;
      author identity is org-free.
- [x] `model-recommender` emits placement before tier, tier before target, supports
      per-phase routing, distinguishes a model string from a delegation alias, and
      never hardcodes either.
- [x] `prompt-audit` is adversarial, establishes the target tier via the shared
      rubric first, reads posture from profile fields rather than model names, and
      outputs tagged findings + a rewritten prompt.
- [x] `tailor-to-fable` resolves its target from `tier_to_model.escalation` and
      writes a self-contained handoff brief when the answer is a fresh session.
- [x] The profiles file is machine-readable and stays that way: every ```yaml block
      parses, and the SessionStart hook fails loudly on a parse error, a missing
      block, or a tier lacking an alias or a profile. Regression-tested against six
      synthetic breakages.
- [x] Verified against live docs: plugin manifest/skills layout
      (code.claude.com/docs plugins reference) and the prompt-engineering page set
      + URLs (platform.claude.com), plus the bundled `claude-api` reference for
      model ids, effort ranges, rejected params, thinking defaults, and pricing.
- [x] Exercised end-to-end against real session history (1151 local transcripts);
      routing counterfactuals and their limits logged in `evidence.md`.
