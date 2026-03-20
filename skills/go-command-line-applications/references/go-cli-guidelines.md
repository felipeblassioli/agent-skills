# Go CLI Guidelines

This reference turns the CLI product doctrine into implementation guidance for
Go command-line applications.

## Purpose

A serious Go CLI should be implemented as a small application with boundaries,
not as a pile of parser callbacks and `fmt.Printf` calls orbiting a giant
`main` package.

The CLI layer is an adapter. Its job is to:

- parse flags and positionals
- resolve configuration and runtime context
- translate surface input into application requests
- call use cases or services
- render results for humans or machines
- map failures to diagnostics and exit codes

Its job is not to become the whole architecture.

## Architectural Shape

Prefer these responsibilities:

1. Process layer: startup, shutdown, signal handling, dependency wiring, final
   exit behavior
2. CLI surface layer: command definitions, help text, flags, positionals,
   surface validation, routing
3. Application layer: use cases, orchestration, business rules
4. Rendering layer: human output, JSON output, tables, summaries, error
   presentation
5. Infrastructure layer: filesystem, HTTP, subprocesses, cloud APIs, config
   loading, clocks, OS interaction

This does not require five elaborate directories in every repo. It requires
consciously separated responsibilities.

## Package Guidance

Good baseline:

- `cmd/<tool>/main.go`
- `internal/cli/...`
- `internal/app/...`
- `internal/render/...` or `internal/output/...`
- `internal/config/...`
- `internal/infra/...`
- `internal/version/...`

Add `internal/domain/...` only when the domain is real enough to justify it.

Avoid vague package names like `common`, `util`, or `helpers`.

## Command Handler Design

A command handler is an adapter, not an application service.

Preferred shape:

- accept already-parsed inputs from the CLI framework
- resolve context prepared at startup
- create a typed application request
- call one application method
- hand the result to a renderer
- return an exit status rather than terminating the process directly

Avoid:

- business rules inside `Run()` methods
- network calls scattered across command structs
- writing to stdout from the application layer
- calling `os.Exit()` from deep execution paths
- coupling handlers directly to infrastructure when injectability matters

If a handler is hard to test without a real terminal, environment, and network,
it is probably too fat.

## Interfaces and Concrete Types

Default bias:

- prefer concrete types by default
- introduce interfaces at consumption boundaries where they buy real decoupling
  or testability
- define interfaces as close as possible to the consumer
- keep interfaces small and behavior-focused

Introduce interfaces mainly at real seams such as:

- HTTP or cloud API clients
- filesystem access when determinism matters in tests
- subprocess runners
- clocks or time sources
- persistence or caching backends with real substitution needs

Avoid producer-owned interface museums created only for mocking.

## CLI Framework Role

Use the parser framework as a command-model tool, not as the architecture.

The framework may own:

- parser concerns
- help generation
- command tree declaration

The application layer should still own meaning.

Avoid:

- framework-specific context leaking into core logic
- relying on parser annotations as the main design language
- burying policy in parser tags that becomes hard to test or evolve

## Input, Output, and Rendering

Separate execution from presentation.

Preferred pattern:

- application layer returns typed results
- rendering layer chooses human text, JSON, scalar, or table output
- process layer decides stdout/stderr usage, exit code, and diagnostic enablement

Default contract:

- stdout for primary output only
- stderr for diagnostics, warnings, progress, mutation summaries, and errors

For serious commands, support a stable `--json` mode.

Treat JSON as a contract, not as a raw dump of internal Go structs. Use explicit
field names and stable envelopes where needed.

## Error Model and Exit Codes

Go returning `error` is not the same thing as having an error model.

Use a small shared failure vocabulary across the app boundary:

- usage or validation
- precondition or state
- not found
- auth or authz
- dependency or transient failure
- conflict or partial success
- internal failure

These categories should drive:

- stderr rendering
- JSON error payloads
- exit-code mapping

Recommended baseline:

- `0` success
- `1` generic failure
- `2` usage or validation error
- `3` state or precondition failure
- `4` external dependency failure
- `5` authentication or authorization failure
- `6` partial success, conflict, or drift detected

Return exit codes from execution paths. Call `os.Exit()` only at the outer
process boundary.

## Configuration and Runtime Context

Resolve configuration once, explicitly, near startup.

Preferred precedence:

1. flags
2. environment variables
3. project-local config
4. user-level config
5. built-in defaults

Good practice:

