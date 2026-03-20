---
name: engineering-tech-debt
description: Use when auditing technical debt, prioritizing refactors, evaluating code health, or building a maintenance backlog with impact, risk, and effort trade-offs.
---

# Engineering Tech Debt

Identify, categorize, and prioritize technical debt systematically.

## Good Fits

- code health reviews
- refactor planning
- maintenance backlog shaping
- deciding what debt to pay down during feature work

## Categories

- code debt
- architecture debt
- test debt
- dependency debt
- documentation debt
- infrastructure debt

## Prioritization

Score each item on:

- impact
- risk
- effort

Priority = `(impact + risk) x (6 - effort)`

## Useful Inputs

- the codebase area or system to inspect
- current pain points such as incidents, slow delivery, or onboarding friction
- any constraints on timing or staffing
- whether you want an audit, a ranked backlog, or a phased plan

## Output

Produce a prioritized remediation plan with:

- item
- category
- effort
- risk
- business justification
- recommended sequencing

## Common Mistakes

- calling every annoyance "high priority" debt
- ignoring the cost of leaving the debt in place
- proposing big-bang cleanup instead of phased remediation
