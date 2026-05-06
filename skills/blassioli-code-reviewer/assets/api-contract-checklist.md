# API Contract Checklist

- [ ] Resources and collections are explicit; no verb-heavy paths by default.
- [ ] Standard methods are used intentionally; custom actions are justified.
- [ ] Resource identity is canonical and stable across endpoints.
- [ ] List endpoints define pagination, limits, and token/cursor behavior.
- [ ] Filtering and ordering semantics are explicit and stable.
- [ ] Mutating endpoints that may be retried have an idempotency boundary.
- [ ] Update/delete flows use optimistic concurrency where lost updates matter.
- [ ] Long-running work uses an async `202 Accepted` plus status pattern when appropriate.
- [ ] Errors use a structured envelope with machine-readable identifiers.
- [ ] Correlation identifiers are separate from idempotency identifiers.
- [ ] Breaking changes are versioned explicitly.
- [ ] Deprecated endpoints include lifecycle signals and a migration path.
- [ ] Required, output-only, and immutable fields are explicit and enforced.
- [ ] Money, units, and timestamps are unambiguous in the contract.
