---
title: Cross-runtime agent packaging model
status: draft
date: 2026-05-19
owner: felipeblassioli
adr: 0004
---

# ADR-0004: Cross-runtime agent packaging model

## Context

This repository already uses Cursor Packs under `packs/<name>/` to distribute
agent runtime assets for personal and project-local use. A pack declares its
install contract in `pack.json`, is indexed by `cursor-pack-registry.json`, and
is installed through `scripts/cursor-pack-sync.sh`.

The current pack model predates the repository's clipped Cursor Plugin
documentation. Cursor Plugins now provide an official Cursor packaging format
with `.cursor-plugin/plugin.json`, marketplace distribution, team marketplace
distribution, local testing under `~/.cursor/plugins/local`, and support for
rules, skills, agents, commands, MCP servers, and hooks.

Claude Code also has a plugin model. Claude plugins are self-contained
directories with `.claude-plugin/plugin.json` and can include skills, agents,
hooks, MCP servers, LSP servers, and commands. Claude plugin marketplaces are
Git-native catalogs declared by `.claude-plugin/marketplace.json`; they can be
added from GitHub repositories, Git URLs, local paths, or direct marketplace
files. Individual plugin entries can point to relative paths, GitHub
repositories, Git URLs, git subdirectories, or npm packages.

The repository goal is broader than a Cursor-only local installer: formalize
packaging of skills, agents, hooks, rules, MCP examples, and supporting assets
so bundles remain locally installable and can become available to at least Cursor
and Claude. At the same time, the repository already has pack-specific
governance that is not captured by official platform manifests:

- registry-managed packs are L3 artifacts under ADR-0003
- pack versions are aligned between `pack.json` and `cursor-pack-registry.json`
- targets and profiles are explicit
- installer behavior includes staging, backup, restore, and install manifests
- MCP config is `none` or `example-only`, never live by default
- bundled skills use `kind: "skill"` and pack-scoped `skillId` values
- pack-bundled skills are not added to `skill-registry.json` unless promoted

The decision needed now is whether official Cursor or Claude plugin manifests
should become the canonical source of truth, or whether the repository should
keep its pack contract canonical and add platform-specific export or install
adapters over time.

## Decision

We will keep existing Cursor Packs as the repository-native governed package
format for local and private agent runtime bundles.

For architecture discussions, the term **Agent Pack** may describe the
cross-runtime role: a versioned bundle of skills, agents, hooks, rules, MCP
examples, and supporting assets with explicit lifecycle and safety policy.

For implementation, the current v0 artifact remains **Cursor Pack**:

- `packs/<name>/pack.json`
- `cursor-pack-registry.json`
- `cursor-pack-*` scripts
- `project-cursor` and `user-cursor` target names
- existing pack maintainer skills, specs, and release artifacts

Cursor Plugin and Claude Plugin manifests are platform-specific adapter or
export surfaces. They are not the canonical authoring source of truth for this
repository's packs.

The first adapter remains the existing Cursor Pack installer,
`scripts/cursor-pack-sync.sh`. Future adapters may generate or stage:

- a Cursor Plugin tree with `.cursor-plugin/plugin.json`
- a Claude Plugin tree with `.claude-plugin/plugin.json`
- a Claude marketplace catalog with `.claude-plugin/marketplace.json`

Those adapters must preserve the pack's safety, lifecycle, registry, and release
rules.

## Scope

This ADR applies to:

- packs under `packs/<name>/`
- pack manifests named `pack.json`
- `cursor-pack-registry.json`
- pack-bundled skills under `packs/<pack>/skills/<skillId>/`
- future export surfaces for Cursor Plugin and Claude Plugin formats
- repository guidance that explains pack versus plugin boundaries

This ADR does not change:

- the current `cursor-pack-*` scripts
- the current pack schema
- `cursor-pack-registry.json`
- existing pack manifests
- the registry-driven release model from ADR-0001
- the skill maintenance model from ADR-0002
- the artifact maturity model from ADR-0003

