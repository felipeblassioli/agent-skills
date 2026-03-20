# Changelog

All notable changes to `cursor-companion` should be recorded here.

## Unreleased

## 0.1.3 - 2026-03-19

### Added

- **Bundled skill** `cursor-companion-pack-overview` (`kind: "skill"` in `pack.json`): orientation for what the pack installs and how it relates to `skill-registry.json` / `skill-sync.sh`
- Pack-local directory `skills/cursor-companion-pack-overview/` with `SKILL.md` and `metadata.json`

### Changed

- `pack.json` / registry: version `0.1.3`; profiles description notes the bundled skill

## 0.1.2 - 2026-03-09

### Added

- **guides/verify-and-use.md**: step-by-step verification for project installs (manifest check, expected files, one-liner sanity check)

### Changed

- README: linked verify-and-use in guides section

## 0.1.1 - 2026-03-09

### Added

- guide for structuring root and nested `AGENTS.md` files alongside pack-owned
  `.cursor/` assets
- root and package `AGENTS.md` templates for repository-local customization

### Changed

- clarified that repo-specific nested `AGENTS.md` files are project-authored,
  while the pack provides templates and guidance
- updated surface-selection guidance to distinguish `AGENTS.md`,
  `.cursor/rules`, skills, and packs more clearly

## 0.1.0 - 2026-03-08

Initial reference release of the pack.

### Added

- companion subagents for pack auditing, hook review, and MCP config review
- project rules for surface selection, subagent delegation, MCP safety, and hook guardrails
- hook configs and hook scripts
- MCP example configuration
- installation, usage, security, and authoring guides

### Validation

See `VERIFICATION.md`.
