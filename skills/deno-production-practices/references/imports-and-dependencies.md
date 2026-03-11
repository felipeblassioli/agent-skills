# Imports And Dependencies

Use an explicit dependency strategy. Production Deno projects get unstable when they mix import styles without a policy.

## Recommended order of preference

1. Deno standard library or built-in runtime APIs
2. First-party or Deno-native packages
3. `npm:` packages only when there is a concrete ecosystem reason
4. Remote URL imports only when the team has explicitly decided to allow them

## Rules

- Keep the project ESM-first. Do not design new modules around CommonJS assumptions.
- Be explicit about where dependencies come from. A reviewer should be able to tell whether a dependency is Deno-native, Node-compatible, or remote.
- Do not introduce `npm:` packages just because the team used them in Node before. Require a reason such as ecosystem maturity, missing Deno-native functionality, or migration constraints.
- Avoid mixing multiple dependency idioms in the same module unless there is a strong boundary reason.
- Favor project-wide consistency over local convenience. One clear dependency policy is better than per-folder exceptions.

## Import review guidance

Flag these patterns in review:

- imports that hide whether the code depends on Node compatibility
- remote imports with no documented trust policy
- new `npm:` dependencies added without explaining why Deno-native alternatives are insufficient
- modules that force CommonJS mental models into otherwise ESM-native code

## Practical policy text

"Imports are deliberate. New dependencies must declare whether they are Deno-native, `npm:`-based, or remote. If a dependency requires Node compatibility, that dependency choice must be called out in review and in project documentation."

## See Also

- [runtime-mental-model.md](runtime-mental-model.md)
- [node-and-npm-interop.md](node-and-npm-interop.md)
- [common-pitfalls.md](common-pitfalls.md)
