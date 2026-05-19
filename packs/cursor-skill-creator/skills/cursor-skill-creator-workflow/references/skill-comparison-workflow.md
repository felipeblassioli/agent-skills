# Skill Comparison Workflow

Use this workflow when deciding whether one skill is better than another, whether
an adaptation improved a skill, or whether an external candidate should be
imported.

## Comparison Modes

Use both modes when the decision matters:

- **Source comparison** checks the skill package itself: frontmatter, metadata,
  hot-path size, references, scripts, trigger clarity, safety, and repo fit.
- **Behavior comparison** runs the same eval prompts through both skills and
  compares outputs, grades, timing, and variance.

Do not declare a winner from source quality alone. A cleaner skill can still
produce worse outputs, and a verbose skill can hide useful operational detail.

## Workspace Layout

Create workspaces under `.work/skill-creator/`:

```text
.work/skill-creator/<comparison-name>/
  comparison_manifest.json
  evals.json
  skill_inventory.json
  iteration-1/
    eval-0-descriptive-name/
      eval_metadata.json
      skill-a/
        run-1/
          outputs/
      skill-b/
        run-1/
          outputs/
```

Use stable configuration labels such as `skill-a` and `skill-b` until the blind
comparison step is finished. Record the real skill paths in
`comparison_manifest.json` rather than in the output directories.

## Fairness Rules

- Use the same model, tools, workspace state, and input files for both skills.
- Run both skills against the same prompt text and same expected outcomes.
- Snapshot any skill being changed before editing it.
- Keep skill labels hidden from blind comparators.
- Use at least two or three runs for high-variance prompts.
- Capture `timing.json` when subagent completion metadata includes duration or
  token counts.
- Preserve transcripts when available; they explain why a skill won or failed.

## Procedure

1. Write or review `evals.json` with realistic prompts and expectations.
2. Run `scripts/bootstrap_skill_comparison.py` to create the workspace.
3. Ask one executor per skill/eval/run to save outputs into the assigned
   `outputs/` directory.
4. Grade each run with `skill-creator-grader`; save `grading.json` next to the
   run directory.
5. For each eval, pass output A and output B to `skill-creator-comparator`
   without revealing which skill produced which output.
6. Run `skill-creator-structural-auditor` on both source skill paths and save
   `skill_inventory.json` or a structural comparison report.
7. Run `scripts/aggregate_benchmark.py` on the iteration directory.
8. Generate a static or served review UI with `eval-viewer/generate_review.py`.
9. Use `skill-creator-analyzer` to combine grades, blind comparisons,
   structural findings, and human feedback into the recommendation.

## Recommendation Standard

The final recommendation should answer:

- Which skill should be preferred now?
- What evidence supports the decision?
- Which result depends on output behavior versus source maintainability?
- What should be copied, rewritten, or discarded?
- What remains untested?

If the comparison only checks source structure, call it a source audit. If it
only checks outputs, call it an output benchmark. Reserve "skill comparison" for
workflows that combine both.

## Out Of Scope

This workflow does not test whether Cursor will automatically trigger a skill
from its description. Treat trigger-rate optimization as a separate workflow
until a Cursor-native harness is chosen.
