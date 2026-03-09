# Changelog

This file tracks user-visible changes to `node-test-verifier`.

Each release should update `VERIFICATION.md` with the commands and outcomes that
justify the release.

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
