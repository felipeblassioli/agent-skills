# Portfolio / Overlap Audit Workflow

Use this workflow when the user wants to audit a **set** of skills — an installed
skill directory (`~/.claude/skills`, `~/.cursor/skills`, `~/.agents/skills`) or a
plugin's `skills/` folder — for overlap, redundancy, trigger collisions, vague
descriptions, and bad bundling. This is the portfolio branch; for one skill use
`references/single-skill-audit.md`.

## When to use this branch

- Agents frequently pick the wrong skill (trigger collisions).
- A new skill seems to overlap heavily with an existing one.
- The catalog has accumulated duplicate names, vague descriptions, or bad
  bundling.
- The user wants to know whether a set of skills respects the best-practice
  compliance rules (bundled in `references/principles.md` and
  `references/archetypes.md`).

Do NOT use this branch for ordinary code linting or a single-skill audit
(`references/single-skill-audit.md`), or for the deeper repo-first-party
methodology when a defensible, scored consolidation plan is required
(`references/repo-skills-overlap-audit.md`).

## Procedure (three-subagent dispatch)

Do not read 50+ `SKILL.md` files in the main conversation thread. Delegate to the
three read-only subagents bundled in this plugin's `agents/` directory:

1. **Inventory the target.** Determine which directory needs auditing and state
   scope explicitly before dispatching subagents.
2. **Cluster.** Dispatch `skill-overlap-clusterer` with the target directory and
   an optional filter (e.g. "only skills starting with `gsd-`"), to group skills
   heuristically by description + body similarity.
3. **Check architecture.** Dispatch `skill-architecture-checker` against the
   folders the clusterer flagged as suspicious — not the entire directory at
   once. Pass the compliance rules **in your prompt** (excerpt them from
   `references/principles.md` / `references/archetypes.md`); the subagent cannot
   read repo files.
4. **Advise.** Dispatch `skill-consolidation-advisor` with the cluster +
   architecture outputs to produce a scored overlap report. Pass it the report
   format from `assets/templates/portfolio-audit-report.md` in its prompt.
5. **Review.** Present the report using
   `assets/templates/portfolio-audit-report.md`. Pause for approval.
6. **Act.** Renames, anti-triggers, or archives happen only after explicit
   approval — and this skill never applies them itself; route them to a
   maintainer skill by name.

## Subagent expectations

| Subagent | Use for |
|---|---|
| `skill-overlap-clusterer` | Heuristic clustering of a directory by description + body similarity. Scope with a glob filter on >~50 skills or the output is noise. |
| `skill-architecture-checker` | Compliance spot-check against the rules you pass in its prompt (bundled — not a repo file). |
| `skill-consolidation-advisor` | Synthesize cluster + architecture outputs into a scored consolidation report. |

All three operate read-only.

## Output contract

Present the final report using
`assets/templates/portfolio-audit-report.md`. It MUST include:

- Executive summary (one paragraph).
- Cluster table (group name, member skills, confusion risk / severity).
- Compliance violations (file, rule, severity).
- Proposed actions (rename, anti-trigger, archive, cross-link), each with a
  confidence score and rationale.

Apply changes only after the user approves.

## See Also

- `references/single-skill-audit.md` — single-skill compliance review.
- `references/repo-skills-overlap-audit.md` — deep repo-first-party methodology.
- `references/principles.md`, `references/archetypes.md` — the compliance rules
  to pass to the architecture checker.
