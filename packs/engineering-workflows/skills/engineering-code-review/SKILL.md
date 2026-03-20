---
name: engineering-code-review
description: Use when reviewing code changes for correctness, security, performance, maintainability, or merge readiness, especially from a PR URL, diff, or set of changed files.
---

# Engineering Code Review

Review code changes with a structured lens on security, performance,
correctness, and maintainability.

## Good Fits

- PR reviews before merge
- targeted review of a risky diff or hot path
- second-pass review focused on security, correctness, or rollout safety

## Review Dimensions

- Security: injection, auth flaws, secrets, traversal, SSRF
- Performance: N+1 queries, wasteful loops, missing indexes, resource leaks
- Correctness: edge cases, race conditions, error handling, type safety
- Maintainability: naming, structure, duplication, test coverage, docs

## Useful Inputs

- a PR URL, diff, or changed file list
- what matters most: security, performance, correctness, or maintainability
- production context such as PII, auth boundaries, or scaling concerns

## Output Shape

```markdown
## Code Review: [PR title or file]

### Summary
### Critical Issues
### Suggestions
### What Looks Good
### Verdict
```

## Connected Tools

If connector categories are available:

- source control: pull PR diffs and CI status automatically
- project tracker: compare findings against stated requirements
- knowledge base: check team standards or review checklists

## Common Mistakes

- listing nits before real correctness or security risks
- calling something a bug without showing the execution path that breaks
- reviewing only the happy path and ignoring failure modes or tests

## Tips

1. Provide context such as hot paths, PII handling, or rollout risk.
2. Say if you want a security-heavy or performance-heavy pass.
3. Include tests when you want coverage quality reviewed too.
