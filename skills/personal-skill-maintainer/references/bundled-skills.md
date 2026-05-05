# Pack-Bundled Skill Model

Pack-bundled skills live inside a pack and keep the same skill package semantics, but their release authority and discovery rules are different.

## Location
`packs/<pack>/skills/<skillId>/`

## Minimum Shape
```text
packs/<pack>/skills/<skillId>/
├── SKILL.md
└── metadata.json
```

## Rules for Pack-Bundled Skills
1. `pack.json` MUST declare them with `kind: "skill"` and an explicit `skillId`.
2. `skillId` MUST be pack-scoped (e.g., `cursor-companion-pack-overview`) to prevent collisions in shared `~/.cursor/skills` paths.
3. `SKILL.md` frontmatter `name` MUST match `skillId`.
4. Bundled skill changes are recorded in the **pack's** changelog.
5. They are NOT added to `skill-registry.json` unless explicitly promoted.

## Promotion to Root Skill
Promoting a bundled skill to a root skill requires an explicit maintenance decision:
- Copy/move the skill to `skills/<name>/`.
- Assign independent version authority in `skill-registry.json`.
- Add/update `CHANGELOG.md`.
- Ensure `metadata.json` matches the promoted release version.
- Decide if the pack should continue bundling it or depend on separate sync.
