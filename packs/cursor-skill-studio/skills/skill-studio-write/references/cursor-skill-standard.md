# Cursor Skill Standard Reference

Condensed reference for authoring Cursor-native skills, with the Cursor-specific
nuances this repository cares about. Merged from the writing-cursor-skills and
create-skill-from-refs reference notes.

## Required frontmatter

```yaml
---
name: my-skill          # lowercase, hyphens, max 64 chars, MUST match folder name
description: >-         # max 1024 chars, non-empty, third-person, WHAT + WHEN
  What the skill does. Use when <trigger 1>, <trigger 2>.
---
```

- `name` must match the parent folder name exactly.
- `description` is the only text Cursor reads before deciding to load the body.
- Write the description in third person and include WHAT + WHEN.

## Optional frontmatter

| Field | Type | Purpose |
|---|---|---|
| `license` | string | License name or reference to a bundled LICENSE |
| `compatibility` | list | Prerequisites: system packages, network, runtimes |
| `metadata` | map | Arbitrary key-value pairs (domain, framework, project) |
| `disable-model-invocation` | bool | `true` -> slash-command only, never auto-invoked |

## Invocation policy

Cursor supports two main behaviors:

| Behavior | How to encode it |
|---|---|
| Agent may auto-apply the skill | Omit `disable-model-invocation` |
| Skill behaves like a slash command (`/skill-name`) | Set `disable-model-invocation: true` |

Always ask which behavior the user wants. Do not assume.

## Discovery mechanism

Cursor reads skill descriptions at startup and presents them to the agent.
Auto-discovery paths (checked in order):

| Location | Scope | Notes |
|---|---|---|
| `.agents/skills/` | Project | Generic agent discovery surface |
| `.cursor/skills/` | Project | Default for project skills |
| `~/.cursor/skills/` | Global | Personal/global Cursor capabilities |

Compatibility aliases: `.claude/skills/`, `.codex/skills/` and their `~/`
variants.

## Description rules

1. **Third person** — the description is injected into the system prompt.
   - Yes: "Deploys the application to staging environments."
   - No: "I can deploy ..." or "You can use this to deploy ..."
2. **WHAT + WHEN** — state capabilities AND trigger scenarios.
3. **Specific trigger terms** — include keywords the user would say.
4. **Anti-triggers** — when there is a sibling skill with overlapping vocabulary,
   include "Do not use when ..." to keep the router on the right path.

Formula: `<verb-phrase of capabilities>. Use when <trigger 1>, <trigger 2>. Do not use when <anti-trigger>.`

### Description token economy

Descriptions ship to the routing surface even when
`disable-model-invocation: true` is set. They are hot-path text.

- **Default (auto-invoked skills):** use the `Use when ... Do not use when ...`
  formula above. The prose pays for itself because the model uses it to
  decide whether to load the skill.
- **Router exception (`disable-model-invocation: true`):** prefer a
  compact keyword-tag form. The skill is invoked explicitly by slash
  command, so the description does not gate loading — but it still costs
  characters on every routing pass.
  - Yes: `Skill Studio audit and improvement | single-skill compliance | portfolio overlap | repo-first-party deep audit`
  - No: `Audit and improve existing Cursor skills and packs ... Invoke explicitly via /skill-studio-audit. Do not use for ...`

The `skill_hot_path_audit.py` script in `skill-studio-audit` emits a
`procedural_description` finding for router skills that still use the
`Use when` form. That finding is informational by design — it points
authors at this exception, not at a bug in the formula.

## Name rules

- Lowercase letters, numbers, hyphens only.
- Max 64 characters.
- Must match the parent folder name exactly.
- Must be descriptive (`processing-pdfs`, not `helper`).

## Directory conventions

```text
skill-name/
+-- SKILL.md          # Required main instructions
+-- metadata.json     # Required in this repo (version/author/date/abstract)
+-- references/       # On-demand docs the agent reads when needed
+-- assets/           # Static resources: templates, data, checklists
+-- scripts/          # Executable code the agent can run
```

Only create directories that will contain files.

## Progressive disclosure

- `SKILL.md` is loaded when the skill is invoked. Keep it under **500 lines**;
  aim much smaller (under 200) when the skill is a router for a wider library
  of references.
- Files in `references/` and `assets/` are loaded on demand only when the agent
  follows a link from SKILL.md.
- Keep references **one link deep** from SKILL.md. The routing table in
  SKILL.md should provide direct paths to every reference file. Deeply nested
  chains risk partial reads.

## Scripts

- Any language supported by the agent's runtime (bash, python, JS, etc.).
- Referenced in SKILL.md via relative paths from the skill root.
- Make it explicit in SKILL.md whether the agent should **execute** the script
  or only **read** it.

## Cursor-specific migration nuances

If the source artifact is a Cursor rule or command, ask:

1. Was the original meant to apply automatically or only when called directly?
2. Is the user preserving behavior or intentionally changing it?
3. Should the migrated skill stay Cursor-only, or remain portable to other
   agent directories later?

Guidance:

- Intelligent/dynamic rules often map well to auto-invoked skills.
- Slash commands often map well to `disable-model-invocation: true`.
- Always-apply or file-glob rules usually should remain rules, not skills.
