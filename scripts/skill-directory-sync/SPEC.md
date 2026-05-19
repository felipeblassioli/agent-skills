# Skill Directory Sync Specification

## Status

Draft.

## Purpose

Define a small, safe tool for comparing and synchronizing agent skill discovery
directories, such as `~/.cursor/skills` and `~/.claude/skills`.

The tool exists to make it easy to add user skills from one agent environment to
another while preserving a clear audit trail and avoiding accidental deletion or
silent overwrite.

This specification is implementation-neutral. The first implementation may be a
Bash script, but this document should be complete enough for an AI or engineer to
rebuild the tool in TypeScript, Go, or another language without relying on the
original script internals.

## Goals

- Compare two skill directories at the skill-directory level.
- Support both raw filesystem paths and named skill targets.
- Copy missing or changed skills from a selected source to a selected destination.
- Create per-skill directory symlinks from destination to source when requested.
- Back up destination entries before overwrite.
- Treat `SKILL.md` as the strict marker for a valid skill.
- Keep write operations explicit, predictable, and one-way.
- Provide enough structured behavior for future restore, JSON output, and richer
  reconciliation features.

## Non-Goals

- Modify `skill-registry.json`.
- Deploy only repository-managed skills.
- Delete destination-only skills.
- Perform true bidirectional apply in one command.
- Perform full line-by-line content diffs.
- Resolve semantic differences between skill versions.
- Install Cursor packs or runtime assets outside skill directories.
- Automatically restore from backups in v0.
- Support interactive conflict resolution in v0.

## Terminology

**Skill root** means a directory that contains skill directories as immediate
children, for example `~/.cursor/skills`.

**Skill entry** means an immediate child of a skill root.

**Valid skill** means a skill entry that is a directory, or a symlink resolving to
a directory, containing `SKILL.md` at its root.

**Named target** means a short name that resolves to a known skill root.

**Source** means the skill root passed via `--from`.

**Destination** means the skill root passed via `--to`.

**Apply** means a one-way write operation from source to destination.

## Named Targets

The tool MUST support these named targets:

| Name | Path |
| --- | --- |
| `cursor` | `~/.cursor/skills` |
| `claude` | `~/.claude/skills` |
| `agents` | `~/.agents/skills` |

The tool MAY support additional named targets later, such as `gemini`, when the
repository establishes a stable discovery path.

Target resolution rules:

- If an input matches a named target, resolve it to the target path.
- Named target resolution has precedence over raw relative paths. Users who need
  a local directory with the same name MUST pass `./cursor`, `./claude`,
  `./agents`, or an absolute path.
- Otherwise, treat the input as a raw filesystem path.
- Expand a leading `~` to the current user's home directory.
- Normalize paths before comparing source and destination identity.
- Refuse to run an apply operation when source and destination resolve to the
  same directory.
- For apply safety, source and destination identity MUST be compared using
  canonical physical identity where possible. The implementation SHOULD resolve
  root symlinks and compare device/inode or the platform equivalent. If either
  existing root cannot be canonicalized, the tool MUST fail safely or compare the
  canonical existing parent plus final path component.
- Apply MUST reject source and destination roots when either root contains the
  other after canonicalization. This prevents mutating the source through a nested
  destination and prevents recursive self-copy or self-link behavior.

Root existence rules:

- If the source root does not exist or is not a directory, `diff` and `apply`
  MUST exit nonzero.
- If the destination root does not exist, `diff` MUST treat it as an empty skill
  root without creating it.
- If the destination root does not exist, `apply --yes` MUST create it before
  planned writes.

## Command Line Interface

The v0 CLI SHOULD have this shape:

```bash
bash scripts/skill-directory-sync.sh diff --from=cursor --to=claude
bash scripts/skill-directory-sync.sh diff --from="$HOME/.cursor/skills" --to="$HOME/.claude/skills"

bash scripts/skill-directory-sync.sh apply \
  --from=cursor \
  --to=claude \
  --mode=copy \
  --backup \
  --overwrite \
  --yes

bash scripts/skill-directory-sync.sh apply \
  --from=claude \
  --to=cursor \
  --mode=symlink \
  --backup \
  --overwrite \
  --yes

bash scripts/skill-directory-sync.sh list-targets
```

