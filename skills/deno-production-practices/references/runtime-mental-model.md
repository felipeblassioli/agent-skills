# Runtime Mental Model

Deno should be treated as a runtime with explicit security and module contracts, not as "Node with a different CLI."

## Production defaults

- Start from `secure by default`: code should run with no ambient filesystem, network, environment, or subprocess access unless the command explicitly grants it.
- Treat the command line as part of the application contract. If a task needs `--allow-net` or `--allow-read`, document that requirement next to the task or deployment command.
- Prefer ESM-first design and URL-like dependency thinking. Avoid assuming CommonJS resolution, implicit transpilation quirks, or package-manager-specific behavior.
- Keep the runtime surface narrow. A Deno service should expose a clear entrypoint and a small set of documented tasks rather than many ad hoc shell commands.

## Policy

For production code, write down three things for every executable path:

1. the entrypoint or task
2. the exact permissions it requires
3. whether it depends on Node/npm compatibility

If any of those are unclear, the project is not release-ready.

## Review questions

- Does the runtime command express the real privilege boundary?
- Would a new engineer know which permissions are intentional and which are accidental?
- Is the project still Deno-native, or is it slowly becoming a Node compatibility wrapper?

## See Also

- [imports-and-dependencies.md](imports-and-dependencies.md)
- [permissions-and-security.md](permissions-and-security.md)
- [node-and-npm-interop.md](node-and-npm-interop.md)
