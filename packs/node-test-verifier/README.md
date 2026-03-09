---
name: node-test-verifier
version: "0.1.0"
description: Portable Node and Jest verifier pack with a reusable subagent and project guidance for low-noise, tier-aware verification.
---

# Node Test Verifier

`node-test-verifier` packages the runtime layer for verifying Node.js and Jest
projects that have multiple test tiers, multiple Jest configs, noisy command
output, or tier-specific coverage flows.

It now also includes a reusable bootstrapper agent for adapting the pack to a
repository's real test scripts and local guidance surfaces after installation.

The pack is intentionally opinionated about execution style:

- keep terminal output compact
- prefer the smallest meaningful tier set
- summarize failures instead of dumping raw Jest logs
- treat coverage as tier-aware rather than universal
- make prerequisites explicit before running slow or environment-backed suites

It is intentionally not opinionated about your repository's script names,
coverage paths, or test-tier map. Those stay project-local.

## Profiles

- `lite`: installs reusable verifier and bootstrapper subagents only
- `strict`: installs the same subagents plus a project rule that nudges agents
  to verify substantial changes with tier-aware, low-noise execution

## Target support

- `project-cursor`: installs into a repository's `.cursor/` directory
- `user-cursor`: installs into `~/.cursor/`

Project installs can include `.cursor/rules/` for the `strict` profile.
User installs skip rules because Cursor user rules are managed in settings
rather than a `~/.cursor/rules/` directory.

## Included runtime assets

- `.cursor/agents/test-verifier.md`
- `.cursor/agents/test-verifier-bootstrapper.md`
- optional strict project rule at `.cursor/rules/verify-after-change.mdc`

## What this pack expects from a project

This pack works best when the repository already documents:

- the working directory that owns tests
- the package manager and test entrypoints
- how changed files map to tiers
- which tiers can emit coverage
- prerequisite commands such as `build:modules`, Docker checks, emulators, or
  required environment variables

The subagent stays reusable by consuming that project-specific contract instead
of hardcoding any one repository's scripts.

## Post-install bootstrap flow

Install the pack first, then run the `test-verifier-bootstrapper` agent against
the target repository.

That bootstrap step should inspect the repository's `package.json`, local
`AGENTS.md`, and relevant `.cursor/rules/` files, then create or update a
repo-local overlay such as:

- a test-verifier section in `AGENTS.md`
- a repository rule like `.cursor/rules/test-verifier-project.mdc`
- a small config note such as `.cursor/test-verifier-config.md`

This keeps the pack reusable across repositories while still letting each repo
describe its own:

- tier routing
- real script names
- coverage paths
- build-before-test prerequisites
- environment-backed test constraints

## Recommended tier model

Version `0.1.0` is optimized for Node and Jest repositories that use some or all
of these tiers:

- `unit`
- `structural`
- `integration`
- `functional`
- `functional-http`
- `emulator`
- `system`
- `smoke`

Only tiers that actually emit coverage should be treated as instrumentable. In a
common Jest setup, those are usually `unit`, `integration`, `functional`, and
`functional-http`.

## How it works with project-local guidance

Use this pack when the agent needs:

- a portable installed verifier at `.cursor/agents/test-verifier.md`
- a portable installed bootstrapper at `.cursor/agents/test-verifier-bootstrapper.md`
- isolated execution that keeps noisy test output out of the parent context
- persistent project guidance in `strict` mode

Keep these details in the project rather than the pack:

- the changed-file to tier routing matrix
- exact test and coverage commands
- build-before-test prerequisites
- repository-specific thresholds and PR wording

## Guides

- [guides/bootstrap.md](guides/bootstrap.md)
- [guides/configuration.md](guides/configuration.md)
- [guides/usage.md](guides/usage.md)

## Release Artifacts

- [CHANGELOG.md](CHANGELOG.md)
- [VERIFICATION.md](VERIFICATION.md)
- [RELEASE-POLICY.md](RELEASE-POLICY.md)
- [ROADMAP.md](ROADMAP.md)
