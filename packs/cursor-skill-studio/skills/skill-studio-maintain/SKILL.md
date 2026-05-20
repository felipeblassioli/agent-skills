---
name: skill-studio-maintain
description: >-
  Maintain governed root skills, pack-bundled skills, Cursor packs, and repo
  scripts/tools in `felipeblassioli/agent-skills`. Covers SemVer bumps with
  the bundled bump scripts, registry alignment (`skill-registry.json`,
  `cursor-pack-registry.json`), release-artifact refreshes (CHANGELOG,
  VERIFICATION, ROADMAP, RELEASE-POLICY, README), bundled-skill artifact
  edits and promotion-or-demotion decisions, artifact maturity classification
  per ADR-0003, deprecation stubs and tag flips, and install verification
  via `cursor-pack-verify.sh` plus dry-run `cursor-pack-sync.sh`. Invoke
  explicitly via `/skill-studio-maintain`. Do not use for creating or
  scaffolding new skills or packs (use `/skill-studio-write`), for
  single-skill audits, overlap clustering, or improvement diagnostics (use
  `/skill-studio-audit`), or for running install scripts without
  maintenance intent (use the repo scripts directly).
disable-model-invocation: true
---

# Skill Studio — Maintain

Governance and release surface for skills, pack-bundled skills, Cursor
packs, and repo scripts/tools. Propose first, apply after explicit approval.
One skill, six branches, shared registry doctrine with `skill-studio-write`
and `skill-studio-audit`.

## Applicability Gate

Apply this skill when ANY of the following are true:

- The user wants to bump a SemVer for an existing root skill or pack.
- The user wants to refresh `CHANGELOG.md`, `VERIFICATION.md`, `ROADMAP.md`,
  or `RELEASE-POLICY.md` on a registry-managed pack.
- The user wants to align `skill-registry.json` or
  `cursor-pack-registry.json` with the current state of an artifact (rename,
  tag, deprecate, mark replacedBy).
- The user wants to add, edit, or remove a bundled-skill artifact in
  `pack.json`.
- The user wants to promote a pack-bundled skill into a root skill (or
  stop bundling one).
- The user wants to classify or reclassify an artifact under the maturity
  model (ADR-0003).
- The user wants to verify install discovery paths, targets, profiles, or
  install safety for a pack before merge.

Do NOT apply when:

- The user wants to **create or scaffold** a new skill, pack, or external
  intake → use `/skill-studio-write`.
- The user wants a **compliance audit**, **portfolio overlap audit**, or
  **improvement recommendations** for an existing artifact
  → use `/skill-studio-audit`.
- The user wants to **install or sync** an already-shipped artifact
  operationally → use the repo scripts directly
  (`scripts/skill-sync.sh`, `scripts/cursor-pack-sync.sh`,
  `scripts/cursor-pack-restore.sh`).
- The work is general programming guidance with no governance impact.
- The work is in a repository other than `felipeblassioli/agent-skills`.

## Intent Router

Pick exactly one branch. Each branch lists the references to load on demand
and the bundled scripts it orchestrates.

| Signal | Branch | Primary references | Scripts orchestrated |
|---|---|---|---|
| Bump a root skill, refresh its CHANGELOG/README, sync `skill-registry.json` | **A. Root skill release** | `references/root-skill-package-model.md`, `references/root-skill-docs-model.md`, `references/skill-versioning-and-release.md` | `scripts/skill-version.sh`, `scripts/skill-sync.sh --dry-run` |
| Bump a pack, refresh release artifacts, sync `cursor-pack-registry.json` | **B. Pack release** | `references/manifest-and-registry.md`, `references/pack-versioning-and-release.md`, `references/pack-release-artifacts.md` | `scripts/cursor-pack-version.sh`, `scripts/cursor-pack-verify.sh` |
| Add / edit / remove a bundled-skill artifact in `pack.json` | **C. Bundled-skill artifact** | `references/bundled-skills.md`, `references/targets-profiles-artifacts.md`, `references/manifest-and-registry.md` | `scripts/cursor-pack-verify.sh` after the manifest change |
| Promote a bundled skill → root skill (or demote / stop bundling) | **D. Promotion / demotion** | `references/bundled-skills.md`, `references/root-skill-package-model.md`, `references/maturity-and-backlog.md` | `scripts/skill-version.sh` (first release of promoted root skill); registry sync |
| Classify or reclassify maturity (ADR-0003) for any artifact | **E. Maturity & backlog** | `references/maturity-and-backlog.md`, `references/script-tool-maintenance.md` (for scripts) | None — governance decision plus tag/registry edits |
| Verify pack targets, profiles, or install safety before merge | **F. Install verification** | `references/pack-lifecycle-scripts.md`, `references/safety-and-mcp-policy.md`, `references/targets-profiles-artifacts.md` | `scripts/cursor-pack-verify.sh`, `scripts/cursor-pack-sync.sh --dry-run` (per profile / target) |

