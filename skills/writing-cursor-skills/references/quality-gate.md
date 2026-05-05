# Quality Gate

Run this before presenting the skill for final approval.

## Structural checks

- `SKILL.md` exists at the skill root
- `metadata.json` exists at the skill root
- the frontmatter `name` matches the folder name exactly
- the `description` is non-empty and written in third person
- the skill location is intentional: `.cursor/skills/` for project scope or
  `~/.cursor/skills/` for user scope
- `SKILL.md` stays concise and uses direct routing to supporting files
- no empty directories were created

## Scope and meaning checks

- the skill's job can be stated in one sentence
- in-scope and out-of-scope lists are explicit
- triggers are concrete and realistic
- anti-triggers are explicit when overlap is plausible
- neighboring skills or surfaces are named when hand-offs matter
- the skill does not hide multiple unrelated jobs behind one broad label
- the authoring flow explicitly asked whether this should stay a skill instead of
  a rule, hook, subagent, or command

## Content checks

- `SKILL.md` acts as a dispatcher, not a dump
- references contain domain-specific guidance, not generic LLM filler
- templates are realistic and reusable
- scripts, if present, are actually justified
- terminology is consistent throughout
- Cursor-specific behavior is explicit:
  - whether the skill auto-invokes or uses `disable-model-invocation: true`
  - whether optional `compatibility` or `metadata` fields are needed

## Packaging checks

- the skill folder contains only purposeful files
- `skill-registry.json` has a matching entry
- registry `description`, `tags`, and `targets` fit the actual skill
- supporting files are linked directly from `SKILL.md`
- if the skill came from a rule or command, the migrated invocation semantics
  were preserved or intentionally changed

## Reject the skill until fixed if

- the description is vague
- the boundary with a sibling skill is still fuzzy
- the user would not know when to invoke it
- the skill should really be a pack, rule, hook, subagent, or command
- the scaffold contains placeholder files with no clear use
- it is unclear whether Cursor should auto-apply it or require explicit `/` use
