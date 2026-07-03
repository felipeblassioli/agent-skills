# skill-studio

A best-practice toolkit for **authoring, auditing, and enhancing** Claude Code skills
and plugins. It is the Claude-first evolution of the `cursor-skill-studio` Cursor pack
(now frozen — see [ADR-0007](../../docs/ADR/ADR-0007-skill-studio-plugin-canonical.md)),
modeled on the shape of Anthropic's `skill-creator`.

## Skills

| Skill | Use it to… |
|---|---|
| **skill-create** | Create a skill from scratch (Socratic greenfield discovery), distill reference material into a skill, scaffold a Claude plugin, or evaluate/adapt an external skill before importing it. |
| **skill-audit** | Audit a skill for quality, context-efficiency, and best-practice compliance; classify its archetype; and review a portfolio of skills for overlap and trigger collisions. |
| **skill-enhance** | Recommend the highest-leverage improvements to an existing skill, and run the eval/benchmark loop (with-skill vs baseline) that proves a change actually helped. |

Release/versioning/registry **governance** lives in the sibling `repo-governance`
plugin, not here (craft vs governance split).

## Install

```bash
/plugin marketplace add felipeblassioli/agent-skills
/plugin install skill-studio@agent-skills
```

## What's bundled

- `agents/` — helper subagents (grader, comparator, analyzer, bootstrapper,
  structural-auditor, overlap-clusterer, architecture-checker, consolidation-advisor).
- Per-skill `scripts/` — the `skill_hot_path_audit.py` auditor, the `audit-skill.sh`
  mechanical checker, and the Python eval/benchmark harness.
- Per-skill `references/` — the authoring, audit, and evaluation doctrine.
