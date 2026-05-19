# Eval Schemas

Use these JSON shapes when building a bundled authoring review loop.

## `evals.json`

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

## `eval_metadata.json`

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

## `grading.json`

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

## `benchmark.json`

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

## `comparison_manifest.json`

```json
{
  "comparison_name": "candidate-vs-current",
  "created_at": "2026-05-19T18:00:00Z",
  "iteration": "iteration-1",
  "configurations": [
    {
      "label": "skill-a",
      "skill_path": "skills/current-skill",
      "role": "baseline"
    },
    {
      "label": "skill-b",
      "skill_path": "tmp/candidate-skill",
      "role": "candidate"
    }
  ],
  "evals_path": "evals.json",
  "runs_per_configuration": 1
}
```

Use labels such as `skill-a` and `skill-b` for output directories so blind
comparators do not infer which skill produced an output.

## `comparison.json`

```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name",
  "winner": "A",
  "reasoning": "Output A completes the requested workflow with clearer evidence.",
  "output_quality": {
    "A": {
      "score": 9,
      "strengths": ["Complete", "Evidence-backed"],
      "weaknesses": []
    },
    "B": {
      "score": 6,
      "strengths": ["Readable"],
      "weaknesses": ["Missed one required artifact"]
    }
  },
  "expectation_results": {
    "A": {
      "passed": 3,
      "total": 3,
      "pass_rate": 1.0
    },
    "B": {
      "passed": 2,
      "total": 3,
      "pass_rate": 0.67
    }
  }
}
```

`winner` must be `A`, `B`, or `TIE`. Store one comparison per eval or run when
you need detailed traceability.

## `skill_inventory.json`

```json
{
  "generated_at": "2026-05-19T18:00:00Z",
  "skills": [
    {
      "label": "skill-a",
      "skill_path": "skills/current-skill",
      "frontmatter": {
        "name": "current-skill",
        "description": "Use when..."
      },
      "metadata": {
        "version": "1.0.0",
        "author": "felipeblassioli",
        "date": "2026-05-19",
        "abstract": "..."
      },
      "package_shape": {
        "has_skill_md": true,
        "has_metadata_json": true,
        "reference_count": 2,
        "script_count": 1
      },
      "hot_path": {
        "skill_md_lines": 120,
        "description_chars": 180
      }
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

## `analysis.json`

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
