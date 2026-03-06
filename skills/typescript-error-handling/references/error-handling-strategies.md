# Error Handling Strategies

Applying functional error handling concepts to TypeScript workflows.

## 1. Catching and Recovering

When catching errors, ensure you only handle *expected failures*. If you encounter an unexpected defect, rethrow it.

```typescript
try {
  await performAction();
} catch (e) {
  if (e instanceof DomainError) {
    // Recover from expected error
    return handleDomainError(e);
  }
  // Rethrow unexpected defects!
  throw e;
}
```

## 2. Fallback

If an operation fails, gracefully fallback to an alternative.

```typescript
// Exception-based
async function getConfig() {
  try {
    return await readPrimaryConfig();
  } catch (e) {
    if (e instanceof FileNotFoundError) {
      return await readBackupConfig();
    }
    throw e;
  }
}

// Result-based (neverthrow)
const configResult = await readPrimaryConfig()
  .orElse(() => readBackupConfig());
```

## 3. Retrying

For expected transient errors (e.g., network timeouts), use a retry mechanism.

```typescript
async function withRetry<T>(
  fn: () => Promise<T>, 
  retries = 3
): Promise<T> {
  for (let i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (e) {
      if (e instanceof NetworkError && i < retries - 1) {
        continue; // Retry
      }
      throw e; // Give up or not a transient error
    }
  }
  throw new Error("Unreachable");
}
```

## 4. Sandboxing

Isolate defects to prevent them from crashing the entire application.
For example, in an Express/Fastify server or an event loop, wrap the route handler so an unexpected defect only crashes that specific request, not the whole server.

```typescript
app.get('/route', async (req, res, next) => {
  try {
    await handleRequest();
  } catch (e) {
    // Sandbox the defect: log it and return 500
    // The main Node.js process survives
    next(e);
  }
});
```