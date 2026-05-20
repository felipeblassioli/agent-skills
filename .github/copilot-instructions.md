This repository stores installable agent skills under `skills/` and Cursor packs under `packs/`.

When performing GitHub Copilot code review, prioritize concrete findings over praise. Surface missing required files, broken packaging, registry drift, missing validation evidence, scope creep, secret exposure, and build or generated-output drift before commenting on style or tone.

Lead with the highest-signal review comments first. Prefer comments that block safe merge or reveal repo-policy drift over generic compliments or minor wording suggestions.

All PR content should be in English and should follow `.github/pull_request_template.md`. For skill-related PRs, expect a clear Motivation section, an accurate Skills affected table, a truthful quality checklist, and validation commands with results.

Treat current repo rules and scripts as the source of truth. Prefer guidance already enforced or documented in `AGENTS.md`, `.cursor/rules/00-repo-map.mdc`, `.cursor/rules/10-commit-conventions.mdc`, `.cursor/rules/30-pr-workflow.mdc`, `packs/cursor-skill-studio/skills/skill-studio-write/scripts/validate-skill.sh`, and `scripts/cursor-pack-verify.sh`.

When a change touches skill or pack policy and packaging sources such as `.github/pull_request_template.md`, `AGENTS.md`, `.cursor/rules/00-repo-map.mdc`, `.cursor/rules/10-commit-conventions.mdc`, `.cursor/rules/30-pr-workflow.mdc`, `packs/cursor-skill-studio/skills/skill-studio-write/scripts/validate-skill.sh`, `cursor-pack-registry.json`, or `scripts/cursor-pack-verify.sh`, check whether `.github/copilot-instructions.md` or the files under `.github/instructions/` should be updated in the same PR.

Do not assume automation exists where the repo does not prove it. If documentation, build config, workflows, and verification scripts disagree, flag the drift explicitly instead of inventing a rule.