## Terminology

**Agent Pack** means the architectural role: a governed, cross-runtime package
model for agent artifacts.

**Cursor Pack** means the current repository implementation of that role. Cursor
Packs are authored under `packs/<name>/`, declared by `pack.json`, indexed by
`cursor-pack-registry.json`, and installed by repository scripts.

**Cursor Plugin** means Cursor's official plugin format with
`.cursor-plugin/plugin.json`. Cursor Plugins can be distributed through Cursor
Marketplace or Team Marketplace surfaces, and can also be tested locally under
`~/.cursor/plugins/local`.

**Claude Plugin** means Claude Code's plugin format with
`.claude-plugin/plugin.json`.

**Claude Plugin Marketplace** means a Claude Code catalog declared by
`.claude-plugin/marketplace.json`. A marketplace may be hosted in GitHub, another
Git host, a local path, or a direct marketplace file.

## Rules

### Pack authority

`pack.json` remains the full install and artifact contract for repository packs.
`cursor-pack-registry.json` remains the discovery and version authority for
installable packs.

Generated or staged plugin manifests must not introduce independent
source-of-truth fields that drift from `pack.json` or
`cursor-pack-registry.json`.

### Maintenance gates

Registry-managed packs remain governed L3 artifacts. This ADR does not weaken
the required release files:

- `README.md`
- `CHANGELOG.md`
- `VERIFICATION.md`
- `RELEASE-POLICY.md`
- `ROADMAP.md`

Pack changes that touch `pack.json`, `cursor-pack-registry.json`, runtime
artifacts, bundled skills, or release artifacts still require
`scripts/cursor-pack-verify.sh` and relevant `cursor-pack-sync.sh --dry-run`
evidence.

### Plugin boundary

Official Cursor Plugins destined for Cursor Marketplace or Team Marketplace
distribution remain outside the pack maintenance workflow when they are authored
directly as Cursor Plugins.

When a Cursor Plugin or Claude Plugin is generated or staged from a repository
pack, the pack remains the source of truth and the generated plugin output must
respect pack maintenance gates.

### Operational names

This ADR does not rename operational surfaces. Do not rename:

- `cursor-pack-registry.json`
- `cursor-pack-*` scripts
- `project-cursor`
- `user-cursor`
- existing pack directories
- existing pack release tags

Any future terminology migration from "Cursor Pack" to "Agent Pack" must be a
separate decision or spec, after this ADR is accepted.

### Safety policy

MCP remains `none` or `example-only` by default. Export adapters must not promote
MCP examples into live MCP configuration automatically.

Live MCP activation is a separate trust decision because MCP servers may access
external systems, credentials, and local files.

Hooks shipped by packs remain bounded, inspectable, and documented. Project-only
rules and repo-specific hooks must not be exported into user-global surfaces
unless a later spec explicitly proves the target platform preserves that
boundary.

### Bundled skills

Pack-bundled skills remain skill-shaped artifacts:

- declared with `kind: "skill"` in `pack.json`
- assigned a pack-scoped `skillId`
- shipped with `SKILL.md` and `metadata.json`
- versioned with the containing pack by default
- excluded from `skill-registry.json` unless explicitly promoted

Export adapters may map bundled skills into platform plugin skill directories,
but the pack remains the release authority.

### Claude self-contained export

Claude Code copies installed plugins into a versioned cache under
`~/.claude/plugins/cache`. Therefore exported Claude plugin trees must be
self-contained and must not depend on `../` paths outside the plugin root.

Shared files must be copied, generated, or explicitly handled by a future export
spec rather than referenced outside the exported plugin directory.

## Options Considered

### Option A: Make Cursor Plugin canonical

Use `.cursor-plugin/plugin.json` as the source of truth and treat existing packs
as legacy local installer state.

**Pros**

