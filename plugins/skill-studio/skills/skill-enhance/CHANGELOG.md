# Changelog

All notable changes to the `skill-enhance` skill are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/) and the skill
uses [Semantic Versioning](https://semver.org/).

## 0.1.0 - 2026-07-02

### Added

- Initial release. The "enhance" surface of the `skill-studio` plugin, evolved
  Claude-first from the `cursor-skill-studio` pack's improvement + eval-loop
  machinery.
- **(A) Improvement recommendation** — diagnose an existing skill or plugin and
  deliver 1-3 ranked, effort/risk-scored recommendations via a template.
- **(B) Eval / benchmark loop** — bootstrap a comparison workspace, run
  with-skill vs baseline, grade, blind A/B compare, aggregate, and review.
- `references/skill-improvement.md`, `references/plugin-improvement.md`
  (reframed from the Cursor `pack-improvement.md`), and
  `references/eval-loop.md` (Cursor-specific phrasing generalized).
- `assets/templates/improvement-recommendation.md`.
- `scripts/bootstrap_skill_comparison.py`, `scripts/aggregate_benchmark.py`,
  and `scripts/eval-viewer/` (`generate_review.py` + `viewer.html`).
- Dispatches the `skill-creator-grader`, `skill-creator-comparator`,
  `skill-creator-analyzer`, and `skill-creator-structural-auditor` subagents
  bundled in the `skill-studio` plugin.