If the user wants to **deprecate** an artifact (stub its `SKILL.md`, mark
the registry entry, tag `[DEPRECATED]`), route to **Branch A** for a root
skill or **Branch B** for a pack — deprecation is a versioned release.

## Shared Principles

These apply to every branch.

- **Propose, then apply.** Present the proposed file changes (registry
  edits, version bumps, manifest edits, CHANGELOG entries) and wait for
  explicit approval before writing. See "Confirmation Policy" below.
- **Registry is the source of truth.** Versions in `metadata.json` /
  `pack.json` MUST match the corresponding `skill-registry.json` /
  `cursor-pack-registry.json` entry. Never bump one without the other.
- **Frontmatter stays light.** `SKILL.md` carries `name` and `description`
  only; do not add `version:` or `last_reviewed:` to frontmatter.
- **Bundled skills version with their pack** and do not appear in
  `skill-registry.json` unless they are explicitly promoted.
- **VERIFICATION is mandatory for pack releases.** Record the actual
  command output (verify + per-profile dry-run) — it is the artifact a
  reviewer reads to trust the release.
- **One-Hop Rule.** This `SKILL.md` is a router. Each reference is linked
  directly from the intent table above.

## Branch Procedures

Each branch is a thin handoff to its reference(s). Follow the numbered
steps; load reference files only when needed.

### A. Root skill release
1. Confirm scope: which root skill (`skills/<name>/`), and what kind of
   release (`patch` / `minor` / `major`, or a deprecation stub).
2. Read `references/skill-versioning-and-release.md` for the bump ritual
   and registry alignment rules. Cross-check the package shape against
   `references/root-skill-package-model.md`.
3. Draft the CHANGELOG entry (Keep a Changelog) per
   `references/root-skill-docs-model.md`. Confirm the README still reflects
   reality.
4. Propose the diff (`metadata.json`, `skill-registry.json`,
   `CHANGELOG.md`, optional README/SKILL edits). **Pause for approval.**
5. After approval, run
   `bash scripts/skill-version.sh <skill-name> patch|minor|major` and a
   `bash scripts/skill-sync.sh --skill=<name> --dry-run` to confirm
   installs unchanged.

### B. Pack release
1. Confirm scope: which pack (`packs/<name>/`), what kind of release, and
   which profiles changed.
2. Read `references/pack-versioning-and-release.md` for the bump ritual.
   Cross-check the manifest against
   `references/manifest-and-registry.md` and the release artifacts against
   `references/pack-release-artifacts.md`.
3. Draft the CHANGELOG, VERIFICATION, and ROADMAP updates. Confirm
   README/RELEASE-POLICY only if their content actually changed.
4. Propose the diff (`pack.json`, `cursor-pack-registry.json`, release
   artifacts). **Pause for approval.**
5. After approval, run
   `bash scripts/cursor-pack-version.sh <pack> patch|minor|major`,
   `bash scripts/cursor-pack-verify.sh --pack=<pack>`, and per-profile
   `--dry-run` installs. Record the actual numbers in `VERIFICATION.md`.

### C. Bundled-skill artifact
1. Confirm whether the change is "add a bundled skill", "edit existing",
   or "remove / deprecate".
