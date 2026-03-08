## What

<!-- Brief description of what changed and why. -->

## Skills affected

<!-- List each skill touched, with version changes if applicable. -->
<!-- Delete this section if the PR doesn't touch any skill. -->

| Skill | Change | Version |
|-------|--------|---------|
| `skill-name` | added / updated / removed | X.Y.Z → A.B.C |

## Packs affected

<!-- List each pack touched, with version changes if applicable. -->
<!-- Delete this section if the PR doesn't touch any pack. -->

| Pack | Change | Version |
|------|--------|---------|
| `pack-name` | added / updated / removed | X.Y.Z → A.B.C |

## Release units

<!-- Use this section for release PRs or tag-preparation PRs. -->
<!-- Delete this section if the PR is not preparing a release. -->

- Release kind: skill / pack / mixed
- Planned tag(s): `skill-name@X.Y.Z`, `pack-name@A.B.C`
- Scope is release-only: yes / no

## Motivation

<!-- Why does this change exist? Link issues, ADRs, or prior discussion. -->

## Quality checklist

- [ ] `skill-registry.json` updated (if skills added/removed/versioned)
- [ ] `metadata.json` version matches registry
- [ ] SKILL.md frontmatter has valid `name` (matches folder) and `description` (WHAT + WHEN)
- [ ] SKILL.md is under 500 lines
- [ ] No empty directories in skill tree
- [ ] No secrets or credentials in skill content
- [ ] `bash scripts/skill-sync.sh --list` shows correct state (if applicable)
- [ ] `cursor-pack-registry.json` updated (if packs added/removed/versioned)
- [ ] `pack.json` version matches the pack registry
- [ ] pack release docs updated when releasing a maintained pack: `CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, `ROADMAP.md`
- [ ] release PRs are focused on version bumps, release docs, and validation evidence only

## Validation

<!-- Commands run and their output. Example: -->
<!-- - `bash scripts/skill-sync.sh --dry-run` → OK -->
<!-- - `bash skills/create-skill-from-refs/scripts/validate-skill.sh skills/<name>` → all checks pass -->
<!-- - `bash scripts/cursor-pack-verify.sh --pack=<name>` → OK -->
<!-- - `bash scripts/cursor-pack-sync.sh --pack=<name> --target=project --project-root="$PWD" --profile=strict --dry-run` → OK -->

## Additional context

<!-- Anything else: accepted risks, follow-ups, stacking notes. Delete if empty. -->
