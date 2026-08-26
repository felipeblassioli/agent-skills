---
name: simplify-skill
description: Rewrite an existing skill in the cursor-team-kit register — smaller, less rigid, more natural — beside the original, and report what the simplification kept, cut, and refused to cut. Use for "simplify this skill", "this skill is too rigid", "make a kit-style version of this", "why is this skill 300 lines", or when comparing an enforcement-heavy skill against a lighter one.
---

# Simplify a skill

Two registers, both legitimate. The rigid one enforces behavior under pressure: binding
rules, falsifiability gates, tables, restated gotchas. The kit one is short, plain, and
cheap to load, and trusts the model to be competent. Most rigid skills carry some of each,
and the interesting question is which lines are which.

Write the simpler variant *beside* the original. Overwriting it destroys the comparison,
which is the point.

## Workflow

1. Read the skill whole — `SKILL.md`, its references, and its `CHANGELOG.md`.
2. Classify every section as load-bearing or scaffolding.
3. Rewrite the load-bearing parts in the kit register: under ~60 lines, `Trigger` /
   `Workflow` / `Guardrails` / `Output`, plain sentences, no tables, bash only where the
   exact flags matter.
4. Keep a load-bearing rule even when it breaks the register, and say which ones did.
5. Report the delta, ending with what the simple version can no longer do.

## Load-bearing

- A rule whose violation changes the outcome, not the style.
- Falsifiability gates, honesty floors, and anything that stops a plausible-sounding lie.
- Domain facts the model cannot infer: flags, quirks, IDs, limits, ordering constraints.
- A rule the `CHANGELOG.md` says was added after something actually went wrong. That is
  evidence, not preference — the strongest signal in the file.

## Scaffolding

- Explanations of things the model already knows.
- The same rule restated as principle, then table, then gotcha.
- Tables holding prose that was never tabular.
- Rationale essays defending a decision nobody contested.
- `ALWAYS` / `NEVER` where a plain sentence carries the same weight.
- Sections kept for symmetry with nothing real in them.

## Guardrails

- Simplification is not deletion. A shorter skill that lost an invariant is a worse skill,
  not a leaner one.
- Keep the frontmatter description's trigger vocabulary. Length there buys triggering, and
  a skill that stops firing is simplified to zero.
- Reference other skills by name. Installed plugins are copied to a cache, so relative
  paths across skills break.
- Name what the simple version gives up. If the answer is "nothing", the original was
  scaffolding all the way down — say that too, it is the most useful finding available.

## Output

- The simplified variant, written beside the original at a stated path.
- Kept, cut, and refused-to-cut: one line each.
- One sentence on what the simple version can no longer do.
