# Changelog

All notable changes to this skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2026-05-05

### Changed

- Made per-endpoint markdown docs a required default deliverable, adding an
  explicit endpoint-doc drafting step and default path suggestion.
- Tightened `assets/endpoint-doc-template.md` to be evidence-bound by default,
  with stronger `unknown`/assumption handling and a dedicated
  `Assumptions & Unknowns` section.
- Strengthened `references/openapi-inference-rules.md` and surrounding skill
  guidance to avoid speculative scalar types/formats and naming-driven domain
  inferences.

## [0.2.1] - 2026-05-05

### Added

- Added the endpoint documentation scaffold asset (`assets/endpoint-doc-template.md`) and documented the optional per-endpoint output naming convention.

### Changed

- Updated discovery guidance and templates to favor git remote permalinks as primary evidence references, with local file paths as fallback.
- Clarified evidence confidence sourcing by routing confidence scoring to the OpenAPI inference rules reference.

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
