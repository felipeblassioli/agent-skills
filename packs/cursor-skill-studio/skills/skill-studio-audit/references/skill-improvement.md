# Skill Improvement Review

Use this reference when the target artifact lives under `skills/`.

## Review Dimensions

Check the skill in this order:

1. **Current job**
   - Can its purpose be stated in one sentence?
   - Is it trying to do more than one reusable job?

2. **Trigger surface**
   - Is the name searchable and specific?
   - Does the description match realistic user prompts?
   - Is the description too broad or too workflow-heavy?

3. **Hot path and Token Economy**
   - Hot path for a skill = the frontmatter `description` (always
     shipped, even with `disable-model-invocation: true`) plus the
     `SKILL.md` body once the skill is invoked. Everything under
     `references/`, `assets/`, and `scripts/` is cold path.
   - Is `SKILL.md` routing well, or trying to teach everything inline?
   - What repeated or obvious content can move out?
   - Are there prompt-visible surfaces (like long descriptions) that
     could be tighter? Cite
     `skills[].hot_path_metrics.description_chars` from
     `skill_hot_path_audit.py` for evidence, not paraphrased token
     estimates.
   - **Router exception:** if `disable-model-invocation: true`, prefer
     compact keyword-tag form over the `Use when` formula (see
     `cursor-skill-standard.md` → "Description token economy"). A
     `procedural_description` finding from the auditor points at this
     rule, not at a defect in the formula itself.

4. **Progressive disclosure**
   - Are references one hop away?
   - Are files named clearly enough for targeted reads?
   - Are large examples justified?

5. **Boundaries**
   - Should any content become a script, a pack asset, or project-local guidance
     instead of staying in the skill?
   - Does the skill overlap with siblings?

6. **Behavior**
   - Does the skill improve activation and decision quality?
   - Does it reduce context use relative to the old design?

## Diagnostic Questions

Ask only what is missing:

- Which prompts should trigger this skill?
- Which prompts should NOT trigger it?
- What does the skill repeat in the description, body, and references?
- What parts of the body are reference material rather than routing guidance?
- What is the concrete expected outcome of improving it?

## Common Recommendations

| Problem | Recommendation | Expected outcome |
|---|---|---|
| Description is broad or vague | Rewrite the description around real triggers and anti-triggers | Better activation and fewer false positives |
| Description acts like marketing copy or a tutorial | Convert to keyword-dense routing tags | Lower token cost and better routing |
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