- normalize into a typed effective-config struct
- centralize context resolution enough to explain and test behavior
- provide a way to inspect effective configuration or resolved execution context

Avoid:

- reading env vars from random deep helpers
- multiple precedence models across subcommands
- hidden fallback behavior that silently changes targets

## Context Propagation

If the CLI touches network, filesystem, subprocesses, or long-running work,
make `context.Context` part of the design.

Good practice:

- derive context near process start
- connect signal handling to cancellation where appropriate
- honor context in external calls
- make timeout policy explicit for remote operations

Avoid ad hoc timeout logic per adapter and hidden context creation deep in
helpers.

## Concurrency

Use concurrency only when it materially improves throughput, latency, or
operator experience.

Prefer:

- bounded worker pools
- explicit fan-out and fan-in
- context-aware workers
- clear partial-failure policy
- deterministic aggregation when ordering matters

Avoid:

- unbounded goroutine spawning
- mixing concurrency with rendering
- hiding races around shared result accumulation
- treating partial failures as success without surfacing them

Sequential execution is often the better default until concurrency solves a real
problem.

## Diagnostics and Debuggability

Normal output should stay calm, but the CLI should expose deeper detail when the
operator needs to see the machinery moving.

Recommended ladder:

- default: essential output only
- `--verbose`: human-oriented operational breadcrumbs
- `--debug`: deeper execution detail

For API-heavy tools, debug output may include:

- method and URL
- attempt number
- response status
- retry/backoff decisions
- rate-limit signals
- correlation or request IDs
- timing information

Rules for transport logging:

- off by default
- opt in explicitly
- redact tokens, cookies, secrets, and sensitive payload fields
- keep the format consistent enough to follow a request chain

Prefer wrapping transports or clients once over sprinkling ad hoc prints
throughout the codebase.

## Testing Strategy

Do not collapse CLI testing into only subprocess E2E tests, and do not pretend
unit tests alone cover the operator surface.

Recommended layers:

1. Application-layer unit tests for orchestration, logic, and error
   classification
2. Renderer tests for human text and JSON output
3. Command-surface tests for args, stdin/stdout/stderr, help, output-mode
   switching, and exit mapping
4. Infrastructure integration tests using fakes, stubs, `httptest`, temp dirs,
   or real dependencies when justified
5. Built-binary smoke tests in CI for important tools

Use golden files for:

- stable help text
- multiline human output
- plans or generated text where visual shape matters

Do not rely on golden files alone for JSON contracts. Assert JSON as data.

## Filesystem and Subprocess Boundaries

Model environment, filesystem, subprocess execution, and OS interaction as
explicit infrastructure concerns.

Prefer:

- temporary directories in tests
- explicit path resolution
- structured subprocess invocation
- clear distinction between discovery and mutation

Avoid hidden subprocess calls and shelling out when a stable Go library would do
the job better.

## Versioning and Release Metadata

A serious CLI should know what build it is.

Provide:

- a `version` command or equivalent
- build metadata injected at compile time
- at least version, commit, and build date
- human-readable output and `--json`

Useful JSON keys:

- `version`
- `commit`
- `buildDate`
- `goVersion`
- `platform`

## Documentation Expectations

Minimum expectations:

- top-level help that orients quickly
- command-specific examples that look like real use
- explicit description of output modes
- clear exit-code documentation
- visible config-precedence documentation

Generated help can support the docs, but it should not be the whole doc story.

## Common Failure Modes

Recurring ways Go CLIs decay:

- `main` becomes the whole program
- command handlers become business-logic containers
- printing is scattered everywhere
- config is read from random locations
- env vars become hidden control flow
- `os.Exit` leaks into deep code paths
- JSON mode becomes an unstable dump of structs
- concurrency appears without a partial-failure model
- tests cover only internals and ignore the command surface
- tests cover only subprocess E2E and become brittle
- help text drifts from real behavior

## Project-Level Decisions Worth Freezing

For a real CLI, choose and document these deliberately:

- command grammar and canonical verbs
- environment variable prefix
- config filenames and locations
- JSON envelope shape
- help-text style
- golden-file conventions
- version command format
- verbosity ladder
- package and directory names where consistency helps navigation

These quickly become public API for humans, scripts, CI, and agents.

## Final Heuristic

Build the CLI so that:

- command parsing is not business logic
- business logic is not rendering
- rendering is not process control
- process control is not hidden global state

If those lines remain visible, the tool will age far better.
