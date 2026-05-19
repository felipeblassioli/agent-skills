# Import Paths

Choose the import path based on the inspected source shape.

## Path 1: Canonical Project Skill

Use this when the candidate resolves to `.cursor/skills/<name>/` in another
project and already looks like a normal Cursor skill.

Recommended path:

```bash
bash scripts/skill-import.sh <project-root> <skill-name> --tags=tag1,tag2
```

Use this path when:

- the source is a project root or a direct `.cursor/skills/<name>` candidate
- the folder already contains a valid `SKILL.md`
- the folder name and `name` frontmatter match
- only light review or metadata polishing is needed

## Path 2: Arbitrary Skill-Like Folder

Use this when the candidate is not already in the canonical
`.cursor/skills/<name>/` location, but still contains the core ingredients of a
skill.

Recommended path:

1. Create `skills/<name>/`
2. Copy only skill-relevant files
3. Normalize the structure:
   - keep `SKILL.md` at the root
   - move reference docs into `references/`
   - move templates/checklists into `assets/`
   - keep executable helpers in `scripts/`
4. Add or fix `metadata.json`
5. Add the `skill-registry.json` entry

Use this path when:

- the candidate lives in a random folder
- the source folder name does not match the skill name
- the source bundles extra project files that should not be imported
- the skill needs cleanup before it belongs in the registry

## Path 3: Stop And Rework

Do not import yet when the candidate is not a stable skill package.

Stop when:

- there is no valid frontmatter
- the scope is too broad to describe cleanly
- the candidate mostly contains notes rather than an operational skill
- the scripts are unsafe, misleading, or tightly coupled to an external repo

Recommended next step:

- rework the source in place, or
- recreate the useful parts with `create-skill-from-refs`

## Metadata Normalization

If the imported candidate lacks `metadata.json`, create one with:

```json
{
  "version": "1.0.0",
  "author": "felipeblassioli",
  "date": "March 2026",
  "abstract": "Short summary of what the skill does and when to use it."
}
```

Then add the matching registry entry with:

- `version`
- `author`
- `scope`
- `targets`
- `tags`
- `description`

## Safety Notes

- Never import secrets, credentials, or environment-specific config.
- Review scripts before trusting them.
- Prefer manual normalization over force-copying a messy folder into `skills/`.
