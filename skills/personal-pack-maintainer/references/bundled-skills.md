# Bundled Skills

Bundled skills live inside a pack and version with the pack, but they are still
skill-shaped artifacts.

## Location

```text
packs/<pack>/skills/<skillId>/
```

## Minimum shape

```text
packs/<pack>/skills/<skillId>/
├── SKILL.md
└── metadata.json
```

## Required rules

1. The pack manifest MUST declare the artifact with `kind: "skill"`.
2. The artifact MUST declare a `skillId`.
3. `skillId` MUST be pack-scoped and slug-safe: `^[a-z0-9-]+$`.
4. `SKILL.md` frontmatter `name` MUST equal `skillId`.
5. The bundled skill versions with the pack; it does not get its own entry in
   `skill-registry.json`.

## Promotion boundary

Promotion into a root skill is a separate maintenance decision. When promoting:

1. Move or copy the skill into `skills/<name>/`.
2. Give it independent version authority in `metadata.json` and
   `skill-registry.json`.
3. Add its own `CHANGELOG.md` and `README.md` if it becomes maintained as a root
   skill.
4. Decide whether the pack should keep bundling it or stop shipping it.

## Common mistakes

- Missing `metadata.json` in the bundled skill directory.
- Using `kind: "runtime"` for a bundled skill artifact.
- Reusing a generic `skillId` that can collide in shared `~/.cursor/skills/`.
- Adding the bundled skill directly to `skill-registry.json` without explicit
  promotion.
