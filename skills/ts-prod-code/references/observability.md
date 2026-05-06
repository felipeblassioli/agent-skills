# Observability — structured logging and OpenTelemetry correlation

Every error and every meaningful event the service emits must be **structured** and **correlated** so dashboards and trace UIs can pivot from a failed HTTP request → root infrastructure error → exact line of code.

## Core rules

1. **Structured logging only.** JSON, key-value. No `console.log("user " + id + " did X")`.
2. **Never log secrets or PII.** Tokens, passwords, full PANs, full CPFs, raw emails when avoidable. Mask at the logger or before the log call.
3. **One throw → one log** at the surfacing boundary. Lower layers wrap and propagate; they do not log.
4. **Always include correlation**: `traceId`, `spanId`, `requestId`, plus business context (entity ids).
5. **Stable event names** as `as const` constants. No string typos drifting across the codebase.

## Log levels

| Level | When |
|---|---|
| `FATAL` | Process cannot continue and will terminate |
| `ERROR` | Request aborted; requires human intervention ASAP (SLO burn) |
| `WARN` | Request not satisfactorily served; intervention needed soon |
| `INFO` | Process flow / business signal at boundaries (request received, entity created, gateway call) |
| `DEBUG` | Internal flow detail; off in production unless investigating |
| `TRACE` | Hyper-detailed; never on in production |

`DomainError` typically logs at `INFO` or `WARN` (it's a normal business outcome, not a system failure). `RecoverableInfrastructureError` after retry budget exhaustion logs at `ERROR`. See [error-model.md](error-model.md).

## What to include in every log entry

| Field | Source |
|---|---|
| `event` | Stable constant: `"booking.failed"`, `"card.tokenized"` |
| `level` | Logger level |
| `message` | Human-readable summary |
| `code` | Outer error code (if error) |
| `rootCode` / `rootMessage` | From `error.rootCause()` (if error) |
| `context` | Domain-specific ids (`customerId`, `cardId`) |
| `traceId`, `spanId` | From OpenTelemetry context |
| `requestId` / `correlationId` | From inbound header or generated per request |
| `service`, `op` | `"booking-service"` / `"POST /booking"` |
| `retryCount` | For infra errors after each attempt |
| `circuitState` | `"CLOSED" | "OPEN" | "HALF_OPEN"` |

## Typed event vocabulary

```ts
// shared/log-events.ts
export type LogEvent =
  | { name: "user.created"; userId: UserId }
  | { name: "card.tokenized"; cardId: string; vendor: string }
  | { name: "booking.failed"; bookingId: string; code: ErrorCode };
```

Pass `LogEvent` to the logger; reject string-only logs in code review.

## OpenTelemetry — minimal bootstrap

```ts
// tracing.ts — run once at process start (e.g., --require ./tracing)
import { NodeSDK } from "@opentelemetry/sdk-node";
import { getNodeAutoInstrumentations } from "@opentelemetry/auto-instrumentations-node";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { Resource } from "@opentelemetry/resources";
import { SEMRESATTRS_SERVICE_NAME } from "@opentelemetry/semantic-conventions";

new NodeSDK({
  resource: new Resource({ [SEMRESATTRS_SERVICE_NAME]: "booking-service" }),
  traceExporter: new OTLPTraceExporter({ url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT }),
  instrumentations: [getNodeAutoInstrumentations()],
}).start();
```

## Correlation middleware

```ts
import { context, trace } from "@opentelemetry/api";
import { randomUUID } from "node:crypto";

export function correlationMiddleware(req, _res, next) {
  const correlationId = req.header("x-correlation-id") ?? randomUUID();
  req.correlationId = correlationId;
  context.with(trace.setSpan(context.active(), trace.getActiveSpan()!), () => next());
}
```

Add this **first**, so every downstream span (auto-instrumented or manual) inherits it.

## Mapping `Result` failures onto span status

```ts
import { SpanStatusCode, trace } from "@opentelemetry/api";
import { Result } from "../shared/result";

export async function withSpan<T, E extends string>(
  name: string,
  fn: () => Promise<Result<T, E>>,
): Promise<Result<T, E>> {
  const span = trace.getTracer("booking-service").startSpan(name);
  try {
    const result = await fn();
    if (!result.ok) {
      span.setStatus({ code: SpanStatusCode.ERROR, message: result.code });
      if (result.cause instanceof Error) span.recordException(result.cause);
    }
    return result;
  } finally {
    span.end();
  }
}
```

## Logger ↔ trace bridge

```ts
import { context, trace } from "@opentelemetry/api";

export function otelIds() {
  const span = trace.getSpan(context.active());
  return span
    ? { traceId: span.spanContext().traceId, spanId: span.spanContext().spanId }
    : {};
}

logger.info(
  { ...otelIds(), event: "booking.failed", code: err.code, rootCode: err.rootCause()?.code },
  "Booking failed",
);
```

Wire this into your pino/winston/bunyan formatter so **every** log line has trace ids automatically.

## Linkage matrix

| Where emitted | Attach | How |
|---|---|---|
| Span | `SpanStatusCode.ERROR` + `exception.*` | `span.setStatus()` + `span.recordException()` |
| Log event | `traceId`, `spanId`, `code`, `rootCode` | Formatter injection (above) |
| HTTP response | `trace-id` header (optional for client debug) | `res.set("trace-id", currentTraceId)` |

## What good error messages look like

Good user-facing errors and warnings are:

- **Few**: emit at error level only for things the user must act on.
- **Clear and precise**: state what went wrong.
- **Unambiguous**: avoid "if you also see X". Resolve in code, or downgrade to warn.
- **Actionable**: suggest next steps when possible.
- **Contextual**: provide enough info (ids, line number, error code) to drill down.

A canonical structured-error pattern (Istio-style):

```ts
export const OperatorFailedToGetObject = {
  code: "OPERATOR_GET_OBJECT_FAILED",
  moreInfo: "Failed to fetch an object from the API server (transient API error or object deleted).",
  impact: "Updates for the object cannot be processed; control plane may drift.",
  likelyCause: "Transient API server error, network blip, or object deletion.",
  action: "If the object was deleted, ignore. If persistent, see https://example.com/runbooks/api.",
} as const;
```

## Anti-patterns

- **String concatenation logs**: `logger.info("user " + id + " created")`. Use structured fields.
- **Logging the same error at every layer**. Once at the boundary, with `cause` chain.
- **Logging then rethrowing**. Do one or the other; the boundary that finally handles the error logs.
- **PII in logs**: full email, full phone, full document number. Mask before logging.
- **Stack traces in user-facing responses**. Internal only; opt-in via header for trusted callers.

## Smells

- A logger configured per file with different formatters. Centralize one logger module; inject it.
- A controller that logs and a global error handler that also logs the same error. Pick one.
- Manual `traceId` extraction in every handler. Centralize via middleware + formatter injection.

## Further reading

- OpenTelemetry JS — [https://opentelemetry.io/docs/instrumentation/js/](https://opentelemetry.io/docs/instrumentation/js/)
- Marco Behler — Java logging guide (level definitions used here).
- ZIO — Expected vs unexpected errors.
- Istio — Error dictionary convention.
