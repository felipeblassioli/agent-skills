# Marketplace Governance (Claude-First)

`agent-skills` is a **Claude Code plugin marketplace**. Skills are distributed as
plugins, installed and updated through Claude Code's plugin manager. This document
defines how plugins are owned, how skills get in, and how they are promoted —
adapted from
[Anthropic's skills-marketplace model](https://claude.com/blog/lessons-from-building-claude-code-how-we-use-skills).

See
[ADR-0006](ADR/ADR-0006-adopt-claude-first-plugin-marketplace.md)
for the decision record behind the Claude-first model and how it coexists with
this repository's pre-existing Cursor-era registry.

## Layout

```text
.claude-plugin/marketplace.json   # marketplace catalog, name: "agent-skills"
plugins/<plugin>/.claude-plugin/plugin.json
plugins/<plugin>/skills/<skill>/SKILL.md
```

Install:

```bash
/plugin marketplace add felipeblassioli/agent-skills
/plugin install skill-studio@agent-skills      # author / audit / enhance skills
/plugin install repo-governance@agent-skills   # release governance / meta-tooling
/plugin install blassioli@agent-skills         # personal sandbox — use at your own risk
```

## Tiers

There is no centralized committee that decides what is "good." Usefulness is found
organically, and every plugin has a single accountable **owner**.

| Tier | What it is | Example | Guarantees |
|---|---|---|---|
| **Marketplace (official)** | Reviewed, supported plugins for a defined audience | *(none yet — the destination sandbox skills get promoted to once they earn traction)* | Versioned, validated, maintained |
| **Sandbox (personal)** | Experimental, unproven skills published by an individual | `blassioli` | **None — use at your own risk** |

The official tier is aspirational today: it is the destination a sandbox skill
graduates to once it earns real traction, not a populated set of plugins. A
sandbox plugin is the GitHub equivalent of "drop it in a folder and point people
to it." It carries an explicit `USE AT YOUR OWN RISK` note in its `plugin.json`
description and is not supported.

Two plugins are meta-tooling rather than a tier of consumer-facing skills:
`skill-studio` (authoring craft — create, audit, and enhance skills) and
`repo-governance` (release governance — versioning, validating, promoting, and
releasing plugins and skills). See
[ADR-0007](ADR/ADR-0007-skill-studio-plugin-canonical.md) for the craft-vs-governance
split.

## Ownership

Every plugin declares an owner via `author` (name + email) in its `plugin.json`,
and the marketplace declares an `owner`. The owner:

- decides when a sandbox skill has earned enough traction to be promoted,
- is the point of contact for issues and review,
- approves changes to their plugin.

Current ownership: **Felipe Blassioli `<felipeblassioli@gmail.com>`** for the
marketplace and all plugins. This is a personal, public marketplace; ownership
can be reassigned if a plugin later moves to a shared home.

## Promotion flow (sandbox → marketplace)

1. **Publish to a sandbox plugin** (e.g. `blassioli`). Announce it and let people
   try it.
2. **Gather traction.** The skill owner decides when there is enough real usage
   and confidence. There is no fixed threshold — it is the owner's call.
3. **Open a PR to promote** the skill into an official plugin (moving it out of
   `plugins/blassioli/skills/<skill>` into a new official plugin), with the
   package brought up to the governance contract below.

Demotion runs the same way in reverse: a flaky or unmaintained skill can move back
to a sandbox plugin or be removed.

## Coexistence with the Cursor-era registry

This Claude-first plugin marketplace lives **alongside** the repository's
pre-existing Cursor-era model. Both continue to exist; they govern different
trees and are released by different tooling.

| Model | Governs | Registry / tooling |
|---|---|---|
| **Claude-first marketplace** (this doc) | `plugins/*` and `.claude-plugin/marketplace.json` | `scripts/release-skill.sh`, `scripts/release-plugin.sh`, the `release-skill.yaml` / `release-plugin.yaml` workflows |
| **Cursor-era model** (pre-existing) | top-level `skills/` and `packs/` | `skill-registry.json`, `cursor-pack-registry.json`, and the sync scripts under `scripts/` |

The marketplace governs **only** `plugins/*` and
`.claude-plugin/marketplace.json`. The legacy top-level `skills/` and `packs/`
keep their own registries and tooling and are **not** released by the marketplace
workflows. See
[ADR-0006](ADR/ADR-0006-adopt-claude-first-plugin-marketplace.md)
for the full rationale and boundary detail.

## Composing skills

Skill dependencies are not natively modeled. Reference another skill **by name**
and the model will invoke it if it is installed — including across plugins. Do
**not** use relative filesystem links across skills or plugins: installed plugins
are copied to a cache, so cross-package relative paths break. Reference bundled
files inside the same skill via `${CLAUDE_SKILL_DIR}` / `${CLAUDE_PLUGIN_ROOT}`.

## Skill package contract (official plugins)

Each skill under an official plugin keeps:

- `SKILL.md` — frontmatter is `name` + `description` only (plus optional
  `allowed-tools`); this is the Agent Skills standard Claude reads.
- `metadata.json` — governance/freshness metadata (`version`, `date`, `abstract`,
  `source_contracts`). This is where versioning and source-contract review live,
  not the frontmatter.
- `CHANGELOG.md` — release history (kept verbatim; not rewritten on rename).
- `evals/` — the skill's test suite and baseline evidence (see below).

### Evals & evidence

Skill behavior is backed by **reproducible evidence**, so every behavioral change
can be defended with a number rather than a hunch. The methodology is
[agentskills.io — Evaluating skill output quality](https://agentskills.io/skill-creation/evaluating-skills)
(with-skill vs. baseline → strict grading with quoted evidence → benchmark → iterate).

What lives where:

| Artifact | Location | Committed? | Role |
|---|---|---|---|
| `evals/evals.json` | inside the skill | **yes** | The test suite — realistic edge cases (traps + over-trigger controls), each with assertions |
| `evals/baselines/<date>-iterN.md` (+`.benchmark.json`) | inside the skill | **yes** | Evidence snapshot: pass-rate delta, model, date |
| `<skill>-workspace/iteration-N/` | `.work/` | **no** (gitignored) | Raw runs / transcripts — reproducible from the suite |

Rules:

- Each official skill carries an `evals/evals.json` suite. Design **realistic**
  edge cases — include safety traps and over-trigger controls, not happy paths only.
- Establishing or moving a baseline commits a small `evals/baselines/` snapshot;
  the bulky raw runs stay in `.work/`.
- Every `CHANGELOG.md` version bump that changes behavior **cites the baseline
  snapshot** (pass-rate delta + model + date) as its evidence.

The `skill-studio:skill-audit` skill reports whether a skill has an `evals/`
suite and a baseline snapshot (an `evals` signal in its JSON), so missing evidence
surfaces in the marketplace sweep.

Validate before opening a PR:

```bash
claude plugin validate ./plugins/<plugin> --strict
claude plugin validate . --strict     # marketplace
```

See [versioning](versioning.md) and [releasing](releasing.md) for version bumps
and release tags.
