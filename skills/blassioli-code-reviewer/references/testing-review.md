# Testing Review Reference

Use this when evaluating test coverage or requesting tests.

## Test intent taxonomy

- Unit tests: small deterministic behavior, no external services.
- Integration tests: database, filesystem, queue emulator, or real adapter boundary.
- Contract tests: API/event schemas and compatibility expectations.
- Functional tests: user-story or workflow behavior across multiple units.
- Regression tests: specific bug cannot reappear silently.

## For queue consumers

Ask for tests that prove runtime semantics, not only happy path parsing.

Important cases:

- Duplicate message.
- Retryable failure before ack.
- Permanent invalid payload.
- Crash window after side effect.
- Concurrency cap.
- Out-of-order event when order matters.
- Shutdown drain behavior.

## For migrations

Ask for:

- Migration applies from previous schema.
- Application version N and N+1 can coexist during rollout if required.
- Rollback or forward-fix path is documented.
- Backfill is resumable and idempotent.

## For APIs

Ask for:

- Validation failures.
- Authorization failures.
- Backward compatibility cases.
- Idempotent retry behavior for mutating endpoints when clients may retry.