- Aligns with Cursor's official packaging format.
- Creates a direct path to local plugin testing and future marketplace
  distribution.
- Reduces conceptual duplication for Cursor-only artifacts.

**Cons**

- Does not encode current pack profiles, backup/restore policy, install
  manifests, registry release authority, or `example-only` MCP policy.
- Orients the repository around marketplace semantics even when the goal is
  personal and private local use.
- Does not solve Claude distribution without another translation layer.

**Decision**

Rejected. Cursor Plugin is an important export target, not the repository's
canonical authoring model.

### Option B: Make Claude Plugin canonical

Use `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` as the
source of truth because Claude marketplaces are Git-native and can be hosted from
public repositories.

**Pros**

- Strong fit for GitHub-hosted marketplace distribution.
- Supports skills, agents, hooks, MCP servers, LSP servers, and commands.
- Provides direct Claude Code install and update semantics.

**Cons**

- Makes Claude-specific runtime semantics the repository's core abstraction.
- Requires reconstructing pack-specific safety and lifecycle rules after the
  fact.
- Claude plugin cache behavior requires self-contained exports, which is an
  output constraint rather than a good source model for this repository.
- Does not solve Cursor local install or Cursor marketplace export without
  another translation layer.

**Decision**

Rejected. Claude Plugin is a valuable export target and distribution channel,
but not the canonical source format.

### Option C: Create a new neutral package format immediately

Introduce a new `agent-pack.json`, registry, schema, and scripts, then migrate
existing Cursor Packs to that format.

**Pros**

- Names the cross-runtime intent directly.
- Avoids Cursor-specific terminology in long-lived architecture.
- Could be designed around Cursor and Claude from the start.

**Cons**

- Creates migration churn before the repository has export adapters.
- Duplicates a working governed pack model.
- Risks weakening current validation and release discipline during a rename.

**Decision**

Rejected for now. The ADR may introduce "Agent Pack" as an architectural role,
but implementation remains on the existing Cursor Pack model.

### Option D: Keep packs canonical and add platform adapters

Keep `packs/<name>/pack.json` and `cursor-pack-registry.json` as the canonical
repository package model, while future work adds Cursor Plugin and Claude Plugin
export adapters.

**Pros**

- Preserves current governance, registry, safety, and release model.
- Avoids unnecessary schema and script churn.
- Supports private local install immediately.
- Allows Cursor and Claude outputs to be generated from the same source.
- Keeps marketplace-specific behavior at the edges.

**Cons**

- The "Cursor Pack" name remains narrower than the emerging cross-runtime role.
- Export adapters will need clear mapping specs.
- Some platform features may not map cleanly and will require platform-only
  escape hatches.

**Decision**

Accepted.

## Consequences

### Positive

- Existing pack governance remains authoritative.
- Future Cursor Plugin and Claude Plugin support can be added without rewriting
  pack authorship.
- The repository can support Git-native Claude marketplace distribution while
  keeping its local install and safety model.
- Official plugin formats are treated as platform contracts rather than global
  repository architecture.

### Negative

- "Cursor Pack" remains the implementation name even when the architecture is
  cross-runtime.
- Future export scripts must carefully map platform differences instead of just
  copying directories.
- Documentation must keep "pack", "Cursor Pack", "Agent Pack", "Cursor Plugin",
  and "Claude Plugin" distinct.

### Neutral

- Publishing to Cursor Marketplace remains out of scope unless a future decision
  changes the repository's distribution goal.
- Claude marketplace export is future work, not a behavior guaranteed by this
  ADR.
- The current `cursor-pack-sync.sh` installer remains the only implemented pack
  adapter.

## Cross-platform metadata gap

`pack.json` and the existing artifact schema do not capture per-artifact
metadata that target platforms may require. Concrete examples:

- Claude Plugin agents accept fields such as `effort`, `maxTurns`, `tools`,
  `disallowedTools`, `skills`, `memory`, and `isolation`.
