# Verification

## 0.6.0

### Commands

- `bash scripts/cursor-pack-verify.sh --pack=cursor-skill-studio`
- `bash packs/cursor-skill-studio/skills/skill-studio-write/scripts/validate-skill.sh packs/cursor-skill-studio/skills/skill-studio-maintain`
- `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root=".work/pr4-smoke" --profile=lite   --dry-run`
- `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root=".work/pr4-smoke" --profile=strict --dry-run`
- `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=user   --profile=lite   --dry-run`

### Outcome (recorded 2026-05-20)

- `cursor-pack-verify.sh --pack=cursor-skill-studio` returned
  `{"pass": true, "packsChecked": 1, "errors": [], "warnings": []}`.
- `validate-skill.sh packs/cursor-skill-studio/skills/skill-studio-maintain`
  returned `{"pass": true, "skill": "skill-studio-maintain", "lines": 256,
  "errors": [], "warnings": []}` — `SKILL.md` is 256 lines (above the
  ≤200-line authoring target but well below the 500-line hard limit; the
  extra mass is the unified 19-item review checklist that merges the skill
  maintainer's 10 items with the pack maintainer's 16 items, deduped, plus
  the six-branch router) with no broken in-tree references.
- Project dry-run `lite` against a fresh `.work/pr4-smoke` staging root:
  copied 87, updated 0, conflicts 0, unchanged 0 (up from 72 in 0.5.0; the
  +15 files are the `skill-studio-maintain` SKILL.md + metadata.json + 13
  references).
- Project dry-run `strict`: copied 89, updated 0, conflicts 0, unchanged 0
  (lite + the two project rules).
- User-target dry-run `lite`: copied 83, updated 3, conflicts 3, unchanged 1.
  The conflicts/updates match the 0.4.0/0.5.0 pattern (legacy
  `cursor-skill-creator` install on this host) — no new conflicts introduced
  by `skill-studio-maintain`.

### Diagnosis

- All three studio bundled skills (`skill-studio-write` 0.4.0,
  `skill-studio-audit` 0.5.0, `skill-studio-maintain` 0.6.0) install
  side-by-side with no overlap, conflict, or shared file collision.
- The duplicate `bundled-skills.md` reference that lived in both
  `personal-skill-maintainer/references/` and
  `personal-pack-maintainer/references/` is collapsed into a single merged
  reference in the bundled skill. The duplicates remain in the deprecated
  source skills for one release window so existing links keep resolving.
- Pack manifest now declares four `kind: "skill"` artifacts (write, audit,
  maintain, legacy workflow). The legacy `cursor-skill-creator-workflow` is
  still installed for compatibility; removal target is PR 6.

### Residual risks

- User-target conflicts on this host are inherited from the
  `cursor-skill-creator` → `cursor-skill-studio` rename in 0.3.0 and are
  unrelated to PR 4. A clean host install will copy zero conflicts.
- The maintain skill `SKILL.md` is intentionally above the ≤200-line target
  (256 lines) because the unified review checklist replaces two separate
  review checklists from the source skills. If this becomes a hot-path cost
  concern, the checklist can be lifted into
  `references/review-checklist.md` in a follow-up patch.
- Several specs and ADRs still link to `personal-skill-maintainer` /
  `personal-pack-maintainer` paths (`docs/specs/claude-plugin-export-from-packs.md`,
  `docs/ADR/ADR-0003-artifact-maturity-model.md`,
  `docs/ADR/ADR-0004-cross-runtime-agent-packaging-model.md`,
  `docs/agent-skills.md`). Those incoming references are updated in PR 5
  (the 1.0.0 documentation sweep) per ADR-0005.

## 0.5.0

### Commands

- `bash scripts/cursor-pack-verify.sh --pack=cursor-skill-studio`
- `bash scripts/cursor-pack-verify.sh --pack=skill-consistency-auditor`
- `bash packs/cursor-skill-studio/skills/skill-studio-write/scripts/validate-skill.sh packs/cursor-skill-studio/skills/skill-studio-audit`
- `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root=".work/pr3-smoke" --profile=lite --dry-run`
- `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root=".work/pr3-smoke" --profile=strict --dry-run`
- `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=user --profile=lite --dry-run`
- `bash scripts/cursor-pack-sync.sh --pack=skill-consistency-auditor --target=project --project-root=".work/pr3-smoke" --profile=lite --dry-run`

