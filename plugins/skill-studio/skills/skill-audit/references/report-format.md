# Audit Report Format

Produce a scorecard per skill. Keep it skimmable; lead with the verdict and cite
concrete evidence, not generic advice.

## Per-skill scorecard

Use this shape:

### `<plugin>:<skill>` — PASS | NEEDS WORK | SPLIT CANDIDATE

- **Archetype:** one archetype, or "ambiguous: X + Y → split"
- **Single responsibility:** pass/warn/fail — one line of evidence
- **Composability:** pass/warn/fail — evidence
- **Context efficiency:** pass/warn/fail — cite checker numbers (lines, heavy
  refs); is `SKILL.md` a lean hub dispatching to spokes? name any
  `orphan_references` (shipped, never pointed to) or `dangling_skill_links`
- **Maintainability:** pass/warn/fail — evidence
- **Instruction craft:** pass/warn/fail — right altitude (not railroading with
  step-locked prose); sound first-run setup (detect-ask-persist config,
  AskUserQuestion for choices, no committed user values); earns its context
  (non-obvious knowledge, not restating what the model already knows); and has its
  highest-signal content — a quality gotchas section (cite `gotchas_section`; for a
  knowledge/reference/integration skill, absence is a warn). Cite the offending
  passage (see `authoring-for-claude.md`)
- **Evidence:** pass/warn/fail — has `evals/evals.json` (cite `eval_count`) + a
  committed baseline snapshot? For an official skill, no suite is a **warn**
  (no evidence backing its behavior); see `docs/marketplace-governance.md`
- **Manifest:** `claude plugin validate` pass/fail

**Top fixes (prioritized):**
1. highest-impact fix → hand to `skill-maintainer`
2. ...

Distinguish **fail** (violates the contract: missing/invalid metadata, legacy
frontmatter fields, cross-package relative link, description missing WHAT/WHEN)
from **warn** (quality smell: borderline length, missing reference TOC, thin
description). Reserve PASS for skills with no fails and at most minor warns.

## Sweep summary (`--all`)

Lead with a table, then the per-skill scorecards worst-first:

| Plugin | Skill | Archetype | Verdict | Top issue |
|---|---|---|---|---|

End with the count by verdict and the single highest-leverage fix across the
marketplace.

## Routing fixes

This skill does not edit. For each recommended fix, point at
`/repo-governance:skill-maintainer` with the specific change. Example:

> Use `/repo-governance:skill-maintainer` to move the `version` / `last_reviewed`
> frontmatter fields in `argocd-incident-ops` into `metadata.json` (Claude reads
> only `name` + `description`).