- Cursor subagent frontmatter uses Cursor-specific model slugs (for example
  `fast`, `composer-2`) that are not valid Claude model slugs.
- Cursor pack `runtime` artifacts do not declare whether they are subagents,
  rules, hooks, or MCP examples; today this is inferred from the source path.

Export adapters MUST either:

- accept information loss with explicit warnings (drop fields the source does
  not capture), or
- be paired with an opt-in extension of `pack.json` that captures the missing
  metadata at the artifact level.

The first adapter (`docs/specs/claude-plugin-export-from-packs.md`) takes the
first approach with a planned opt-in extension (`runtimeKind` discriminator)
for artifact classification. Future adapters may propose further extensions,
but any extension MUST keep `pack.json` and `cursor-pack-registry.json` as the
authoritative source of truth.

## Adapter sequencing

Adapters are sequenced deliberately, not by accident:

1. The existing Cursor Pack installer (`scripts/cursor-pack-sync.sh`) remains
   the only fully implemented adapter.
2. The Claude Plugin export adapter is sequenced first among new adapters
   because Claude Code offers a Git-native, no-cost marketplace path.
3. A Cursor Plugin export adapter is sequenced after Claude because the free
   Cursor Plugin distribution path is local-only; a Cursor Plugin export adds
   little capability over the existing Cursor Pack installer until Cursor
   provides a free private-distribution surface.

This is a stated choice, not an unaddressed gap.

## Maturity

Under ADR-0003, both planned export adapters start at **L0 (experimental)**.
Promotion to L1 requires:

- a verification workflow passing against at least one real pack
- the corresponding spec accepted
- safety and lifecycle rules in this ADR honored by the implementation

## Follow-up Work

- Implement `docs/specs/claude-plugin-export-from-packs.md` as the first
  cross-runtime export adapter (Claude Plugin and Claude Plugin Marketplace).
- Write a separate Cursor Plugin export specification when a meaningful Cursor
  free distribution path exists or when local Cursor Plugin testing becomes a
  goal beyond what the existing Cursor Pack installer covers.
- Write a separate "public Claude distribution surface" specification covering
  whether the repository commits generated plugin trees, uses an orphan branch,
  publishes release archives, or publishes a separate distribution repo. The
  initial Claude export spec deliberately stages output locally only.
- Decide whether repository docs should gradually introduce "Agent Pack"
  terminology outside this ADR.
- Consider schema and script changes only after this ADR is accepted.

## Validation Strategy

This ADR is implemented when:

- `docs/ADR/README.md` indexes ADR-0004
- the ADR preserves `personal-pack-maintainer` requirements
- the ADR does not rename current operational pack surfaces
- the ADR keeps MCP activation as a separate trust decision
- the ADR references Cursor Plugin and Claude Plugin distribution as future
  adapter work, not current script behavior
- export adapters introduced under this ADR start at L0 maturity and are
  promoted only with verification evidence
- export adapters that need metadata absent from `pack.json` either accept
  documented information loss or extend `pack.json` through a separate spec
  rather than relying on a parallel source of truth

## References

- ADR-0001: `docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md`
- ADR-0002: `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`
- ADR-0003: `docs/ADR/ADR-0003-artifact-maturity-model.md`
- `AGENTS.md`
- `.agents/skills/personal-pack-maintainer/SKILL.md`
- `docs/specs/cursor-pack-specification.md`
- `docs/specs/agentic-skill-pack-authoring.md`
- `.references/cursor/Cursor Docs - Cursor Plugins.md`
- Claude Code docs: `https://code.claude.com/docs/en/plugin-marketplaces`
- Claude Code docs: `https://code.claude.com/docs/en/plugins-reference`
- Claude Code docs: `https://code.claude.com/docs/en/discover-plugins`

## Changelog

| Date | Author | Change |
|------|--------|--------|
| 2026-05-19 | felipeblassioli | Initial draft |
