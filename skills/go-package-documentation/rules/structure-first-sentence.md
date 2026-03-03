---
title: Start With "Package <name>"
impact: CRITICAL
impactDescription: required format for package documentation
tags: golang, documentation, structure, naming
---

## Start With "Package <name>"

The first sentence of package documentation must start with `Package <name>` in
that exact format. This is the canonical pattern recognized by all Go
documentation tools.

**Incorrect:**

```go
// Provides HTTP utility functions.
package httputil
```

```go
// This package handles authentication.
package auth
```

**Correct:**

```go
// Package httputil provides HTTP utility functions and middleware.
package httputil
```

```go
// Package auth handles user authentication and authorization.
package auth
```

**Why this matters:** The `Package <name>` prefix is a universal convention that
makes package documentation immediately recognizable and searchable. Tools like
`pkg.go.dev` expect this format and may not properly index or display
documentation that doesn't follow it.

Reference: [Godoc: documenting Go code](https://go.dev/blog/godoc)