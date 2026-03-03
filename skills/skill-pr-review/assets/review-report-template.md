# Skill PR Review Report

Use this template for final reporting when running `skill-pr-review`.

## Summary

- **Overall status:** PASS | FAIL
- **Base branch:** `main` (or provided base)
- **Branch reviewed:** `<branch-name>`
- **Changed skills:** `skill-a`, `skill-b`
- **Removed skills:** `skill-x` (if any)

## Findings

| ID | Severity | Category | Evidence | Recommendation |
|---|---|---|---|---|
| F-001 | HIGH | Structural | `skills/<name>/SKILL.md` exceeds 500 lines | Move deep content to `references/` |

## Structural validation

| Skill | Pass | Errors | Warnings |
|---|---|---|---|
| `skill-a` | true | 0 | 1 |

## Registry consistency

- **Pass:** true | false
- Findings:
  - `[HIGH] ...`
  - `[MEDIUM] ...`

## PR hygiene

- Branch naming convention valid: true | false
- Commit title convention valid: true | false
- Commit checks:
  - `feat(skill-a): ...` -> valid
  - `update files` -> invalid

## Content quality (agent-evaluated)

- Applicability gate quality: pass | warn | fail
- Routing table quality: pass | warn | fail
- Progressive disclosure quality: pass | warn | fail
- Terminology consistency: pass | warn | fail

## Merge recommendation

- **Safe to merge:** yes | no
- Required actions before merge:
  1. ...
  2. ...