### Outcome (recorded 2026-05-19)

- `cursor-pack-verify.sh --pack=cursor-skill-studio` returned
  `{"pass": true, "packsChecked": 1, "errors": [], "warnings": []}`.
- `cursor-pack-verify.sh --pack=skill-consistency-auditor` returned
  `{"pass": true, "packsChecked": 1, "errors": [], "warnings": []}` — the
  deprecation banner and bumped version did not invalidate the manifest.
- `validate-skill.sh packs/cursor-skill-studio/skills/skill-studio-audit`
  returned `{"pass": true, "skill": "skill-studio-audit", "lines": 197,
  "errors": [], "warnings": []}` — `SKILL.md` is 197 lines (under the
  authoring 200-line target and well below the 500-line hard limit) with no
  broken in-tree references.
- Project dry-run `lite` against a fresh `.work/pr3-smoke` staging root:
  copied 72, updated 0, conflicts 0, unchanged 0 (up from 65 in 0.4.0; the
  +7 files are the `skill-studio-audit` SKILL/metadata + six references +
  two templates, minus the `.gitkeep` placeholder).
- Project dry-run `strict`: copied 74, updated 0, conflicts 0, unchanged 0
  (lite + the two project rules).
- User-target dry-run `lite`: copied 68, updated 3, conflicts 3, unchanged 1.
  The conflicts/updates match the 0.4.0 pattern (legacy
  `cursor-skill-creator` install on this host) — no new conflicts introduced
  by `skill-studio-audit`.
- Auditor pack dry-run (`skill-consistency-auditor`, project lite): copied 5,
  updated 0, conflicts 0, unchanged 0. Pack still installs cleanly during
  the deprecation window; the bundled SKILL is now a redirect stub.

### Diagnosis

- Two consolidated bundled skills (`skill-studio-write`, `skill-studio-audit`)
  install side-by-side with no overlap or conflict.
- The previously broken `assets/report-template.md` install path
  (flagged FAIL in ADR-0005) is now resolved at
  `.cursor/skills/skill-studio-audit/assets/templates/portfolio-audit-report.md`.
- `skill-consolidation-advisor` now references the installed path explicitly.
- Auditor pack remains installable but is clearly marked deprecated across
  `pack.json`, `README.md`, `CHANGELOG.md`, and `cursor-pack-registry.json`.

### Residual risks

- User-target conflicts on this host are inherited from the
  `cursor-skill-creator` → `cursor-skill-studio` rename in 0.3.0 and are
  unrelated to PR 3. A clean host install will copy zero conflicts.
- Branch D (deep repo-first-party audit) defers to
  `docs/specs/skill-overlap-audit.md`; if the spec evolves, the bundled
  adapter must be kept in sync — not exercised in this verification.
- The three auditor subagents now live in both packs during the deprecation
  window; PR 6 removes the duplicates by archiving `skill-consistency-auditor`.

## 0.4.0

### Commands

- `bash scripts/cursor-pack-verify.sh --pack=cursor-skill-studio`
- `bash packs/cursor-skill-studio/skills/skill-studio-write/scripts/validate-skill.sh packs/cursor-skill-studio/skills/skill-studio-write`
- `python3 -m py_compile packs/cursor-skill-studio/skills/skill-studio-write/scripts/aggregate_benchmark.py packs/cursor-skill-studio/skills/skill-studio-write/scripts/bootstrap_skill_comparison.py packs/cursor-skill-studio/skills/skill-studio-write/eval-viewer/generate_review.py`
- `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="<staging-root>" --profile=lite --dry-run`
- `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="<staging-root>" --profile=strict --dry-run`
- `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=user --profile=lite --dry-run`

### Outcome (recorded 2026-05-19)

- `cursor-pack-verify.sh --pack=cursor-skill-studio` returned
  `{"pass": true, "packsChecked": 1, "errors": [], "warnings": []}`.