2. Read `references/bundled-skills.md` for the rules (pack-scoped
   `skillId`, `kind: "skill"`, `name` matches `skillId`, lives with the
   pack's `CHANGELOG.md`) and `references/targets-profiles-artifacts.md`
   for the artifact JSON shape.
3. Propose the `pack.json` artifact entry plus any source-tree changes
   under `packs/<pack>/skills/<skillId>/`. **Pause for approval.**
4. After approval, run `cursor-pack-verify.sh --pack=<pack>` to confirm
   the manifest still parses cleanly, then route to **Branch B** to cut a
   release that includes the bundled-skill change.

### D. Promotion / demotion
1. Confirm direction: bundled → root, root → bundled, or stop bundling
   entirely.
2. Read `references/bundled-skills.md` (Promotion boundary) plus
   `references/root-skill-package-model.md` if promoting into `skills/`.
   Consult `references/maturity-and-backlog.md` to decide whether the
   new home is L2 or L3.
3. Propose the file moves, the new (or removed) `skill-registry.json`
   entry, the affected `pack.json` artifact change, and the dual
   `CHANGELOG.md` entries (root skill + pack). **Pause for approval.**
4. After approval, follow **Branch A** for the root skill release and
   **Branch B** for the pack release that drops/changes the bundling.

### E. Maturity & backlog
1. Identify the artifact type (root skill / bundled skill / pack /
   script/tool / repo guidance).
2. Read `references/maturity-and-backlog.md`. For scripts/tools, also
   load `references/script-tool-maintenance.md`.
3. Propose the maturity label and any missing artifacts the new level
   requires (e.g., `SPEC.md` for an L2 script, `VERIFICATION.md` for an
   L3 pack). Link any new GitHub issues that should track concrete
   backlog slices.
4. If the maturity change has a release impact (e.g., a registry tag flip
   or a CHANGELOG entry), route to **Branch A** or **Branch B**.

### F. Install verification
1. Confirm scope: which pack, which targets (`project-cursor`,
   `user-cursor`), which profiles.
2. Read `references/pack-lifecycle-scripts.md` for the verify / dry-run
   ritual, `references/targets-profiles-artifacts.md` for the install
   contract, and `references/safety-and-mcp-policy.md` for the safety
   gates (MCP policy, project-only invariants, hook narrowness).
3. Run `cursor-pack-verify.sh --pack=<pack>` and per-profile
   `cursor-pack-sync.sh --dry-run` against a fresh `.work/<scratch>`
   staging root. Capture copy / update / conflict counts.
4. If a release is in flight, write the results into the pack's
   `VERIFICATION.md` under the current version section.

## Unified Review Checklist

Use this before claiming a maintenance task is done. Items not relevant to
the branch can be skipped — but every applicable item MUST be confirmed.

- [ ] `SKILL.md` frontmatter is light: `name` (matches directory or
      `skillId`) and a third-person `description`; no `version:` or
      `last_reviewed:` unless strictly necessary for provenance.
- [ ] `metadata.json` exists with `version`, `author`, `date`, `abstract`;
      prefer ISO dates for new entries.
- [ ] On version bump, the matching `skill-registry.json` or
      `cursor-pack-registry.json` entry was updated (versions identical).
- [ ] `CHANGELOG.md` updated using Keep a Changelog style for any
      maintained root skill or registry-managed pack.
- [ ] `README.md` reflects current behavior for any maintained root skill
      or registry-managed pack.
- [ ] Pack-bundled skills declare `kind: "skill"` in `pack.json`, use
      pack-scoped `skillId`, and have matching `SKILL.md` `name`.
- [ ] Bundled skills are NOT added to `skill-registry.json` unless
      explicitly promoted with independent version authority.
- [ ] `pack.json.version` equals `cursor-pack-registry.json.packs.<name>.version`.
- [ ] At least one profile declared; `install.defaultProfile` names a
      declared profile.
- [ ] Runtime artifacts: `projectPath` present iff `project-cursor` in
      `targets`; `userPath` present iff `user-cursor` in `targets`;
      project-only payloads not installed via `user-cursor`.
- [ ] `mcpPolicy` is `none` or `example-only`; no live `mcp.json` written
      by the install path; hooks are narrow and inspectable.
- [ ] Required release files exist on registry-managed packs:
      `README.md`, `CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`,
      `ROADMAP.md`.
- [ ] Registry-managed packs treated as L3 under ADR-0003; scripts/tools
      with stable contracts carry `SPEC.md` and tests.
- [ ] Backlog slices that affect durable direction are tracked in
      `ROADMAP.md` and linked GitHub issues.
- [ ] On pack bump: `cursor-pack-version.sh` used; `cursor-pack-verify.sh`
      pass recorded; per-profile `--dry-run` numbers recorded in
      `VERIFICATION.md`.
- [ ] On skill bump: `skill-version.sh` used; `skill-sync.sh --dry-run`
      shows clean install.
- [ ] Repository-level governance changes update root `CHANGELOG.md`.
- [ ] Release tag follows `skill-<name>@<version>` for root skills or
      `pack-<name>@<version>` for packs.

## Confirmation Policy

Do not modify `skill-registry.json`, `cursor-pack-registry.json`,
`pack.json`, release artifacts, or version files without explicit user
confirmation. The flow is always:

1. Restate the scope (which artifact, what change).
2. Present the proposed diff.
3. **Pause for approval.**
4. Apply the change and report back with the verification evidence
   (script output, dry-run numbers).

## Repo-Only Operations

The bundled bump and verify scripts assume this repository's layout.
Outside `felipeblassioli/agent-skills`, only the install scripts
(`cursor-pack-sync.sh`, `cursor-pack-restore.sh`, `skill-sync.sh`) apply.

## See Also

- [`docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md`](../../../../docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md) — release model.
- [`docs/ADR/ADR-0002-governed-skill-maintenance-model.md`](../../../../docs/ADR/ADR-0002-governed-skill-maintenance-model.md) — governed maintenance model.
- [`docs/ADR/ADR-0003-artifact-maturity-model.md`](../../../../docs/ADR/ADR-0003-artifact-maturity-model.md) — maturity tiers.
- [`docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md`](../../../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md) — why this surface exists and how it relates to the deprecated source skills.
- [`docs/specs/skill-authoring-checklist.md`](../../../../docs/specs/skill-authoring-checklist.md) and [`pack-authoring-checklist.md`](../../../../docs/specs/pack-authoring-checklist.md) — authoring-side checklists (link, do not duplicate).
- [`docs/specs/artifact-maintenance-workflow.md`](../../../../docs/specs/artifact-maintenance-workflow.md) — repo-level workflow this branch implements.
- `../skill-studio-write/SKILL.md` and `../skill-studio-audit/SKILL.md` — sibling surfaces.