### Subcommands

`diff` compares source and destination and never writes.

`apply` performs one-way synchronization from source to destination.

`list-targets` prints known target names and resolved paths.

`help` prints usage.

### Flags

Required for `diff` and `apply`:

- `--from=<target-or-path>`
- `--to=<target-or-path>`

Apply flags:

- `--mode=copy|symlink`: default is `copy`.
- `--backup`: required when `--overwrite` would replace an existing destination
  entry.
- `--overwrite`: allows replacing changed or conflicting destination entries.
- `--yes`: required for write operations.
- `--skill=<name>`: restricts operation to one skill. This flag MAY be repeated.

`--skill` values MUST be skill entry names, not paths. Values containing `/`,
NUL, or platform path separators MUST be rejected with usage error. Matching MUST
use exact string equality against immediate child entry names after discovery. No
globbing, case folding, or path normalization is applied to skill names.

Read-only flags:

- `--verbose`: MAY show additional detail in later versions. In v0, this can be
  accepted but does not need to print file-level diffs.

Future flags:

- `--pretty`
- `--json`
- `--include=<glob>`
- `--exclude=<glob>`
- `--restore=<backup-dir>`

## Skill Discovery Contract

The tool MUST inspect only immediate children of the skill root.

An entry is a valid skill when:

- the entry is a directory containing `SKILL.md`; or
- the entry is a symlink that resolves to a directory containing `SKILL.md`.

The tool MUST NOT recursively discover nested skills inside child directories.

The tool SHOULD report, but not operate on, these invalid entries:

- regular files;
- directories without `SKILL.md`;
- broken symlinks;
- symlinks resolving to non-directories.

The tool MUST NOT require `metadata.json` for v0 discovery.

## Diff State Model

The default report is skill-level only. It compares the set of valid source and
destination skills by skill folder name.

Each comparable skill row MUST have exactly one primary state and zero or more
annotations.

The tool MUST support these primary states:

| State | Meaning |
| --- | --- |
| `missing-in-destination` | Valid skill exists in source but not destination. |
| `destination-only` | Valid skill exists in destination but not source. |
| `identical` | Valid skill exists in both and content checksums match. |
| `changed` | Valid skill exists in both and content checksums differ. |
| `destination-conflict-for-source` | Valid selected source skill has a same-named destination entry that is not an operable skill directory. |
| `invalid-source-entry` | Source immediate child is not a valid skill. |
| `invalid-destination-entry` | Destination immediate child is not a valid skill. |
| `broken-source-symlink` | Source immediate child is a broken symlink. |
| `broken-destination-symlink` | Destination immediate child is a broken symlink. |

The tool MUST support these annotations:

| Annotation | Meaning |
| --- | --- |
| `source-symlink` | Source skill entry is a symlink. |
| `destination-symlink` | Destination skill entry is a symlink. |

Primary state counts MUST count only primary states. Annotation counts MAY be
printed separately. For example, a skill can have primary state `changed` and
annotation `destination-symlink`.

## Content Comparison

Directory equality MUST be content-based, not metadata-based.

The v0 implementation SHOULD compute a deterministic digest from:

- normalized relative file paths;
- file contents.

Digest input rules:

- Sort entries by bytewise normalized relative path.
- Use `/` as the path separator in digest input, regardless of platform.
- Hash file contents as raw bytes without newline normalization.
- Ignore empty directories for v0 digest purposes.
- Include hidden files unless ignored by the default ignored paths or a future
  ignore policy.

The digest MUST ignore file modification time, owner, group, and permission bits
unless a future version explicitly adds permission-sensitive comparison.

Default ignored paths:

- `.git/`
- `.DS_Store`

The tool MUST NOT ignore `README.md` by default. Unlike repository skill deploy,
this tool mirrors user skill directories and should preserve user-facing files.

When a skill entry is a symlink resolving to a directory, content comparison MAY
hash the resolved directory contents, but the report MUST preserve that the entry
is a symlink.

