# Skill Improvement Review

Use this reference when the target artifact is a single skill (a
`SKILL.md` package with `metadata.json` and optional
`references/`, `assets/`, `scripts/`).

## Review Dimensions

Check the skill in this order:

1. **Current job**
   - Can its purpose be stated in one sentence?
   - Is it trying to do more than one reusable job?

2. **Trigger surface**
   - Is the name searchable and specific?
   - Does the description match realistic user prompts?
   - Is the description too broad or too workflow-heavy?
   - Does it name anti-triggers so it does not fire on the wrong prompts?

3. **Hot path and token economy**
   - Hot path for a skill = the frontmatter `description` (always
     shipped to the model for routing) plus the `SKILL.md` body once
     the skill is invoked. Everything under `references/`, `assets/`,
     and `scripts/` is cold path (loaded on demand).
   - Is `SKILL.md` routing well, or trying to teach everything inline?
   - What repeated or obvious content can move out to a reference?
   - Are there prompt-visible surfaces (like a long description) that
     could be tighter? Cite measured character/line counts as evidence
     (for example from a hot-path audit), not paraphrased token
     estimates.

4. **Progressive disclosure**
   - Are references one hop away from `SKILL.md`?
   - Are files named clearly enough for targeted reads?
   - Are large examples justified, or should they move to `assets/`?

5. **Boundaries**
   - Should any content become a script, a bundled asset, or
     project-local guidance instead of staying inline in the skill?
   - Does the skill overlap with sibling skills in the same plugin?

6. **Behavior**
   - Does the change improve activation and decision quality?
   - Does it reduce context use relative to the old design?

## Diagnostic Questions

Ask only what is missing:

- Which prompts should trigger this skill?
- Which prompts should NOT trigger it?
- What does the skill repeat across the description, body, and references?
- What parts of the body are reference material rather than routing guidance?
- What is the concrete expected outcome of improving it?

## Common Recommendations

| Problem | Recommendation | Expected outcome |
|---|---|---|
| Description is broad or vague | Rewrite it around real triggers and anti-triggers | Better activation and fewer false positives |
| Description reads like marketing copy or a tutorial | Trim to WHAT + WHEN + anti-triggers | Lower token cost and better routing |
| `SKILL.md` is too large | Move heavy detail to one-hop references | Lower hot-path token cost |
| Multiple jobs mixed together | Split into sibling skills or reduce scope | Cleaner boundaries and easier discovery |
| Repeated process text everywhere | Keep only routing and critical policy in `SKILL.md` | Faster decisions with less noise |
| Deterministic steps explained in prose | Add a utility script or tighter reference | More reliable execution and fewer tokens |

## Recommendation Bias

Default to:

- the smallest viable refactor
- better triggering before better prose
- smaller hot paths before more examples
- a split only when the skill truly has multiple jobs

Do not recommend a change you cannot tie to a concrete expected outcome.
When behavior might regress, recommend proving it with the eval loop
(see `eval-loop.md`) before merging.
