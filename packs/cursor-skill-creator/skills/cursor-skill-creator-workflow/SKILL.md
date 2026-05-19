---
name: cursor-skill-creator-workflow
description: Use when creating a Cursor pack or installed skill from reference material, adapting a Claude-style skill or plugin-like folder into Cursor-native artifacts, comparing two skills, or setting up an eval and review loop for authoring workflows.
---

# Cursor Skill Creator Workflow

Create or adapt Cursor-native authoring artifacts without collapsing packs,
skills, rules, and helper prompts into one mixed bundle.

## Use This Skill For

- creating a new Cursor pack from docs, examples, or existing workflows
- importing or normalizing a standard repo-root skill from external material
- adapting a Claude-style skill or plugin-like folder into Cursor-native assets
- comparing two skills to decide which is more effective, maintainable, or ready
  to import
- deciding whether content should become a bundled skill, a subagent, docs, or a
  strict rule
- setting up a review or benchmark loop for authoring work

Do not use this skill for ordinary code implementation unrelated to pack or skill
authoring.

## Core Model

- `skills/` are routing and knowledge
- repo-root standard skills are best when the source is primarily reusable
  guidance and does not need an installable runtime bundle
- `packs/` are installable runtime bundles
- bundled skills are still skills; the pack is only their delivery channel
- subagents handle bounded helper work such as grading, comparison, or bootstrap
- rules enforce persistent project guidance, not long-form methodology

## Workflow

1. Inspect the source material and classify it into:
   - pack runtime
   - bundled skill guidance
   - docs or references
   - excluded Claude-only material
2. Choose the smallest correct destination shape:
   - standard repo-root skill
   - pack only
   - pack with bundled skill
   - docs only
3. Define the pack contract before scaffolding files:
   - pack name
   - targets
   - profiles
   - artifact matrix
4. Keep the hot path small:
   - move templates and schemas into `assets/` and `references/`
   - move deterministic repeatable work into scripts
5. When behavior needs proof, set up an eval workspace and run the review loop.

## Routing

If the source is a mixed Claude-style plugin or plugin-like folder:

- read `references/decomposition-guide.md`
- use `assets/templates/adaptation-report.md`
- prefer bundled skills over copying guidance into rules

If the source is reference material for a new pack:

- read `references/pack-standard.md`
- use `assets/templates/bundled-skill-artifact.fragment.json`
- define the pack contract before creating files

If the source is already mostly a reusable skill with references or scripts:

- prefer a standard repo-root skill over a new pack
- keep the hot path in `SKILL.md`
- move heavy material into `references/` or `scripts/`

If you need to compare two skills:

- read `references/skill-comparison-workflow.md`
- bootstrap the workspace with `scripts/bootstrap_skill_comparison.py`
- use `skill-creator-structural-auditor` for source-level comparison
- use `skill-creator-comparator` only for blind output comparison
- treat trigger-rate optimization as out of scope unless a Cursor-specific
  harness has been chosen

If you need evidence that a change actually improved the artifact:

- create an iteration workspace under `.work/`
- use the installed helper subagents:
  - `skill-creator-bootstrapper`
  - `skill-creator-structural-auditor`
  - `skill-creator-grader`
  - `skill-creator-analyzer`
  - `skill-creator-comparator`
- use the bundled scripts and review UI

## Eval Loop

1. Create a small eval set with realistic prompts.
2. Run candidate and baseline outputs into separate directories.
3. Grade with `skill-creator-grader`.
4. Aggregate results with `scripts/aggregate_benchmark.py`.
5. Generate a review UI with `eval-viewer/generate_review.py`.
6. Use `skill-creator-analyzer` to interpret benchmark patterns.
7. If needed, compare two outputs blindly with `skill-creator-comparator`.

## Skill Comparison Loop

1. Choose shared eval prompts that both skills should handle.
2. Bootstrap an iteration workspace with
   `scripts/bootstrap_skill_comparison.py`.
3. Run each skill against the same evals and save outputs under separate
   configuration directories.
4. Grade both configurations with `skill-creator-grader`.
5. Use `skill-creator-comparator` for blind output-level A/B decisions.
6. Use `skill-creator-structural-auditor` to compare source structure,
   metadata, hot-path size, references, scripts, and repo fit.
7. Aggregate metrics, generate the review UI, and use `skill-creator-analyzer`
   to produce the final recommendation.

## Bundled Resources

- `references/pack-standard.md`: repo-style pack contract and artifact rules
- `references/decomposition-guide.md`: how to split mixed sources into the
  smallest correct Cursor-native shape
- `references/eval-schemas.md`: JSON shapes for eval metadata and results
- `references/skill-comparison-workflow.md`: fair skill-vs-skill comparison
  procedure and workspace conventions
- `assets/templates/adaptation-report.md`: concise migration report structure
- `assets/templates/bundled-skill-artifact.fragment.json`: manifest fragment for
  pack-bundled skills
- `scripts/bootstrap_skill_comparison.py`: create comparison workspaces and eval
  metadata without running agents
- `scripts/aggregate_benchmark.py`: summarize pass rate, timing, and token data
- `eval-viewer/generate_review.py`: generate or serve the review UI

## Common Mistakes

- Treating a source skill tree as if it were already a pack
- Referencing repo-local top-level skills from installed bundled skills
- Copying long guidance into rules instead of a bundled skill
- Porting Claude-only CLI automation without redesigning the execution model
- Comparing skill prose only and skipping output behavior evidence
- Skipping the artifact matrix and discovering the pack shape mid-edit
