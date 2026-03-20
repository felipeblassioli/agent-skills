# Release Policy

## Scope

`cursor-skill-creator` should evolve when the bundled workflow meaningfully
improves pack or skill authoring, bundled review tooling becomes more reliable,
or the Cursor runtime surfaces gain important new capabilities.

## Versioning

- Patch: docs clarifications, template tweaks, or non-breaking authoring guidance
- Minor: new bundled references, templates, subagents, or workflow improvements
- Major: breaking changes to pack structure, bundled skill entry points, or eval
  workspace conventions

## Release expectations

Each release should:

- update `CHANGELOG.md`
- summarize verification in `VERIFICATION.md`
- keep `ROADMAP.md` aligned with the current next steps
- pass `scripts/cursor-pack-verify.sh`

## Safety expectations

- Keep MCP guidance example-only unless the pack explicitly grows that surface
- Keep machine-specific paths and personal identifiers out of bundled assets
- Keep bundled skill guidance self-contained rather than depending on repo-local
  top-level skills
