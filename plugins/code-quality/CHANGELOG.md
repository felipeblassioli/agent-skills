# Changelog — code-quality plugin

All notable changes to this plugin will be documented in this file.

## 0.1.0 - 2026-07-03

### Added

- Initial plugin. Establishes the official-tier **Code Quality & Review**
  group-plugin (ADR-0008 group 6, ROADMAP Phase 1, #103).
- **Graduated `code-reviewer`** from the `blassioli` sandbox into this plugin as
  `code-quality:code-reviewer`. The skill passed the `skill-studio:skill-audit`
  promotion gate (name/description valid, 126-line router, cache-safe script
  paths, no orphan/dangling refs, Gotchas present, 6 evals + committed baselines)
  and was hardened during promotion (see the skill's own `CHANGELOG.md`, 1.5.0).
