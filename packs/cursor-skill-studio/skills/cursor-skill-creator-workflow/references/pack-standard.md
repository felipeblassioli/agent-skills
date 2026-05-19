# Pack Standard

Use this reference when defining the install contract for a new Cursor pack.

## Required files

- `packs/<name>/pack.json`
- `packs/<name>/README.md`
- `cursor-pack-registry.json`

For evolving packs, also commit:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `RELEASE-POLICY.md`
- `ROADMAP.md`

## Common runtime surfaces

- `.cursor/agents/*.md` for reusable helper subagents
- `.cursor/rules/*.mdc` for persistent project guidance
- `skills/<folder>/` under the pack root for bundled skills
- `guides/*.md` for human-facing usage and safety notes

## Bundled skill rule

Bundled skills stay skill-shaped:

- keep `SKILL.md` compact
- keep `metadata.json` next to it
- declare the skill in `pack.json` with `"kind": "skill"` and a pack-scoped
  `skillId`
- do not duplicate the skill body into rules or README prose

## Manifest defaults

- targets: `project-cursor`, `user-cursor`
- profiles: usually `lite`, `strict`
- install conflict policy: `backup-and-overwrite`
- MCP policy: default to `none` or `example-only`
