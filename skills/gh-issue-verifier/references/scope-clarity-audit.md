# Scope Clarity Audit

## Purpose

Judge whether the issue is clear enough to verify reliably and report any scope ambiguity as part of the outcome.

## Dimensions

Audit the issue on these dimensions:

- problem statement clarity
- expected behavior clarity
- acceptance criteria quality
- reproduction specificity
- subsystem or boundary identification
- out-of-scope boundary clarity

## Ratings

### Clear

- the issue describes a concrete failing behavior
- expected behavior is explicit or strongly inferable
- affected area is identifiable
- acceptance criteria are present or narrow enough to infer safely

### Mixed

- the issue identifies a real problem, but expected behavior or scope is only partially defined
- acceptance criteria are incomplete
- multiple interpretations are plausible

### Unclear

- the issue is mostly symptom-oriented with little actionable detail
- expected outcome is missing
- reproduction steps are absent and cannot be inferred
- issue scope is too broad or undefined

## Reporting Rules

- Always separate scope-quality comments from implementation-quality comments.
- Do not penalize the implementation for issue ambiguity without saying so explicitly.
- If the issue is unclear, report which parts were inferred.
- Weak issue quality should lower confidence, even if some evidence of a fix exists.

## Typical Ambiguity Signals

- "does not work" with no expected behavior
- no environment or trigger conditions
- no acceptance criteria
- multiple subsystems mentioned without scope boundaries
- issue title implies one bug while body describes another

## Strictly Observational Recommendations

Allowed recommendation types:

- clarify acceptance criteria
- clarify scope boundaries
- provide reproduction steps
- provide evidence for unverified behavior

Not allowed:

- prescribe code changes
- propose refactors
- redesign the implementation

## Links

- Parsing rules: `issue-parsing.md`
- Verdict rules: `verdict-rubric.md`
- Report shape: `../assets/templates/verification-report.md`
