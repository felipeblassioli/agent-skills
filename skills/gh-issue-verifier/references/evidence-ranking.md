# Evidence Ranking

## Purpose

Rank how persuasive the available evidence is for claiming that the issue is resolved.

## Strong Evidence

Strong evidence usually includes multiple signals that align with the issue:

- code changes that directly address the reported behavior
- tests that target the issue scenario or reproduction path
- PR discussion or issue timeline linking the work to the issue
- docs or specs updated when behavior changes require documentation
- branch or PR diffs clearly scoped to the affected area

## Medium Evidence

- commit messages referencing the issue without enough code proof
- code changes in the right area, but no targeted tests
- tests changed nearby, but not clearly covering the reported behavior
- issue linked to a PR whose diff is only partially relevant

## Weak Evidence

- issue referenced in commit or PR title only
- broad refactors in the same subsystem with no explicit behavior proof
- file churn near the area with no issue-specific logic
- comments claiming a fix without verification artifacts

## Non-Proof

The following do not count as sufficient proof on their own:

- linked PR or commit references
- passing tests unrelated to the scenario
- renamed files or cleanup-only changes
- changelog mentions
- "looks fixed" judgments without code-path inspection

## Confidence Mapping

- `High`
  Strong direct evidence in code plus targeted tests, with little ambiguity.
- `Medium`
  Some direct evidence exists, but tests, scope, or behavior mapping are incomplete.
- `Low`
  Evidence is indirect, partial, ambiguous, or mostly procedural.

## Tie-Break Rules

- Prefer stronger code and test evidence over metadata signals.
- Prefer direct behavior coverage over commit-message intent.
- Prefer explicit issue alignment over nearby but generic improvements.
- If strong contradictory signals exist, lower confidence and consider `INCONCLUSIVE`.

## Links

- Verdict rules: `verdict-rubric.md`
- Report shape: `../assets/templates/verification-report.md`
