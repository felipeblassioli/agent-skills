# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Added repository-level `CHANGELOG.md` to track global changes.
- Added ADR-0003 artifact maturity model for skills, scripts/tools, Cursor packs, and repository guidance.
- Added `docs/specs/artifact-maintenance-workflow.md` as the practical maturity and backlog workflow.
- Added `.cursor/rules/50-artifact-maturity.mdc` to route agents through maturity-aware edits.
- Added explicit root `CHANGELOG.md` guidance for cross-cutting governance and workflow changes.

### Changed
- Updated `AGENTS.md` to route maintained artifacts through ADR-0003 and the artifact maintenance workflow.
- Updated `personal-skill-maintainer` and `personal-pack-maintainer` to align with artifact maturity and backlog policy.
- Updated `scripts/skill-directory-sync/SPEC.md` to track the `--pretty` output-mode backlog item.
- Renamed `cursor-skill-creator` skill to `writing-cursor-skills`.
- Enhanced `writing-cursor-skills` to incorporate context-efficiency best practices (progressive disclosure, strict output shapes, and cheap-agent-first delegation).
- Upgraded `audit-skill-for-cursor` to evaluate skills against the Context Litmus Test for token efficiency and subagent delegation.
