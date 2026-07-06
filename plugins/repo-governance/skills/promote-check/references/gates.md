# Promotion gates — reference

`scripts/promote-check.sh <skill-dir> [--json]` runs four gates in order and emits
a go / no-go verdict. It is read-only and harness-agnostic (no Claude dependency),
so CI can call it directly. **Exit codes:** `0` = go, `1` = no-go, `2` =
usage/environment error (bad args, missing tool, candidate not in a git repo).

The verdict is `no-go` if **any** gate fails; every failing gate is reported, and
each names its finding. `go` requires all four green.

## 1. `audit` — deterministic best-practice findings

Runs `skill-studio`'s `audit-skill.sh <skill-dir>` and blocks on any of these
mechanical, unambiguous findings (the judgment dimensions — archetype fit,
description quality — are deliberately **not** gated here; they stay with a human
running `skill-studio:skill-audit`):

- `name` does not match the folder name
- orphan references (a `references/*.md` never linked from `SKILL.md`)
- dangling `SKILL.md` links (a relative `.md` link with no target)
- non-executable bundled `*.sh` scripts
- relative bundled-script calls (a `bash scripts/…` invocation not prefixed with
  `${CLAUDE_SKILL_DIR}` / `${CLAUDE_PLUGIN_ROOT}` — breaks after the install cache-copy)
- cross-package relative links (a Markdown link whose target escapes the skill
  with `../../`)
- missing or invalid `metadata.json`

This is the "audit-first" core: these are exactly the findings a promotion must
**fix**, not waive.

## 2. `alignment` — marketplace / registry drift

Runs `scripts/marketplace-consistency.sh --plugin <plugin> --json` (scoped to the
candidate's plugin when it lives at `plugins/<plugin>/skills/<skill>`, else
repo-wide) and blocks on any drift it reports: `marketplace.json` ↔ each
`plugin.json` (name/source), `metadata.json` ↔ top `CHANGELOG.md` entry ↔
`skill-registry.json` line, and duplicate skill names.

## 3. `version`

`metadata.json` must carry a non-empty `version`.

## 4. `changelog`

`CHANGELOG.md` must exist and its top versioned entry must equal the
`metadata.json` version. The extractor accepts both `## 1.2.3 - date` and
Keep-a-Changelog `## [1.2.3] - date`, skipping an `## [Unreleased]` heading.

> The `changelog` and `alignment` gates overlap on the metadata↔CHANGELOG axis by
> design — `alignment` sees it repo-wide via the consistency helper, `changelog`
> checks the candidate directly so the gate still fires if the helper is scoped
> away. A version/CHANGELOG mismatch therefore surfaces under both, which is
> intended redundancy, not a bug.

## Routing failures

- `audit` findings → fix with `skill-studio:skill-enhance`.
- `alignment` / `version` / `changelog` → fix with `repo-governance:skill-maintainer`
  (it owns `plugin.json` / `metadata.json` / `CHANGELOG.md` / marketplace wiring).

Re-run `promote-check` until the verdict is `go`.
