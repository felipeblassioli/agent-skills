# Modeling Errors in TypeScript

We model *Expected Errors* (Failures) explicitly so the compiler and the developer know what can go wrong. *Unexpected Errors* (Defects) are never typed.

## Two Paradigms: Exception-Based vs Result-Based

The codebase may prefer one of two main strategies. **Exception/error-based is often preferred in standard TypeScript**, but functional paradigms use Result types.

### 1. Exception/Error-Based (Preferred)

Instead of generic `throw new Error()`, model domain errors using custom classes that form an Algebraic Data Type (ADT) or Union.

```typescript
// 1. Define a common supertype
abstract class DomainError extends Error {
  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
  }
}

// 2. Define specific errors
class InvalidUserId extends DomainError {
  constructor(public readonly id: string) { super(`Invalid user ID: ${id}`); }
}

class ExpiredAuth extends DomainError {
  constructor(public readonly id: string) { super(`Auth expired for: ${id}`); }
}

// Use union types for documentation and type constraints (if using libraries that support it)
type UserServiceError = InvalidUserId | ExpiredAuth;

function getUserProfile(id: string): UserProfile {
  if (!isValid(id)) throw new InvalidUserId(id);
  // ...
}
```

*Pros:* Native to JS/TS engine, stack traces are preserved natively, standard `try/catch`.
*Cons:* TypeScript does not have checked exceptions, so the compiler won't force you to catch `InvalidUserId`.

### 2. Result-Based (e.g., `neverthrow`)

If the project uses a functional approach (like `neverthrow`), errors are treated as values.

```typescript
import { err, ok, Result } from 'neverthrow';

type UserServiceError = InvalidUserId | ExpiredAuth;

function getUserProfile(id: string): Result<UserProfile, UserServiceError> {
  if (!isValid(id)) return err(new InvalidUserId(id));
  return ok({ id, name: "Alice" });
}
```

*Pros:* TypeScript enforces exhaustive checking of errors. You cannot ignore a failure.
*Cons:* Can lead to verbose code, requires mapping/binding throughout the entire call stack.

## Don't Type Unexpected Errors

Do not include `TypeError`, `RangeError`, or unexpected `Error` in your domain unions or Result types. Let defects throw natively and crash the execution context. If you catch an unexpected error from a third-party library, let it propagate or rethrow it as a defect (e.g., `throw new Error("Defect: " + e.message)`).