## Nested Symlink Policy

Nested symlinks are symlinks inside a valid skill directory.

For v0, nested symlinks MUST be treated as symlink entries, not followed, for
digest, copy, and backup operations.

Digest input for a nested symlink MUST include:

- the normalized relative path;
- a marker that the entry is a symlink;
- the symlink target string as stored in the filesystem.

Copy mode MUST recreate nested symlinks as symlinks when supported by the
platform. It MUST NOT copy the resolved target contents of nested symlinks.

Broken nested symlinks MUST be reported as invalid content. In apply mode, a
selected source skill containing a broken nested symlink MUST cause the command to
exit nonzero before writes unless a future flag explicitly permits preserving
broken nested symlinks.

## Apply State Machine

Apply is always one-way: source to destination.

Apply operates only on valid source skills. If any `--skill` selection does not
match exactly one valid source skill, `apply` MUST exit nonzero before writes and
report the unmatched or invalid skill name.

For each selected source skill:

1. If the destination skill is missing, create it using the selected mode.
2. If the destination skill is identical, do nothing.
3. If the destination skill is changed, overwrite only when `--overwrite` and
   `--backup` are both present.
4. If the destination path exists but is not an operable skill directory, treat it
   as `destination-conflict-for-source` and overwrite only when `--overwrite` and
   `--backup` are both present.
5. If the destination entry is a broken symlink, treat it as
   `destination-conflict-for-source` and overwrite only when `--overwrite` and
   `--backup` are both present.
6. Never remove destination-only skills.

The tool MUST refuse to perform writes unless `--yes` is present.

The tool MUST create the destination skill root if it does not exist and the user
has requested `apply --yes`.

`--backup` alone does not permit replacement and MUST NOT create backups unless
an overwrite actually occurs.

Changed or conflicting entries without `--overwrite` MUST be reported as skipped
and MUST cause `apply` to exit nonzero with a safety-refusal exit code after all
selected skills have been evaluated.

If any selected skill fails to copy, link, or back up, the tool MUST exit nonzero
and report the failed skill name. V0 does not need transactional rollback, but it
MUST avoid deleting backups after partial failure.

After a destination entry is successfully backed up, the tool MUST ensure restore
metadata for that backup is persisted before deleting or replacing the destination
entry. On partial failure, metadata MUST include all successfully created backups,
and command output MUST identify skills whose backup succeeded but apply failed.

## Copy Mode

In `--mode=copy`, the destination skill entry becomes a normal directory with the
same contents as the source skill.

Copy rules:

- Copy regular files and directories recursively.
- Preserve file contents.
- Preserve executable bits when supported by the implementation.
- Exclude `.git/` and `.DS_Store` unless a future flag changes ignore policy.
- If the source skill entry is a symlink, copy the resolved directory contents,
  not the symlink itself.
- Copy overwrite MUST replace the destination skill entry at the directory-entry
  level where possible.
- Copy overwrite MUST NOT merge into an existing destination directory.
- Files present only in the old destination skill MUST NOT remain after
  overwrite.

## Symlink Mode

In `--mode=symlink`, the destination skill entry becomes a directory symlink to
the source skill entry.

Symlink rules:

- Symlink at the skill directory boundary only.
- Do not create file-level symlink mirrors.
- Prefer absolute symlink targets for predictable behavior across working
  directories.
- If the source skill entry is itself a symlink, the implementation SHOULD link to
  the resolved real path unless a future flag requests preserving the symlink
  chain.
- If the destination already exists, replace it only with explicit overwrite and
  backup.
- When replacing a destination symlink, remove only the symlink entry, never the
  resolved target. The implementation MUST use filesystem behavior equivalent to
  `unlink` on the destination entry, not recursive deletion after symlink
  resolution.

## Backup Contract

Backups MUST be created before replacing any existing destination entry.

Default backup root:

```text
.work/skill-directory-sync-backups/<timestamp>/<destination-label>/
```

Relative backup roots MUST be resolved against the current working directory
unless a future `--backup-root` flag is introduced. The resolved absolute backup
root MUST be printed before writes and recorded in `backup-metadata.json`.

