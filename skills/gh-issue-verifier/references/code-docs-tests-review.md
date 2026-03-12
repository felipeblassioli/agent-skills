# Code, Docs, And Tests Review

## Purpose

Verify the reported fix by inspecting implementation logic, supporting documentation, and meaningful test coverage.

## Code Review Rules

- Inspect the actual code path that appears to address the issue.
- Verify whether the changed logic matches the issue's problem statement or inferred acceptance criteria.
- Check neighboring paths for likely residual failures.
- Look for TODO, FIXME, hack comments, feature flags, or partial branches that suggest incompleteness.
- Distinguish direct fixes from broad refactors that only happen to touch the same area.

## What Counts As A Good Code Match

- the changed condition or branch directly addresses the failing scenario
- state transitions or side effects now align with expected behavior
- error handling or retry logic matches the issue description
- changed configuration or defaults plausibly explain the behavior correction

## Documentation Review Rules

Check docs only when behavior, API, operations, or user expectations changed.

Relevant locations may include:

- `README.md`
- `docs/`
- changelog files
- ADR or RFC files
- OpenAPI or AsyncAPI specs
- inline operational docs

Report one of:

- docs updated consistently
- docs not updated but not applicable
- docs likely should have changed but did not

## Test Review Rules

- Prefer tests that directly target the issue scenario.
- A meaningful test should fail before the fix and pass after it.
- Co-located tests can still be strong evidence if they clearly exercise the issue scenario.
- If only snapshot or smoke coverage exists, mark that as weak evidence.
- Note whether new tests were added or existing tests were extended.

## Residual Gap Signals

- no targeted tests for a risky behavior change
- code change exists but no issue-specific scenario is covered
- only happy path was tested
- docs or specs still describe the old behavior
- adjacent paths still appear vulnerable to the original bug

## Links

- Workflow: `git-and-gh-workflow.md`
- Verdict rules: `verdict-rubric.md`
- Report shape: `../assets/templates/verification-report.md`
