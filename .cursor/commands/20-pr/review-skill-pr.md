---
description: Review a pull request that changes skills. Runs structural and registry checks, evaluates PR hygiene, and returns a merge-readiness report. Do not change files unless the user explicitly asks to apply fixes.
---

## User Input

```text
$ARGUMENTS
```

Optional flags accepted from `$ARGUMENTS`:

- `--base=<branch>` (default `main`)
- `--format=json|markdown` (default `markdown`)
- `--json-only` (skip prose and print script JSON only)

## Goal

Review current branch changes as a skill-quality gate for pull requests:

1. Detect changed skills vs base branch
2. Validate touched skills structurally
3. Verify registry and metadata consistency
4. Evaluate PR hygiene and content quality
5. Return a structured report and merge recommendation

## Procedure

1. Resolve base branch from arguments (fallback `main`).
2. Execute:

```bash
bash skills/skill-pr-review/scripts/review-skill-pr.sh --base=<base> --format=json
```

3. Parse JSON output and map findings to severity categories:
   - Structural
   - Registry
   - PRHygiene
   - ContentQuality
4. Produce report using:
   - [skills/skill-pr-review/assets/review-report-template.md](../../../skills/skill-pr-review/assets/review-report-template.md)
   - [skills/skill-pr-review/references/review-criteria.md](../../../skills/skill-pr-review/references/review-criteria.md)
5. If blocking findings exist (`CRITICAL`/`HIGH`), mark as **Not safe to merge** with concrete actions.

## Output Contract

Always return:

- Summary (pass/fail, base, branch, changed skills)
- Findings table (ID, severity, category, evidence, recommendation)
- Structural and registry validation sections
- PR hygiene section (branch + commits)
- Merge recommendation

If `--json-only` is present, output only the JSON result from `review-skill-pr.sh`.

## Safety Rule

This command is read-only by default. If the user asks to fix findings, present proposed diffs first and wait for explicit confirmation before editing files.