- `validate-skill.sh packs/cursor-skill-studio/skills/skill-studio-write`
  returned `{"pass": true, "skill": "skill-studio-write", "lines": 215,
  "errors": [], "warnings": []}` — `SKILL.md` is 215 lines (well under the
  500-line limit) with no broken in-tree references.
- `python3 -m py_compile` succeeded for `aggregate_benchmark.py`,
  `bootstrap_skill_comparison.py`, and `eval-viewer/generate_review.py`.
- Project dry-run `lite` against a fresh `.work/pr2-smoke` staging root:
  copied 65, updated 0, conflicts 0, unchanged 0 (up from 20 in 0.3.0 — the
  +45 files are the lifted `skill-studio-write` tree).
- Project dry-run `strict`: copied 67, updated 0, conflicts 0, unchanged 0
  (lite + the two project rules).
- User-target dry-run `lite`: copied 61, updated 3, conflicts 3, unchanged 1.
  The conflicts and updates come from prior `cursor-skill-creator` installs
  in `~/.cursor/`, identical to the 0.3.0 outcome and not new in 0.4.0.

### Diagnosis

- 0.4.0 lifts content from five deprecated root skills into the new
  `skill-studio-write` bundled skill per ADR-0005. No behavior change to the
  pre-existing helper subagents, the legacy `cursor-skill-creator-workflow`
  bundled skill, or the auditor subagents merged in 0.3.0.
- The new skill is explicit-only (`disable-model-invocation: true`), closing
  the auto-invocation collision that the previous `external-skill-intake` and
  `claude-plugin-to-cursor-pack` skills had.
- `validate-pack.sh` now resolves the repo root via `git rev-parse` or the
  `AGENT_SKILLS_REPO` env var so the script keeps working when the bundled
  skill is installed outside the repo (it returns exit code `2` with a clear
  message when invoked outside `agent-skills`).

### Residual risks

- The five root-skill stubs still expose their `references/`, `assets/`, and
  `scripts/` directories. Those payloads are duplicated for one release window
  to avoid breaking external links; full removal is queued for the stub-removal
  PR per ADR-0005.
- The `cursor-skill-creator-workflow` bundled skill still installs in 0.4.0;
  consumers that pin to its `skillId` will continue to work. Removal target is
  `0.5.0`.
- No live two-skill eval comparison was executed in this release; the lifted
  scripts only got `py_compile` and dry-run smoke coverage.

## 0.3.0

### Commands

- Run `bash scripts/cursor-pack-verify.sh --pack=cursor-skill-studio`
- Run `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="$PWD" --profile=lite --dry-run`
- Run `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="$PWD" --profile=strict --dry-run`
- Run `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=user --profile=lite --dry-run`
- Run `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=user --profile=strict --dry-run`

### Outcome (recorded 2026-05-19)

- `cursor-pack-verify.sh --pack=cursor-skill-studio` returned
  `{"pass": true, "packsChecked": 1, "errors": [], "warnings": []}`.
- Project dry-run `lite`: copied 20, conflicts 0, unchanged 0.
- Project dry-run `strict`: copied 22, conflicts 0, unchanged 0 (the extra two
  files are the renamed routing rule and the existing eval-loop rule).
- The existing `cursor-skill-creator-workflow` bundled skill installs
  alongside the three new (placeholder) `skill-studio-*` skeleton directories.
- User-target dry-runs not re-run in this PR because user installs already
  hold staging conflicts from prior `cursor-skill-creator` installs;
  resolved in PR 5 release validation.

### Diagnosis

- This release is a pure rename plus skeleton plus subagent merge per ADR-0005.
- No behavior change to authoring helpers, eval loop, comparison workflow, or
  the existing bundled workflow skill.

### Residual risks

- The three new bundled-skill directories are empty placeholders. They will
  fail any consumer that tries to install or invoke them by ID until PRs 2-4
  lift content into them.
- Users who installed `cursor-skill-creator@0.2.0` must re-install under the
  new pack name; the old name is no longer present in
  `cursor-pack-registry.json`.
