# Common Pitfalls

These are the mistakes most likely to erode a production Deno codebase.

## Pitfalls to flag

| Pitfall | Why it matters | Preferred response |
|---|---|---|
| Treating Deno like Node with a different binary | Hides the runtime's security and module model | Re-state the runtime contract: permissions, imports, and interop assumptions |
| Granting broad permissions to every task or test | Turns least privilege into a slogan instead of a control | Narrow permissions per command and prove they still work |
| Adding `npm:` packages without justification | Pulls Node compatibility into the architecture by accident | Require an explicit reason and document the boundary |
| Mixing Deno-native and Node-centric patterns in the same module | Makes review and debugging harder | Isolate interop-heavy code and keep most modules Deno-native |
| Assuming compatibility means identical behavior | Migration bugs stay hidden until runtime | Verify behavior under Deno instead of trusting parity claims |
| Ignoring Deno-specific naming, test, and comment conventions | Teams lose consistency and code review signal | Adopt a project policy rooted in Deno's own style guidance |

## Review stance

When reviewing Deno code, prioritize these questions:

1. What permissions does this code actually need?
2. Where does dependency trust come from?
3. Is Node compatibility deliberate or accidental?
4. Are tests exercising the real runtime boundary?

## See Also

- [permissions-and-security.md](permissions-and-security.md)
- [imports-and-dependencies.md](imports-and-dependencies.md)
- [node-and-npm-interop.md](node-and-npm-interop.md)
