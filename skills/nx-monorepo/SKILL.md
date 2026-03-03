---
name: nx-monorepo
description:
  Scaffold and maintain Nx monorepo structure with hexagonal architecture,
  project tags, TypeScript project references, and npm workspaces linking.
  Use when creating new apps/libs/tools, fixing build or linking errors,
  configuring project tags, or enforcing module boundary rules.
compatibility:
  files: ["nx.json", "tsconfig.base.json"]
  system: ["nx"]
---

# Nx Monorepo

Architecture, build, linking, and tag rules for an Nx TypeScript monorepo with
hexagonal architecture, npm workspaces, and strict module boundaries. Contains
16 rules across 4 categories.

## When to Apply

Reference these guidelines when:

- Creating new Nx apps, libs, or tools
- Deciding where new code should live (apps vs libs vs tools)
- Configuring TypeScript builds (tsconfig, project references)
- Adding workspace dependencies between packages
- Fixing "Cannot find module" or build errors in an Nx workspace
- Configuring project tags or enforcing module boundary rules
- Reviewing PRs for architectural compliance

## When NOT to Apply

Do NOT reference these guidelines when:

- The workspace does NOT use Nx as the monorepo tool
- The project is a single-package repo (not a monorepo)
- The workspace uses yarn workspaces or pnpm workspaces without Nx
- You are working in this skills repository itself

## Stack Summary

| Concern | Tool / Config | Key File |
|---------|---------------|----------|
| Monorepo | Nx 22 + npm workspaces | `nx.json`, root `package.json` |
| Language | TypeScript 5.x, ESM (`"type": "module"`) | `tsconfig.base.json` |
| Build | `@nx/js:tsc` | per-project `project.json` |
| Linking | npm workspaces + `@nx/source` custom condition | root `package.json`, lib `exports` |
| Boundaries | Nx tags + `@nx/enforce-module-boundaries` | `project.json` tags |

## Quick Reference

### Architecture (CRITICAL)

- [arch-project-locations](references/rules/arch-project-locations.md) — All code MUST live under apps/, libs/, or tools/
- [arch-library-first](references/rules/arch-library-first.md) — Product features MUST begin as standalone libraries
- [arch-hexagonal-deps](references/rules/arch-hexagonal-deps.md) — Domain libs must not depend on data/api/infra/tool
- [arch-domain-purity](references/rules/arch-domain-purity.md) — Domain libs are pure: no I/O, no framework deps
- [arch-apps-thin-shell](references/rules/arch-apps-thin-shell.md) — Apps are thin composition roots, no business logic

### Tags (MEDIUM)

- [tags-required-dimensions](references/rules/tags-required-dimensions.md) — Every project MUST have scope + type tags
- [tags-hex-constraints](references/rules/tags-hex-constraints.md) — Tags must obey hexagonal dependency rules

### Build (HIGH)

- [build-composite-tsconfig](references/rules/build-composite-tsconfig.md) — Referenced tsconfigs must have composite: true
- [build-rootdir-separation](references/rules/build-rootdir-separation.md) — Keep vitest.config.ts out of tsconfig.lib.json
- [build-no-circular-refs](references/rules/build-no-circular-refs.md) — No circular TypeScript project references
- [build-tsconfig-base-locked](references/rules/build-tsconfig-base-locked.md) — Don't modify tsconfig.base.json without reason

### Linking (HIGH)

- [linking-exports-field](references/rules/linking-exports-field.md) — Lib package.json must have exports with @nx/source
- [linking-consumer-deps](references/rules/linking-consumer-deps.md) — Consumers must declare workspace dependencies
- [linking-no-file-link](references/rules/linking-no-file-link.md) — Never use file:, link:, or relative paths
- [linking-no-path-aliases](references/rules/linking-no-path-aliases.md) — Never use root-level TS path aliases for workspace libs
- [linking-workspaces-coverage](references/rules/linking-workspaces-coverage.md) — Root workspaces array must cover all project folders

## Common Errors Quick Lookup

| Error / Symptom | Start Here |
|-----------------|------------|
| `Cannot find module '@turbi/...'` | [linking-consumer-deps](references/rules/linking-consumer-deps.md), [TROUBLESHOOTING.md](references/TROUBLESHOOTING.md) §4 |
| `File is not under 'rootDir'` | [build-rootdir-separation](references/rules/build-rootdir-separation.md) |
| `Referenced project must have composite: true` | [build-composite-tsconfig](references/rules/build-composite-tsconfig.md) |
| Build order / stale cache | [TROUBLESHOOTING.md](references/TROUBLESHOOTING.md) §8 |

## How to Use

**For automated checks** — run the relevant script before reading rule files:

| Symptom area | Script | Rules covered |
|-------------|--------|---------------|
| Linking / package.json | `bash scripts/check-package-json.sh` | 4 rules |
| TypeScript / tsconfig | `bash scripts/check-tsconfig.sh` | 4 rules |
| Project tags | `bash scripts/check-project-tags.sh` | 2 rules |

Scripts output JSON. Fix reported violations; only open rule files if you need
to understand the rationale.

**For a specific topic** — read the relevant rule from the Quick Reference
above. Each file is self-contained with incorrect/correct examples.

**Important:** Do NOT apply changes derived from these rules without explicit
user confirmation. Present proposed changes as diffs and wait for approval.

## Related Skills

- For ESM import errors (`ERR_MODULE_NOT_FOUND`, `ERR_REQUIRE_ESM`, `__dirname`), see the **esm-typescript** skill.
- For Vitest configuration and test discovery, see the **vitest-monorepo** skill.
- For general TypeScript quality (typed clients, validation, logging), see the **typescript-quality** skill.

## Additional Resources

- For detailed error troubleshooting, see [TROUBLESHOOTING.md](references/TROUBLESHOOTING.md)

### Authoring

- Rule template: [assets/authoring/rule-template.md](assets/authoring/rule-template.md)
- Section definitions: [assets/authoring/sections.md](assets/authoring/sections.md)
