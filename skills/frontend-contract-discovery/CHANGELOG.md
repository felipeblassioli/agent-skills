# Changelog

All notable changes to this skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-05-05

### Changed

- Enhanced progressive disclosure by explicitly instructing the agent to use the `Read` tool to fetch reference and asset files instead of just listing paths.
- Added explicit instructions for large codebases to use the `Task` tool (subagents like `explore` or `generalPurpose`) to parallelize the search for API call sites.

## [0.1.0] - 2026-05-05

### Added

- Initial release of the `frontend-contract-discovery` skill.
- Added `openapi-inference-rules.md` reference.
- Added `evidence-sources.md` reference.
- Added `discover-log-template.md` and `drift-checklist.md` assets.

### Validation

- `bash scripts/skill-sync.sh --skill=frontend-contract-discovery --dry-run`
