# Skill Comparison

Use this workflow to compare two skills before importing, replacing, or
promoting one of them.

## What The Workflow Proves

The comparison combines two evidence types:

- **Behavior evidence**: both skills run against the same eval prompts, then
  outputs are graded and optionally compared blindly.
- **Source evidence**: both skill folders are audited for frontmatter, metadata,
  hot-path size, references, scripts, safety, and repo fit.

The final recommendation should identify which evidence type supports each
claim. Trigger-rate behavior is not measured in this version.

## Quick Start

Prepare an `evals.json` file:

```json
{
  "skill_name": "candidate-vs-current",
  "evals": [
    {
      "id": 0,
      "name": "realistic-task",
      "prompt": "Compare these two API docs and produce a migration summary.",
      "expected_output": "A concise migration summary with risks and next steps.",
      "files": [],
      "expectations": [
        "The output names at least one migration risk",
        "The output distinguishes required changes from optional improvements"
      ]
    }
  ]
}
```

Bootstrap the workspace:

```bash
python3 packs/cursor-skill-studio/skills/skill-studio-write/scripts/bootstrap_skill_comparison.py \
  --comparison-name candidate-vs-current \
  --skill-a skills/current-skill \
  --skill-b tmp/candidate-skill \
  --evals .work/candidate-vs-current/evals.json \
  --runs 1
```

This creates:

```text
.work/skill-creator/candidate-vs-current/
  comparison_manifest.json
  evals.json
  skill_inventory.json
  iteration-1/
    eval-0-realistic-task/
      eval_metadata.json
      skill-a/run-1/outputs/
      skill-b/run-1/outputs/
```

## Execution Loop

1. Run each skill against each eval and save outputs in the assigned
   `outputs/` directory.
2. Save transcripts beside each run when available.
3. Grade each run with `skill-creator-grader`.
4. Compare paired outputs blindly with `skill-creator-comparator`.
5. Audit source structure with `skill-creator-structural-auditor`.
6. Aggregate the iteration with `aggregate_benchmark.py`.
7. Generate the review UI with `eval-viewer/generate_review.py`.
8. Use `skill-creator-analyzer` for the final recommendation.

## Fairness Checklist

- Same eval prompt and input files for both skills.
- Same model and tool access for both runs.
- Stable skill labels during blind comparison.
- Multiple runs for flaky or subjective prompts.
- `timing.json` captured when token or duration metadata is available.
- Structural audit combined with behavior results before deciding.

## Interpreting Results

Prefer a skill when it has stronger behavior evidence and no blocking source
maintenance issues. If behavior is tied, use source evidence to choose the more
maintainable skill. If one skill wins behavior but has source problems, recommend
targeted edits rather than a full replacement.
