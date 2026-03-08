---
applyTo: "skills/**/rules/**,skills/**/AGENTS.md,packages/react-best-practices-build/**,.github/workflows/react-best-practices-ci.yml"
---

Treat rules-based skill changes as build-backed changes, not as markdown-only edits.

For skills that use a `rules/` directory, verify the full contract:
- edits happen in `rules/` when the skill is rules-based
- generated `AGENTS.md` output is regenerated when needed and committed with the source change
- the build package under `packages/react-best-practices-build/` still knows about the skill
- relevant CI workflow coverage still matches the skills the repo claims are rules-based

When reviewing build-package changes, check `packages/react-best-practices-build/src/config.ts` for skill registration and output paths. If a PR introduces or converts a rules-based skill without updating build config, flag it.

When reviewing workflow changes, check whether `.github/workflows/react-best-practices-ci.yml` still exercises the right paths. If documentation says a skill is rules-based but build config or CI does not cover it, call out that drift explicitly.

Do not assume every rules-based skill is already automated correctly. Prefer evidence from the current build config and workflows over repo prose when they conflict, and ask for the mismatch to be resolved or documented.
