---
name: commit-hygiene
description: Commit hygiene and self-contained pull requests. Highlights production impact, uses gh CLI for opening/updating PRs, and adding proof comments (test runs, coverage reports).
---
# Commit Hygiene

## Conventional Commits

Every commit message must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <description>

[optional body]
```

Allowed types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `ci`, `build`, `style`.

## Separation of concerns per commit

Never mix these categories in a single commit:

| Category | Files | Commit type |
|----------|-------|-------------|
| **Production code** | `*.js` in `functions/` (excluding `test*/`, `*.test.js`, `*.spec.js`) | `feat`, `fix`, `refactor`, `perf` |
| **Test code** | `*.test.js`, `*.spec.js`, files under `test*/` dirs | `test` |
| **Documentation** | `*.md`, `docs/**`, `AGENTS.md`, `README*` | `docs` |

### Rules

1. A commit touching production `.js` files must NOT include test or doc files.
2. A commit touching test files must NOT include production `.js` or doc files.
3. A docs-only commit must use `docs:` type and contain no code changes.
4. Config/tooling files (`Makefile`, `docker-compose.yaml`, CI, `.cursor/rules/`) use `chore` or `ci` and may stand alone or accompany prod code if directly related.

### Example sequence

```
feat(risk-engine): add plate cooldown window to scoring
test(risk-engine): add unit tests for plate cooldown scoring
docs: document plate cooldown scoring in risk engine guide
```

### When in doubt

If a change requires both prod and test updates (e.g., TDD), create **two commits**: one for the production code, one for the tests. Mention the relationship in the commit body if helpful.
