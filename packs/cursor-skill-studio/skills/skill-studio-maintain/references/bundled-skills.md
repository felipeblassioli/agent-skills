# Bundled Skills

Pack-bundled skills live inside a pack and version with the pack, but they are
still skill-shaped artifacts. They share the skill package contract with root
skills under `skills/<name>/` but have different release authority and
registry treatment.

Merged from the two source references that previously lived in
`skills/personal-skill-maintainer/references/bundled-skills.md` and
`skills/personal-pack-maintainer/references/bundled-skills.md`.

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
2. The artifact MUST declare an explicit `skillId`.
3. `skillId` MUST be pack-scoped and slug-safe (`^[a-z0-9-]+$`) — for
   example `cursor-companion-pack-overview` or `skill-studio-write` — to
   prevent collisions in shared `~/.cursor/skills/` paths.
4. `SKILL.md` frontmatter `name` MUST equal `skillId`.
5. The bundled skill versions with the pack; bundled skill changes are
   recorded in the **pack's** `CHANGELOG.md`.
6. Bundled skills are NOT added to `skill-registry.json` unless they are
   explicitly promoted into a root skill (see "Promotion boundary" below).

## Promotion boundary

Promoting a bundled skill to a root skill is a separate maintenance decision.
When promoting:

1. Move or copy the skill into `skills/<name>/`.
2. Give it independent version authority in `metadata.json` and
   `skill-registry.json`.
3. Add a dedicated `CHANGELOG.md` and `README.md` if it becomes maintained
   as a root skill.
4. Ensure `metadata.json` matches the promoted release version.
5. Decide whether the pack should continue bundling it or stop shipping it.

## Common mistakes

- Missing `metadata.json` in the bundled skill directory.
- Using `kind: "runtime"` (or any other kind) for a bundled skill artifact
  instead of `kind: "skill"`.
- Reusing a generic `skillId` that can collide in shared `~/.cursor/skills/`.
- Adding the bundled skill directly to `skill-registry.json` without an
  explicit promotion step.
- Recording bundled skill changes in the root `CHANGELOG.md` instead of the
  pack's `CHANGELOG.md`.
