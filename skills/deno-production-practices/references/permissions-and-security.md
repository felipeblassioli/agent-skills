# Permissions And Security

Permissions are a first-class production concern in Deno. They are not an optional deployment detail.

## Core rule

Grant the minimum `--allow-*` set that makes the command work, and treat any additional permission as risk that must be justified.

## Production guidance

- Document the exact permissions for every `deno task`, CI command, service start command, and operational script.
- Keep permissions specific to the command being executed. Do not reuse a broad permission set across unrelated tasks.
- Review tests the same way you review production commands. Test helpers often accumulate permissions silently.
- Be careful with dynamic behavior. Static local module loading and runtime operations do not have the same permission shape, so permission assumptions must be tested rather than guessed.
- If a command needs broad access, explain why the boundary cannot be narrowed further.

## Review checklist

- Does the command require filesystem access, environment access, network access, subprocesses, or FFI?
- Are those permissions declared explicitly and narrowly?
- Is there any permission included "just in case"?
- Would a failure under tighter permissions reveal an unnecessary dependency or side effect?

## Policy text

"Permissions are explicit. Every executable path in the project must declare the minimum `--allow-*` flags it needs. Broad flags require justification in code review. No task or test may rely on ambient permissions."

## Sharp edge to call out

Do not collapse all permission behavior into one rule of thumb. Deno's static module loading, dynamic imports, and runtime side effects can differ in permission behavior, so production guidance should describe the exact command contract and verify it with real runs.

## See Also

- [runtime-mental-model.md](runtime-mental-model.md)
- [style-and-testing.md](style-and-testing.md)
- [common-pitfalls.md](common-pitfalls.md)
