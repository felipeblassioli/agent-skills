# Release Policy

## Scope

`engineering-workflows` should evolve when the bundled workflow skills become
clearer, the connector guidance improves, or the pack gains justified project
guardrails.

## Versioning

- Patch: text clarifications, guide fixes, non-breaking skill wording updates
- Minor: new bundled skills, stronger examples, or improved MCP example coverage
- Major: breaking changes to skill IDs, pack structure, or install behavior

## Release expectations

Each release should:

- update `CHANGELOG.md`
- summarize validation in `VERIFICATION.md`
- keep `ROADMAP.md` current
- pass `scripts/cursor-pack-verify.sh`

## Safety expectations

- keep MCP configuration example-only
- avoid machine-specific paths and personal settings
- preserve bundled skill IDs to avoid breaking installed references
