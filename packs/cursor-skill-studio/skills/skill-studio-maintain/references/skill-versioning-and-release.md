# Versioning, Releases, and Authority

## Version Authority

**Root Skill Authority:**
- `skill-registry.json`
- `skills/<name>/metadata.json`
- Latest `skills/<name>/CHANGELOG.md` entry.
- Optional: `SKILL.md` frontmatter `version` ONLY if the skill already uses it.

**Pack Authority:**
- `cursor-pack-registry.json`
- `packs/<pack>/pack.json`
- Pack release docs.

**Pack-Bundled Skill Authority:**
- The containing pack version by default.
- Bundled skill `metadata.json` for local provenance.
- Independent SemVer ONLY after promotion to `skills/<name>/`.

## Semantic Versioning (Behavior-Based)
- **Patch**: Wording clarifications, typo fixes, metadata-only corrections, safer examples, or documentation improvements that do not change when or how an agent uses the skill.
- **Minor**: New supported workflow, source contract, review path, safety check, template, reference, or script that expands the skill without breaking prior behavior.
- **Major**: Activation boundary changes, removed guidance, changed default behavior, changed confirmation policy, or safety policy changes that may invalidate previous agent behavior.

## Releases (ADR-0001)
Releases are registry-driven.
- One module-scoped Git tag (`skill-<name>@<version>` or `pack-<name>@<version>`).
- One GitHub Release tied to that tag.
- Version source of truth remains the registry files, not the GitHub release itself.

### Executing a Release

When asked to "release a skill", perform these exact steps:

1. **Bump the version:**
   ```bash
   bash scripts/skill-version.sh <skill-name> patch|minor|major
   ```
2. **Update the Changelog:** Add the new version entry in `skills/<skill-name>/CHANGELOG.md`.
3. **Commit the changes:**
   ```bash
   git add skills/<skill-name> skill-registry.json
   git commit -m "chore(<skill-name>): bump to <new-version>"
   ```
4. **Tag the release:**
   ```bash
   git tag skill-<skill-name>@<new-version>
   ```
5. **Sync locally (optional but recommended):**
   ```bash
   bash scripts/skill-sync.sh --skill=<skill-name>
   ```