- Documentation references to `cursor-skill-creator` outside this pack are
  intentionally left for the 1.0.0 release (PR 5) to update in a single docs
  pass.

## 0.2.0

### Commands

- Run `python3 -m py_compile packs/cursor-skill-creator/skills/cursor-skill-creator-workflow/scripts/*.py packs/cursor-skill-creator/skills/cursor-skill-creator-workflow/eval-viewer/generate_review.py`
- Run `bash scripts/cursor-pack-verify.sh --pack=cursor-skill-creator`
- Run `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-creator --target=project --project-root="$PWD" --profile=lite --dry-run`
- Run `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-creator --target=project --project-root="$PWD" --profile=strict --dry-run`
- Run `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-creator --target=user --profile=lite --dry-run`
- Run `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-creator --target=user --profile=strict --dry-run`
- Run `python3 packs/cursor-skill-creator/skills/cursor-skill-creator-workflow/scripts/bootstrap_skill_comparison.py --comparison-name skill-comparison-smoke --skill-a skills/personal-skill-maintainer --skill-b skills/personal-pack-maintainer --evals .work/skill-comparison-smoke-evals.json --runs 1`
- Run `python3 packs/cursor-skill-creator/skills/cursor-skill-creator-workflow/eval-viewer/generate_review.py .work/skill-creator/skill-comparison-smoke/iteration-1 --skill-name skill-comparison-smoke --static .work/skill-creator/skill-comparison-smoke/iteration-1/review.html`

### Outcome

- Python syntax checks passed for the bundled scripts and review utility.
- `cursor-pack-verify.sh` returned `"pass": true` with no errors or warnings.
- Project dry-runs completed without conflicts:
  - `project` + `lite`: copied 20, conflicts 0
  - `project` + `strict`: copied 22, conflicts 0
- User dry-runs completed without changing destination files:
  - `user` + `lite`: copied 16, updated 3, conflicts 3, unchanged 1
  - `user` + `strict`: copied 16, updated 3, conflicts 3, unchanged 1
- The smoke bootstrap created `.work/skill-creator/skill-comparison-smoke`.
- The review utility generated a static smoke report at
  `.work/skill-creator/skill-comparison-smoke/iteration-1/review.html`.

### Diagnosis

- The new structural auditor subagent, comparison guide, bootstrap script,
  schema additions, and version bump are accepted by the pack verifier.
- The bundled skill still installs as a pack-scoped `kind: "skill"` artifact and
  remains outside `skill-registry.json`.
- The smoke test verified deterministic workspace and static review generation,
  not live agent execution or grading.
- User-level dry-runs detected conflicts with already-installed user Cursor
  assets, but this is expected dry-run conflict reporting and no files were
  changed.

### Residual risks

- The workflow has not yet run a full two-skill comparison with executor
  subagents, `grading.json`, `comparison.json`, and analyzer output.
- Trigger-rate behavior remains explicitly out of scope until a Cursor-native
  activation harness is designed.
- The smoke report contains empty output folders because it validates workspace
  and viewer mechanics rather than skill behavior.

## 0.1.0

### Commands

- Run `bash scripts/cursor-pack-verify.sh --pack=cursor-skill-creator`
- Run `python3 -m py_compile packs/cursor-skill-creator/skills/cursor-skill-creator-workflow/scripts/aggregate_benchmark.py packs/cursor-skill-creator/skills/cursor-skill-creator-workflow/eval-viewer/generate_review.py`

### Outcome

- `cursor-pack-verify.sh` passed with no errors after the initial scaffold.
- Python syntax checks passed for the bundled benchmark and review utilities.

### Diagnosis

- The pack manifest, registry entry, bundled skill metadata, and runtime agent
  frontmatter were all accepted by the validator.
- The initial warnings were limited to release-document quality and were fixed by
  adding a verification pointer in `CHANGELOG.md` and richer outcome notes here.

### Residual risks

- The review UI has only been syntax-checked and structurally validated in the
  pack source tree; it still needs a real workspace smoke test after installation.
- The bundled workflow intentionally omits a Cursor-native replacement for the
  Claude CLI description-optimization loop, so that part remains a follow-up.
