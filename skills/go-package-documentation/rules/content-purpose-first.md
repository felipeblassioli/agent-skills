---
title: Start With Purpose, Not Implementation
impact: MEDIUM
impactDescription: improves documentation clarity for new users
tags: golang, documentation, content, clarity
---

## Start With Purpose, Not Implementation

Package documentation should start with WHAT the package does (purpose), then
explain HOW it works (implementation details). Don't lead with technical
details.

**Incorrect:**

```go
// Package cache uses LRU eviction and sharding for performance.
// It implements a concurrent-safe map with automatic cleanup.
package cache
```

**Correct:**

```go
// Package cache provides in-memory caching with TTL and eviction policies.
//
// The implementation uses LRU eviction and automatic sharding across
// multiple internal maps for improved concurrent access performance.
// All operations are safe for concurrent use.
package cache
```

**Why this matters:** Users first need to understand what a package is for
before they care about how it works. Leading with implementation details makes
documentation harder to scan and understand quickly. Purpose-first organization
matches how developers search for and evaluate packages.

Reference: [Effective Go: Commentary](https://go.dev/doc/effective_go#commentary)