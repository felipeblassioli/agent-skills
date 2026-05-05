# Cursor Pack Uninstall Follow-Up

## Status

Proposed

## Purpose

Define the follow-up work needed before Cursor Packs can support a safe
first-class uninstall command.

Cursor Packs v0 support install, backup-based restore, and upgrade by
reinstalling a newer version. They do not yet support safe uninstall because the
current install manifest records installed file paths but not enough ownership
or change-detection data to remove files without risking user work.

## Problem

A naive uninstall command would remove every file listed in
`.cursor-pack-manifest.json` for a pack. That is unsafe because installed files
can be edited after installation.

The uninstall command must distinguish:

- files still owned by the pack and unchanged since installation
- files installed by the pack but modified by a user
- files that no longer exist
- empty directories left behind after safe file removal

## Proposed Design

Add an uninstall command only after the install manifest records file hashes.

Command shape:

```bash
bash scripts/cursor-pack-uninstall.sh \
  --pack=<name> \
  --target=project|user \
  --project-root=<path> \
  --dry-run
```

User-level uninstall would omit `--project-root`.

## Manifest Changes

Extend each manifest pack entry from a list of file paths to file records:

```json
{
  "path": ".cursor/agents/example.md",
  "sha256": "<installed-file-hash>"
}
```

The installer should compute the hash after writing the destination file. Future
manifest versions may also record source artifact ids, but hashes are the
minimum requirement for safe uninstall.

## Uninstall Semantics

The uninstall command should:

1. Resolve the target root.
2. Load the target manifest.
3. Find the requested pack entry.
4. For each installed file:
   - skip missing files and report them
   - remove unchanged files whose current hash matches the manifest hash
   - refuse to remove changed files unless `--force` is passed
5. Remove only directories that are empty after file removal.
6. Remove the pack entry from the manifest after successful uninstall.

`--dry-run` must report planned removals, skipped missing files, and modified
files without changing the filesystem.

## Safety Requirements

- Default behavior must never delete modified files.
- `--force` must be explicit and should still show changed files before removal.
- The command must not remove directories recursively unless they are empty.
- The command must not infer ownership from file paths alone.
- The command must fail if the manifest is missing, invalid, or does not contain
  the requested pack.

## Verification Requirements

Before shipping uninstall:

- Install a pack into a scratch project and uninstall it unchanged.
- Install a pack, modify one installed file, and verify uninstall refuses to
  remove the changed file.
- Run the same modified-file case with `--force`.
- Verify user-target and project-target uninstall behavior separately.
- Verify empty directories are removed only when empty.

## Relationship To Restore

Restore and uninstall solve different problems.

Restore uses install-time backups to return the target to its previous state.
Uninstall removes the currently installed pack files when the user no longer
wants the pack.

Restore should remain available even after uninstall exists.
