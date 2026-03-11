# Production Readiness Checklist

Use this checklist before calling a Deno project ready for release.

- [ ] Every executable path has a documented entrypoint or `deno task`
- [ ] Every executable path documents its exact `--allow-*` permissions
- [ ] No command or test uses broader permissions than necessary
- [ ] The dependency policy is explicit: Deno-native, `npm:`, and remote imports are distinguishable
- [ ] Every `npm:` dependency has a written justification
- [ ] Any Node compatibility boundary is isolated and documented
- [ ] Public modules have tests
- [ ] Test commands document the permissions they require
- [ ] File naming and comment conventions are consistent with Deno-native guidance
- [ ] `TODO` and `FIXME` markers are attributable to an owner or issue
- [ ] `deno.json` tasks express the intended operational workflows clearly
- [ ] Release reviewers can explain the project's runtime contract without guessing
