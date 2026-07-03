# Changelog

All notable changes to the `skill-studio` plugin are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/) and the plugin
uses [Semantic Versioning](https://semver.org/).

## 0.1.0 - 2026-07-02

### Added

- Initial release. Claude-first evolution of the `cursor-skill-studio` Cursor pack
  (frozen at 1.2.0), modeled on Anthropic's `skill-creator`.
- Three skills: `skill-create`, `skill-audit`, `skill-enhance`.
- Eight bundled helper subagents under `agents/`.
- Absorbed the genericized `skill-auditor` doctrine (archetypes, principles,
  authoring-for-claude, report-format) into `skill-audit`.

See [ADR-0007](../../docs/ADR/ADR-0007-skill-studio-plugin-canonical.md) for the
plugin-canonical / pack-frozen / craft-vs-governance decision.
