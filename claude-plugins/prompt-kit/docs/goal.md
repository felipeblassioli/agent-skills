# Goal

## Purpose

Codify, as two Claude Code skills, the model-routing and prompt-quality judgment
I currently apply by hand in chat — so the decisions are consistent, fast, and
survive model releases without editing.

- **model-recommender** — task in, durable verdict out (archetype → tier +
  effort), then today's model string.
- **prompt-audit** — draft prompt in, adversarial findings + a rewritten prompt
  out.

Both read one shared reference, `~/.claude/model-profiles.md`, which is also
consumed by the `loop-compiler` plugin. The reference is the single point of
model-version churn; the skills carry only durable technique.

## Design constraints

1. **Durable vs volatile split.** Cross-model prompting technique is embedded in
   the skills. Per-model deltas and concrete model strings live only in
   `model-profiles.md` and self-refresh. A concrete `claude-*` id appears in
   exactly one place (§2 of that file).
2. **Agreement by construction.** Both skills apply the same routing rubric from
   the same file, so a `prompt-audit` archetype call and a `model-recommender`
   routing never contradict each other.
3. **Graceful staleness.** The skills always emit tier + effort (durable) even
   when the model table is stale or unreachable, and flag the staleness rather
   than guessing a model string.
4. **No rot on release.** Nothing outside `model-profiles.md §2/§3` names a model
   or a per-model tip; those sections refresh from canonical Anthropic pages per
   the staleness rule.

## Definition of done

- [x] `~/.claude/model-profiles.md` exists with §1 rubric, §2 tier→model table
      (only location of a model id), §3 per-model profiles (deltas + `source_url`
      + `last_verified`), §4 staleness rule.
- [x] Plugin has `.claude-plugin/plugin.json`, `skills/`, and `README.md`;
      author identity is org-free.
- [x] `model-recommender` emits the durable verdict before the model string,
      supports per-phase routing, and never hardcodes a model id.
- [x] `prompt-audit` is adversarial, establishes the intended archetype via the
      shared rubric first, applies the required checks, and outputs tagged
      findings + a rewritten prompt.
- [x] Verified against live docs: plugin manifest/skills layout
      (code.claude.com/docs plugins reference) and the prompt-engineering page
      set + URLs (platform.claude.com — general page + Fable 5 / Sonnet 5 /
      Opus 4.8 per-model pages).
- [ ] Exercised end-to-end in a session on real tasks/prompts; results logged in
      `evidence.md`.
