# Verdict Rubric

## Purpose

Choose the most honest verdict based on observed evidence.

## RESOLVED

Use `RESOLVED` only when most of the following are true:

- the issue's reported behavior is clearly addressed in code
- the relevant target branch, PR, or current codebase contains that behavior change
- tests directly cover the issue scenario, or equivalent strong evidence exists
- there are no major unresolved contradictions in docs, code, or linked history

## NOT RESOLVED

Use `NOT RESOLVED` when one or more of the following are true:

- the current code or target diff does not address the core issue behavior
- the evidence points to a different problem being solved
- the issue scenario still appears reachable in the inspected logic
- linked PRs or commits exist, but the actual implementation proof is missing or contrary

## INCONCLUSIVE

Use `INCONCLUSIVE` when any of the following apply:

- the issue is too ambiguous to define a stable verification target
- the available code or GitHub evidence is incomplete
- there are plausible signs of a fix, but direct proof is weak
- tests are absent or too indirect to support a clear verdict
- the repository state being inspected may not correspond to the claimed fix state

## Contradiction Handling

- If metadata says fixed but code says unclear, prefer `INCONCLUSIVE` or `NOT RESOLVED`.
- If code looks fixed but issue scope is too vague, lower confidence and consider `INCONCLUSIVE`.
- If one acceptance criterion is met but another is unverified, do not use `RESOLVED`.

## Confidence Pairing

- `RESOLVED` with `Low` confidence should be rare.
- `NOT RESOLVED` may still have `High` confidence when the missing behavior is explicit.
- `INCONCLUSIVE` is often appropriate with `Low` or `Medium` confidence.

## Links

- Evidence ranking: `evidence-ranking.md`
- Scope audit: `scope-clarity-audit.md`
