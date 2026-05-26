---
name: shell-scripting-bats-testing-patterns
description: Use when adding or reviewing Bats tests for shell scripts, including fixtures, setup and teardown, exit-code assertions, output assertions, and CI-friendly shell test layout.
---

# Shell Scripting Bats Testing Patterns

Use Bats when shell behavior is important enough to preserve with executable
tests. Keep tests focused on observable CLI behavior rather than implementation
details.

## Recommended Layout

```text
tests/
├── helpers/
│   └── test_helper.bash
├── fixtures/
└── script_name.bats
```

## Test Pattern

```bash
#!/usr/bin/env bats

setup() {
  tmpdir="$(mktemp -d)"
}

teardown() {
  rm -rf -- "$tmpdir"
}

@test "prints usage for missing input" {
  run ./scripts/example.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage:"* ]]
}
```

## Coverage Priorities

- successful invocation with representative inputs
- missing required arguments or environment variables
- invalid paths and permission failures
- dry-run behavior when supported
- cleanup behavior for temporary files
- shell portability matrix when the script claims POSIX support

## Validation Report

End with the exact command and result:

```markdown
## Bats Validation

- Command:
- Result:
- Not covered:
```
