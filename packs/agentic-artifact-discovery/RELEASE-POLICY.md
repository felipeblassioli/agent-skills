# Release Policy

`agentic-artifact-discovery` is expected to evolve. Releases should leave behind
durable artifacts that explain what changed, how it was verified, and what
still needs work.

## Release artifacts to commit

Every meaningful released change should keep these files up to date:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `ROADMAP.md`
- this file when the release policy itself changes

These artifacts are committed on purpose. They are part of the pack's operating
history, not temporary notes.

## Minimum release expectations

For each release:

1. update `pack.json.version`
2. update `cursor-pack-registry.json`
3. add or update the release entry in `CHANGELOG.md`
4. append the verification evidence in `VERIFICATION.md`
5. revise `ROADMAP.md` if the next steps changed
6. run structural verification and relevant dry-run installs

## Verification standard

Every release should record at least:

- `bash scripts/cursor-pack-verify.sh --pack=<name>`
- the dry-run install commands relevant to the changed profiles or targets

When the change affects behavior, prompts, or boundaries, also record:

- one realistic usage example
- observed outcome
- diagnosis or residual risks

## Release categories

### Patch

Use for:

- documentation improvements
- prompt wording fixes
- clearer anti-triggers
- validation note additions
- non-breaking guidance clarifications

### Minor

Use for:

- new pack artifacts
- materially improved discovery heuristics
- additional supported agentic artifact shapes
- new runtime capabilities that remain backward compatible

### Major

Use for:

- breaking changes to pack structure
- profile meaning changes that alter expected installs
- artifact removals or major workflow changes

## Documentation expectations

- `CHANGELOG.md` explains what changed
- `VERIFICATION.md` explains how the release was tested
- `ROADMAP.md` explains what still needs improvement

If a release cannot provide meaningful verification, that gap should be stated
explicitly in `VERIFICATION.md`.
