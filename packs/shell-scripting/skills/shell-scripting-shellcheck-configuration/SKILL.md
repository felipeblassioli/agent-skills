---
name: shell-scripting-shellcheck-configuration
description: Use when configuring ShellCheck, fixing ShellCheck findings, choosing Bash versus POSIX analysis mode, setting project suppressions, or wiring shell lint into CI.
---

# Shell Scripting ShellCheck Configuration

Use ShellCheck as the first static-analysis gate for shell scripts. Match the
ShellCheck mode to the script's actual portability promise.

## Mode Selection

- Bash script: `shellcheck --shell=bash script.sh`
- POSIX sh script: `shellcheck --shell=sh script.sh`
- Sourced files: add `--check-sourced` when the dependency graph matters.

## Project Config

Prefer a project `.shellcheckrc` when multiple scripts share the same policy:

```text
shell=bash
external-sources=true
check-sourced=true
enable=all
```

For POSIX-first projects, set `shell=sh` and avoid suppressing SC3000-series
portability findings unless the file is explicitly Bash-only.

## Suppression Policy

- Fix warnings before suppressing them.
- Use narrow inline suppressions for intentional exceptions.
- Include a short reason next to each suppression.
- Avoid global suppression of quoting, globbing, or injection-related findings.

## CI Pattern

```bash
shellcheck --shell=bash scripts/*.sh
shfmt -d -i 2 -ci -bn scripts
```

For POSIX scripts:

```bash
shellcheck --shell=sh scripts/*.sh
shfmt -ln posix -d scripts
```

## Output Shape

```markdown
## ShellCheck Summary

- Mode:
- Findings fixed:
- Suppressions added:
- CI command:
- Remaining risks:
```
