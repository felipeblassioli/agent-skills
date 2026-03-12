# Node And Npm Interop

Node compatibility in Deno is a tool, not the default architecture.

## Default stance

Interop is acceptable when it solves a real problem:

- migration from an existing Node codebase
- use of a mature library with no strong Deno-native alternative
- temporary compatibility during an incremental adoption plan

Interop is a warning sign when it appears by habit rather than by need.

## Rules

- Do not assume "Node-compatible" means "behaviorally identical."
- Call out every place where the project depends on `npm:` packages, CommonJS assumptions, or Node-specific APIs.
- Keep compatibility boundaries explicit. A reviewer should know which modules are Deno-native and which ones are interop-heavy.
- Avoid spreading Node shims through the whole codebase when only one integration point actually needs them.
- If a migration is in progress, document which parts are transitional and which are the intended steady state.

## Migration guidance

When moving from Node to Deno:

1. preserve behavior first
2. isolate compatibility-heavy modules
3. replace Node assumptions with Deno-native patterns incrementally
4. remove broad compatibility scaffolding once the boundary is no longer needed

## Review questions

- Is `npm:` use justified, or is it leftover habit?
- Does any module depend on CommonJS mental models that should be refactored away?
- Is the compatibility surface isolated, or is it leaking across the whole codebase?
- Would a new teammate understand whether this project is truly Deno-native?

## See Also

- [imports-and-dependencies.md](imports-and-dependencies.md)
- [runtime-mental-model.md](runtime-mental-model.md)
- [common-pitfalls.md](common-pitfalls.md)
