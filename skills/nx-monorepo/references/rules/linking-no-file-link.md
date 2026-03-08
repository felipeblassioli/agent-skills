---
title: Never Use file — , link — , or Relative Paths for Workspace Deps
impact: HIGH
impactDescription: prevents broken resolution and non-portable configs
tags: linking, dependencies, package-json, anti-pattern
---

## Never Use file:, link:, or Relative Paths for Workspace Deps

**Impact: HIGH (prevents broken resolution and non-portable configs)**

Workspace dependencies MUST use `"*"` as the version specifier. Never use
`file:`, `link:`, or relative paths. These bypass npm workspaces linking and
create fragile, non-portable configurations.

**Incorrect (file: protocol):**

```json
{
  "dependencies": {
    "@acme/orders-domain": "file:../../libs/orders/domain"
  }
}
```

**Incorrect (link: protocol):**

```json
{
  "dependencies": {
    "@acme/orders-domain": "link:../../libs/orders/domain"
  }
}
```

**Incorrect (relative path):**

```json
{
  "dependencies": {
    "@acme/orders-domain": "../../libs/orders/domain"
  }
}
```

These approaches bypass npm's workspace resolution, create duplicate
`node_modules`, and break when the directory structure changes.

**Correct (workspace wildcard):**

```json
{
  "dependencies": {
    "@acme/orders-domain": "*"
  }
}
```

npm workspaces automatically resolves `"*"` to the local workspace package and
creates a symlink in `node_modules/@acme/orders-domain`.

Reference: [npm Workspaces](https://docs.npmjs.com/cli/using-npm/workspaces)
