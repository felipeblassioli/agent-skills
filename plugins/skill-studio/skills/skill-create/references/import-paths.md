# Import Paths

Choose the import path based on the inspected source shape. All paths land the
skill in a Claude plugin at `plugins/<plugin>/skills/<name>/` — a sandbox plugin
(e.g. `blassioli`) for unproven skills, an official plugin once earned.

## Path 1: Clean Skill Package

Use this when the candidate already looks like a normal Agent Skill: a folder
with a valid `SKILL.md`, matching `name` frontmatter, and clean supporting files.

Recommended path:

1. Copy the folder to `plugins/<plugin>/skills/<name>/`.
2. Confirm `name` frontmatter matches the folder name.
3. Confirm `SKILL.md` frontmatter is `name` + `description` only.
4. Add or reconcile `metadata.json` and `CHANGELOG.md`.

Use this path when:

- the folder already contains a valid `SKILL.md`
- the folder name and `name` frontmatter match
- only light review or metadata polishing is needed

## Path 2: Skill-Like Folder Needing Normalization

Use this when the candidate contains the core ingredients of a skill but is not
yet a clean package.

Recommended path:

1. Create `plugins/<plugin>/skills/<name>/`.
2. Copy only skill-relevant files.
3. Normalize the structure:
   - keep `SKILL.md` at the root; move governance fields out of frontmatter
     into `metadata.json` (`name` + `description` only stay in frontmatter)
   - move reference docs into `references/`
   - move templates/checklists into `assets/`
   - keep executable helpers in `scripts/`, referenced via
     `${CLAUDE_SKILL_DIR}/...`
   - rewrite cross-skill links as by-name handoffs (installed plugins are
     copied to a cache, so cross-package relative links break)
4. Add or fix `metadata.json` and `CHANGELOG.md`.
5. List the plugin in `.claude-plugin/marketplace.json` if it is new.

Use this path when:

- the source folder name does not match the skill name
- the source bundles extra project files that should not be imported
- the frontmatter carries governance fields that must move to `metadata.json`
- the skill needs cleanup before it belongs in a plugin

## Path 3: Stop And Rework

Do not import yet when the candidate is not a stable skill package.

Stop when:

- there is no valid frontmatter
- the scope is too broad to describe cleanly
- the candidate mostly contains notes rather than an operational skill
- the scripts are unsafe, misleading, or tightly coupled to an external repo

Recommended next step:

- rework the source in place, or
- recreate the useful parts via the **distill from reference material** branch
  of this skill.

## Metadata Normalization

If the imported candidate lacks `metadata.json`, create one:

```json
{
  "version": "0.1.0",
  "author": "felipeblassioli@gmail.com",
  "date": "2026-07-02",
  "abstract": "Short summary of what the skill does and when to use it.",
  "source_contracts": []
}
```

Add a `CHANGELOG.md` with a matching-version entry. Record any external contract
the skill teaches in `source_contracts` using canonical GitHub or docs URLs.

## Safety Notes

- Never import secrets, credentials, or environment-specific config.
- Review scripts before trusting them.
- Prefer manual normalization over force-copying a messy folder.
- Convert any live MCP config to an example with `${env:VAR}` placeholders.

## See Also

- `references/candidate-review.md` — the go/no-go rubric that precedes this.
- `assets/templates/skill-intake-report.md` — the report to present before import.
