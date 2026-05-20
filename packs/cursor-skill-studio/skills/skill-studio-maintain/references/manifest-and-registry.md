# Manifest and Registry Alignment

## `pack.json` required fields

```json
{
  "name": "<lowercase-slug>",
  "version": "MAJOR.MINOR.PATCH",
  "description": "...",
  "author": "...",
  "targets": ["project-cursor", "user-cursor"],
  "profiles": ["lite", "strict"],
  "artifacts": [ /* see targets-profiles-artifacts.md */ ],
  "install": {
    "defaultProfile": "strict",
    "conflictPolicy": "backup-and-overwrite",
    "backupOnConflict": true,
    "stageRoot": ".work/cursor-pack-staging",
    "backupRoot": ".work/cursor-pack-backups",
    "manifestFile": ".cursor-pack-manifest.json"
  }
}
```

The `install` block currently has fixed v0 values. Do not invent new values for `conflictPolicy`, `stageRoot`, `backupRoot`, or `manifestFile` until the installer implements them.

## Slug and version regex

| Field | Regex |
|-------|-------|
| `name`, artifact `id`, bundled `skillId` | `^[a-z0-9-]+$` |
| `version` | `^[0-9]+\.[0-9]+\.[0-9]+$` |

## Registry entry

`cursor-pack-registry.json` MUST contain exactly one entry per installable pack with:

- `version`
- `author`
- `path`           (e.g. `packs/<name>`)
- `targets`
- `profiles`
- `install`        (policy summary)
- `tags`
- `description`

## Version alignment invariant

`packs/<name>/pack.json.version` **MUST** equal `cursor-pack-registry.json.packs.<name>.version`.

Use the bump script — do not edit one side by hand:

```bash
bash scripts/cursor-pack-version.sh <name> patch|minor|major
```

## Common drift to check

- `pack.json` bumped, registry forgotten (or vice versa).
- `targets` / `profiles` arrays diverging between manifest and registry.
- New artifact added to `pack.json` but profile not declared in `profiles[]`.
- Slug rename in directory not reflected in `name` field or registry key.
- `install.defaultProfile` no longer present in `profiles[]`.

## Validation

```bash
bash scripts/cursor-pack-verify.sh --pack=<name>
```

Note: the verifier uses bespoke jq/bash checks today; treat it as the primary repository validation command for pack changes.
