---
name: shell-scripting
version: "0.1.0"
description: Codex pack for production shell scripting assistance.
---

# Shell Scripting

`shell-scripting` is a Codex pack adapted from the upstream
`claude-code-workflows` shell-scripting plugin. It installs two focused Codex
subagents and three bundled skills for production Bash, POSIX portability,
Bats testing, and ShellCheck configuration.

## Profiles

- `lite`: installs all shell-scripting agents and skills. No hooks, rules, or
  MCP configuration are installed.

## Target Support

- `project-codex`: installs into a project `.codex/`
- `user-codex`: installs into `~/.codex/`

## Included Surfaces

- `.codex/agents/shell-scripting-bash-pro.md`
- `.codex/agents/shell-scripting-posix-shell-pro.md`
- `shell-scripting-bash-defensive-patterns`
- `shell-scripting-bats-testing-patterns`
- `shell-scripting-shellcheck-configuration`

## Install Examples

```bash
bash scripts/cursor-pack-sync.sh --pack=shell-scripting --target=codex-project --project-root="$PWD" --profile=lite --dry-run
bash scripts/cursor-pack-sync.sh --pack=shell-scripting --target=codex-user --profile=lite --dry-run
```

## Attribution

Adapted from the MIT-licensed `shell-scripting` plugin in
`claude-code-workflows`, originally credited in the plugin manifest to Ryan
Snodgrass. See [guides/adaptation-notes.md](guides/adaptation-notes.md) and
[LICENSE.upstream.md](LICENSE.upstream.md).
