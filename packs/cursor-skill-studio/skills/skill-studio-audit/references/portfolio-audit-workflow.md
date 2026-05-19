# Portfolio Audit Workflow

Use this workflow when the user wants to audit an installed skill directory
(`~/.cursor/skills`, `~/.agents/skills`, or `~/.claude/skills`) or a large
in-repo skill catalog for overlap, redundancy, vague triggers, and compliance
with `docs/architecture.md`.

Lifted from the deprecated `skill-consistency-auditor-workflow` bundled skill;
the three subagents it orchestrates are now bundled with this pack.

## When to use this branch

- Agents frequently pick the wrong skill.
- A new skill seems to overlap heavily with an existing one.
- The installed catalog has accumulated duplicate names, vague descriptions,
  or bad bundling.
- The user wants to know whether installed skills align with
  `docs/architecture.md`.

Do NOT use this branch for ordinary code linting, single-file audits (see
`references/single-skill-audit.md`), or for repo-wide first-party audits where
the canonical methodology in `docs/specs/skill-overlap-audit.md` is required
(see `references/repo-skills-overlap-audit.md` for the lighter pointer).

## Procedure

1. **Inventory the target.** Determine which directory needs auditing
   (e.g., `~/.agents/skills` or `~/.cursor/skills`). State scope explicitly
   before dispatching subagents.
2. **Cluster.** Dispatch the `skill-overlap-clusterer` subagent to group the
   target skills heuristically based on their `SKILL.md` descriptions and
   bodies.
3. **Check architecture.** Dispatch the `skill-architecture-checker` subagent
   to verify the skills respect the rules defined in `docs/architecture.md`
   (frontmatter shape, progressive disclosure, surface fit).
4. **Advise.** Dispatch the `skill-consolidation-advisor` subagent with the
   outputs of the cluster and architecture checks to produce a scored overlap
   report.
5. **Review.** Present the report to the user using
   `assets/templates/portfolio-audit-report.md`.
6. **Act.** Only apply fixes (renames, anti-triggers, archives) if the user
   explicitly approves the proposal.

## Subagent expectations

Do not attempt to read 50+ `SKILL.md` files in the main conversation thread.

- Use `skill-overlap-clusterer` with a target directory and a filter
  (e.g., "only skills starting with `gsd-`" or "only testing-related skills").
- Use `skill-architecture-checker` against specific folders that look
  non-compliant, not the entire directory at once.
- Use `skill-consolidation-advisor` to synthesize the findings; pass it the
  clusterer + architecture outputs together.

All three subagents operate in read-only mode by default.

## Output contract

Present the final report using
`assets/templates/portfolio-audit-report.md`. The report MUST include:

- Executive summary (one paragraph).
- Cluster table (group name, member skills, severity).
- Architecture compliance violations (file, rule, severity).
- Proposed actions (rename, anti-trigger, archive, cross-link), each with a
  confidence score and rationale.

Apply changes only after the user approves.

## See Also

- `references/single-skill-audit.md` — single-skill compliance review.
- `references/repo-skills-overlap-audit.md` — repo-first-party deep overlap
  methodology.
- `docs/architecture.md` — compliance authority.
