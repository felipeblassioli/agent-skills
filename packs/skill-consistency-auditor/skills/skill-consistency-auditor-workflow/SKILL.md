---
name: skill-consistency-auditor-workflow
description: Use when you need to audit installed skills to detect overlap, redundancy, vague triggers, or inconsistency with docs/architecture.md. Invoke explicitly via /skill-consistency-auditor-workflow.
disable-model-invocation: true
---

# Skill Consistency Auditor Workflow

This workflow uses specialist subagents to safely analyze a large directory of installed skills without polluting your primary context window. 

## When to Use

- You notice agents frequently picking the wrong skill.
- You suspect a new skill overlaps heavily with an existing one.
- You want to clean up duplicate names, vague descriptions, or bad bundling.
- You want to check if the installed skills align with `docs/architecture.md`.

Do NOT use this for code linting or ordinary implementation work.

## Procedure

1. **Inventory the target.** Determine which directory needs auditing (e.g., `~/.agents/skills` or `~/.cursor/skills`).
2. **Cluster.** Dispatch the `skill-overlap-clusterer` subagent to group the target skills heuristically based on their `SKILL.md` descriptions and bodies.
3. **Check Architecture.** Dispatch the `skill-architecture-checker` subagent to verify that the skills respect the rules defined in `docs/architecture.md` (e.g., proper frontmatter, progressive disclosure).
4. **Advise.** Dispatch the `skill-consolidation-advisor` subagent with the outputs of the cluster and architecture checks to produce a scored overlap report.
5. **Review.** Present the report to the user using the `assets/report-template.md` format.
6. **Act.** Only apply fixes (renames, anti-triggers, archives) if the user explicitly approves the proposal.

## Expected Subagent Usage

Do not attempt to read 50+ `SKILL.md` files in the main conversation thread.

- Use `skill-overlap-clusterer` with a target directory and a filter (e.g., "only skills starting with `gsd-`" or "only testing-related skills").
- Use `skill-architecture-checker` against specific folders that seem non-compliant.
- Use `skill-consolidation-advisor` to synthesize the findings.

All subagents operate in read-only mode by default.
