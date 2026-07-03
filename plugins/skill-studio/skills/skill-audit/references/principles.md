# Audit Principles (Claude-First)

Audit each skill against these four principles. They are adapted from the
earlier (Cursor-packs) governance to the **Claude-first** model: plugins +
`.claude-plugin/marketplace.json` + `plugin.json`, not Cursor packs and not
`skill-registry.json` (legacy). For the canonical model see
`docs/marketplace-governance.md`.

## 1. Single Responsibility

- Each skill does one reusable guidance or routing job well — and fits one
  archetype (see archetypes.md).
- The `description` optimizes **activation accuracy**, not a summary of every
  behavior: WHAT it does + WHEN to use it, a little pushy to combat
  under-triggering.
- Supporting detail lives in `references/`, `assets/`, or `scripts/` — not the
  hot path.

Signals: archetype straddling; a `description` listing many unrelated triggers;
a `SKILL.md` teaching several domains at once.

## 2. Composability Over Bundling

- A skill is independently installable as part of a plugin and composes with
  others **by name** — the model invokes a named sibling if it is installed,
  even across plugins.
- A **plugin** bundles a coherent set of skills for one audience (e.g.
  `repo-governance` for skill maintainers) and is the install + release unit.
  This is the Claude-first equivalent of the original "pack" idea — there are no
  Cursor packs here.
- Broad operating models are split across multiple skills/plugins, not folded
  into one giant `SKILL.md`.
- Cross-skill references are **by name**, never relative filesystem links:
  installed plugins are copied to a cache, so `../../other-skill/...` breaks.

Signals: `cross_package_relative_links` (the checker flags these); a skill that
should be two; a plugin mixing unrelated audiences.

## 3. Context Efficiency

- Frequently loaded surfaces stay small and discriminative. The `SKILL.md`
  frontmatter is the first routing signal; keep `SKILL.md` lean (≤ ~500 lines,
  ideally far less) and dispatcher-style.
- Heavy examples and domain references load only when the activated skill needs
  them (progressive disclosure). Large references (> ~300 lines) should carry a
  table of contents.
- A skill is a **folder, not a file** — treat the whole tree as progressive
  disclosure. Make `SKILL.md` a **hub**: a lean dispatcher (e.g. a symptom → file
  routing table) that names its spoke files, and let each spoke
  (`references/stuck-jobs.md`, `references/api.md`, …) carry the detail for one
  situation. Claude only loads a file if `SKILL.md` points to it, so every
  reference must be wired in: an **orphan** reference (shipped but never named) is
  dead weight Claude won't read, and a **dangling** pointer (named but missing) is
  a broken path.
- Output templates belong in `assets/` for Claude to copy, not inline in prose.
- Deterministic scripts are preferred over long prose for repeated mechanical
  work. Bundled scripts are referenced via `${CLAUDE_SKILL_DIR}` /
  `${CLAUDE_PLUGIN_ROOT}` (cache-safe), never a bare relative path.

Signals (checker): `skill_md_lines`, `heavy_references_without_toc`,
`orphan_references`, `dangling_skill_links`, `relative_bundled_script_calls`,
`non_executable_scripts`.

## 4. Maintainability

- `.claude-plugin/marketplace.json` (+ each `plugin.json`) is the source of
  truth for plugins, versions, and ownership. `skill-registry.json` is **legacy**
  (Cursor-era) and being retired — new plugin skills do not belong there.
- Per-skill governance/freshness lives in `metadata.json` (version, date,
  source_contracts); `CHANGELOG.md` is history.
- Skill content, manifest changes, and tooling changes stay in separate,
  reviewable commits.
- Release units are independent: one plugin can be validated, versioned, and
  released without moving the whole repository.

Signals: missing/invalid `metadata.json`; missing `CHANGELOG.md`; a pluginized
skill still listed in `skill-registry.json`; `legacy_fields` in the frontmatter
that belong in `metadata.json`.
