# Changelog — code-quality plugin

All notable changes to this plugin will be documented in this file.

## 0.3.0 - 2026-07-03

### Added

- **Graduated `gh-post-code-review`** from the Cursor-era registry into this plugin as
  `code-quality:gh-post-code-review` (0.1.0 → 0.2.0). Passed the `skill-studio:skill-audit`
  gate; hardened during promotion (removed legacy `compatibility:` frontmatter,
  **fixed two cache-unsafe bare script paths** to `${CLAUDE_SKILL_DIR}`, trimmed the
  description, fixed a stale `blassioli-code-reviewer` cross-ref, added a Gotchas section
  and an eval suite). ROADMAP Phase 1, #103.

## 0.2.0 - 2026-07-03

### Added

- **Graduated `typescript-quality`** from the Cursor-era registry into this plugin as
  `code-quality:typescript-quality` (1.0.0 → 1.1.0). Passed the `skill-studio:skill-audit`
  gate; hardened during promotion (removed the legacy `compatibility:` frontmatter, added
  a Gotchas section and an eval suite). ROADMAP Phase 1, #103.

## 0.1.0 - 2026-07-03

### Added

- Initial plugin. Establishes the official-tier **Code Quality & Review**
  group-plugin (ADR-0008 group 6, ROADMAP Phase 1, #103).
- **Graduated `code-reviewer`** from the `blassioli` sandbox into this plugin as
  `code-quality:code-reviewer`. The skill passed the `skill-studio:skill-audit`
  promotion gate (name/description valid, 126-line router, cache-safe script
  paths, no orphan/dangling refs, Gotchas present, 6 evals + committed baselines)
  and was hardened during promotion (see the skill's own `CHANGELOG.md`, 1.5.0).
