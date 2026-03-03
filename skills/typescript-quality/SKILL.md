---
name: typescript-quality
description:
  TypeScript code quality patterns -- typed clients with timeouts, Zod input
  validation, structured domain errors, no any on public APIs, structured JSON
  logging with pino, OpenTelemetry tracing, and PII redaction. Use when adding
  external API calls, validating inputs, handling errors, or setting up logging.
compatibility:
  files: ["tsconfig.json"]
---

# TypeScript Quality

Code quality and observability patterns for TypeScript projects. Contains
7 rules across 2 categories: safe boundary patterns and production
observability.

## When to Apply

Reference these guidelines when:

- Adding external HTTP/queue/database calls
- Implementing input validation at API boundaries
- Designing error types and error handling
- Removing `any` from public TypeScript surfaces
- Setting up structured logging
- Adding OpenTelemetry tracing or metrics
- Reviewing code for PII/secret leakage in logs

## When NOT to Apply

Do NOT reference these guidelines when:

- The project is plain JavaScript without TypeScript
- You are working in this skills repository itself

## Quick Reference

### Boundaries (MEDIUM)

- [boundaries-typed-clients](references/rules/boundaries-typed-clients.md) — External calls must use typed clients with timeouts
- [boundaries-input-validation](references/rules/boundaries-input-validation.md) — Inputs must be validated at boundaries (Zod)
- [boundaries-no-any](references/rules/boundaries-no-any.md) — Public TypeScript surfaces must have explicit types
- [boundaries-structured-errors](references/rules/boundaries-structured-errors.md) — Errors must use stable codes and standard structures

### Observability (MEDIUM)

- [observability-structured-logging](references/rules/observability-structured-logging.md) — Logging must be structured JSON (pino)
- [observability-otel](references/rules/observability-otel.md) — OpenTelemetry is standard for tracing and metrics
- [observability-pii-redaction](references/rules/observability-pii-redaction.md) — Secrets and tokens must be redacted from logs

## How to Use

**For a specific topic** — read the relevant rule from the Quick Reference
above. Each file is self-contained with incorrect/correct examples.

**For reusable code** — copy from templates and customize:

| Template | Purpose |
|----------|---------|
| [domain-error.ts](assets/templates/domain-error.ts) | Base `DomainError` class with stable codes |
| [otel-init.ts](assets/templates/otel-init.ts) | OpenTelemetry SDK initialization |
| [pino-logger.ts](assets/templates/pino-logger.ts) | Pino logger with PII redaction |

**Important:** Do NOT apply changes derived from these rules without explicit
user confirmation. Present proposed changes as diffs and wait for approval.
