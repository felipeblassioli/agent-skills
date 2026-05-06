---
name: 'otel-instrumentation'
description: 'Configures OpenTelemetry trace spans, metrics, and log exporters. Use ONLY when instrumenting applications specifically with OpenTelemetry (OTel). Triggers on requests explicitly mentioning OpenTelemetry, OTel, or OTLP.'
license: MIT
metadata:
  author: dash0
  version: '2.0.0'
  workflow_type: 'advisory'
  supports-traces: "true"
  supports-metrics: "true"
  supports-logs: "true"
---

# OpenTelemetry Instrumentation Guide

Expert guidance for implementing high-quality, cost-efficient OpenTelemetry telemetry.

## Rules & Quick Reference

| Use Case / Rule | Description |
|-----------------|-------------|
| [telemetry](./rules/telemetry.md) | **Entrypoint** — signal types, correlation, and navigation |
| [resolve-values](./rules/resolve-values.md) | Resolving configuration values from the codebase |
| [resources](./rules/resources.md) | Resource attributes — service identity and environment |
| [k8s](./rules/platforms/k8s.md) | Kubernetes deployment — downward API, pod spec |
| [spans](./rules/spans.md) | Spans — naming, kind, status, and hygiene |
| [logs](./rules/logs.md) | Logs — structured logging, severity, trace correlation |
| [metrics](./rules/metrics.md) | Metrics — instrument types, naming, units, cardinality |
| [sensitive-data](./rules/sensitive-data.md) | Sensitive data — PII prevention, sanitization, redaction |
| [validation](./rules/validation.md) | Telemetry validation — post-deployment verification checklist |
| [nodejs](./rules/sdks/nodejs.md) | Node.js instrumentation setup |
| [go](./rules/sdks/go.md) | Go instrumentation setup |
| [python](./rules/sdks/python.md) | Python instrumentation setup |
| [java](./rules/sdks/java.md) | Java instrumentation setup |
| [scala](./rules/sdks/scala.md) | Scala instrumentation setup |
| [dotnet](./rules/sdks/dotnet.md) | .NET instrumentation setup |
| [ruby](./rules/sdks/ruby.md) | Ruby instrumentation setup |
| [php](./rules/sdks/php.md) | PHP instrumentation setup |
| [browser](./rules/sdks/browser.md) | Browser instrumentation setup |
| [nextjs](./rules/sdks/nextjs.md) | Next.js full-stack instrumentation (App Router) |

## Official documentation

- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/)
- [Dash0 Integration Hub](https://www.dash0.com/hub/integrations)

## Getting started

Follow these steps when instrumenting an application from scratch:

1. **Pick your SDK rule** — choose the language-specific rule from the table above (e.g., [nodejs](./rules/sdks/nodejs.md), [python](./rules/sdks/python.md)).
2. **Set up resource attributes** — define service identity and environment per [resources](./rules/resources.md).
3. **Add spans, metrics, and logs** — instrument your code following [spans](./rules/spans.md), [metrics](./rules/metrics.md), and [logs](./rules/logs.md).
4. **Guard sensitive data** — scrub PII before export per [sensitive-data](./rules/sensitive-data.md).
5. **Validate** — confirm telemetry reaches the backend using the checklist in [validation](./rules/validation.md).

**When activated, you MUST use the Read tool to read the relevant rule file from the table above before providing guidance.**

## Output Format

When providing instrumentation guidance, strictly follow this structure:
1. **Required Packages**: List dependencies to install.
2. **Configuration**: Required environment variables.
3. **Implementation**: Code snippets for initialization and custom spans.
4. **Validation**: How to verify the telemetry is exported.
Do not include conversational filler.

## Delegation

- If the user asks to instrument an entire codebase or multiple services, use the `Task` tool (subagent) to explore the codebase or apply instrumentation in parallel across services.

## Key principles

### Signal density over volume

Every telemetry item should serve one of three purposes:
- **Detect** - Help identify that something is wrong
- **Localize** - Help pinpoint where the problem is
- **Explain** - Help understand why it happened

If it doesn't serve one of these purposes, don't emit it.

### Sample in the pipeline, not the SDK

Use the `AlwaysOn` sampler (the default) in every SDK.
Do not configure SDK-side samplers — they make irreversible decisions before the outcome of a request is known.
Defer all sampling to the [Collector](../otel-collector/rules/sampling.md), where policies can be changed centrally without redeploying applications.

```
SDK (AlwaysOn)  →  Collector (sampling)  →  Backend (retention)
     ↓                    ↓                       ↓
  All spans         Head or tail            Storage policies
  exported          sampling applied
```
