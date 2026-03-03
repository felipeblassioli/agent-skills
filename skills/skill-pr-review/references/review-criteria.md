# Review Criteria for Skill PRs

Canonical criteria used by `skill-pr-review` for severity, findings, and merge recommendation.

## Severity model

| Severity | Meaning | Merge impact |
|---|---|---|
| CRITICAL | Broken repository invariants or missing required files | Block merge |
| HIGH | Strong risk of broken discoverability, invalid versioning, or wrong invocation | Block merge |
| MEDIUM | Significant quality issue that should be fixed before merge when possible | Usually block unless justified |
| LOW | Improvement opportunity with low immediate risk | Do not block by default |

## Category criteria

### Structural

Check required files and format correctness:

- `SKILL.md` and `metadata.json` exist
- frontmatter is valid (`name`, `description`)
- `name` matches folder exactly
- `SKILL.md` length and link integrity are within standard

Default source: `skills/create-skill-from-refs/scripts/validate-skill.sh`.

### Registry

Check repo registry invariants:

- new or modified skills are represented in `skill-registry.json`
- removed skills are removed from `skill-registry.json`
- `metadata.json.version` equals registry `version`
- tags are present and useful

Default source: `scripts/check-registry-consistency.sh`.

### PRHygiene

Check pull request hygiene:

- branch naming convention
- commit-title conventional format
- focused scope by concern (skill content vs registry/scripts vs build)
- PR body includes motivation and validation evidence

### ContentQuality

Check skill authoring quality:

- applicability gate has clear triggers and anti-triggers
- routing table points directly to actionable references/scripts
- progressive disclosure is respected (`SKILL.md` is dispatcher, not dump)
- terminology is consistent across touched files

## Merge recommendation policy

- **Not safe to merge** if any `CRITICAL` or `HIGH` finding exists.
- **Conditionally safe** if only `MEDIUM` findings exist and user accepts trade-offs.
- **Safe to merge** if only `LOW` findings exist, or no findings.

## Suggested finding IDs

| Prefix | Category |
|---|---|
| `STR_` | Structural |
| `REG_` | Registry |
| `PRH_` | PR hygiene |
| `CNT_` | Content quality |

Examples:

- `STR_SKILL_MD_MISSING`
- `REG_VERSION_MISMATCH`
- `PRH_COMMIT_TITLE_INVALID`
- `CNT_NO_APPLICABILITY_GATE`

## See also

- [assets/pr-hygiene-checklist.md](../assets/pr-hygiene-checklist.md)
- [assets/review-report-template.md](../assets/review-report-template.md)
