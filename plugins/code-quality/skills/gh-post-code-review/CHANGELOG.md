# Changelog

All notable changes to this skill follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [SemVer](https://semver.org/).

## 0.2.0 - 2026-07-03

### Changed

- **Graduated into the `code-quality` plugin** as `code-quality:gh-post-code-review`
  (moved from the Cursor-era `skill-registry.json`). Passed the
  `skill-studio:skill-audit` gate. See `docs/ADR/ADR-0008` and `docs/ROADMAP.md`
  (Phase 1, #103).
- Removed the legacy `compatibility:` frontmatter (Claude contract is `name` +
  `description`); its prerequisites moved into a `## Prerequisites` section.
- **Cache-safe script paths:** `parse-refs.py` and `post-review.sh` are now invoked via
  `${CLAUDE_SKILL_DIR}` so they resolve after the plugin is copied to the install cache.
- Trimmed the frontmatter description under 500 chars.
- Fixed a stale anti-trigger reference (`blassioli-code-reviewer` → `code-quality:code-reviewer`).

### Added

- **Gotchas section** — self-review event restriction, single-vs-multi inline comments,
  `line`/`side` vs `position` anchoring, out-of-diff 422s, SHA re-fetch, idempotency marker.
- **Evaluation suite** (`evals/evals.json`) — event-mapping and anchoring fixtures plus an
  over-trigger control.

## [0.1.0] — 2026-05-06

### Added
- Initial release.
- `SKILL.md` dispatcher with applicability gate, inputs/outputs contract,
  10-step procedure, safety gates, and routing table.
- References:
  - `gh-cli-vs-api.md` — decision matrix for `gh pr review` vs. `gh api`.
  - `severity-mapping.md` — verdict + severity → review event table.
  - `code-ref-parsing.md` — Cursor `start:end:path` grammar and edge cases.
  - `author-personas.md` — cheap addressing default + opt-in `--persona-probe`.
- Assets:
  - `templates/review-payload.json` — skeleton for the REST `/reviews` endpoint.
- Scripts:
  - `parse-refs.py` — review markdown → findings JSON.
  - `post-review.sh` — `gh api` POST with head-SHA drift guard.
