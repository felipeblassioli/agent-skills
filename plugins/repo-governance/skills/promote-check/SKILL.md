---
name: promote-check
description: >-
  Promotion preflight gate for the agent-skills marketplace. Run before promoting
  a skill from a sandbox plugin to an official one, or before opening a promotion
  PR, to get a go / no-go verdict. Audit-first: it chains the deterministic
  skill-audit signals, marketplace/registry alignment, and version + CHANGELOG
  presence, and BLOCKS (no-go) on any unresolved finding, citing the failing gate.
  User-invoked only. For fixing what it surfaces use skill-studio:skill-enhance;
  for the release wiring use repo-governance:skill-maintainer.
disable-model-invocation: true
---

# Promote Check

A **user-invoked** preflight gate for promoting a skill into an official plugin.
Established policy is audit-first: a promotion must **fix everything the audit
surfaces, not just pass a binary**. This skill makes that discipline mechanical
and hard to skip — it emits a **go / no-go** verdict and names the gate that
failed.

It composes existing tooling; it does not re-implement any check. Fixing findings
is `skill-studio:skill-enhance`; version/CHANGELOG/marketplace wiring and the
actual move is `repo-governance:skill-maintainer`. This skill only decides
go / no-go.

## Apply when

- Deciding whether a candidate skill is ready to graduate from a sandbox plugin
  (e.g. `blassioli`) to an official one.
- Before opening a promotion PR, as the preflight that must be green first.

## Do not apply when

- Authoring or fixing a skill → `skill-studio:skill-create` / `skill-enhance`.
- Doing the version bump / CHANGELOG / marketplace move → `repo-governance:skill-maintainer`.
- Auditing for judgment dimensions (archetype fit, description quality) →
  `skill-studio:skill-audit` (this gate consumes only its deterministic signals).

## Procedure

Run the deterministic gate against the candidate skill directory:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/promote-check.sh" plugins/<plugin>/skills/<skill>
# add --json for machine-readable output
```

Read the verdict:

- **go** — every gate passed. The candidate is clear for the `skill-maintainer`
  promotion workflow. `go` is necessary, not sufficient: judgment dimensions
  (archetype fit, description quality, real traction) are still the owner's call.
- **no-go** — one or more gates failed. The output names each failing gate and
  the finding. Route the fixes (audit findings → `skill-enhance`; drift/version/
  changelog → `skill-maintainer`), then re-run until `go`.

The gates run in order and every failure is reported (not just the first). See
[references/gates.md](references/gates.md) for exactly what each gate checks, the
exit codes, and the tools it wraps.

## Gates

| Gate | Blocks when | Wraps |
|------|-------------|-------|
| `audit` | unresolved mechanical finding (name↔folder, orphan/dangling refs, non-exec scripts, relative bundled-script calls, cross-package links, missing/invalid metadata) | `skill-studio` `audit-skill.sh` |
| `alignment` | marketplace ↔ plugin.json ↔ metadata ↔ CHANGELOG ↔ registry drift | `scripts/marketplace-consistency.sh` |
| `version` | `metadata.json` has no version | — |
| `changelog` | no `CHANGELOG.md`, or its top entry ≠ metadata version | — |

## Confirmation policy

- This gate is read-only and side-effect-free; it never edits, versions, moves,
  or promotes anything. Acting on a `go` (the actual promotion) is
  `skill-maintainer` and carries its own confirmation policy.

## Dependencies

- `scripts/marketplace-consistency.sh` (the `alignment` gate) and
  `plugins/skill-studio/.../audit-skill.sh` (the `audit` gate) must exist in the
  repo. If either is missing the gate exits non-zero with a clear message rather
  than passing silently.

Maintainer validation commands for this skill package live in
[README.md](README.md).
