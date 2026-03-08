---
title: Consumers Must Declare Workspace Dependencies
impact: HIGH
impactDescription: prevents "Cannot find module" errors at runtime
tags: linking, dependencies, package-json, workspaces
---

## Consumers Must Declare Workspace Dependencies

**Impact: HIGH (prevents "Cannot find module" errors at runtime)**

If a project imports `@acme/foo`, its `package.json` MUST declare the
dependency. npm workspaces will create a symlink in `node_modules/@acme/foo`
only if the dependency is declared.

**Incorrect (importing without declaring dependency):**

```typescript
// apps/example-api/src/main.ts
import { ingestEvent } from '@acme/orders-domain'; // ❌ works in TS but may fail at runtime
```

```json
// apps/example-api/package.json
{
  "dependencies": {
    // ❌ @acme/orders-domain not listed
    "express": "^4.18.0"
  }
}
```

TypeScript may resolve via project references, but Node.js at runtime uses
`node_modules` symlinks which require the dependency declaration.

**Correct (dependency declared):**

```json
// apps/example-api/package.json
{
  "dependencies": {
    "@acme/orders-domain": "*",
    "@acme/orders-data": "*",
    "express": "^4.18.0"
  },
  "devDependencies": {
    "@acme/testkit-db": "*"
  }
}
```

**Rules:**

- Use `dependencies` for runtime deps (apps importing libs)
- Use `devDependencies` for build-only or test-only deps
- Always use `"*"` as the version for workspace packages
- Run `npm install` after adding new dependencies to regenerate symlinks

Reference: [npm Workspaces](https://docs.npmjs.com/cli/using-npm/workspaces)