The backup root MUST be created atomically and MUST NOT reuse an existing
directory. If the timestamp path already exists, the tool MUST add a unique suffix
or fail before writes.

The resolved backup root MUST be outside the canonical source root and outside
the canonical destination root. If a future configuration permits backup roots
inside either tree, the tool MUST still reject any backup root that is inside an
entry being backed up or replaced. V0 SHOULD fail safely instead of attempting
in-tree backups.

Each overwritten skill SHOULD be backed up to:

```text
.work/skill-directory-sync-backups/<timestamp>/<destination-label>/<skill-name>/
```

For raw destination paths, the destination label MUST be sanitized so it is safe
as a directory name.

The backup MUST preserve enough information for manual restore:

- regular destination directories copied recursively;
- destination symlinks backed up as symlinks, not by following the target;
- conflicting files copied as files.

The backup root MUST include a metadata file named `backup-metadata.json`.

The metadata file MUST include these top-level fields:

- `createdAt`: UTC timestamp.
- `source`: absolute resolved source root.
- `destination`: absolute resolved destination root.
- `mode`: `copy` or `symlink`.
- `operation`: currently `overwrite` when any overwrite occurred.
- `backupRoot`: absolute resolved backup root.
- `skills`: array of successfully backed-up skills only.

Each `skills[]` entry MUST include:

- `name`: skill name.
- `destinationPath`: absolute destination entry path.
- `backupPath`: absolute backup entry path.
- `existedBefore`: boolean.
- `wasSymlink`: boolean.

Skipped and failed skills MUST be reported in command output, but MUST NOT appear
as successfully backed-up skills in `skills[]`.

Example metadata:

```json
{
  "createdAt": "2026-05-07T00:00:00Z",
  "source": "/Users/example/.cursor/skills",
  "destination": "/Users/example/.claude/skills",
  "mode": "copy",
  "operation": "overwrite",
  "backupRoot": "/Users/example/repo/.work/skill-directory-sync-backups/20260507-000000/claude",
  "skills": [
    {
      "name": "example-skill",
      "destinationPath": "/Users/example/.claude/skills/example-skill",
      "backupPath": "/Users/example/repo/.work/skill-directory-sync-backups/20260507-000000/claude/example-skill",
      "existedBefore": true,
      "wasSymlink": false
    }
  ]
}
```

## Output Contract

The default output SHOULD be a human-readable table or grouped list.

It MUST include:

- resolved source path;
- resolved destination path;
- selected mode for apply;
- counts by state;
- per-skill state rows;
- backup directory for apply operations that create backups.

Example diff output:

```text
Source: cursor (/Users/example/.cursor/skills)
Destination: claude (/Users/example/.claude/skills)

STATE                    SKILL
missing-in-destination   tdd-classicist
changed                  gh-pr-creator
destination-only         local-claude-helper
identical                typescript-quality
```

Machine-readable JSON output is out of scope for v0, but the implementation
SHOULD keep internal state structured enough to add it later.

A future `--pretty` mode MAY provide a more readable human report for large
cleanup workflows. It MUST preserve the default output unless the spec is updated
to define a breaking CLI change. It MUST remain separate from any future `--json`
machine-readable contract.

## Exit Codes

The tool MUST define stable exit behavior:

| Code | Meaning |
| --- | --- |
| `0` | Command completed successfully. `diff` exits `0` even when differences are found. |
| `2` | Usage error, invalid flag, unsupported mode, or unknown subcommand. |
| `3` | Safety refusal, such as missing `--yes`, missing backup for overwrite, same source and destination, or selected invalid source skill. |
| `4` | Read, write, copy, symlink, backup, or filesystem failure. |

Invalid entries discovered during `diff` SHOULD be reported but SHOULD NOT make
`diff` exit nonzero unless the source root itself cannot be read.

## Filtering

V0 MUST support `--skill=<name>` for selecting one skill. The flag MAY be
repeated.

V0 SHOULD defer glob filtering unless implementation complexity remains low.

Future filtering MAY add:

- `--include=<glob>`;
- `--exclude=<glob>`;
- tag-based filtering if registry integration is added.

