# Knowledge Hub Template

Use this template when the skill is primarily reference material, taxonomies,
decision trees, or domain knowledge that the agent dispatches to on demand.

---

```markdown
---
name: SKILL_NAME
description: >-
  WHAT_IT_DOES. SECONDARY_CAPABILITY. Use when TRIGGER_1, TRIGGER_2,
  or TRIGGER_3. Do NOT use for EXCLUSION_1 (route to OTHER_SKILL).
---

# SKILL_TITLE

ONE_LINE_PURPOSE_STATEMENT.

## Applicability Gate

Apply this skill when ANY of the following are true:

- CONDITION_1
- CONDITION_2
- CONDITION_3

Do NOT apply when:

- EXCLUSION_1 → route to **OTHER_SKILL_NAME**
- EXCLUSION_2 → route to **OTHER_SKILL_NAME**

## Routing Table

| Question | Route to |
|----------|----------|
| "QUESTION_1?" | [references/REF_1.md](references/REF_1.md) |
| "QUESTION_2?" | [references/REF_2.md](references/REF_2.md) |
| "QUESTION_3?" | [assets/LOOKUP.md](assets/LOOKUP.md) |
| "QUESTION_4?" | [assets/DECIDE.md](assets/DECIDE.md) |

## Procedure

1. **Identify the task type.** What is the user trying to do?
2. **Route to the right reference.** Use the routing table above.
   Read only the reference file(s) needed — do not load all.
3. **Apply the methodology.** Follow the normative rules from the
   loaded reference.
4. ADDITIONAL_STEP_IF_NEEDED.

## Confirmation Policy

Do NOT apply changes derived from these rules without explicit user
confirmation. Present proposed changes as diffs and wait for approval.

## Related Skills

- **OTHER_SKILL_1** — HOW_IT_RELATES (reference by name)
- **OTHER_SKILL_2** — HOW_IT_RELATES (reference by name)
```

---

## Guidance

- Frontmatter is `name` + `description` only. No governance fields, no
  `disable-model-invocation`.
- The routing table is the core of this template. Every reference file must
  appear in it. Keep links one hop deep from SKILL.md.
- Questions in the routing table should use the user's natural language
  ("How do I...?", "What should I...?").
- The procedure section should be short (3-6 steps). The real depth lives in
  the reference files.
- If the skill has >10 routing entries, group them with subheadings.
- Reference sibling skills **by name**, never by relative path.
