# Changelog

This file tracks user-visible changes to `node-test-verifier`.

Each release should update `VERIFICATION.md` with the commands and outcomes that
justify the release.

## 0.2.0 - 2026-03-18

- Reworked the verifier around a canonical repo-local contract at
  `.cursor/test-verifier.contract.json` so steady-state runs no longer need the
  parent agent to restate a large tier matrix.
- Changed the default verifier behavior to answer pass or fail first, summarize
  the first useful failures, and return evidence paths for deeper investigation.
- Updated the bootstrapper to generate a compact contract with quiet execution
  preferences, evidence roots, stale-contract hints, and repo-specific tier data.
- Updated the strict rule and guides to prefer quiet execution, repo-owned test
  scripts, explicit prerequisites, and coverage only when requested.

## 0.1.0 - 2026-03-09

- Added the first `node-test-verifier` Cursor pack with a reusable
  `test-verifier` subagent for low-noise Node and Jest verification.
- Added a reusable `test-verifier-bootstrapper` subagent for adapting the pack
  to repo-local test layouts without changing the pack itself.
- Added a strict project rule that nudges agents toward tier-aware verification
  after substantive changes.
- Added configuration, bootstrap, and usage guides for repositories with
  multiple Jest configs, build-before-test prerequisites, and tier-specific
  coverage.
