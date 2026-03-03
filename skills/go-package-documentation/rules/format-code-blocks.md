---
title: Indent Code Blocks Properly
impact: HIGH
impactDescription: ensures code examples render correctly
tags: golang, documentation, formatting, code-blocks
---

## Indent Code Blocks Properly

Code examples in documentation must be indented with 4 spaces or 1 tab. This
signals to `go doc` that the text is code and should be rendered as such.

**Incorrect:**

```go
// Package api provides REST API client functionality.
//
// Example:
// client := api.NewClient("token")
// resp, err := client.Get("/users")
package api
```

**Correct:**

```go
// Package api provides REST API client functionality.
//
// Example usage:
//
//	client := api.NewClient("token")
//	resp, err := client.Get("/users")
//	if err != nil {
//		log.Fatal(err)
//	}
package api
```

**Why this matters:** Without proper indentation, code examples render as plain
text in documentation viewers, making them harder to read and impossible to
distinguish from prose. Indented code blocks are syntax-highlighted and clearly
identified as executable code.

Reference: [Go Doc Comments](https://go.dev/doc/comment)