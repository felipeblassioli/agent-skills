# Eval Loop and JSON Schemas

Use this reference when you need evidence that an authoring change actually
improved a skill or pack — comparing two skills, validating an adaptation,
deciding whether to import an external candidate.

Merged from the `skill-comparison-workflow` and `eval-schemas` references
of the deprecated `cursor-skill-creator-workflow` bundled skill.

## When to run an eval loop

- The user wants to know whether one skill is better than another.
- An adaptation or refactor needs proof before being merged.
- An external candidate is being evaluated for import.
- A behavioral regression is suspected after editing a skill.

Skip the eval loop for trivial wording edits — the loop has setup cost.

## Comparison modes

Use both modes when the decision matters:

- **Source comparison** checks the skill package itself: frontmatter, metadata,
  hot-path size, references, scripts, trigger clarity, safety, repo fit.
- **Behavior comparison** runs the same eval prompts through both skills and
  compares outputs, grades, timing, and variance.

Do not declare a winner from source quality alone. A cleaner skill can still
produce worse outputs, and a verbose skill can hide useful operational detail.

## Workspace layout

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

Use stable configuration labels such as `skill-a` and `skill-b` until the
blind comparison step is finished. Record the real skill paths in
`comparison_manifest.json` rather than in the output directories.

## Fairness rules

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
4. Grade each run with the `skill-creator-grader` subagent; save `grading.json`
   next to the run directory.
5. For each eval, pass output A and output B to `skill-creator-comparator`
   without revealing which skill produced which output.
6. Run `skill-creator-structural-auditor` on both source skill paths and save
   `skill_inventory.json` or a structural comparison report.
7. Run `scripts/aggregate_benchmark.py` on the iteration directory.
8. Generate a static or served review UI with `eval-viewer/generate_review.py`.
9. Use `skill-creator-analyzer` to combine grades, blind comparisons,
   structural findings, and human feedback into the recommendation.

## Recommendation standard

The final recommendation should answer:

- Which skill should be preferred now?
- What evidence supports the decision?
- Which result depends on output behavior versus source maintainability?
- What should be copied, rewritten, or discarded?
- What remains untested?

If the comparison only checks source structure, call it a source audit. If it
only checks outputs, call it an output benchmark. Reserve "skill comparison"
for workflows that combine both.

## Out of scope

This loop does not test whether Cursor will automatically trigger a skill from
its description. Treat trigger-rate optimization as a separate workflow until
a Cursor-native harness is chosen.

---

## JSON schemas

### `evals.json`

```json
{
  "skill_name": "artifact-name",
  "evals": [
    {
      "id": 0,
      "prompt": "Realistic user prompt",
      "expected_output": "Short description of the expected result",
      "files": []
    }
  ]
}
```

### `eval_metadata.json`

```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name",
  "prompt": "Realistic user prompt",
  "assertions": [
    "The output follows the requested structure"
  ]
}
```

### `grading.json`

```json
{
  "expectations": [
    {
      "text": "The output follows the requested structure",
      "passed": true,
      "evidence": "Verified in outputs/result.md headings"
    }
  ],
  "summary": {
    "passed": 1,
    "failed": 0,
    "total": 1,
    "pass_rate": 1.0
  }
}
```

### `benchmark.json`

```json
{
  "metadata": {
    "skill_name": "artifact-name",
    "skill_path": "<path>",
    "timestamp": "2026-03-20T00:00:00Z",
    "evals_run": [0],
    "runs_per_configuration": 1
  },
  "runs": [],
  "run_summary": {},
  "notes": []
}
```

### `comparison_manifest.json`

```json
{
  "comparison_name": "candidate-vs-current",
  "created_at": "2026-05-19T18:00:00Z",
  "iteration": "iteration-1",
  "configurations": [
    {"label": "skill-a", "skill_path": "skills/current-skill", "role": "baseline"},
    {"label": "skill-b", "skill_path": "tmp/candidate-skill", "role": "candidate"}
  ],
  "evals_path": "evals.json",
  "runs_per_configuration": 1
}
```

Use labels such as `skill-a` and `skill-b` for output directories so blind
comparators do not infer which skill produced an output.

### `comparison.json`

```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name",
  "winner": "A",
  "reasoning": "Output A completes the requested workflow with clearer evidence.",
  "output_quality": {
    "A": {"score": 9, "strengths": ["Complete", "Evidence-backed"], "weaknesses": []},
    "B": {"score": 6, "strengths": ["Readable"], "weaknesses": ["Missed one required artifact"]}
  },
  "expectation_results": {
    "A": {"passed": 3, "total": 3, "pass_rate": 1.0},
    "B": {"passed": 2, "total": 3, "pass_rate": 0.67}
  }
}
```

`winner` must be `A`, `B`, or `TIE`. Store one comparison per eval or run when
you need detailed traceability.

### `skill_inventory.json`

```json
{
  "generated_at": "2026-05-19T18:00:00Z",
  "skills": [
    {
      "label": "skill-a",
      "skill_path": "skills/current-skill",
      "frontmatter": {"name": "current-skill", "description": "Use when..."},
      "metadata": {"version": "1.0.0", "author": "felipeblassioli", "date": "2026-05-19", "abstract": "..."},
      "package_shape": {"has_skill_md": true, "has_metadata_json": true, "reference_count": 2, "script_count": 1},
      "hot_path": {"skill_md_lines": 120, "description_chars": 180}
    }
  ],
  "findings": [
    {
      "severity": "medium",
      "skill": "skill-b",
      "finding": "Description mixes trigger conditions with process details.",
      "evidence": "Frontmatter description is 940 characters and lists workflow steps."
    }
  ]
}
```

Use `skill_inventory.json` for structural/source audit output. It complements
behavioral benchmark data; it does not replace eval runs.

### `analysis.json`

```json
{
  "recommendation": "prefer-skill-a",
  "confidence": "medium",
  "evidence": [
    "skill-a won 2 of 3 blind comparisons",
    "skill-b had higher token cost with no pass-rate gain"
  ],
  "source_findings": [
    "skill-a has clearer trigger boundaries",
    "skill-b has a reusable script worth preserving"
  ],
  "next_steps": [
    "Keep skill-a as the base",
    "Port skill-b's validation script into skill-a after review"
  ],
  "residual_risks": [
    "Trigger-rate behavior was not measured"
  ]
}
```
