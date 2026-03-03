---
title: Document Thread Safety
impact: MEDIUM
impactDescription: prevents concurrency bugs
tags: golang, documentation, content, concurrency
---

## Document Thread Safety

Package documentation should explicitly state whether exported types are safe
for concurrent use or require external synchronization.

**Incorrect:**

```go
// Package cache provides in-memory caching with LRU eviction.
package cache
```

**Correct:**

```go
// Package cache provides in-memory caching with LRU eviction.
//
// # Thread Safety
//
// All exported types are safe for concurrent use by multiple goroutines.
// Internal synchronization uses read-write locks to maximize concurrent
// reads while serializing writes.
package cache
```

**Alternative (when NOT thread-safe):**

```go
// Package buffer provides a ring buffer implementation.
//
// # Thread Safety
//
// Buffer is not safe for concurrent use. Callers must provide external
// synchronization when accessing a Buffer from multiple goroutines.
package buffer
```

**Why this matters:** Go is built for concurrency, and users need to know
whether they can safely use package APIs from multiple goroutines. Ambiguity
about thread safety leads to subtle race conditions and production bugs.
Explicit documentation prevents these issues.

Reference: [Go Concurrency Patterns](https://go.dev/blog/pipelines)