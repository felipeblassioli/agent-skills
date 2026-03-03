---
title: Include Practical Usage Examples
impact: MEDIUM
impactDescription: helps users get started quickly
tags: golang, documentation, content, examples
---

## Include Practical Usage Examples

Package documentation should include practical, runnable code examples that show
actual API usage, not pseudocode or abstract descriptions.

**Incorrect:**

```go
// Package client provides an HTTP client.
//
// Usage: Create a client and make requests.
package client
```

**Correct:**

```go
// Package client provides an HTTP client with automatic retries and timeout handling.
//
// # Basic Usage
//
// Create a client and make a GET request:
//
//	client := client.New("https://api.example.com",
//		client.WithTimeout(30*time.Second),
//		client.WithRetries(3),
//	)
//	
//	resp, err := client.Get(context.Background(), "/users/123")
//	if err != nil {
//		log.Fatal(err)
//	}
//	defer resp.Body.Close()
package client
```

**Why this matters:** Concrete examples are the fastest way for users to
understand how to use a package. Abstract descriptions or pseudocode force users
to guess at the actual API, leading to confusion and support requests. Runnable
examples also serve as informal tests of the documentation's accuracy.

Reference: [Effective Go: Examples](https://go.dev/doc/effective_go#examples)