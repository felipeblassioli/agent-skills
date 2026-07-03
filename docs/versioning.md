# Skill Versioning

Each skill is versioned independently. Keep the same version in:

- `plugins/<plugin>/skills/<skill>/SKILL.md` frontmatter
- `plugins/<plugin>/skills/<skill>/metadata.json`
- the latest `plugins/<plugin>/skills/<skill>/CHANGELOG.md` entry

## Version Bumps

Use semantic versioning for agent-visible behavior:

- Patch: wording clarifications, safer examples, typo fixes, or metadata-only
  corrections that do not change when or how the skill is used.
- Minor: new supported source contract, workflow input, safety check, template,
  or review path that expands the skill without breaking existing guidance.
- Major: activation boundary changes, removed guidance, changed default behavior,
  or safety policy changes that may invalidate previous agent behavior.

## Dates

Use ISO dates (`YYYY-MM-DD`) for:

- `last_reviewed` in `SKILL.md`
- `date` in `metadata.json`
- changelog entries
- `source_contracts[].reviewed_at`

Use the date when the source contract review was completed, not the date when an
agent first noticed possible drift.

## Changelog

Every release entry should include:

- what changed
- why it changed when useful
- source contracts reviewed, for skills that teach an upstream contract

Keep changelog entries concise. Detailed platform explanation belongs in
`references/` or the upstream docs.

The latest changelog entry is also the **release notes** for the published
GitHub Release (see `docs/releasing.md`). Write it so it reads cleanly when
rendered standalone on the GitHub Releases page.

## Tag Taxonomy

`agent-skills` is a monorepo of independently versioned skills, so a flat
`vX.Y.Z` tag would collide. Tag releases with the skill name as a prefix:

```text
<skill-name>/v<version>
```

For a plugin skill, `<skill-name>` is `<plugin>-<skill>` (collision-free across
plugins). Examples:

- `blassioli-gcp-log-triage/v1.2.0`
- `blassioli-error-trace-rootcause/v1.1.0`
- `repo-governance-skill-maintainer/v1.1.0`

One PR may bump multiple skills; that produces multiple tags and multiple
GitHub Releases on merge — one per changed skill.

## Release Rule

Every accepted version bump on `main` must be published as a GitHub Release
using the tag above. Releases are created automatically by
`.github/workflows/release-skill.yaml`; manual fallback uses
`scripts/release-skill.sh`. See `docs/releasing.md` for the full procedure.
