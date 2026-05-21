# Improvement Recommendation

## Target

- Artifact: `...`
- Type: `skill` or `pack`
- Current job: `...`

## Observed Problem

- Main pain: `...`
- Evidence or symptom: `...`

## Hot-Path Evidence (if applicable)

Run `python3 skills/skill-studio-audit/scripts/skill_hot_path_audit.py <target> --json`
and cite v1 schema fields directly:

- `skills[].hot_path_metrics.skill_md_lines`: `...`
- `skills[].hot_path_metrics.description_chars`: `...`
- `skills[].findings[].id` triggered: `...`
- `skills[].duplication_buckets[]` triggered: `...`
- `pack.cross_skill_duplication_buckets[]` (if pack-scope): `...`
- `thresholds` used by the auditor: `...`

Caveats (copy verbatim from the auditor `caveats` block; do NOT
paraphrase as token estimates).

## Desired Outcome

- Primary improvement goal: `...`
- Expected outcome: `...`

## Recommendations

### 1. [Highest-leverage change]

- Improvement: `...`
- Why here: `...`
- Expected outcome: `...`
- Effort/risk: `low` | `medium` | `high`

### 2. [Optional follow-up]

- Improvement: `...`
- Why here: `...`
- Expected outcome: `...`
- Effort/risk: `low` | `medium` | `high`

## Keep As-Is

- `...`

## Open Questions

- `...`
