# simplify-skill

Maintainer notes. The skill itself is [SKILL.md](SKILL.md).

## Why this exists

Two authoring registers are in use in this repo, and the choice between them was being made
by habit rather than by evidence.

**Rigid** — binding rules, falsifiability gates, tables, restated gotchas, rationale for
each constraint. It enforces behavior under pressure and survives an agent that is rushing.
It also costs context on every invocation and is expensive to keep coherent.

**Kit** — the [cursor-team-kit](https://github.com/cursor/team-kit) shape: under ~60 lines,
`Trigger` / `Workflow` / `Guardrails` / `Output`, plain sentences, no tables, bash only when
the exact flags matter. Legible, cheap, and it trusts the model. It also has nowhere to put
a rule that only matters when the model is under pressure.

This skill does not pick a winner. It produces the kit-register variant *beside* the
original and reports the delta, so the tradeoff is visible in a specific case instead of
argued in the abstract.

## The classification is the whole idea

Line count is a symptom. The question is which lines are load-bearing.

The `CHANGELOG.md` is the sharpest instrument available: a rule added after something
actually went wrong is load-bearing by demonstration. A rule present since the first commit,
with a paragraph defending it, is usually the author reassuring themselves. Reading the
changelog before the skill body inverts the usual order and is the single highest-value step
in the workflow.

Two escape hatches keep this from degenerating into line-count golf:

- A load-bearing rule may break the register, and the report must say which ones did.
- The frontmatter description is exempt. Length there buys triggering; a skill that stops
  firing has been simplified to zero.

## Calibration available in this repo

Three skills cover the same discipline — distilling a PR description — at three registers.
Read them in this order for a sense of what each register can and cannot hold (by name, not
by path: installed plugins are copied to a cache, so relative links across skills break):

- `gh-pr-creator` — rigid. Binding rules, falsifiability gates, a gotchas section.
- `gh-pr-make-reviewable` — middle. Diagnostic tables, a bundled script, worked examples.
- `gh-pr-distill` — kit. One deletion test, two lists, guardrails.

`gh-pr-distill`'s own README records the two candidates it was chosen between, which is a
worked example of the comparison this skill automates.

## Not yet done

No eval baseline. `evals/evals.json` is a suite only — no runs have been executed, so there
is no pass-rate evidence that the classification actually holds up on a real rigid skill.
The trap worth watching is eval-1: whether an enforcement rule survives when the register
says it should not fit.
