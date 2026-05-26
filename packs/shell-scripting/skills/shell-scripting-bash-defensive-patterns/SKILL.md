---
name: shell-scripting-bash-defensive-patterns
description: Use when writing or reviewing production Bash scripts that need strict error handling, safe file operations, argument validation, cleanup traps, and predictable CI behavior.
---

# Shell Scripting Bash Defensive Patterns

Apply these patterns when the script is intentionally Bash-specific. If the
script must run as `/bin/sh`, switch to POSIX guidance instead.

## Baseline

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SCRIPT_NAME="$(basename -- "${BASH_SOURCE[0]}")"
```

Use `shopt -s inherit_errexit` only when Bash 4.4+ is an explicit requirement.

## Safety Rules

- Quote variable expansions: `"$path"`, `"${items[@]}"`.
- Use arrays for dynamic commands: `cmd=(git diff -- "$path")`; then
  `"${cmd[@]}"`.
- Validate required environment variables with `: "${NAME:?message}"`.
- Validate external commands with `command -v tool >/dev/null 2>&1`.
- Use `mktemp` and `trap` for temporary resources.
- Pass `--` before path operands controlled by input.
- Prefer NUL-delimited file iteration: `find . -print0` with
  `while IFS= read -r -d '' file`.
- Avoid `eval`, parsing `ls`, and unquoted command substitutions.

## Output Shape

When reviewing or changing a script, report:

```markdown
## Shell Safety Summary

- Bash/POSIX decision:
- Strict-mode and trap changes:
- Input/path safety changes:
- Tests or lint run:
- Remaining portability limits:
```
