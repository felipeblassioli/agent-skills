# Socratic Discovery

Do not start by asking for filenames or folder trees. Start by defining the
skill's meaning.

## Discovery goals

By the end of discovery, you should be able to state:

- the one recurring job the skill owns
- whether the artifact should live in project or user Cursor scope
- who uses it and in what situations
- what it must do
- what it must not do
- what phrases should trigger it
- what phrases or contexts should route elsewhere

## Mandatory questions

Ask these before any scaffolding:

1. What recurring job should this skill own?
2. What problem keeps repeating that makes a skill worthwhile?
3. Should this be a project skill in `.cursor/skills/` or a user skill in `~/.cursor/skills/`?
4. What would success look like when this skill is used well?
5. What is explicitly in scope?
6. What is explicitly out of scope?
7. What related skills, rules, hooks, subagents, or commands could overlap with it?
8. What phrases should trigger it?
9. What phrases or situations should not trigger it?
10. Should Cursor auto-apply this skill, or should it be explicit-only via `disable-model-invocation: true`?
11. Is this a fresh skill, or a migration/refactor of an existing Cursor artifact?

## Output format

Present the result like this:

```markdown
## Proposed Skill Meaning

- Job: <one recurring job>
- In scope: <flat list>
- Out of scope: <flat list>
- Triggers: <phrases users would say>
- Anti-triggers: <phrases or situations that should route elsewhere>
- Related surfaces: <rules / commands / hooks / sibling skills>
```

## Strictness rules

- If the "job" contains "and" more than once, challenge it.
- If the scope sounds like a family of workflows, propose a split.
- If no anti-triggers are needed, explain why the boundary is still safe.
- If the user describes implementation details before meaning, steer back to the
  job-to-be-done first.

## Smells to challenge

- vague names such as `helper`, `utils`, or `creator`
- skills defined by file structure rather than by job
- missing sibling boundaries
- "It should handle anything related to X"
- broad meta-skills that should really be several smaller skills
