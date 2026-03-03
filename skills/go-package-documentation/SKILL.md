---
name: go-package-documentation
description:
  Go package documentation (doc.go) following official conventions. Use when
  creating package-level documentation, writing doc.go files, or ensuring
  compliance with go doc, godoc, and pkg.go.dev standards. Triggers on tasks
  involving package comments, API documentation, or Go documentation review.
license: MIT
metadata:
  author: internal
  version: '1.0.0'
  language: go
  tags: [golang, documentation, godoc, package-comments, doc.go]
---

# Go Package Documentation (doc.go)

Guidelines for writing doc.go files that follow official Go documentation
conventions and render correctly in go doc, godoc, and pkg.go.dev.

## When to Apply

Reference these guidelines when:

- Creating new Go packages that need comprehensive documentation
- Writing package-level documentation exceeding a few lines
- Documenting complex packages with architectural patterns
- Ensuring documentation compliance with Go standards
- Reviewing package documentation for consistency

## Rule Categories by Priority

| Priority | Category           | Impact   | Prefix      |
| -------- | ------------------ | -------- | ----------- |
| 1        | Structure          | CRITICAL | `structure-` |
| 2        | Formatting         | HIGH     | `format-`    |
| 3        | Content Guidelines | MEDIUM   | `content-`   |

## Quick Reference

### 1. Structure (CRITICAL)

- `structure-package-clause` - No blank line between comment and package clause
- `structure-first-sentence` - Must start with "Package <name>"

### 2. Formatting (HIGH)

- `format-present-tense` - Use "provides", "implements" (not past/future tense)
- `format-complete-sentences` - All documentation uses complete sentences
- `format-code-blocks` - Indent with 4 spaces or 1 tab for code examples
- `format-headings` - Use `#` syntax for section headings

### 3. Content Guidelines (MEDIUM)

- `content-purpose-first` - Start with purpose, then implementation details
- `content-usage-examples` - Include practical, runnable code examples
- `content-thread-safety` - Document thread safety when relevant

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/structure-package-clause.md
rules/format-present-tense.md
rules/content-usage-examples.md
```

Each rule file contains:

- Brief explanation of why it matters
- Incorrect code example with explanation
- Correct code example with explanation
- Additional context and references

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`

## Testing Documentation

Verify documentation renders correctly:

```bash
# View package docs in terminal
go doc

# View with source
go doc -src FunctionName

# Start local doc server
godoc -http=:6060
```

## References

- [Go Doc Comments](https://go.dev/doc/comment)
- [Effective Go: Commentary](https://go.dev/doc/effective_go#commentary)
- [Google Go Style Guide](https://google.github.io/styleguide/go/)