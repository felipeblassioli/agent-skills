# Audit Skill for Cursor

Audits and improves Cursor skills to ensure they function as context-efficient dispatchers, following progressive disclosure and TDD-driven documentation principles.

## When To Use

- "Audit the `my-skill` skill."
- "Review `.cursor/skills` for context efficiency."
- "Improve this skill's `SKILL.md` to act as an index."

## What This Skill Maintains

- `SKILL.md`: Lean dispatcher with applicability gating.
- `metadata.json`: Governance and versioning metadata.
- `references/`: Heavy reference documents and audit procedures.

## Release And Validation

```bash
bash scripts/skill-sync.sh --skill=audit-skill-for-cursor --dry-run
bash scripts/skill-sync.sh --skill=audit-skill-for-cursor
```

## Related Skills Or Packs

- `cursor-skill-creator`
- `writing-skills`
- `personal-skill-maintainer`
