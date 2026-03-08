This repository stores installable agent skills under `skills/` and Cursor packs under `packs/`.

For pull request review, prioritize concrete findings over praise. Surface missing required files, broken packaging, registry drift, missing validation evidence, scope creep, and build or generated-output drift before commenting on style.

All PR content should be in English and should follow `.github/pull_request_template.md`. For skill-related PRs, expect a clear Motivation section, an accurate Skills affected table, the quality checklist to be truthful, and validation commands with results.

Treat current repo rules and scripts as the source of truth. Prefer guidance already enforced or documented in `AGENTS.md`, `.cursor/rules/00-repo-map.mdc`, `.cursor/rules/10-commit-conventions.mdc`, `.cursor/rules/30-pr-workflow.mdc`, and `skills/create-skill-from-refs/scripts/validate-skill.sh`.

When a change touches skill policy or packaging sources such as `.github/pull_request_template.md`, `AGENTS.md`, `.cursor/rules/00-repo-map.mdc`, `.cursor/rules/10-commit-conventions.mdc`, `.cursor/rules/30-pr-workflow.mdc`, or `skills/create-skill-from-refs/scripts/validate-skill.sh`, check whether `.github/copilot-instructions.md` or the files under `.github/instructions/` should be updated in the same PR.

Do not assume automation exists where the repo does not prove it. If documentation, build config, and workflows disagree, flag the drift explicitly instead of inventing a rule.
