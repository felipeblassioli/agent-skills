# Cursor-Specific Skill Nuances

This skill authors Cursor-native skills, not generic agent-skill packages.

## Skill locations

Choose the location explicitly:

| Location | Scope | Use when |
|---|---|---|
| `.cursor/skills/<name>/` | Project | The skill belongs to one repository and should travel with version control |
| `~/.cursor/skills/<name>/` | User | The skill is a personal/global Cursor capability |

If the user says "Cursor-specific skill", default to `.cursor/skills/` unless
they explicitly want a global personal skill.

## Required frontmatter

Every Cursor skill needs:

```yaml
---
name: my-skill
description: What the skill does and when to use it.
---
```

Rules:

- `name` must match the folder name
- `description` is what Cursor sees before loading the skill body
- write the description in third person
- include WHAT + WHEN in the description

## Optional frontmatter to discuss

| Field | Use when |
|---|---|
| `disable-model-invocation` | The skill should be explicit-only via `/skill-name` |
| `compatibility` | The skill depends on runtimes, packages, network, or other environment prerequisites |
| `metadata` | The user wants explicit structured metadata for domain, framework, or repo-specific context |

## Invocation policy

Cursor supports two main behaviors:

| Behavior | How to encode it |
|---|---|
| Agent may auto-apply the skill | Omit `disable-model-invocation` |
| Skill behaves like a slash command | Set `disable-model-invocation: true` |

Always ask which behavior the user wants. Do not assume.

## Migration nuances

If the source artifact is a Cursor rule or command, ask:

1. Was the original meant to apply automatically or only when called directly?
2. Is the user preserving behavior or intentionally changing it?
3. Should the migrated skill stay Cursor-only, or remain portable to other
   agent directories later?

Guidance:

- intelligent/dynamic rules often map well to auto-invoked skills
- slash commands often map well to `disable-model-invocation: true`
- always-apply or file-glob rules usually should remain rules, not skills

## Surface distinctions in Cursor

| Surface | Best for |
|---|---|
| Skill | Reusable knowledge/workflow package with progressive disclosure |
| Rule | Persistent system-level guidance, optionally always-on or file-scoped |
| Hook | Runtime observation, enforcement, blocking, or loop control |
| Subagent | Context-isolated specialist work or parallel execution |

Do not create a skill that is really trying to be a hook policy, a persistent
rule, or a subagent role prompt.
