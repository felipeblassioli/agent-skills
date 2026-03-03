---
title: No Blank Line Before Package Clause
impact: CRITICAL
impactDescription: prevents documentation from being ignored by go doc
tags: golang, documentation, structure, package-clause
---

## No Blank Line Before Package Clause

The package comment must immediately precede the `package` declaration with no
blank line in between. A blank line breaks the association and go doc will
ignore the comment.

**Incorrect:**

```go
// Package bank implements core banking operations.

package bank
```

**Correct:**

```go
// Package bank implements core banking operations.
package bank
```

**Why this matters:** Go's documentation tools associate comments with the
immediately following declaration. A blank line breaks this association, causing
`go doc` to ignore the package comment entirely. The package will appear
undocumented in `pkg.go.dev` and `godoc`.

Reference: [Go Doc Comments](https://go.dev/doc/comment)