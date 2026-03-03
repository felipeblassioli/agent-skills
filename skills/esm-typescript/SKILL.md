---
name: esm-typescript
description:
  Fix and prevent ESM errors in TypeScript projects using "type": "module"
  with moduleResolution "nodenext". Use when encountering ERR_MODULE_NOT_FOUND,
  ERR_REQUIRE_ESM, missing .js extensions, or __dirname ReferenceError.
compatibility:
  files: ["tsconfig.json", "package.json"]
---

# ESM TypeScript

Rules for ESM-first TypeScript projects using `"type": "module"` with
`moduleResolution: "nodenext"`. Contains 4 rules targeting the most common
ESM runtime errors.

## When to Apply

Reference these guidelines when:

- Encountering `ERR_MODULE_NOT_FOUND` or `Directory import is not supported`
- Encountering `ERR_REQUIRE_ESM` or CJS/ESM mixing errors
- Seeing `ReferenceError: __dirname is not defined`
- Writing or reviewing ESM imports in TypeScript
- Configuring `package.json` with `"type": "module"`

## When NOT to Apply

Do NOT reference these guidelines when:

- The project uses CommonJS (no `"type": "module"` in package.json)
- The project is plain JavaScript without TypeScript
- You are working in this skills repository itself

## Quick Reference

- [esm-type-module](references/rules/esm-type-module.md) — package.json must have `"type": "module"`
- [esm-import-extensions](references/rules/esm-import-extensions.md) — Must include `.js` extensions in ESM imports
- [esm-no-require](references/rules/esm-no-require.md) — Never use `require`/`module.exports`
- [esm-import-meta-url](references/rules/esm-import-meta-url.md) — Use `import.meta.url`, never bare `__dirname`

## Common Errors Quick Lookup

| Error / Symptom | Start Here |
|-----------------|------------|
| `ERR_MODULE_NOT_FOUND` / missing `.js` extension | [esm-import-extensions](references/rules/esm-import-extensions.md) |
| `ERR_REQUIRE_ESM` / CJS/ESM conflict | [esm-no-require](references/rules/esm-no-require.md), [esm-type-module](references/rules/esm-type-module.md) |
| `ReferenceError: __dirname is not defined` | [esm-import-meta-url](references/rules/esm-import-meta-url.md) |

## How to Use

**For automated checks** — scan source files for ESM violations:

```
bash scripts/check-imports.sh [WORKSPACE_ROOT]
```

The script checks for missing `.js` extensions, `require`/`module.exports`
usage, and bare `__dirname`/`__filename`. Outputs JSON.

**For a specific topic** — read the relevant rule from the Quick Reference
above. Each file is self-contained with incorrect/correct examples.

**Important:** Do NOT apply changes derived from these rules without explicit
user confirmation. Present proposed changes as diffs and wait for approval.
