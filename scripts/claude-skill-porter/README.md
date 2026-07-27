# Claude Skill Porter

Safely inspect ZIP downloads, import the Agent Skills they contain into a
canonical directory, and expose those skills to Claude and Cursor projects.

## Install and help

```bash
cd scripts/claude-skill-porter
go install ./cmd/claude-skill-porter
claude-skill-porter help
```

For a repository-local binary: `go build -o ./bin/claude-skill-porter
./cmd/claude-skill-porter`.

## Examples

```bash
claude-skill-porter scan ~/Downloads/skills.zip
claude-skill-porter scan ~/Downloads/skills.zip --json

claude-skill-porter import ~/Downloads/skills.zip \
  --canonical "$HOME/.agents/skills" --dry-run
claude-skill-porter import ~/Downloads/skills.zip \
  --canonical "$HOME/.agents/skills"
claude-skill-porter import ~/Downloads/skills-v2.zip \
  --canonical "$HOME/.agents/skills" --update --dry-run

claude-skill-porter link --canonical "$HOME/.agents/skills" \
  --project-root "$PWD" --skill code-review --dry-run
claude-skill-porter doctor --canonical "$HOME/.agents/skills" \
  --project-root "$PWD" --json
```

Flags may appear after the archive positional argument. `--json` emits a stable
report object suitable for automation. `--dry-run` is supported by the mutating
`import` and `link` commands and guarantees no filesystem mutation.

## Supported layouts

- A direct skill with `SKILL.md` at the ZIP's logical root.
- A scaffold containing one or many nested skill roots.
- Either layout inside one common wrapper directory (common in GitHub ZIPs).
- Instruction-only archives can be identified by `scan`, but are not imported.

Compiled VS Code/Cursor extensions are reported as incompatible and refused.

## Safety guarantees

- ZIP paths are contained below a private temporary extraction directory;
  absolute paths, traversal, symlinks, and special files are rejected.
- Archive content is never executed.
- Every `SKILL.md` root is detected; internal relative layout is preserved.
- Skill names are normalized to lowercase kebab case.
- Existing canonical entries cause an error by default. Explicit `--update`
  replaces only porter-managed entries whose recorded digest proves that their
  payload has not been locally modified; the replacement is staged with rollback.
- Project links never replace unrelated files or directories.
- Every installed skill receives an auditable, typed `PORT_INFO.json`.

## Limitations

ZIP is the only archive format. This version has no collision rename or forced overwrite,
frontmatter validation, registry updates, instruction-file conversion, global
link management, or archive script execution. See [SPEC.md](SPEC.md) for the
normative behavioral contract.
