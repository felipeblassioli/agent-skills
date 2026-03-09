# Release Policy

`node-test-verifier` should release when its reusable verification workflow or
installation surface changes in a way that matters to users.

## Release expectations

Each release should update:

- `CHANGELOG.md` with user-visible changes
- `VERIFICATION.md` with the commands that proved the release is structurally sound
- `ROADMAP.md` when the next priorities change materially

## Minimum validation before release

Run:

```bash
bash scripts/cursor-pack-verify.sh --pack=node-test-verifier
```

Also dry-run the supported install shapes that matter to the change:

- `project-cursor` with `lite`
- `project-cursor` with `strict` when rules changed
- `user-cursor` with `lite` when agent assets changed

## Versioning guidance

- Patch: docs cleanup, safer wording, or non-breaking guidance refinement
- Minor: new runtime assets, broader supported workflows, or meaningful new docs
- Major: breaking install-map changes, renamed artifacts, or incompatible config expectations

## Scope guardrails

- Keep the pack focused on Node and Jest verification
- Keep repository-specific routing maps, thresholds, and commands out of the pack
- Add helper scripts only when they improve portability rather than baking in a
  single repository layout
