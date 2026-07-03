# API Contract Review Reference

Use this reference when the diff adds, removes, or changes HTTP endpoints,
OpenAPI specs, request/response schemas, pagination behavior, error envelopes,
versioning, deprecation, PATCH semantics, or long-running API workflows.

## Default posture

Treat the API contract as a product surface with stability obligations.
Review the contract separately from the runtime implementation.

Ask first:

1. What resource or workflow does this API model?
2. What existing clients will depend on this shape or behavior?
3. What would break if a caller cached, retried, paginated, or partially updated
   this interface incorrectly?

## The eight API invariants

### 1. Resource-oriented identity

Review:

- The API is modeled around resources and collections, not RPC verbs in paths.
- Resource identity is canonical and stable.
- Parent/child hierarchy is explicit where ownership matters.
- The same resource shape is returned consistently across standard methods.

Red flags:

- Endpoints like `/createOrder`, `/getUsers`, or `/deleteInvoice`.
- The `GET` response shape differs materially from create/update responses.
- IDs or names are ambiguous, case-sensitive without reason, or change format by
  endpoint.

### 2. Standard methods first

Review:

- `GET`, `POST`, `PATCH`, and `DELETE` are used with their normal semantics.
- Custom actions are used only when CRUD is the wrong shape.
- `PATCH` semantics are explicit: omitted vs cleared vs immutable fields.

Red flags:

- `POST` used for read-only fetches without a strong reason.
- "Action" endpoints that should really be modeled as resources.
- Partial updates with unclear null/omission behavior.

### 3. Collections are first-class

Review:

- List endpoints have pagination from day one.
- Filtering and ordering semantics are explicit and stable.
- Partial response or field-selection behavior is documented when supported.
- Cross-parent or federated reads surface partial reachability clearly.

Red flags:

- List endpoints with no cursor/token or limit behavior.
- Ad-hoc filtering parameters that grow without a documented contract.
- Page tokens that do not bind the rest of the request parameters.
- Cross-parent reads that silently omit unreachable scopes.

### 4. Mutation safety

Review:

- Mutating endpoints that callers may retry have a real idempotency boundary.
- Lost-update protection exists where stale writes matter.
- Dry-run or validate-only behavior exists when the validation surface is large.

Red flags:

- `POST` with side effects and no idempotency key or natural-key protection.
- Update/delete flows with no `ETag` or conditional-write mechanism where two
  actors can race.
- Retried writes that can duplicate money movement, provisioning, or emails.

For money, units, schema safety, or dual-write concerns, cross-reference
`references/data-integrity-review.md`.

### 5. Error contract

Review:

- Error responses are stable enough for callers to branch on.
- HTTP APIs use a structured envelope such as RFC 9457 Problem Details.
- Field validation errors are machine-readable, not only embedded in prose.
- Correlation identifiers are separate from idempotency keys.

Red flags:

- `{"error":"something failed"}` with no stable type or reason.
- Clients are expected to branch on `message` text.
- `request_id` is used for both tracing and idempotency.

For internal error-classification discipline, cross-reference
`references/error-handling-review.md`.

### 6. Versioning and lifecycle

Review:

- Breaking changes are explicit.
- Versioning strategy is consistent and visible.
- Deprecated endpoints surface a migration path and sunset behavior.

Red flags:

- Response or field removals with no version boundary.
- Silent behavior changes under an existing major version.
- Missing `Deprecation`, `Sunset`, or migration guidance for retired endpoints.

### 7. Async and long-running workflows

Review:

- Slow or quota-sensitive operations use an async request-reply pattern when
  appropriate.
- The API exposes durable operation status and terminal outcomes.
- Clients have a stable way to observe completion or failure.

Red flags:

- Requests hold open while batch work or orchestration runs for too long.
- Work continues after client timeout with no status resource.
- Accepted async work has no durable operation state.

### 8. Field-level discipline

Review:

- Required, output-only, and immutable fields are explicit and enforced.
- Server-owned fields are not silently writable by clients.
- Money and units are unambiguous.
- Timestamp format and timezone expectations are stable.

Red flags:

- Float money in request or response contracts.
- Field names hide units or timezones.
- Output-only fields accepted on create/update without a clear policy.
- Immutable fields can be patched accidentally.

## Questions worth asking in a review

- What is the canonical resource here?
- If a client retries this exact write after a timeout, what duplicates?
- If two clients update this resource concurrently, which one wins and how does
  the loser learn that?
- What happens when a caller paginates while new rows are inserted?
- Can a client branch on the error payload without parsing prose?
- If this endpoint is deprecated later, what lifecycle signals will clients see?

## Tests worth asking for

- Retried mutating request yields one durable side effect.
- Stale update/delete is rejected by the concurrency boundary.
- Pagination remains stable under concurrent inserts/deletes.
- Validation errors return the documented structured envelope.
- Deprecated endpoints emit the expected lifecycle headers.
- Async `202` flow persists operation state and terminal failure detail.

## Source profile

Use these defaults unless the repository has a clearly documented alternative:

- Google AIP resource-oriented design, standard methods, pagination, field
  masks, validate-only, idempotency, resource freshness, and errors.
- RFC 9457 Problem Details for HTTP error envelopes.
- RFC 7232 for `ETag` / conditional requests.
- RFC 7240 for `Prefer`.
- RFC 8594 for `Sunset`.
- RFC 9745 for `Deprecation`.
