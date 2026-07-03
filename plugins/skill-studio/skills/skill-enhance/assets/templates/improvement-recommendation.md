# Improvement Recommendation

## Target

- Artifact: `...`
- Type: `skill` or `plugin`
- Current job: `...`

## Observed Problem

- Main pain: `...`
- Evidence or symptom: `...`

## Hot-Path Evidence (if applicable)

Cite measured values, not paraphrased token estimates. If a hot-path audit
was run (see the sibling `skill-audit` skill), quote its fields directly:

- Skill scope:
  - `skill_md_lines`: `...`
  - `description_chars`: `...`
  - findings triggered: `...`
  - duplication buckets triggered: `...`
- Plugin scope:
  - `plugin.json` description length: `...`
  - per-skill `description_chars`: `...`
  - per-agent `description_chars`: `...`
  - cross-skill duplication buckets: `...`

Copy any caveats verbatim from the audit; do not paraphrase them as token
estimates.

## Desired Outcome

- Primary improvement goal: `...`
- Expected outcome: `...`

## Recommendations

Rank 1–3 by leverage (highest first). Score each by effort/risk.

### 1. [Highest-leverage change]

- Improvement: `...`
- Why here: `...`
- Expected outcome: `...`
- Effort/risk: `low` | `medium` | `high`
- Prove it: `eval loop` | `not needed` (behavior may regress → run the loop)

### 2. [Optional follow-up]

- Improvement: `...`
- Why here: `...`
- Expected outcome: `...`
- Effort/risk: `low` | `medium` | `high`
- Prove it: `eval loop` | `not needed`

### 3. [Optional follow-up]

- Improvement: `...`
- Why here: `...`
- Expected outcome: `...`
- Effort/risk: `low` | `medium` | `high`
- Prove it: `eval loop` | `not needed`

## Keep As-Is

- `...`

## Open Questions

- `...`
