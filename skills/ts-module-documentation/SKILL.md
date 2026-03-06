---
name: ts-module-documentation
description: Ensures all public TypeScript functions, variables, types, and modules are clearly documented with their purpose and provided APIs.
---

# TypeScript Module Documentation

## Applicability Gate
Apply this skill when the user asks to "document code", "add JSDoc", "explain this module", or review a TypeScript file's public API. Apply proactively when the user creates new `export` statements in `src/` or `lib/` directories. Do NOT apply when the user is modifying private functions, writing tests, or tweaking configuration files.

## Routing Table

| If you need to... | Route to... |
| :--- | :--- |
| Document a file/module's overall purpose | `references/module-docs.md` |
| Document exported functions or variables | `references/export-docs.md` |
| Document exported types, interfaces, or classes | `references/type-docs.md` |
| Copy standard JSDoc block templates | `assets/README.md` |
| Find undocumented exports in a file | `scripts/audit-exports.mjs` |

## Procedure
1. **Assess Scope**: Identify if the file is a test or config file. If so, exit unless explicitly requested.
2. **Audit File**: Run `scripts/audit-exports.mjs` to list missing docs, or manually scan the file for undocumented `export` keywords.
3. **Read Standards**: Consult the relevant files in `references/` for formatting and content rules.
4. **Apply Templates**: Use templates from `assets/templates/` to ensure consistent formatting.
5. **Propose Changes**: Present the proposed documentation updates to the user.

## Confirmation Policy
Do NOT write any documentation changes to files until the user explicitly confirms the proposed docstrings.

## Verification Checklist
- [x] Skill appears in Cursor/Agent context.
- [x] Auto-invocation triggers strictly on documentation tasks or new public exports.
- [x] Anti-triggers prevent firing on test files, config files, or internal implementations.
- [x] Routing links point accurately to `references/`, `assets/`, and `scripts/`.