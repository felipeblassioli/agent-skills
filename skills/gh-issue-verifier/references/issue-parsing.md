# Issue Parsing

## Purpose

Convert the issue into a verification target that can be checked against code, docs, tests, and GitHub history.

## Rules

- Extract the problem statement first.
- Extract explicit acceptance criteria if present.
- If acceptance criteria are missing, infer the minimum behavior that would reasonably count as resolution.
- Record reproduction steps when present. Treat them as high-value verification clues.
- Extract issue fingerprints:
  - symbols
  - file paths
  - API routes
  - config keys
  - error messages
  - user-visible behaviors
- Identify affected domains or subsystems.
- Separate facts from assumptions.

## Required Output

Produce a concise working note with:

- problem statement
- explicit acceptance criteria
- inferred acceptance criteria
- reproduction clues
- issue fingerprints
- likely affected areas
- ambiguity notes

## Inference Policy

- Infer acceptance criteria only from the issue text and directly linked context.
- Mark inferred criteria as inferred, never explicit.
- Do not upgrade a vague issue into a precise issue without saying so.

## Weak Issue Text

When the issue is weakly written:

- preserve the ambiguity in the report
- verify only what can be grounded in the text or linked evidence
- reduce confidence if the target behavior is unclear
- prefer `INCONCLUSIVE` over overclaiming

## Anti-Patterns

- Treating the title alone as sufficient scope
- Ignoring reproduction steps because they are incomplete
- Assuming the expected behavior from unrelated code
- Collapsing several possible interpretations into one without noting ambiguity

## Links

- Report shape: `../assets/templates/verification-report.md`
- Quick flow: `../assets/templates/quick-checklist.md`
