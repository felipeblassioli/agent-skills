# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
as recorded in `metadata.json` and `skill-registry.json` for this skill.

## 0.1.0 - 2026-07-25

### Added

- Adopted into the registry. The skill already existed and was in use, but lived
  only as an unversioned directory in `~/.claude/skills/` — untracked, unbacked,
  and invisible to every clone. This entry records the adoption, not new
  authorship.
- `metadata.json` and a `skill-registry.json` entry, which the package lacked.
- **Deletion guardrail.** Deleting an artifact now requires all three of: tier is
  `attach`, the PR/issue is merged/closed, and no *open* case file references it.
  Added because applying "merged ⇒ delete" on PR state alone destroyed a
  `convert`-tier explainer and an in-use verification report on 2026-07-25 —
  both unrecoverable, because neither had been committed anywhere. The tier
  column already encoded the right answer; nothing told the reader to consult it
  before deleting.

### Changed

- Genericized the sibling-repo and workbench sweeps. This repo is public, and the
  live copy hard-coded four employer-internal repo names, a `~/turbi/` clone root,
  and a reference to a specific service decommission plan. The sweeps now take
  `$WORKSPACE_ROOT` and `$CURRENT_REPO`, which also makes them work for anyone
  whose clones do not live in that one directory. Method, tiers, and guardrails
  are otherwise unchanged.
