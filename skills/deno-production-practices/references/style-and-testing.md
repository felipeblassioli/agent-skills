# Style And Testing

Use Deno-native conventions instead of carrying over a generic Node or TypeScript style guide unchanged.

## Style rules to enforce

- Prefer filenames that follow Deno's style guidance rather than ecosystem habits imported from other runtimes.
- Keep comments compact and high-signal. Avoid noisy commentary that restates obvious code.
- Require `TODO` and `FIXME` comments to be attributable to an owner, issue, or tracked follow-up.
- Keep public modules readable and easy to test; hidden side effects make permission review harder.

## Testing rules

- Public functionality should have tests. Missing tests on exported modules are a release risk.
- Test commands must document the exact permissions they require, just like production commands.
- Do not let convenience flags normalize broad permissions in the test suite.
- Prefer tests that prove module behavior under the real runtime boundary instead of only mocking around permission-sensitive code.

## Review questions

- Does the code follow one consistent naming and file-organization style?
- Do tests cover the public behavior that the module exposes?
- Are permission requirements visible in test tasks and examples?
- Are `TODO` or `FIXME` markers owned and actionable?

## Policy text

"Deno code follows Deno-native project conventions. Public modules are tested, comments stay compact, and unowned TODO or FIXME markers are not release-ready."

## See Also

- [permissions-and-security.md](permissions-and-security.md)
- [common-pitfalls.md](common-pitfalls.md)
