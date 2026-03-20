---
name: go-command-line-applications
description: Use when authoring or reviewing Go command-line applications, especially when deciding command grammar, output contracts, exit codes, config precedence, thin CLI architecture, testing strategy, automation safety, or agent-friendly behavior.
---

# Go Command-Line Applications

Use this skill for serious Go CLIs that need to work well for humans, scripts,
CI, and AI agents.

The goal is not maximal abstraction or fancy terminal UX. The goal is a CLI that
is predictable, explicit about side effects, stable to automate, and easy to
debug under pressure.

## When to Use

Reach for this skill when:

- designing a new Go CLI
- reviewing an existing CLI's command shape or operator UX
- deciding whether output should be text, JSON, or both
- defining exit codes, config precedence, or error vocabulary
- splitting Go CLI code into CLI, app, render, config, and infra boundaries
- checking whether a CLI is safe for CI or headless agent use

Do not use this skill for:

- generic Go style that is not CLI-specific
- one-off tiny shell replacements where long-term contracts do not matter
- framework-specific parser syntax beyond the architectural role of the parser

## North Star

A good Go CLI should be:

- predictable instead of clever
- scriptable without fragile text scraping
- explicit about mutation and resolved context
- thin at the CLI layer and well-bounded underneath
- calm by default and diagnosable on demand

## Default Position

Treat the CLI as a **contract-first automation surface** with a good human
renderer.

Default assumptions:

- human-readable text is the default for interactive use
- serious data-bearing commands support `--json`
- stdout is for primary output; stderr is for diagnostics, warnings, progress,
  and errors
- exit codes stay small, semantic, and stable
- mutating commands look mutating and support real `--dry-run` where useful
- command handlers stay thin and call application services rather than becoming
  the architecture

## Default Go Shape

Use the lightest structure that still preserves clear boundaries:

- `cmd/<tool>/main.go` for process startup and final exit
- `internal/cli/...` for command definitions, flags, and surface validation
- `internal/app/...` for use cases and orchestration
- `internal/render/...` or `internal/output/...` for human and JSON rendering
- `internal/config/...` for precedence resolution and effective config
- `internal/infra/...` for filesystem, HTTP, subprocesses, and external systems
- `internal/version/...` for build metadata

If a tool is tiny, the code can be physically smaller than this. The
responsibilities should still remain visible.

## Review Checklist

Check these first when authoring or reviewing a Go CLI:

1. Does the command tree reveal the domain instead of growing into flag soup?
2. Are side effects obvious, especially for remote or destructive operations?
3. Do serious commands support machine-readable output with stable structure?
4. Is stdout clean enough for pipes and stderr reserved for diagnostics?
5. Are exit codes documented, tested, and mapped from a small error taxonomy?
6. Is config resolution explicit, inspectable, and consistent across commands?
7. Does the CLI layer translate parsed input into application requests instead
   of owning business logic?
8. Can core workflows run non-interactively in CI or headless agent contexts?
9. Are help text and examples realistic enough to teach actual usage?
10. Are rendering, process control, and infrastructure concerns testable
    without end-to-end shelling for every case?

## Default Contracts

Unless the repository has a deliberate reason to differ, start here:

- command grammar: domain-shaped `noun verb` or `noun subnoun verb`
- config precedence: flags > env > project config > user config > defaults
- exit codes:
  - `0` success
  - `1` generic failure
  - `2` usage or validation error
  - `3` state or precondition failure
  - `4` external dependency failure
  - `5` authentication or authorization failure
  - `6` partial success, conflict, or drift detected
- version output: support human-readable output and `--json`
- diagnostics: default quiet, `--verbose` for breadcrumbs, `--debug` for deeper
  execution detail

## Read Next

Read the right reference for the question in front of you:

- `references/cli-product-doctrine.md`
  - use for command design, operator UX, output contracts, inference policy,
    side-effect semantics, compatibility surfaces, and AI-agent ergonomics
- `references/go-cli-guidelines.md`
  - use for package layout, handler design, render boundaries, error modeling,
    config loading, context propagation, diagnostics, and testing

If you are making repo-specific decisions for a new CLI, extract the resulting
choices into local project conventions instead of keeping them as ambient taste.

## Common Mistakes

- Turning `SKILL.md` into a giant essay instead of keeping the hot path small
- Hiding mutation inside commands that look read-only
- Treating JSON output as a raw dump of internal Go structs
- Printing from application services instead of rendering at the boundary
- Calling `os.Exit()` deep in command execution paths
- Reading env vars or config files from random helpers across the codebase
- Designing interactive-only workflows for commands that will land in CI
- Adding interfaces by reflex instead of at real consumption boundaries

## Practical Heuristic

When choosing between two CLI designs, prefer the one that is:

- easier to explain in `--help`
- safer to run headlessly
- more stable to script against
- clearer about target, state, and side effects
- easier to debug from stderr and exit code alone
