# Targets, Profiles, Artifacts

## Targets

| Manifest/registry name | CLI flag | Destination |
|------------------------|----------|-------------|
| `project-cursor`       | `--target=project` | `<project>/.cursor/` |
| `user-cursor`          | `--target=user`    | `~/.cursor/` |

Project installs are appropriate for repository-specific rules, hooks, and subagents.
User installs are appropriate for reusable skills, subagents, hooks, and MCP examples shared across projects.

**Invariant:** project-only artifacts (e.g. project rules encoding repo policy) MUST NOT be installed via `user-cursor` paths.

## Profiles

A pack MUST declare at least one profile. Repository convention:

- `lite`   — minimal install, lower policy surface
- `strict` — fuller install, may include project rules or hooks

Rules:

- `install.defaultProfile` MUST be one of the declared `profiles[]`.
- Every artifact's `profiles` array MUST reference declared profile names only.
- Profiles SHOULD describe real operating modes, not vague maturity levels.

## Runtime artifacts

```json
{
  "id": "subagents",
  "kind": "runtime",
  "source": ".cursor/agents",
  "targets": ["project-cursor", "user-cursor"],
  "profiles": ["lite", "strict"],
  "projectPath": ".cursor/agents",
  "userPath": ".cursor/agents",
  "notes": "..."
}
```

Required: `id`, `source`, `targets`, `profiles`.
Conditionally required:

- `projectPath` — required when `targets` includes `project-cursor`.
- `userPath`    — required when `targets` includes `user-cursor`.

Group runtime artifacts by responsibility (subagents, rules, hooks, MCP examples), not as one big mixed directory.

## Bundled-skill artifacts (`kind: "skill"`)

```json
{
  "id": "<artifact-id>",
  "kind": "skill",
  "source": "skills/<skill-folder>",
  "targets": ["project-cursor", "user-cursor"],
  "profiles": ["strict"],
  "skillId": "<pack-scoped-skill-id>"
}
```

Rules (full set in `references/bundled-skills.md`):

- `kind: "skill"` REQUIRED.
- `skillId` REQUIRED, pack-scoped (e.g. `cursor-companion-pack-overview`) to avoid collisions in shared `~/.cursor/skills/`.
- Source dir MUST contain `SKILL.md` and `metadata.json`.
- `SKILL.md` frontmatter `name` MUST equal `skillId`.
- Bundled skills are NOT entries in `skill-registry.json` unless explicitly promoted.
- Destinations are derived from `skillId` (project install → `<project>/.cursor/skills/<skillId>/`; user install → `~/.cursor/skills/<skillId>/`).

## Common artifact mistakes to flag

- Runtime artifact missing `projectPath` despite targeting `project-cursor`.
- Bundled skill omitted `kind: "skill"` (treated as runtime, paths break).
- `skillId` collides with a root skill name in `skill-registry.json`.
- Artifact references a profile not declared in `profiles[]`.
- Project rule artifact set to install on `user-cursor`.
