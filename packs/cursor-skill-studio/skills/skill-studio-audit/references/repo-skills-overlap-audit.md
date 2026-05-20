# Repo-First-Party Overlap Audit (deep)

Use this branch when the user wants a deep overlap audit of repo-first-party
skills under `skills/` (and optionally `packs/*/skills/`) rather than the
faster portfolio audit of installed skills.

The normative methodology lives in
[`docs/specs/skill-overlap-audit.md`](../../../../docs/specs/skill-overlap-audit.md).
This file is a thin adapter so the bundled skill stays one-hop away from it
without copying the spec verbatim.

## When to use this branch

- The user is preparing a consolidation ADR (like ADR-0005) and needs a
  defensible, scored consolidation plan with evidence.
- The audit scope is repo-first-party (`skills/<name>/`), not installed
  directories.
- The output must include a normalized skill inventory (versions, hot-path
  size, triggers, anti-triggers, references) for later programmatic use.
- The user explicitly wants the spec methodology (inventory → cluster A/B/C
  → arbiter), not the lighter installed-portfolio path.

Do NOT use when:

- The user just wants a quick installed-skills cleanup → use
  `references/portfolio-audit-workflow.md`.
- The user is auditing a single skill → use `references/single-skill-audit.md`.
- The user wants to refactor / write a new skill → hand off to
  `/skill-studio-write`.

## Procedure (high level)

The full procedure is in `docs/specs/skill-overlap-audit.md`. Summary:

1. **Inventory.** Read each skill's frontmatter and key body fields into a
   normalized JSON inventory; do this with cheap subagents in parallel rather
   than serially in the main thread.
2. **Cluster A — description similarity.** Group skills whose descriptions
   share triggers or scope keywords.
3. **Cluster B — body similarity.** Group skills whose SKILL.md bodies share
   reference files, scripts, or workflow steps.
4. **Cluster C — registry/tag similarity.** Cross-check with
   `skill-registry.json` tags and `description` overlap.
5. **Arbiter pass.** Reconcile the three clusters into final overlap groups
   with severity scores, then propose consolidation actions (merge, anti-
   trigger, archive, rename, cross-link).

## Subagent guidance

- Prefer **multiple cheap read-only subagents in parallel** for the inventory
  and the three cluster passes. The spec describes prompt shapes for each.
- The arbiter pass should still run as a single subagent that receives all
  three cluster outputs plus the inventory.
- Do NOT load the full body of more than a handful of skills in the main
  thread; pass paths or inventory entries to subagents instead.

## Output contract

Use `assets/templates/portfolio-audit-report.md` for the human-facing report,
augmented with:

- The normalized inventory JSON (attached or linked).
- The three cluster outputs (A/B/C) before the arbiter merged them.
- The arbiter's final overlap groups with severity, evidence, and proposed
  actions.

## See Also

- [`docs/specs/skill-overlap-audit.md`](../../../../docs/specs/skill-overlap-audit.md) — full normative spec.
- `references/portfolio-audit-workflow.md` — lighter installed-skills audit.
- `docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md` — example of an
  ADR produced from a deep repo overlap audit.
