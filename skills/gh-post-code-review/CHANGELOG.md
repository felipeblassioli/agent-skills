# Changelog

All notable changes to this skill follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [SemVer](https://semver.org/).

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
