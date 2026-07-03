---
title: skill-studio plugin is the canonical skill-authoring toolkit
status: accepted
date: 2026-07-02
owner: felipeblassioli
adr: 0007
---

# ADR-0007: `skill-studio` plugin is the canonical skill-authoring toolkit

## Context

ADR-0005 consolidated a fragmented skill-authoring surface into one **Cursor pack**,
`cursor-skill-studio` (bundled skills `skill-studio-write` / `-audit` / `-maintain`, a
shared subagent pool, an audit script, and an eval/benchmark harness). ADR-0004 set the
cross-runtime stance that **packs are canonical and plugins are export adapters**.
ADR-0006 then introduced a Claude-first plugin **marketplace** as an additive layer, and
its first governance plugin, `repo-governance`, shipped a lean `skill-auditor` +
`skill-maintainer` that **overlaps** the pack's audit/maintain.

Two things changed the calculus:

- Claude Code plugins natively support **skills + bundled `agents/`** (proven by
  Anthropic's `skill-creator` and `plugin-dev`), so the authoring toolkit can be a
  **first-class, hand-authored plugin** — not a mechanical export of the pack.
- The authoring craft is where the owner's best practices live and evolve; it deserves a
  native Claude install path (`/plugin install …`) with description-triggered skills,
  bundled subagents, and the eval harness.

Keeping the craft split across a Cursor pack, an overlapping governance plugin, and the
`skill-creator` model we admire is redundant. We want one canonical Claude home for
skill **creating, auditing, and enhancing**.

## Decision

1. **`skill-studio` is the canonical skill-authoring toolkit**, shipped as a first-class
   Claude plugin (`plugins/skill-studio/`), modeled on `skill-creator`: three
   model-invocable skills — `skill-create`, `skill-audit`, `skill-enhance` — plus eight
   bundled `agents/` and Python audit/eval scripts.
2. **Craft vs governance split.** `skill-studio` owns the *craft* (create / audit /
   enhance). `repo-governance` keeps only `skill-maintainer` and owns *release
   governance* (versioning, validation, registry/marketplace alignment, promotion). The
   genericized `skill-auditor` doctrine (archetypes, principles, authoring-for-claude,
   report-format, `audit-skill.sh`) is **absorbed into `skill-audit`**; `skill-auditor`
   is removed from `repo-governance`.
3. **The Cursor pack is frozen.** `cursor-skill-studio` is frozen at **1.2.0**
   (bugfix-only) and stays installable for Cursor users; all new authoring work lands in
   the plugin.
4. **This updates ADR-0004.** For the skill-authoring toolkit specifically, the
   **plugin is canonical and the Cursor pack is the frozen sibling** — the reverse of
   ADR-0004's "packs canonical, plugins are export adapters." ADR-0004 remains the
   default for other packs. This **continues ADR-0005**'s consolidation into the plugin
   era.

### The three authoring/governance surfaces

| Surface | Home | Owns |
|---|---|---|
| **skill-studio** (plugin) | `plugins/skill-studio/` | Craft: create, audit, enhance (canonical) |
| **repo-governance** (plugin) | `plugins/repo-governance/` | Release governance: version, validate, promote, release |
| **cursor-skill-studio** (pack) | `packs/cursor-skill-studio/` | Frozen Cursor-native mirror (bugfix-only) |

Cross-surface handoffs are **by name** (e.g. `skill-audit` routes fixes to
`skill-enhance`; versioning to `repo-governance:skill-maintainer`).

## Consequences

### Positive
- Native Claude install/update for the authoring toolkit, with description-triggered
  skills and bundled subagents + eval harness.
- One canonical home for the owner's create/audit/enhance best practices; the genericized
  auditor is absorbed rather than duplicated.
- Clean craft-vs-governance boundary keeps each plugin single-purpose.

### Negative
- The Cursor pack no longer gains features; Cursor users stay at 1.2.0 for new capability.
  Mitigated: the pack is kept installable and bugfix-maintained.
- `skill-create` intentionally does **not** teach Cursor-pack authoring (that stays in the
  frozen pack); it carries a one-line pointer instead.
- Two authoring surfaces coexist during transition. Mitigated by this ADR + the freeze
  notices and by-name routing.

### Neutral
- ADR-0004 still governs non-authoring packs (packs remain canonical there).
- `repo-governance` remains the release/governance authority (ADR-0006 unchanged).

## Alternatives considered

- **A — Mechanical export from the pack (ADR-0004 model).** Generate the plugin from the
  pack. Rejected: the owner wants a first-class, hand-authored toolkit that evolves in
  the plugin, not a derived artifact.
- **B — Keep only the Cursor pack.** Rejected: forgoes native Claude install and the
  description-triggered skill surface.
- **C — One plugin absorbing governance too.** Fold `skill-maintainer` into
  `skill-studio`. Rejected per the chosen craft-vs-governance split; release governance is
  a distinct concern that also serves the other plugins.

## See also
- `docs/ADR/ADR-0004-cross-runtime-agent-packaging-model.md` (updated by this ADR for the authoring toolkit)
- `docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md` (continued by this ADR)
- `docs/ADR/ADR-0006-adopt-claude-first-plugin-marketplace.md`
- `docs/marketplace-governance.md`
- `plugins/skill-studio/README.md`
