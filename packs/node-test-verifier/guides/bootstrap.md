# Bootstrap Guide

Use the `test-verifier-bootstrapper` agent after installing the pack into a
project. Its purpose is to adapt the reusable pack to the repository's actual
test setup without editing the pack itself.

## What the bootstrapper should do

It should inspect:

- `package.json`
- root or nested `AGENTS.md`
- `.cursor/rules/` related to testing or verification
- any existing repo-local verifier guidance

Then it should produce or update a repo-local overlay containing:

- working directory
- package manager and quiet execution style
- discovered tiers
- per-tier commands
- per-tier coverage commands
- per-tier prerequisites
- changed-file routing when documented
- unresolved gaps that need human confirmation

## Recommended output targets

Pick one of these based on repository shape:

- root `AGENTS.md` when the repo has one main Node test workflow
- nested `AGENTS.md` when only one package or subtree owns the test model
- `.cursor/rules/test-verifier-project.mdc` when the verification policy should
  apply persistently
- `.cursor/test-verifier-config.md` when the command matrix is too detailed for a
  short rule

## Suggested bootstrap prompt

```text
Adapt the installed node-test-verifier pack to this repository.
Inspect package.json, AGENTS.md files, and relevant .cursor/rules.
Discover the real test tiers, coverage commands, prerequisites, and any build-before-test steps.
Create a repo-local overlay instead of editing the pack.
Preferred target: .cursor/rules/test-verifier-project.mdc and a short AGENTS.md reference if needed.
If anything is ambiguous, leave it unresolved rather than inventing commands.
```

## Example outcome for a multi-config Jest repo

For a repo with scripts like:

- `test:unit`
- `test:unit:cov`
- `test:integration`
- `test:integration:cov`
- `test:functional`
- `test:functional:cov`
- `test:functional:http`
- `test:functional:http:cov`
- `test:structural`
- `test:emulator`
- `test:system`
- `smoke:test`
- `coverage:merge`
- `coverage:all`
- `build:modules`

the bootstrapper should likely generate a repo-local overlay that tells the
reusable `test-verifier` agent:

- `functions` or equivalent is the working directory
- npm quiet execution should prefer `npm --silent run`
- `integration`, `functional`, and `functional-http` may require
  `npm run build:modules`
- `integration` depends on Docker
- `emulator` depends on emulator-specific env and runtime setup
- only selected tiers emit coverage summaries

## Why this is better than pack mutation

The pack stays reusable across repos. Only the overlay changes per repository.

That means:

- no Turbi-specific assumptions leak into the pack
- different repos can keep different tier names and prerequisites
- future pack upgrades remain compatible with existing overlays
