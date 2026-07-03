# Reducing noise at the source

Triage (querying around the noise) is the hot path. But for a *recurring* noisy class,
fix it once at the source. Four levers, cheapest first. **Always prefer fixing the
emitter over excluding** — exclusions hide problems; emitter fixes remove them.

## Lever 0 (do first): stop logging secrets and blobs in the emitter

The single most important fix for the worked example is **not a logging-platform
setting** — it is the application logger. In the worked example the logger writes the
entire request header set (`jsonPayload.keys.httpRequest.headers`) on every entry,
including:

```
authorization: Bearer <redacted-JWT>   # a live user credential, in plaintext, in the log sink
cookie: ...                             # session material
```

This is simultaneously the bulk of the payload size **and** a credential leak with
compliance impact. Anyone with Logs Viewer can read live bearer tokens.

Fixes, in order of preference:
1. **Strip/redact a denylist before logging**: drop `authorization`, `cookie`,
   `set-cookie`, `x-api-key`, `proxy-authorization` (and prefer an allowlist of headers
   actually useful for debugging: `user-agent`, `referer`, `x-forwarded-for`, `host`).
2. **Stop echoing the full request on the error path** — an error log needs the route,
   method, status, and trace, not the verbatim request. Log `keys.query` and a header
   *allowlist*, never the raw `headers` map.
3. **Gate empty context** — do not serialize all-empty `track` / `params` / `position`
   objects; omit them when blank.
4. **Collapse the duplicate error emit** — the example logs the same `TimeoutError`
   twice on stderr (service catch + middleware). Log the error once, at the boundary,
   with the trace; let inner layers rethrow.

If a token has appeared in logs, treat it as **disclosed**: rotate/revoke and consider
purging the affected log entries. Field-level redaction can also be enforced
centrally with Cloud Logging
[data redaction / log scoping](https://docs.cloud.google.com/logging/docs), but
emitter-side redaction is the durable fix.

## Lever 1: severity hygiene

Make severity mean something so `severity >= "ERROR"` is a clean filter:
- Lifecycle/middleware request logs (`LoggerMiddleware: GET …`) are `INFO` — correct,
  but they should be the *first* thing excluded or sampled, not promoted.
- Reserve `ERROR` for actionable failures; use `WARNING` for handled/expected timeouts
  if they are routine, so genuine errors stand out.

## Lever 2: exclusion filters (drop true noise before it is stored)

Exclusions are attached to a **log sink** — typically the catch-all **`_Default`** sink.
Excluded entries are **not stored and not billed**, but exclusions are
**not retroactive** and excluded entries are **not recoverable**. Only exclude logs you
are sure you never want. The `_Required` sink cannot be excluded.

Confirmed flags (`gcloud logging sinks update`): `--add-exclusion` (repeatable; keys
`name=`, `filter=` both required, plus optional `description=`, `disabled`),
`--remove-exclusions=NAME`, `--clear-exclusions`.

Exclude the high-volume INFO request-middleware logs for one Gen 2 service:
```bash
gcloud logging sinks update _Default \
  --add-exclusion='name=orders-api-info-middleware,
    filter=resource.type="cloud_run_revision"
      resource.labels.service_name="orders-api"
      severity<"WARNING"
      logName=~"run.googleapis.com%2Fstdout"' \
  --project=acme-services
```

Keep a *fraction* instead of dropping everything — exclusion filters support the
`sample()` function (sampling on `insertId`). Drop 95% of INFO, keep 5% for spot checks:
```bash
gcloud logging sinks update _Default \
  --add-exclusion='name=info-sample-95,
    filter=severity="INFO" AND sample(insertId, 0.95)' \
  --project=acme-services
```

Disable an exclusion temporarily (e.g. while debugging) without deleting it by setting
`disabled` on it via `--update-exclusion`, or remove it:
```bash
gcloud logging sinks update _Default --remove-exclusions=orders-api-info-middleware --project=acme-services
```

Verify what is currently excluded:
```bash
gcloud logging sinks describe _Default --project=acme-services --format='yaml(exclusions)'
```

## Lever 3: routing — separate signal from noise with sinks + buckets

When logs have value but shouldn't share a haystack, **route** rather than exclude:
- Create a dedicated **log bucket** for errors with longer retention; route
  `severity>="ERROR"` there with a sink, and give it its own Log Analytics view.
- Route audit/business logs to their own bucket/dataset (BigQuery sink) for analytics,
  keeping the operational `_Default` bucket lean.
- Use **log scopes** / saved views so each team queries its own slice without wading
  through everyone else's streams.

Sinks (like exclusions) are **not retroactive** — they only affect entries received
after creation. See
[Routing and storage overview](https://docs.cloud.google.com/logging/docs/routing/overview).

## Decision guide

| Situation | Lever |
|---|---|
| Secrets / PII / full headers in logs | Lever 0 — fix the emitter, rotate the token |
| Same error logged 2–3× per request | Lever 0 — collapse duplicate emit |
| Wrong severity makes `>=ERROR` useless | Lever 1 — severity hygiene |
| High-volume, zero-value, never want it | Lever 2 — exclusion filter (or `sample()`) |
| Valuable but clutters the default view | Lever 3 — route to a dedicated bucket/view |

Before excluding anything, confirm the volume is real and the value is zero. Run the
"count errors by class" and "count by severity/stream" queries in
`references/query-cookbook.md` first — exclude based on data, not on a single noisy
export.
