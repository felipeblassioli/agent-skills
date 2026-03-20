# CLI Product Doctrine

This reference captures the product-level doctrine for serious command-line
applications. It is language-agnostic. Use it when deciding how the command
surface should behave for humans, scripts, CI, and AI agents.

## Purpose

The CLI is an automation surface first and a human interface second.

That does not mean humans are secondary users. It means the design starts from
explicit semantics, stable contracts, trustworthy side effects, and safe
automation, then renders those semantics well for humans.

## North Star

A strong CLI should feel:

- predictable
- legible
- stable
- hard to misuse accidentally
- scriptable without brittle text scraping
- explicit about state and mutation

A weak CLI feels slippery:

- behavior depends on hidden context
- output shape changes unexpectedly
- read-like commands mutate silently
- scripts must parse prose
- failures do not say whether retry is safe

## Core Principles

### Predictability over cleverness

Prefer:

- explicit command naming
- stable defaults
- visible mutation boundaries
- trustworthy exit codes
- consistent grammar across subcommands

Avoid:

- magical inference with no way to inspect it
- parser tricks that change flag meaning across contexts
- hidden state that silently changes behavior

### Humans and machines are both first-class

Design both intentionally:

- concise human output for interactive use
- structured output such as JSON for automation
- deterministic field naming
- stable output contracts
- clean stdout for data and stderr for diagnostics

### Errors should classify and teach

At minimum, user-visible failures should help distinguish:

- usage problems
- validation failures
- missing resources
- auth or permission failures
- dependency or network failures
- timeouts
- partial success
- internal invariant violations

The operator should understand whether a retry is safe.

### Side effects should be explicit

Prefer:

- read and write paths separated where practical
- plan/apply or preview/execute splits for risky workflows
- confirmations for destructive actions, with bypass flags for automation
- clear reporting of what changed
- idempotent behavior where it is reasonable

Silent mutation is one of the fastest ways to lose trust.

### Domain-shaped commands beat flag jungles

Prefer command trees that reveal the domain model:

- `tool issue get`
- `tool issue list`
- `tool release plan`
- `tool release apply`

The requirement is coherence and discoverability, not doctrinaire purity.

### Documentation is part of the interface

Treat `--help` as contract surface, not decoration.

Good help should be:

- terse at the top level
- realistic in examples
- explicit about what a command prints
- explicit about what a command changes
- consistent in terminology

### Diagnostics matter

The CLI should be quiet by default and diagnosable on demand.

Useful defaults:

- normal mode: essential output only
- `--verbose`: operational detail useful to humans
- `--debug`: deep execution detail for diagnosis

Prefer opt-in diagnostics over noisy defaults.

### Configuration should exist, but stay on a leash

Recommended precedence:

1. flags
2. environment variables
3. project config
4. user config
5. built-in defaults

Resolved context should be explainable and ideally inspectable.

### Composability beats theatrical UX

Prefer:

- pipe-friendly output
- non-interactive operation for core workflows
- support for stdin where meaningful
- bounded output controls such as `--limit`
- no mandatory TUI path for important automation flows

Interactive UX can be valuable, but it should be additive rather than required.

### AI-agent ergonomics are real requirements

Modern CLIs should be:

- discoverable through help
- safe to run headlessly
- explicit in side effects
- structured in output
- parsable in failure
- stable in contracts

Design for agents at the semantic layer, not by making the default human UX
robotic.

## Key Decision Rules

### Output mode

Use plain text for reading and JSON for reasoning.

Default rule:

- text by default for simple interactive success paths
- JSON as a first-class contract from day one for serious commands
- both for most serious data-bearing commands

Human output is a presentation layer. Structured output is the contract.

### Contextual inference

Infer only when it is:

- low-risk
- reversible
- explainable

Never infer silently across mutation boundaries or trust boundaries.

Good inference:

- detect current repository
- detect TTY vs non-TTY
- choose a default config path
- read env vars through explicit precedence

Bad inference:

- silently switching targets
- choosing environment or tenant invisibly
- mutating remote state because the tool guessed intent

### Exit-code taxonomy

Keep exit codes small, semantic, and stable.

Recommended baseline:

- `0` success
- `1` generic failure
- `2` usage or validation error
- `3` state or precondition failure
- `4` external dependency failure
- `5` authentication or authorization failure
- `6` partial success, conflict, or drift detected

The exact count matters less than consistent semantics plus good stderr and JSON
error payloads.

### TUI policy

Build a pure CLI first. Add a TUI only as an optional layer over stable command
primitives.

A TUI is justified when the user must:

- compare many entities
- inspect changing state
- resolve conflicts interactively
- navigate graphs or deep hierarchies
- review a plan before apply

The TUI should not become a separate semantic kingdom.

### Compatibility policy

Treat these as public APIs once exposed:

- command names and subcommand structure
- flag names and meanings
- exit code meanings
- stdout and stderr contracts
- JSON schemas
- config precedence rules
- environment variable names
- dry-run and apply semantics
- emitted identifier formats

If shell scripts, CI jobs, wrappers, plugins, or agents may rely on it, it is
already an API.

## Output Contract

Prefer this baseline:

- stdout for primary data
- stderr for diagnostics, warnings, progress, and mutation summaries
- exit code for coarse result classification

For JSON mode, use a stable shape instead of dumping internal structs.

## Interactivity Policy

Good default:

- interactive if running in a TTY and explicit inputs are absent
- non-interactive if piped, headless, or explicitly flagged
- every prompt has a flag-based equivalent

## Anti-Patterns

Avoid:

- interactive-only workflows for important commands
- mutation hidden inside read-like commands
- output that changes shape unpredictably
- success chatter mixed into stdout data streams
- deeply stateful behavior driven by hidden config
- flag overload instead of command design
- poor error messages that force source-code reading
- many aliases for the same concept
- inconsistent terminology across help, docs, and code

## Design Tensions Worth Preserving

Good CLI design balances:

- explicitness vs ergonomics
- scriptability vs rich UX
- stability vs iteration speed
- human readability vs machine readability
- global consistency vs domain-specific exceptions

These tensions are normal. The goal is not dogma. The goal is trust.

## Final Heuristic

When uncertain between two designs, prefer the one that is:

- easier to explain in `--help`
- safer to run headlessly
- more stable to script against
- clearer about state and target
- easier to debug from stderr and exit code alone

If one design is more charming and the other is more trustworthy, default to
trustworthy.
