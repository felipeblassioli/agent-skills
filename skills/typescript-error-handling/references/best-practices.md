# Error Handling Best Practices

## 1. Don't Reflexively Log Errors

When developers lack typed errors, they often get defensive and log errors everywhere:

```typescript
// BAD: Reflexive logging
try {
  await upload();
} catch (e) {
  console.error("Upload failed", e); // Logged here
  throw e; // And thrown to be logged again higher up!
}
```

**Rule:** Only log an error when you are actually *handling* it or when it hits the edge of your sandbox (like a global error handler). If you are passing the error up the stack, let the higher level log it. Logging at every level creates noise.

## 2. Sequential vs Parallel Errors

- **Sequential:** If steps happen one after another, the first error short-circuits the flow.
- **Parallel:** If running tasks in parallel (e.g., `Promise.allSettled`), you may accumulate multiple errors. 

When handling parallel operations, aggregate the expected errors rather than just throwing the first one, using `AggregateError` or returning a list of failures.

```typescript
const results = await Promise.allSettled(tasks);
const failures = results.filter(r => r.status === 'rejected');

if (failures.length > 0) {
  // Accumulate and report all parallel errors
  throw new AggregateError(failures.map(f => f.reason), "Multiple tasks failed");
}
```

## 3. Keep Domain Errors Clean

Do not leak HTTP status codes or infrastructure concerns into domain errors. A `UserNotFound` domain error should not know about `404`. Map domain errors to HTTP responses at the edge (the controller/router layer).
