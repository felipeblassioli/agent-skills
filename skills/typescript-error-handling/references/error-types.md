# Error Types in TypeScript

Based on ZIO principles, all errors in an application fall into three distinct categories. Understanding them dictates how we handle them.

## 1. Expected Errors (Failures)

- **Definition:** Errors expected to happen under normal circumstances. They can be predicted, and we can plan to recover from them.
- **Examples:** `UserNotFound`, `ValidationFailed`, `ExternalServiceTimeout`.
- **Handling:** Should be handled and recovered from. We model them explicitly in the type system (as typed exceptions or result types).
- **Analogy:** "Unhappy paths" in business logic.

## 2. Unexpected Errors (Defects)

- **Definition:** Errors not expected to occur, representing bugs or unrecoverable states.
- **Examples:** Null pointer exceptions, dividing by zero, memory leaks, missing files that were bundled with the app.
- **Handling:** **Do not type unexpected errors.** Do not try to recover from them at the point of occurrence. Let the application (or the specific sandbox/request) crash, log the stack trace at the edge, and investigate the bug.
- **Analogy:** Programming mistakes or broken invariants.

## 3. Fatal Errors

- **Definition:** Catastrophic unexpected errors.
- **Examples:** Out of memory (OOM), process termination.
- **Handling:** Let the application die. Do not attempt recovery.

## Exceptional vs Unexceptional Effects

When designing functions in TypeScript, explicitly document or type whether a function can fail:

- **Exceptional:** The function performs IO, validation, or complex logic and explicitly declares the errors it might throw or return.
- **Unexceptional:** The function is guaranteed not to fail with an expected error (e.g., generating a UUID, pure math computations).

*Note: Even unexceptional functions might still die due to unexpected defects (like OOM).*
