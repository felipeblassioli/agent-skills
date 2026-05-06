# Cross-Cutting Review Reference

Use this reference when the change touches concerns that apply across HTTP, queue, scheduled, and workflow archetypes. These lenses rarely change architecture but frequently catch the actual production bug.

## `Multi-Tenancy Isolation`

Use when the system serves multiple tenants, customers, organizations, or accounts.

Ask:

- Every database query carrying a tenant scope: is the scope enforced server-side (not from a client-supplied id)?
- Cache keys, queue topic names, blob paths, log labels, metric labels: do they include the tenant dimension where required?
- Rate limits: are they scoped per tenant, or can one tenant starve another?
- Logs and traces: do they avoid putting tenant A's data into tenant B's session?
- Background jobs that iterate "all tenants": is per-tenant failure isolated, or does one bad tenant fail the run?

Red flags:

- `WHERE id = ?` without `AND tenant_id = ?` on a multi-tenant table.
- Cache key built from user-controlled input that omits tenant.
- "We'll trust the JWT claim" without server-side verification.
- Tenant id read from request headers or path without authorization check.

## `Error Model Design`

Use when the change adds, removes, or alters error responses, exceptions thrown across boundaries, or the error envelope of an API.

This section covers the **API envelope and external taxonomy** side. For the **internal error-handling discipline** — failure vs defect vs fatal, retry classification by error class, boundary translation, process-exit posture, anti-patterns — read `error-handling-review.md`.

Ask:

- Are errors classified into stable buckets: validation / authentication / authorization / not-found / conflict / rate-limit / dependency / internal?
- Is "retryable vs terminal" explicit at the boundary, not only inside the consumer?
- Does the error envelope carry enough context for the caller to act (error code, correlation id, optional remediation), without leaking internals (stack traces, SQL fragments, file paths)?
- Are error codes part of the API contract (versioned, documented), or implementation accidents the caller will accidentally depend on?
- Do errors include enough dimensions for aggregation (error class) without high-cardinality fields (raw user input)?

Red flags:

- 500 for predictable validation failures.
- 200 with `{ "error": ... }` body — silent failure that defeats client-side `fetch` error handling.
- Internal exception messages exposed verbatim to clients.
- Retryable / terminal classification only present in the consumer, not the producer's contract.

## `State Machines`

Use when the change transitions an entity through a state field (`status`, `state`, `phase`).

Ask:

- Is the set of states enumerated and exhaustive?
- Are forbidden transitions enforced server-side, not assumed at the call site?
- Are terminal states unambiguous? Can a "completed" item become "pending" again accidentally?
- Are concurrent transitions guarded (optimistic locking, version column, conditional update)?
- Is there a recovery path defined for each state, including stuck states?
- Do logs and metrics include the from/to state for transitions?

Red flags:

- `status = "X"` written without checking the current state.
- States added in code without a migration or default for existing rows.
- Boolean flags used as a state machine (`is_active`, `is_processed`, `is_paid`) without a single source of truth.

## `Feature Flags and Kill Switches`

Use when the change introduces or removes a flag, kill switch, dynamic config, or canary rollout.

Ask:

- Is the risky path guarded by a flag the team can flip without a deploy?
- Is the default value safe for the current production baseline?
- What is the flag scope: global / per-tenant / per-user / per-route? Does the scope match the blast radius?
- Is there a sunset deadline or cleanup tracker for the flag?
- For experiment flags: is the variant assignment stable for a given user / tenant / session?
- Does the system fail safe (closed) if the flag service is unavailable?

Red flags:

- Boolean toggle hard-coded in env vars with no rollback path between deploys.
- "Temporary" flag with no removal plan that survives for years and accumulates dead branches.
- Flag default flips silently as part of a code change.
- Kill switch that requires a deploy to flip.

## `Configuration Safety`

Use when the change adds or alters configuration, environment variables, secrets, dynamic config, or runtime feature toggles.

Ask:

- Does the application fail fast at boot on missing or malformed config, or silently degrade?
- Are silent defaults that change behavior avoided in favor of explicit values?
- Are secrets loaded from a secret manager / mount, not committed config?
- Is hot-reload of config handled atomically, or can a partial reload leave the process in a mixed state?
- Is there a documented contract for env vars (name, type, required, default, blast radius)?
- Are config values logged at startup with secrets redacted?

Red flags:

- `process.env.X || "default"` where the default silently changes production behavior.
- Secret values logged at info level for "debugging".
- Config schema drift between local, dev, and prod (different keys, different defaults).
- Required env vars that the app starts without and fails later under load.

## `Cost and Blast Radius`

Use when the change adds traffic, fan-out, log volume, metric cardinality, or per-request work.

Ask:

- What scales with traffic — N+1 queries, fan-out HTTP calls, log lines per request, metric labels per request?
- If this fires 1M times per hour, what's the bill / DB load / cache fill / log ingest cost?
- Is there a noisy-neighbor cap (per-tenant, per-route, per-IP) so one client cannot exhaust shared budget?
- For new metric labels: is the cardinality bounded? Does any label include user input or unique ids?
- For new log statements: are they leveled correctly (debug vs info vs error) so volume is bounded?

Red flags:

- A new metric label that includes user id, request id, or any unbounded value.
- `for (const item of items) await fetchExternal(item)` without batching or concurrency control.
- Logging full request/response bodies at info level.
- New polling loop with no backoff under failure.

## Tests worth asking for

- Cross-tenant access attempt is rejected at the data layer, not only the controller.
- Forbidden state transitions return a stable error class.
- Feature flag off path and on path both have coverage.
- Boot fails on malformed required config.
- Per-tenant rate limit isolates noisy tenants.
