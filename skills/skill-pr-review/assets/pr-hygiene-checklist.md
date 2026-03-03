# PR Hygiene Checklist for Skill Changes

Use this checklist in addition to the repository PR template.

## Branch and commits

- [ ] Branch name follows `<type>/<skill-name>-<short-description>` or `<type>/<short-description>`
- [ ] Every commit title follows `type(scope): description`
- [ ] Scope uses skill name for skill-specific changes (`feat(tdd-classicist): ...`)
- [ ] Skill content changes are not mixed with unrelated build/tooling changes

## Skill correctness

- [ ] Each touched skill has `SKILL.md` and `metadata.json`
- [ ] `SKILL.md` `name` matches the skill folder name
- [ ] `SKILL.md` description includes WHAT + WHEN
- [ ] `SKILL.md` body stays under 500 lines
- [ ] Internal links in `SKILL.md` resolve

## Registry and versioning

- [ ] New skills are added to `skill-registry.json`
- [ ] Removed skills are deleted from `skill-registry.json`
- [ ] `metadata.json` version matches registry version
- [ ] Registry tags are present and meaningful

## PR narrative quality

- [ ] PR title follows conventional commit format
- [ ] PR body sections are filled (`What`, `Motivation`, `Validation`)
- [ ] Validation includes actual commands and outcomes
- [ ] Follow-ups and accepted risks are explicitly documented when applicable