## Safety Rules

The tool MUST:

- refuse write operations without `--yes`;
- refuse apply when source and destination resolve to the same directory;
- avoid deleting destination-only skills;
- back up before overwriting;
- treat broken destination symlinks as conflicts;
- avoid following destination symlinks when backing up overwritten entries;
- remove only the destination symlink entry when replacing a symlink;
- quote paths safely and support spaces in paths;
- exit nonzero on failed writes.

The tool SHOULD:

- print planned writes before performing them;
- make `diff` the recommended first step;
- keep symlink behavior explicit in reports;
- avoid changing registry files or source skill directories.

## Edge Cases

The implementation and tests SHOULD cover:

- source root missing;
- destination root missing;
- source and destination are the same path;
- paths with spaces;
- source skill missing `SKILL.md`;
- destination directory missing `SKILL.md` with same name as a source skill;
- source skill is a symlink;
- destination skill is a symlink;
- broken symlink in source;
- broken symlink in destination;
- destination path is a regular file;
- changed destination skill requiring backup and overwrite;
- copy mode from symlinked source;
- symlink mode from normal source;
- repeated `--skill` filters;
- permission-denied reads or writes;
- partial write failure after at least one successful operation;
- nested symlink inside a skill directory;
- destination symlink target is not modified during overwrite;
- copy overwrite removes files that existed only in the old destination skill;
- missing destination root during `diff` performs no writes.

## Test Harness Expectations

The v0 Bash implementation SHOULD include a shell-based fixture test script or a
documented manual harness that creates temporary source and destination roots.

Test fixtures SHOULD create minimal skills with this shape:

```text
skill-name/
  SKILL.md
  metadata.json
```

`metadata.json` MAY be present in tests, but discovery MUST depend only on
`SKILL.md`.

The test harness SHOULD verify:

- diff state classification;
- no writes during `diff`;
- missing skill copy;
- missing skill symlink;
- changed skill overwrite with backup;
- refusal to overwrite without backup;
- refusal to apply without `--yes`;
- refusal for same source and destination;
- backup metadata creation;
- backup preserves destination symlink entries as symlinks;
- destination symlink replacement does not modify the symlink target;
- nested symlink digest and copy behavior follows the nested symlink policy;
- copy overwrite does not merge stale destination-only files;
- missing destination root during `diff` creates no directory.

## Bash V0 Recommendation

The initial implementation SHOULD be Bash because this repository already uses
Bash for skill and pack operations.

The Bash implementation should remain conservative:

- skill-level diff only;
- one-way apply only;
- strict `SKILL.md` discovery;
- directory-level symlinks only;
- backup mandatory for overwrite;
- no deletion;
- no registry mutation;
- no restore command.

## Rewrite Threshold

Rewrite the tool in TypeScript or Go if two or more of these requirements become
important:

- stable JSON output as a public API;
- persistent manifests with reconciliation history;
- true bidirectional apply;
- interactive conflict resolution;
- file-level or semantic diff;
- complex include/exclude policy;
- Windows support;
- automated restore and uninstall workflows;
- extensive unit tests for path, symlink, and permission behavior.

TypeScript is the recommended rewrite target when the priority is fast iteration,
JSON/reporting ergonomics, and agent readability.

Go is the recommended rewrite target when the priority is portable binary
distribution and strong filesystem behavior across platforms.

## Backlog

Concrete implementation slices are tracked in GitHub issues and linked here when
they affect the tool's durable behavior contract.

- [#80](https://github.com/felipeblassioli/agent-skills/issues/80):
  add `--pretty` human output mode. Before implementation, define the output
  semantics in this spec and add fixture tests for default output preservation
  and pretty output rendering.

## Open Questions For Future Versions

- Should restore become a first-class subcommand?
- Should JSON output be considered a stable contract?
- Should the tool support registry names from `skill-registry.json` in addition
  to fixed target names?
- Should glob filters be added before or after JSON output?
- Should symlink mode preserve source symlink chains or always resolve them?
- Should line-level diff be delegated to an external command or implemented by
  the tool?
