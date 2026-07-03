---
name: skill-enhance
description: Improve an EXISTING Claude skill or plugin. Use when the user wants to make a skill better, recommend the highest-leverage improvements, tighten a description or hot path, refactor a skill, or PROVE a change helped by running an eval/benchmark loop (with-skill vs baseline, grade, blind A/B compare, aggregate, review). Triggers on "how can I improve this skill", "make this skill better", "benchmark this skill", "did my edit help", "run evals on this skill", "compare these two skill versions", "is the candidate better than current". NOT for creating a new skill from scratch (use skill-create), NOT for a pure read-only quality/overlap audit with no proposed change (use skill-audit), NOT for versioning/release/registry work (use repo-governance:skill-maintainer).
---

# skill-enhance

Make an existing skill or plugin better, and prove it. Two surfaces:

- **(A) Improvement recommendation** — diagnose the artifact, then deliver
  1–3 ranked, effort/risk-scored recommendations.
- **(B) Eval / benchmark loop** — run the changed skill against a baseline
  and produce evidence that the change actually helped.

They compose: recommend first, then prove the risky recommendations with the
loop. Do not run the loop for trivial wording edits — it has setup cost.

## When NOT to use this skill

- Creating a new skill from scratch, distilling reference material into a new
  skill, or scaffolding a plugin → use **skill-create**.
- A pure read-only quality, context-efficiency, or portfolio-overlap audit
  with no proposed change → use **skill-audit**.
- Versioning, release, CHANGELOG bumps, or registry/marketplace governance →
  use **repo-governance:skill-maintainer**.

If the request is "audit AND improve", run the audit view of skill-audit for
evidence, then return here for the ranked recommendations.

## Intent router

| The user wants… | Go to |
|---|---|
| "How can I improve this skill?" / "make it better" | **(A) Improvement recommendation** |
| "Tighten the description / hot path" | **(A)** (leverage: triggering first) |
| "This plugin has overlapping skills" | **(A)**, plugin scope |
| "Did my edit help?" / "prove it" | **(B) Eval loop** |
| "Benchmark this skill" / "run evals" | **(B)** |
| "Is the candidate better than current?" | **(B)**, with-skill vs baseline |
| "Compare these two skill versions" | **(B)**, source + behavior |

---

## (A) Improvement recommendation

Goal: the 1–3 highest-leverage changes, each tied to a concrete expected
outcome and scored by effort/risk. Bias toward the smallest viable refactor.

### 1. Diagnose

Read the artifact and classify it:

- **Single skill** (a `SKILL.md` package) → use
  [references/skill-improvement.md](references/skill-improvement.md).
- **Plugin** (a `.claude-plugin/plugin.json` bundling skills, subagents,
  commands) → use [references/plugin-improvement.md](references/plugin-improvement.md).

Work the review dimensions in order (current job → triggering → hot path →
progressive disclosure → boundaries → behavior). Ask only the diagnostic
questions whose answers you cannot infer from the source.

Prefer measured evidence over estimates. If you need hot-path numbers
(description length, `SKILL.md` lines, cross-skill duplication), run the
hot-path audit from the sibling **skill-audit** skill and quote its fields
directly. Do not paraphrase token counts.

### 2. Rank

Order candidate changes by leverage. Default priority:

1. **Triggering** — a broad/vague/colliding description wastes every other
   improvement. Fix WHAT + WHEN + anti-triggers first.
2. **Hot-path size** — move heavy inline detail to one-hop references.
3. **Boundaries** — split a genuine multi-job skill, or extract shared
   doctrine across a plugin's skills into one reference.
4. **Prose** — clarity edits, last.

Keep the smallest viable refactor. Recommend a split only when the skill truly
has multiple jobs.

### 3. Recommend

Fill in [assets/templates/improvement-recommendation.md](assets/templates/improvement-recommendation.md).
For each recommendation give: the change, why it is the highest leverage here,
the expected outcome, an effort/risk score (low/medium/high), and whether it
needs the eval loop to prove.

Also record what to **keep as-is** and any open questions. If any recommended
change could regress behavior, flag it for the loop in (B).

---

## (B) Eval / benchmark loop

