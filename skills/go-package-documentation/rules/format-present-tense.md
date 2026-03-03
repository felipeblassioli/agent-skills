---
title: Use Present Tense Verbs
impact: HIGH
impactDescription: maintains consistency with Go standard library
tags: golang, documentation, formatting, tense
---

## Use Present Tense Verbs

Package documentation should use present tense verbs like "provides",
"implements", "handles" (not past tense "provided" or future tense "will
provide").

**Incorrect:**

```go
// Package cache will provide in-memory caching.
package cache
```

```go
// Package logger provided structured logging.
package logger
```

**Correct:**

```go
// Package cache provides in-memory caching with TTL and eviction.
package cache
```

```go
// Package logger provides structured logging with multiple backends.
package logger
```

**Why this matters:** Present tense documentation reads as a statement of fact
about what the package currently does. This matches the style of Go's standard
library and provides clear, confident descriptions. Past tense sounds outdated,
and future tense makes the package seem incomplete.

Reference: [Effective Go: Commentary](https://go.dev/doc/effective_go#commentary)