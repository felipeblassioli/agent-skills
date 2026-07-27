# Claude Skill Porter Specification

## Status and purpose

Maintained, versioned contract for `claude-skill-porter`, a non-interactive Go
tool that safely inspects ZIP archives, imports Agent Skills into one canonical
directory, and links those skills into Cursor and Claude project discovery.

## Commands

- `scan ARCHIVE [--json]` safely extracts to a temporary directory, classifies
  the package, and reports every directory containing `SKILL.md`.
- `import ARCHIVE --canonical DIR [--update] [--dry-run] [--json]` performs the
  same scan, then copies every detected skill into the canonical directory.
- `link --canonical DIR --project-root DIR --skill SLUG [--dry-run] [--json]`
  creates or updates links below both `.cursor/skills` and `.claude/skills`.
- `doctor --canonical DIR --project-root DIR [--json]` diagnoses the canonical
  root and both project link directories. It is read-only and exits nonzero when
  issues are found.

Applicable mutating commands MUST implement `--dry-run`. All commands MUST
implement `--json`; JSON reports contain `command`, `dryRun`, `actions`,
`warnings`, and `errors` with arrays present even when empty.

## Archive safety

Only ZIP is supported. Extraction MUST reject empty or absolute names, `..`
traversal, paths whose cleaned destination escapes the extraction root,
symlinks, and non-regular special entries. Existing extracted paths MUST NOT be
overwritten. Imported content is data: the tool MUST never execute archive
content, hooks, scripts, extension code, or installers.

## Layout detection and classification

After extraction, exactly one common top-level directory is logically removed;
its contents are not rewritten. The complete remaining tree is searched without
following symlinks, and every directory containing an exact `SKILL.md` filename
is a skill root.

Classifications are:

| Value | Contract |
| --- | --- |
| `direct-skill` | The logical package root itself contains `SKILL.md`. |
| `scaffolded-skill` | One or more skill roots occur below the package root. |
| `instruction-only` | No skill root; root contains `CLAUDE.md`, `AGENTS.md`, or `.cursorrules`. |
| `incompatible-extension` | VSIX manifest or a VS Code-engine `package.json` identifies an extension. |
| `unknown` | None of the supported signals occur. |

Extension detection takes precedence. Incompatible and rootless packages MUST
NOT be imported.

## Normalization and installation

The source directory's basename is normalized to lowercase kebab case. Runs of
non-alphanumeric characters become one hyphen, camel-case boundaries gain a
hyphen, and leading/trailing hyphens are removed. An empty result is invalid.

Each skill root is recursively copied under `<canonical>/<slug>` while retaining
all paths relative to that root. Source symlinks and special files are refused.
An existing destination of any kind is a collision and MUST fail by default;
this version has no rename or overwrite option. Dry runs perform all discovery
and collision checks but make no filesystem changes.

Successful imports write `<canonical>/<slug>/PORT_INFO.json` with typed fields:
`sourceArchive`, `sourceRoot`, `normalizedSlug`, `classification`, `importedAt`
(UTC RFC 3339 JSON timestamp), `warnings`, `toolVersion`, and `contentDigest`.
The digest is SHA-256 over normalized payload paths and contents, excluding
`PORT_INFO.json` itself.

### Safe updates

Collision failure remains the default. `--update` permits replacement only when
the existing entry is a real directory with valid `PORT_INFO.json`, its slug,
source root, and classification match the incoming skill, and its current
payload digest equals the recorded digest. This proves that the porter created
the entry and that its payload has not subsequently changed. Missing or legacy
digests, local edits, symlinks, mismatched identity, malformed metadata, and
unmanaged entries MUST be refused. A changed source archive path alone does not
invalidate identity, because repeated downloads commonly have different paths.

An accepted update MUST be staged beside the destination. The old directory is
renamed to a temporary backup, the staged directory is atomically renamed into
place, and the old directory is restored if activation fails. Dry-run performs
all ownership, identity, and digest checks without staging or mutation.

## Link and diagnostic safety

Links use absolute targets and are limited to
`<project>/.cursor/skills/<slug>` and `<project>/.claude/skills/<slug>`. A
correct symlink is unchanged; a wrong symlink may be replaced. An unrelated
regular file or directory MUST never be replaced. The canonical skill must
exist and contain `SKILL.md` before linking.

`doctor` reports a missing/non-directory canonical root, broken symlinks,
symlinks resolving outside the canonical root, and non-symlink entries in either
managed link directory. Missing project link directories are allowed.

## Compatibility and limitations

The tool is intentionally non-interactive, ZIP-only, and does not validate skill
frontmatter, infer registry metadata, import instruction-only packages, run
content, force-update locally modified/unmanaged entries, or manage user-global
discovery links. Changing these safety, CLI, report, classification, or
persistence rules requires an updated specification and unit tests.