Goal: evidence that a change helped — with-skill vs baseline, graded, blind
A/B compared, aggregated, reviewed. Full methodology and JSON schemas:
[references/eval-loop.md](references/eval-loop.md).

Run both a **source comparison** (package shape, triggers, hot path) and a
**behavior comparison** (same prompts through both). Never declare a winner
from source quality alone.

### Steps

1. **Define evals.** Write `evals.json` with realistic prompts and expected
   outcomes (schema in the reference). Pick the baseline:
   - candidate skill vs current skill (proves a change helped), or
   - candidate skill vs no-skill (proves the skill helps at all).
   Snapshot the baseline before editing so it is a fixed reference.

2. **Bootstrap the workspace.**
   ```bash
   python3 scripts/bootstrap_skill_comparison.py \
     --comparison-name candidate-vs-current \
     --skill-a <baseline-path> --skill-b <candidate-path> \
     --evals <path>/evals.json --runs 3
   ```
   This scaffolds `.work/skill-creator/<name>/iteration-N/` with per-eval,
   per-label (`skill-a`/`skill-b`), per-run `outputs/` dirs. Labels stay
   opaque so the blind compare is fair.

3. **Run.** One executor per variant/eval/run saves its result into the
   assigned `outputs/` dir. Same model, tools, workspace state, and input
   files for both variants. Use ≥2–3 runs for high-variance prompts.

4. **Grade.** Dispatch the **skill-creator-grader** subagent per run against
   the eval's expectations; it writes `grading.json` next to the run.

5. **Blind compare.** For each eval, hand output A and output B to the
   **skill-creator-comparator** subagent *without* revealing which variant
   produced which. It writes `comparison.json` (winner A/B/TIE + reasoning).

6. **Source audit.** Run the **skill-creator-structural-auditor** subagent on
   both source skill paths for package shape, trigger clarity, and hot-path
   size; save `skill_inventory.json`.

7. **Aggregate.**
   ```bash
   python3 scripts/aggregate_benchmark.py \
     .work/skill-creator/<name>/iteration-N \
     --skill-name <name> --skill-path <candidate-path>
   ```
   Produces `benchmark.json` + `benchmark.md` with per-config pass-rate,
   time, tokens (mean ± stddev) and the candidate−baseline delta.

8. **Review.** Serve or export the viewer:
   ```bash
   python3 scripts/eval-viewer/generate_review.py \
     .work/skill-creator/<name>/iteration-N \
     --benchmark .work/skill-creator/<name>/iteration-N/benchmark.json
   ```
   Add `--static out.html` to write a standalone page instead of serving.
   Feedback auto-saves to `feedback.json` in the workspace.

9. **Interpret & recommend.** Dispatch the **skill-creator-analyzer**
   subagent to combine grades, blind comparisons, structural findings, and
   any human feedback into `analysis.json`: which variant wins, the
   supporting evidence, what is behavior-driven vs source-driven, and what
   remains untested.

### Interpreting the result

- Pass-rate delta is the headline; a gain swamped by stddev is noise — add runs.
- Blind comparisons break ties the rubric misses.
- A candidate that matches the baseline pass rate but costs far more is not a win.
- On a behavior tie, prefer the smaller hot path.
- Source findings explain *why* but never override behavior.

---

## Gotchas

- **Do not judge from source alone.** A cleaner package can produce worse
  outputs. Behavior comparison decides; source audit explains.
- **Keep labels blind.** Record real skill paths in `comparison_manifest.json`,
  never in the `outputs/` directory names, or the blind compare is tainted.
- **Fix the baseline.** Snapshot the skill before editing; comparing against a
  moving target proves nothing.
- **Fairness is everything.** Same model, tools, workspace, and inputs for both
  variants, or the delta is meaningless.
- **Single-run deltas are anecdotes.** Use ≥2–3 runs on high-variance prompts;
  stddev tells you whether the delta is real.
- **This loop measures output quality, not trigger rate.** It does not test
  whether the harness auto-activates the skill from its description — that is a
  separate concern.
- **Right tool for the phase.** Recommending changes lives here; a pure audit
  with no change is skill-audit; a new skill is skill-create; releasing the
  improved skill is repo-governance:skill-maintainer.
