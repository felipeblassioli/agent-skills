---
name: typescript-error-handling
description: >-
  Provides structured error handling patterns for TypeScript, drawing from ZIO principles. Helps distinguish between expected domain errors and unexpected defects. Use when designing API boundaries, handling complex failure scenarios, deciding between thrown exceptions and result types (neverthrow), or ensuring application resilience.
---

# TypeScript Error Handling

Guidelines for robust, declarative, and type-safe error handling in TypeScript, transposed from ZIO principles.

## Applicability Gate

Apply this skill when ANY of the following are true:

- Designing new functions or APIs that can fail
- Deciding whether to use exceptions or result types (`neverthrow`)
- Handling errors from external services or unreliable systems
- Modeling domain-specific business errors
- Reviewing code for error-handling best practices

Do NOT apply when:

- Writing simple scripts where a basic `try/catch` is sufficient without architectural constraints
- Using a framework that mandates a completely different, strict error-handling model

## Routing Table

| Question | Route to |
|----------|----------|
| "What are the types of errors (expected vs unexpected)?" | [references/error-types.md](references/error-types.md) |
| "How should I model errors in TypeScript (classes vs ADTs)?" | [references/modeling-errors.md](references/modeling-errors.md) |
| "Should I throw exceptions or use a Result type like neverthrow?" | [references/modeling-errors.md](references/modeling-errors.md) |
| "How do I handle or recover from errors (catch, fallback, retry)?" | [references/error-handling-strategies.md](references/error-handling-strategies.md) |
| "What are the best practices (logging, sandboxing)?" | [references/best-practices.md](references/best-practices.md) |

## Procedure

1. **Identify the failure modes.** Determine if the error is an *expected domain failure* or an *unexpected defect*.
2. **Route to the right reference.** Use the routing table above based on the scenario.
3. **Select the error mechanism.** Choose between throwing typed exceptions (preferred) and using explicit functional result types, based on the codebase constraints.
4. **Apply the methodology.** Follow the patterns to catch, retry, or sandbox the error properly.

## Confirmation Policy

Do NOT apply these architectural changes to existing code without user confirmation, as refactoring error handling can have cascading effects. Present proposed changes and wait for approval.
