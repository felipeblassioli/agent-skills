---
title: Use Heading Syntax for Sections
impact: MEDIUM
impactDescription: improves documentation navigation and structure
tags: golang, documentation, formatting, headings
---

## Use Heading Syntax for Sections

Use `#` syntax for section headings in longer package documentation. This
creates proper document structure and navigation.

**Incorrect:**

```go
// Package cache provides in-memory caching.
//
// USAGE
//
// Create a new cache with default settings.
//
// CONFIGURATION
//
// Configure eviction policy and TTL.
package cache
```

**Correct:**

```go
// Package cache provides in-memory caching with TTL and eviction policies.
//
// # Usage
//
// Create a new cache with default settings:
//
//	cache := cache.New(cache.WithMaxSize(1000))
//	cache.Set("key", "value", 5*time.Minute)
//
// # Configuration
//
// Configure eviction policy and TTL:
//
//	cache := cache.New(
//		cache.WithLRU(),
//		cache.WithDefaultTTL(10*time.Minute),
//	)
package cache
```

**Why this matters:** Headings create navigable structure in documentation
viewers like `pkg.go.dev`. They make long documentation easier to scan and help
readers find specific information quickly. Plain text "headings" don't provide
this structure.

Reference: [Go Doc Comments](https://go.dev/doc/comment)