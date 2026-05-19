# Evaluation Workflow

Use the bundled skill's evaluation flow when you need proof that a skill or pack
authoring change actually improves outcomes rather than just sounding better.

## Suggested loop

1. Define a small eval set with realistic prompts and expected outcomes.
2. Create an iteration workspace under `.work/`.
3. Run baseline and candidate executions into separate folders.
4. Grade outputs with the installed `skill-creator-grader` subagent.
5. Aggregate benchmark data with `scripts/aggregate_benchmark.py`.
6. Launch the review UI with `eval-viewer/generate_review.py`.
7. Use `skill-creator-analyzer` to surface patterns hidden by aggregate metrics.
8. Iterate on the bundled skill or pack content and repeat.

For skill-vs-skill comparisons, use
[skill-comparison.md](skill-comparison.md) first. It adds a source-structure
audit and blind output comparison on top of this generic eval loop.

## Workspace shape

```text
.work/skill-creator/<artifact-name>/
  iteration-1/
    eval-0/
      with_skill/
        run-1/
          outputs/
      baseline/
        run-1/
          outputs/
```

The bundled references include JSON shapes for `eval_metadata.json`,
`grading.json`, and `benchmark.json`.

Use `scripts/bootstrap_skill_comparison.py` when you need repeatable directory
setup for two-skill comparisons.
