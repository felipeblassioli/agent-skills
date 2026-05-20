# Changelog

All notable changes to `cursor-skill-studio` (formerly `cursor-skill-creator`)
will be documented in this file.

The format is based on Keep a Changelog and this project follows SemVer.

## [1.2.0] - 2026-05-20

### Added — Gotchas sections in all three studio bundled skills

Apply the highest-leverage best-practice from
[agentskills.io best practices for skill creators](https://agentskills.io/skill-creation/best-practices)
("the highest-value content in many skills is a list of gotchas —
environment-specific facts that defy reasonable assumptions"). Each
gotcha captures a concrete correction we have actually made during
PRs 1–6 of ADR-0005, not generic advice.

- `skill-studio-write/SKILL.md`: 6 gotchas — `metadata.json` required
  by `validate-skill.sh`, `skillId`/`name` matching rule for bundled
  skills, promotion semantics for `skill-registry.json` entries, user
  installs skipping `.cursor/rules/`, `disable-model-invocation: true`
  not shrinking the description budget, `mcpPolicy` defaults.
- `skill-studio-audit/SKILL.md`: 5 gotchas — `skill-overlap-clusterer`
  noise threshold, `skill-architecture-checker` path assumption,
  required outcome + effort/risk on every improvement recommendation,
  audits propose-not-apply invariant, the audit-vs-eval boundary.
- `skill-studio-maintain/SKILL.md`: 7 gotchas — version drift between
  `metadata.json` / `skill-registry.json`, the equivalent pack drift,
  deprecation-as-versioned-release rule, `VERIFICATION.md` raw-output
  requirement, user installs skipping project rules, bundled-skill
  version authority, `git mv` for archived packs.

### Removed — redundant Confirmation Policy sections

Drop the top-level `## Confirmation Policy` block from all three
studio bundled skills. Per-branch `**Pause for approval.**` callouts
already carry the per-branch pause points, and the top-level
enumeration risked the agent following a generic 5-step pause list
instead of the branch-specific procedure.

- `skill-studio-write`: deleted the 5-item pause list (surface
  decision / contract / archetype / draft / validation). Per-branch
  callouts remain.
- `skill-studio-audit`: deleted the 3-item pause list (scope /
  initial findings / final remediation). Per-branch callouts remain.
- `skill-studio-maintain`: deleted the 4-step flow ("restate scope →
  propose → pause → apply with verification evidence") and folded the
  unique content into the "Propose, then apply" shared principle, so
  the flow is stated once instead of twice.

### Changed

- `pack.json` and `cursor-pack-registry.json` bumped to 1.2.0.
- README version field updated.
- VERIFICATION.md records the 1.2.0 evidence.

### Non-changes (intentional)

- Descriptions on the three studio bundled skills were NOT tightened
  in this release. That work is deferred to a follow-up PR so the
  trigger surface diff stays isolated and can be rolled back
  independently if anything regresses.
- The `Unified Review Checklist` in `skill-studio-maintain` was kept
  as-is — it serves a different purpose (release self-audit) than
  the deleted Confirmation Policy.
- Reference and template files were not touched. Their mentions of a
  generic "Confirmation Policy" section are prescriptive guidance for
  skills *being authored*, not cross-references to the deleted block.

## [1.1.0] - 2026-05-20

### Removed (ADR-0005 PR 6 — final cleanup)

- **Nine deprecated root-skill stub directories** deleted from `skills/`
  and unregistered from `skill-registry.json`:
  `writing-cursor-skills`, `create-skill-from-refs`,
  `create-cursor-pack-from-refs`, `external-skill-intake`,
  `claude-plugin-to-cursor-pack`, `audit-skill-for-cursor`,
  `improving-agent-artifacts`, `personal-skill-maintainer`,
  `personal-pack-maintainer`. Invoke `/skill-studio-write`,
  `/skill-studio-audit`, or `/skill-studio-maintain` instead.
- **Deprecated `skill-consistency-auditor` Cursor pack** moved to
  `packs/.archive/skill-consistency-auditor/` and removed from
  `cursor-pack-registry.json`. Its installed portfolio audit lives in
  `/skill-studio-audit` Branch C.
- **Legacy `cursor-skill-creator-workflow` bundled skill** removed from
  this pack (`packs/cursor-skill-studio/skills/cursor-skill-creator-workflow/`
  deleted; `bundled-skill-workflow` artifact dropped from `pack.json`).
  Superseded by `skill-studio-write` since 0.4.0. Existing user installs
  should re-sync `cursor-skill-studio` to drop the stale files under
  `~/.cursor/skills/cursor-skill-creator-workflow/`.

### Changed

- `pack.json` and `cursor-pack-registry.json` bumped to 1.1.0; pack
  description refreshed to drop the legacy-bundled-skill clause.
- `skills/gh-post-code-review/README.md` — public GitHub link now points
  at `packs/cursor-skill-studio/skills/skill-studio-write` instead of
  the removed `skills/writing-cursor-skills` directory.

### Migration notes

- Nothing in the active 1.0.x install surface relied on the deleted
  stubs or on `cursor-skill-creator-workflow`; PR 5's documentation
  sweep already moved every routing surface to the studio bundled
  skills. The 1.1.0 → user re-sync is recommended only to keep
  `~/.cursor/skills/` tidy.
- `packs/.archive/` is excluded from `cursor-pack-verify.sh` discovery,
  so the archived auditor pack will not appear in registry listings or
  install commands.

### Provenance / non-changes

- ADR-0005 itself is preserved verbatim as the decision record for the
  consolidation; routing tables there still name the deprecated
  surfaces as historical context. The "current routing" column added
  in 1.0.0 remains the live pointer.

## [1.0.0] - 2026-05-20

### Changed

- **Stable 1.0.0.** Finalizes the skill-studio surface defined by
  [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).
  The three explicit-only bundled skills — `skill-studio-write`,
  `skill-studio-audit`, and `skill-studio-maintain` — are now the canonical
  authoring, audit, and maintain entry points for this repository.
- Promoted the pack to maturity level **stable** per
  [ADR-0003](../../docs/ADR/ADR-0003-artifact-maturity-model.md): documented
  release artifacts (`README.md`, `CHANGELOG.md`, `VERIFICATION.md`,
  `RELEASE-POLICY.md`, `ROADMAP.md`), explicit-only bundled-skill
  invocation, and verified install on both `project-cursor` and
  `user-cursor` targets across `lite` and `strict` profiles.

### Documentation sweep (PR 5 of ADR-0005)

- `docs/agent-skills.md` — collapsed nine deprecated root-skill rows into a
  single ADR-0005 redirect block; updated the pack-bundled table to list
  `skill-studio-write`, `skill-studio-audit`, `skill-studio-maintain`, and
  marked `cursor-skill-creator-workflow` as deprecated.
- `docs/architecture.md` — Pattern 3 "Pack With Bundled Skill" example now
  uses `cursor-skill-studio` / `skill-studio-write`.
- `docs/cursor-packs.md` — replaced the `cursor-skill-creator` quick-start
  entry with `cursor-skill-studio` and added a deprecation row for
  `skill-consistency-auditor`.
- `README.md` — pointed the PR validation example at the bundled
  `validate-skill.sh` under `skill-studio-write` and removed the
  deprecated `create-skill-from-refs` row from "Selected Skills".
- `.cursor/rules/30-pr-workflow.mdc`, `.github/copilot-instructions.md`,
  `.github/instructions/skills.instructions.md`,
  `.github/pull_request_template.md` — repointed all `validate-skill.sh`
  and quality-checklist citations at the bundled
  `skill-studio-write/scripts/` and `references/` paths.
- `docs/ADR/ADR-0003-artifact-maturity-model.md` and
  `docs/ADR/ADR-0004-cross-runtime-agent-packaging-model.md` —
  amendments pointing the maintainer references at `skill-studio-maintain`
  while preserving the original decisions.
- `docs/specs/claude-plugin-export-from-packs.md`,
  `docs/specs/artifact-maintenance-workflow.md`,
  `docs/specs/skill-overlap-audit.md`,
  `docs/specs/pack-recommendation-metadata.md` —
  cross-references and example commits updated.
- `skills/blassioli-code-reviewer/SKILL.md` and `README.md` — anti-trigger
  and "Related Skills Or Packs" sections now route to `cursor-skill-studio`
  bundled skills instead of the deprecated root skills.
- Pack internals: `pack.json` (1.0.0 + refreshed description); bundled
  `references/import-paths.md` line 62 now routes to
  `/skill-studio-write` Branch B; `skill-studio-write/SKILL.md` See-Also
  rephrased to drop the deprecated routing name; `bundled-skills.md` and
  `platform-audit-lenses.md` already pointed at the new bundled paths.

### Provenance / non-changes

- Stub root skills (the nine deprecated entries) and the deprecated
  `skill-consistency-auditor` pack stay installed for one more release; PR 6
  of ADR-0005 deletes the stubs and archives the pack.
- Legacy `cursor-skill-creator-workflow` bundled skill stays installed in
  1.0.0 to avoid an in-flight break for users mid-upgrade; PR 6 removes it.
- "Was `skills/<deprecated>`" provenance lines in this changelog,
  `VERIFICATION.md` historical sections, and the merged `references/*.md`
  banners are intentionally retained as historical context.

## [0.6.0] - 2026-05-20

### Added

- New bundled skill `skill-studio-maintain` consolidates the maintain-side
  surface into one explicit-only entry point
  (`disable-model-invocation: true`) with six intent branches:
  - Branch A — Root skill release
    (was `skills/personal-skill-maintainer`)
  - Branch B — Pack release
    (was `skills/personal-pack-maintainer`)
  - Branch C — Bundled-skill artifact (shared by both source skills)
  - Branch D — Promotion / demotion (shared)
  - Branch E — Maturity & backlog (ADR-0003 routing, shared)
  - Branch F — Install verification
    (was `skills/personal-pack-maintainer`)
- 13 merged references: `root-skill-package-model.md`,
  `root-skill-docs-model.md`, `skill-versioning-and-release.md` (lifted from
  the skill maintainer); `pack-package-model.md`, `manifest-and-registry.md`,
  `targets-profiles-artifacts.md`, `pack-release-artifacts.md`,
  `pack-lifecycle-scripts.md`, `safety-and-mcp-policy.md` (lifted verbatim
  from the pack maintainer); `bundled-skills.md` (merged the two source
  references — skill maintainer + pack maintainer); plus three new thin
  pointers: `pack-versioning-and-release.md` (splits the bump ritual out of
  the lifecycle reference), `maturity-and-backlog.md` (thin pointer to
  ADR-0003 + the artifact maintenance workflow spec), and
  `script-tool-maintenance.md` (codifies the `scripts/<tool>/SPEC.md` +
  tests contract that previously only lived as a checklist item).
- Pack manifest gains a fourth bundled-skill artifact entry
  (`bundled-skill-studio-maintain`) targeting both `project-cursor` and
  `user-cursor` in `lite` and `strict` profiles.

### Deprecated

- `skills/personal-skill-maintainer` and `skills/personal-pack-maintainer`
  are now thin redirect stubs (`disable-model-invocation: true`) pointing
  to `/skill-studio-maintain` (Branches A/C/D/E and B/C/E/F respectively).
  Reference files retained for one release window. Registry entries bumped
  to `1.2.0` with the `deprecated` tag and `[DEPRECATED]` description
  prefix.

### Changed

- Pack `description` updated to mention the third bundled skill and the
  completed maintain workflow.
- `cursor-pack-registry.json` description updated likewise.

### Verification

- `cursor-pack-verify.sh --pack=cursor-skill-studio`: pass.
- `validate-skill.sh packs/cursor-skill-studio/skills/skill-studio-maintain`:
  see `VERIFICATION.md` for line count and warning details.
- Dry-run installs for `project` (lite + strict) and `user` (lite) targets;
  see `VERIFICATION.md` for copy/conflict counts.

## [0.5.0] - 2026-05-19

### Added

- New bundled skill `skill-studio-audit` consolidates the audit-side surface
  into one explicit-only entry point (`disable-model-invocation: true`) with
  four intent branches:
  - Branch A — Single-skill compliance audit
    (was `skills/audit-skill-for-cursor`)
  - Branch B — Improvement recommendation
    (was `skills/improving-agent-artifacts`)
  - Branch C — Installed portfolio audit
    (was `packs/skill-consistency-auditor/skills/skill-consistency-auditor-workflow`)
  - Branch D — Repo-first-party overlap audit
    (thin adapter to `docs/specs/skill-overlap-audit.md`)
- Six merged references: `single-skill-audit.md` (lifted audit procedure),
  `skill-improvement.md`, `pack-improvement.md`, `platform-audit-lenses.md`
  (Cursor + Anthropic + Codex lenses merged into one file),
  `portfolio-audit-workflow.md` (lifted from the deprecated bundled
  workflow), and `repo-skills-overlap-audit.md`.
- Two asset templates under `assets/templates/`:
  `improvement-recommendation.md` (lifted) and `portfolio-audit-report.md`
  (lifted from the broken `packs/skill-consistency-auditor/assets/`
  path — now actually installs with the bundled skill, closing the
  ADR-0005 FAIL).
- Pack manifest gains a third bundled-skill artifact entry
  (`bundled-skill-studio-audit`) targeting both `project-cursor` and
  `user-cursor` in `lite` and `strict` profiles.

### Deprecated

- `skills/audit-skill-for-cursor` and `skills/improving-agent-artifacts`
  are now thin redirect stubs (`disable-model-invocation: true`) pointing to
  `/skill-studio-audit` (Branches A and B). Reference files and assets are
  retained for one release window. Registry entries bumped to deprecated.
- `packs/skill-consistency-auditor` is marked deprecated in `pack.json`,
  `README.md`, and `cursor-pack-registry.json` (description prefixed
  `[DEPRECATED]`, tag `deprecated` added). Pack still installs through this
  release for compatibility. The bundled
  `skill-consistency-auditor-workflow` is a redirect stub; the three audit
  subagents remain functional inside the pack and are duplicated in
  `cursor-skill-studio`. Scheduled to move to `packs/.archive/` in the
  stub-removal PR per ADR-0005.

### Changed

- `skill-consolidation-advisor` subagent updated to point at the installed
  template path (`skill-studio-audit/assets/templates/portfolio-audit-report.md`)
  so the report path actually resolves after install.
- `pack.json` description updated to mention both bundled skills and the
  pending maintain workflow.

### Verification

- `cursor-pack-verify.sh --pack=cursor-skill-studio`: pass.
- `validate-skill.sh packs/cursor-skill-studio/skills/skill-studio-audit`:
  see `VERIFICATION.md` for line count and warning details.
- Dry-run installs for `project` (lite + strict) and `user` (lite) targets;
  see `VERIFICATION.md` for copy/conflict counts.

## [0.4.0] - 2026-05-19

### Added

- New bundled skill `skill-studio-write` consolidates the five write-side root
  skills into one explicit-only authoring surface (`disable-model-invocation:
  true`) with six intent branches:
  - Branch A — Greenfield skill (was `skills/writing-cursor-skills`)
  - Branch B — Skill from reference material (was `skills/create-skill-from-refs`)
  - Branch C — Pack from reference material (was `skills/create-cursor-pack-from-refs`)
  - Branch D — External skill intake (was `skills/external-skill-intake`)
  - Branch E — Claude-plugin adaptation (was `skills/claude-plugin-to-cursor-pack`)
  - Branch F — Eval / comparison loop (lifted from `cursor-skill-creator-workflow`)
- 13 merged references (greenfield discovery, surface selection, Cursor skill
  standard, skill archetypes, skill quality checklist, material intake, pack
  standard, pack archetypes, pack quality checklist, source decomposition,
  candidate review, import paths, eval loop) and 20+ asset templates including
  archetype scaffolds and the pack template family.
- Pack-bundled scripts: `validate-skill.sh`, `validate-pack.sh` (rewritten to
  locate the repo root via `git rev-parse` or `AGENT_SKILLS_REPO`),
  `inspect-candidate-skill.sh`, `bootstrap_skill_comparison.py`,
  `aggregate_benchmark.py`, and the eval review UI under `eval-viewer/`.
- Pack manifest gains a second bundled-skill artifact entry
  (`bundled-skill-studio-write`) targeting both `project-cursor` and
  `user-cursor` in `lite` and `strict` profiles.
- `docs/specs/pack-recommendation-metadata.md` (relocated from
  `skills/create-cursor-pack-from-refs/references/recommendation-metadata.md`)
  so the future advisory-MCP schema grows as a durable spec rather than a
  hot-path skill reference.

### Deprecated

- `skills/writing-cursor-skills`, `skills/create-skill-from-refs`,
  `skills/create-cursor-pack-from-refs`, `skills/external-skill-intake`, and
  `skills/claude-plugin-to-cursor-pack` are now stub-and-redirect skills.
  `SKILL.md` bodies were replaced with a thin redirect to
  `/skill-studio-write`; each skill carries `disable-model-invocation: true`
  (closing the auto-invocation collision that intake and Claude-plugin skills
  previously had). Reference files, asset templates, and scripts remain in
  place for one release window so existing links keep resolving; full removal
  is scheduled for the stub-removal PR per ADR-0005.
- The previous bundled `cursor-skill-creator-workflow` skill is marked
  deprecated in `pack.json` notes. It still installs in 0.4.0 to avoid
  breaking existing installs; removal target is 0.5.0.
- `skill-registry.json` entries for the five stubs gained a `deprecated` tag
  and a `[DEPRECATED — replaced by ...]` description prefix; versions were
  bumped (writing-cursor-skills `1.1.0`→`1.2.0`; the other four
  `1.0.x`→`1.1.0`).

### Changed

- `cursor-pack-registry.json` `cursor-skill-studio` entry bumped to `0.4.0`
  and description updated to reflect the new bundled skill.
- `cursor-skill-creator-workflow` `pack.json` notes rewritten to flag the
  deprecation explicitly.

### Verification

- See [VERIFICATION.md](VERIFICATION.md) for the 0.4.0 validation matrix.

## [0.3.0] - 2026-05-19

### Changed

- **Pack renamed** from `cursor-skill-creator` to `cursor-skill-studio` to
  reflect its new scope: the full skill lifecycle (write, maintain, audit).
  Source tree moved from `packs/cursor-skill-creator/` to
  `packs/cursor-skill-studio/`. Registry key in `cursor-pack-registry.json`
  renamed accordingly. Per ADR-0005.
- Routing rule renamed from `10-skill-creator-routing.mdc` to
  `10-skill-studio-routing.mdc`.

### Added

- Skeleton bundled-skill directories `skills/skill-studio-write/`,
  `skills/skill-studio-maintain/`, and `skills/skill-studio-audit/`.
  Content is lifted from the deprecated root skills in PRs 2-4 of the
  ADR-0005 migration.
- Auditor subagents merged in from `packs/skill-consistency-auditor/`:
  `skill-overlap-clusterer`, `skill-architecture-checker`,
  `skill-consolidation-advisor`. The auditor pack will be archived in PR 6
  per ADR-0005.

### Notes

- The existing `cursor-skill-creator-workflow` bundled skill keeps working
  during the migration; it is replaced by `skill-studio-write` in PR 2.
- Users who installed `cursor-skill-creator@0.2.0` need to re-install under
  the new pack name; no functional regressions in this release.

### Verification

- See [VERIFICATION.md](VERIFICATION.md) for the 0.3.0 validation matrix.

## [0.2.0] - 2026-05-19

### Added

- First-class skill-vs-skill comparison workflow in the bundled installed skill.
- Source-level structural auditor subagent for comparing skill package shape,
  trigger quality, hot-path size, resources, safety, and repository fit.
- Deterministic `bootstrap_skill_comparison.py` workspace setup script.
- Skill comparison guide and JSON schema references for comparison manifests,
  blind comparison results, structural inventories, and final analysis output.

### Changed

- Expanded grader, comparator, analyzer, strict rules, README, and evaluation
  guide to separate behavioral evidence from source-maintainability evidence.

### Verification

- See [VERIFICATION.md](VERIFICATION.md) for validation commands, outcomes, and
  residual risks.

## [0.1.0] - 2026-03-20

### Added

- Initial `cursor-skill-creator` pack scaffold.
- Bundled `cursor-skill-creator-workflow` installed skill.
- Helper subagents for bootstrap, grading, analysis, and blind comparison.
- Strict project rules for authoring workflow discipline.
- Evaluation and review toolkit assets bundled with the installed skill.

### Verification

- See [VERIFICATION.md](VERIFICATION.md) for validator output and residual risks.
