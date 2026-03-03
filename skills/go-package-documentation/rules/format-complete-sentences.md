---
title: Use Complete Sentences
impact: HIGH
impactDescription: improves clarity and professionalism
tags: golang, documentation, formatting, grammar
---

## Use Complete Sentences

All documentation must use complete sentences with subjects and predicates, not
sentence fragments.

**Incorrect:**

```go
// Package db provides database utilities.
//
// Connection pooling and query building.
package db
```

```go
// HTTP client wrapper.
package client
```

**Correct:**

```go
// Package db provides database utilities.
//
// The package includes connection pooling and query building functionality.
package db
```

```go
// Package client provides an HTTP client wrapper with automatic retries.
package client
```

**Why this matters:** Complete sentences are clearer, more professional, and
easier to understand—especially for non-native English speakers and AI tools
parsing documentation. Fragments can be ambiguous and harder to maintain.

Reference: [Google Go Style Guide](https://google.github.io/styleguide/go/)