# Repo-First-Party Overlap Audit (deep)

Use this branch for a **deep** overlap audit of a repository's first-party skills
(`skills/<name>/` and optionally `plugins/*/skills/`) when the output must be a
defensible, scored consolidation plan — for example, input to a consolidation
ADR. It is the heavier sibling of `references/portfolio-audit-workflow.md`.

The full methodology is inlined below so the skill stays self-contained; an
installed plugin cannot read repo spec files, so nothing here depends on one.

## When to use this branch

- The user is preparing a consolidation ADR and needs a scored plan with
  evidence.
- The scope is repo-first-party (`skills/<name>/`), not installed directories.
- The output must include a normalized skill inventory (versions, hot-path size,
  triggers, anti-triggers, references) for later programmatic use.
- The user wants the inventory → cluster A/B/C → arbiter methodology, not the
  lighter installed-portfolio path.

Do NOT use when the user wants a quick installed-skills cleanup
(`references/portfolio-audit-workflow.md`), a single-skill audit
(`references/single-skill-audit.md`), or to write/refactor a new skill (hand off
to the create/enhance sibling skills).

## Methodology

### 0. Inventory (cheap subagents, in parallel)

Read each skill's frontmatter and key body fields into a normalized JSON
inventory — one entry per skill:

```json
{
  "path": "skills/<name>",
  "name": "<frontmatter name>",
  "description": "<frontmatter description>",
  "triggers": ["<phrases from description / Apply When>"],
  "anti_triggers": ["<Do not use when ... phrases>"],
  "archetype_guess": "<one of the ten archetypes>",
  "references": ["<references/*.md>"],
  "scripts": ["<scripts/*>"],
  "hot_path_lines": <skill_md_lines>,
  "version": "<metadata.json version>",
  "tags": ["<registry / plugin tags if any>"]
}
```

Do this with several cheap read-only subagents in parallel — never load 50+ full
skill bodies into the main thread. Pass each subagent a slice of the skill paths
and the schema above; have it return only the JSON.

### 1. Cluster A — description similarity

Group skills whose `description` fields share triggers or scope keywords. These
are the most likely trigger collisions (the model routes off the description).

### 2. Cluster B — body similarity

Group skills whose `SKILL.md` bodies share reference files, scripts, or workflow
steps. Structural overlap even when descriptions differ signals duplicated work.

### 3. Cluster C — registry / tag similarity

Cross-check against any registry tags and `description` overlap. Skills tagged
for the same domain that also share triggers are strong merge candidates.

### 4. Arbiter pass (single subagent)

Reconcile the three cluster outputs into final overlap groups. For each group
assign a severity (Critical / High / Medium / Low) and propose exactly one
action — **merge**, **anti-trigger**, **archive**, **rename**, or **cross-link** —
with evidence. The arbiter runs as a single subagent receiving all three cluster
outputs plus the inventory, so it sees the whole picture rather than one lens.

## Subagent guidance

- Prefer **multiple cheap read-only subagents in parallel** for the inventory
  and the three cluster passes.
- Reserve a **single arbiter subagent** for the reconciliation pass.
- Pass compliance rules (from `references/principles.md` /
  `references/archetypes.md`) in prompts — subagents cannot read repo files.
- Do NOT load the full body of more than a handful of skills in the main thread.

## Output contract

Use `assets/templates/portfolio-audit-report.md` for the human-facing report,
augmented with:

- The normalized inventory JSON (attached or linked).
- The three cluster outputs (A/B/C) before the arbiter merged them.
- The arbiter's final overlap groups with severity, evidence, and proposed
  actions.

Apply changes only after the user approves; route each action to a maintainer
skill by name.

## See Also

- `references/portfolio-audit-workflow.md` — lighter installed-skills audit.
- `references/principles.md`, `references/archetypes.md` — the compliance
  doctrine to pass to subagents.
- `references/report-format.md` — per-skill scorecard shape.
