---
name: skill-pr-review
description: Reviews pull requests that add or modify agent skills by combining structural validation, registry consistency checks, and PR hygiene analysis. Produces a structured pass/fail report with actionable findings. Use when asked to review a skill PR, check pull request quality, validate skill changes before merge, or prepare PR validation evidence.
compatibility:
  - git repository with `main` (or specified base) available locally
  - `jq` installed
  - `bash` and standard Unix tools available
---

# Skill PR Review

Review pull requests in this repository with a consistent quality gate for skill changes.

## Applicability Gate

Apply this skill when ANY of the following are true:

- The user asks to review a pull request that changes one or more skills.
- The user asks to validate PR quality before opening or merging.
- The user asks for a pre-merge check focused on skill correctness and repo conventions.
- The user asks for structured validation evidence to include in a PR.

Do NOT apply when:

- The user is creating a new skill from reference material (use `create-skill-from-refs`).
- The user is authoring or refactoring a single skill without PR context (use `audit-skill-for-cursor` or `improve`).
- The user only wants to create/update a PR description (use `gh-pr-creator`).

## Workflow

1. Detect changed skills in the current branch versus base (`main` by default).
2. Run structural checks for each changed skill using the existing validator.
3. Run registry and metadata consistency checks for changed/removed skills.
4. Evaluate PR hygiene (branch name, commit title format, focused scope).
5. Evaluate content quality for skill docs touched by the PR.
6. Produce a structured report and summarize merge readiness.

## Decision Table

| Change pattern | Review tiers |
|---|---|
| New skill directory added under `skills/` | Structural + Registry + PR Hygiene + Content Quality |
| Existing skill files modified | Structural + Registry + PR Hygiene + Content Quality |
| `skill-registry.json` or `scripts/` only | Registry + PR Hygiene |
| Build/package changes only | PR Hygiene |

## Scripts

| Script | Purpose | Execute or Read |
|---|---|---|
| [scripts/review-skill-pr.sh](scripts/review-skill-pr.sh) | Orchestrates changed-skill detection, structural checks, registry checks, and commit-format checks | Execute |
| [scripts/check-registry-consistency.sh](scripts/check-registry-consistency.sh) | Validates `skill-registry.json` entries and version parity with `metadata.json` | Execute |

## Output Contract

The final output must include:

1. **Summary**
   - Base branch used
   - Changed skills detected
   - Overall pass/fail
2. **Findings table**
   - ID, severity (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`)
   - Category (`Structural`, `Registry`, `PRHygiene`, `ContentQuality`)
   - Evidence and recommendation
3. **Validation details**
   - Structural validator outputs per skill
   - Registry consistency outputs
   - Commit-title format check results
4. **Merge recommendation**
   - `Safe to merge` or `Not safe to merge yet`
   - Required follow-ups when not safe

Use [assets/review-report-template.md](assets/review-report-template.md) as the markdown shape.

## Composition Table

| Related skill | How to combine |
|---|---|
| `gh-pr-creator` | Paste the validation summary into the PR Validation section. |
| `commit-hygiene` | Use findings to split/fix commits before opening or updating the PR. |
| `create-skill-from-refs` | Run this review after new-skill authoring is complete and committed. |

## Procedure

1. Run `scripts/review-skill-pr.sh --base main --format json`.
2. Convert JSON results into the review report format.
3. Add agent-evaluated findings for PR hygiene and content quality.
4. If blocking findings exist, provide concrete remediation steps.
5. If requested, rerun after fixes and compare deltas.

## Confirmation Policy

This skill is review-focused and does not require editing by default. If the user asks to apply fixes, propose diffs first and wait for explicit confirmation before changing files.
