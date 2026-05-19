# Lifecycle Scripts

All commands run from the repo root. Pass `--pack=<name>` explicitly.

## Verify

```bash
bash scripts/cursor-pack-verify.sh --pack=<name>
```

Run before any commit that touches `pack.json`, `cursor-pack-registry.json`, or pack release artifacts. Today this performs bespoke jq/bash checks (not full JSON Schema). Treat schema validation as a separate manual step when needed.

## Install (project)

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=<name> \
  --target=project \
  --project-root="$PWD" \
  --profile=strict
```

Add `--dry-run` first to preview file operations without writing.

## Install (user)

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=<name> \
  --target=user \
  --profile=lite
```

The installer:

1. Resolves the pack from `cursor-pack-registry.json`.
2. Loads `pack.json`.
3. Selects target + profile (defaults to `install.defaultProfile`).
4. Stages selected artifacts under `.work/cursor-pack-staging/`.
5. Applies `conflictPolicy: "backup-and-overwrite"` and writes backups under `.work/cursor-pack-backups/<pack>/<target>/<timestamp>/`.
6. Writes an install manifest at `.cursor-pack-manifest.json`.

## Restore

```bash
bash scripts/cursor-pack-restore.sh \
  --backup-dir .work/cursor-pack-backups/<pack>/<target>/<timestamp>
```

There is **no** first-class uninstall command in v0. Removal options:

- restore from the relevant backup,
- manually remove files listed in the install manifest,
- reinstall a previous pack version from a released archive or checked-out tag.

## Version bump

```bash
bash scripts/cursor-pack-version.sh <name> patch|minor|major
```

This script keeps `pack.json` and `cursor-pack-registry.json` in lockstep. After running it, also update:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `ROADMAP.md`

## Verification ritual before release

1. `bash scripts/cursor-pack-verify.sh --pack=<name>`
2. `bash scripts/cursor-pack-sync.sh --pack=<name> --target=project --project-root="$PWD" --profile=<profile> --dry-run`
3. `bash scripts/cursor-pack-sync.sh --pack=<name> --target=user --profile=<profile> --dry-run`
4. Record evidence in `VERIFICATION.md` (commands run, output highlights, what the dry-runs proved).
