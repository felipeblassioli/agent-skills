# Usage Guide

Use `node-test-verifier` when a Node and Jest repository needs verification that
is informative but not noisy.

## Recommended lifecycle

1. Install the pack.
2. Run the `test-verifier-bootstrapper` agent against the target repository.
3. Let the bootstrapper create or update repo-local overlay files.
4. Use the `test-verifier` agent for ongoing verification runs.

This split keeps the pack reusable while letting each repository describe its
own scripts, tiers, and prerequisites.

## Best use cases

- after substantive production code edits
- before opening a PR
- when a repository has multiple Jest configs or multiple test tiers
- when coverage should be collected only for selected tiers
- when environment-backed tiers have prerequisites such as Docker, builds, or emulators

## When to delegate to the subagent

Use the `test-verifier` subagent when:

- the run will span one full tier or more
- the output is likely to exceed a few dozen lines
- coverage collection is needed
- you want a reusable report for a PR or review comment

Stay inline when:

- the user explicitly wants raw output
- you are only running a single highly targeted file
- you only need to read an existing `coverage-summary.json`

Use the `test-verifier-bootstrapper` subagent when:

- the pack was just installed into a new repository
- the repo's test scripts or tier layout changed
- local guidance is missing or outdated
- you want to scaffold a repo-local overlay instead of hand-writing it

## Common patterns

### 0. First-time adoption

Run the bootstrapper first so the repository gets a local verifier contract.

Expected outcome:

- a repo-local overlay is created or updated
- the reusable verifier no longer needs to guess script names
- unresolved gaps are called out explicitly

### 1. Small code change

Delegate with changed files and let the verifier choose the smallest tier set.

Expected outcome:

- one or two tiers run
- failures summarized in a short table
- no raw Jest flood in the parent context

### 2. Coverage check for instrumentable tiers

Tell the verifier which tiers can emit coverage and where their summaries live.

Expected outcome:

- only instrumentable tiers report coverage
- thresholds are checked only when the project documents them
- merged coverage is reported only if the project asked for it

### 3. Environment-backed verification

For `integration`, `emulator`, `system`, or `smoke`, provide prerequisites up
front.

Expected outcome:

- unavailable Docker or emulator dependencies become explicit skips
- build-before-test steps are recorded in the notes
- the report distinguishes skipped tiers from failed tiers

## Example with multiple Jest configs

This pack is designed for repositories whose `package.json` looks roughly like:

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

That shape is a strong fit because the verifier can:

- route to the right tier quickly
- keep output compact with quiet script execution
- append Jest JSON flags for compatible tiers
- summarize coverage without forcing a single monolithic `test:ci` flow

## Output you should expect

The verifier returns a compact report with:

- changed files
- tiers requested, run, and skipped
- pass or fail counts
- a short failure list
- coverage summary for relevant tiers
- notes about prerequisites, assumptions, and noise suppression

## Practical advice

- Keep the repository's tier matrix close to `package.json` or `AGENTS.md`
- Mark tiers that cannot emit structured JSON so the verifier can degrade gracefully
- Document build-before-test requirements explicitly
- Do not ask the verifier to infer thresholds that the repository never defined
- Re-run the bootstrapper when the repository adds new tiers or renames scripts
