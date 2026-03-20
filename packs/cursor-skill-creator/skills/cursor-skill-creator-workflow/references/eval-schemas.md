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
