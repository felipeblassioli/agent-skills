# Script / Tool Maintenance

Stable tools under `scripts/<tool>/` are maintained artifacts, not throwaway
helpers. They follow the same governance rhythm as skills and packs — small
SPEC, tests, and linked GitHub issues for concrete backlog slices.

## Required shape for a maintained tool

```text
scripts/<tool>/
├── <tool>.sh          # or .py, .ts — the executable entry point
├── SPEC.md            # CLI contract: flags, output, exit codes, safety
└── tests/             # smoke / unit / integration tests for the tool
```

Smaller one-off scripts can live directly under `scripts/<name>.sh` without a
folder. The folder + `SPEC.md` shape is required only when a tool is treated
as a stable contract that other artifacts (skills, packs, CI) depend on.

## SPEC.md must cover

- CLI invocation surface (positional args, flags, environment variables).
- Output contract (stdout schema, stderr, JSON-vs-human modes).
- Exit codes and their meaning.
- Safety rules (`--dry-run` default, backup behavior, idempotency,
  destructive flags requiring `--yes`).
- Persistence model (what files are written, where, with what permissions).
- Backup / restore behavior, if any.

## When changing a maintained tool

Before changing a tool, read its `SPEC.md`. Treat any change to the items
above as a contract change:

- Update `SPEC.md` in the same commit.
- Update or add a test under `scripts/<tool>/tests/`.
- Update any skill or pack reference that pinned the old behavior.
- Record the change in root `CHANGELOG.md` when it affects repository-level
  governance (e.g., a new flag becomes required, a default changes).

## Backlog and issues

Concrete implementation slices for a tool live in GitHub issues. Link them
from `SPEC.md` or `ROADMAP.md` (if the tool ships inside a pack) when they
affect durable product direction. Do not let tool backlog live only in chat.

## See Also

- [`docs/specs/artifact-maintenance-workflow.md`](../../../../docs/specs/artifact-maintenance-workflow.md) — full maintenance workflow per artifact type.
- [`docs/ADR/ADR-0003-artifact-maturity-model.md`](../../../../docs/ADR/ADR-0003-artifact-maturity-model.md) — maturity model for scripts/tools.
