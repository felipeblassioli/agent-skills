# Data Integrity Review Reference

Use this reference when the change touches durable state, side effects across boundaries, caches, monetary values, or anything affected by clocks. These lenses cut across HTTP services, queue consumers, scheduled work, and workflows.

## Default posture

If a single logical operation crosses two systems (DB + queue, DB + HTTP, cache + DB, two databases), assume the operation is **not atomic** unless the code proves it is.

If the operation reads a value derived from time, money, or replicated state, assume the value is **wrong at boundaries** unless the code proves otherwise.

## `Dual-Write` / `Outbox` / `Inbox`

Use when one logical operation writes to a database AND emits an external effect (publish to Pub/Sub, enqueue Cloud Task, call third-party HTTP, write to BigQuery, send email).

Ask:

- Are both writes in the same atomic unit, or can one succeed and the other fail?
- If they are not atomic, is there an outbox table polled by a separate publisher?
- If a message arrives, is there an inbox / dedupe record committed in the same transaction as the side effect?
- Does the producer return success only after the durable record exists?
- If the publisher crashes after the DB commit but before the publish, what re-drives the publish?

Red flags:

- `await db.save(); await pubsub.publish(...)` with no outbox.
- HTTP webhook fan-out inside an HTTP request handler with no retry queue behind it.
- Best-effort emit on a critical side effect ("we'll log if it fails").
- "Eventually consistent" used as a synonym for "we did not think about it".

## `Cache Correctness`

Use when the change reads from or writes to a cache (Redis, Memcached, in-process LRU, CDN, HTTP cache headers, Cloud Run instance memory).

Ask:

- What invalidates the cache? Is invalidation atomic with the write that made the cache stale?
- Does the cache key include every dimension that changes the answer (tenant, locale, version, auth scope, feature flag state, role)?
- What is the TTL, and does it have jitter to avoid stampede on expiry?
- What happens on cache miss under load — is there single-flight / request coalescing, or does every concurrent miss hit the origin?
- Is negative caching used, and can it pin a transient error as a cached "no" for too long?
- Are auth-sensitive responses cached at a layer (CDN, gateway) that does not see the auth context?

Red flags:

- Cache keys missing tenant, locale, role, or feature-flag dimension.
- Identical TTLs on hot keys causing thundering herd on expiry.
- "Set after write" without a transactional or compare-and-set guarantee.
- Caching personalized or auth-gated content at the edge without `Vary` or per-user keying.
- Cache populated from a fallback that includes error states.

## `Read-After-Write` and replication lag

Use when the change reads back state immediately after writing, or reads from a replica.

Ask:

- Does the read happen on the same node / connection / replica as the write?
- If a read replica is used, does the code tolerate replication lag?
- Does the UI or caller expect "I just wrote it" semantics? If so, is read-after-write enforced?
- For event-driven flows: can a downstream consumer read the entity before the producer's transaction commits?

## `Money, Quantities, Units`

Use when the change touches currency, prices, fees, rates, quantities, durations, or any numeric value with a real-world unit.

Ask:

- Are monetary amounts integer minor units (cents) or arbitrary-precision decimals — never IEEE-754 floats?
- Is currency code stored alongside the amount? What enforces consistency on aggregation?
- Is rounding direction explicit (banker's, half-up, truncate) and consistent across read and write paths?
- Do duration fields name their unit (`timeoutMs`, `retentionDays`)?
- Are quantities and rates protected against negative or zero where invalid?
- For multi-currency: is conversion done at a single boundary, with an explicit rate snapshot?

Red flags:

- `number` for money in TypeScript / JS, `float` / `double` for money in any language.
- Aggregations summing values across rows of mixed currency.
- `setTimeout(fn, value)` where `value`'s unit is unclear.
- Comparison of money values without a defined precision contract.

## `Time and Clocks`

Use when the change reads the current time, schedules work, or compares timestamps.

Ask:

- Is the time source injected so it can be controlled in tests?
- Is wall-clock time used where a monotonic clock is needed (measuring elapsed durations, timeouts, retries)?
- Are timestamps stored in UTC with explicit timezone awareness at boundaries?
- What is "today"? In which timezone? What happens to a CronJob run during DST transitions?
- Is time-window logic inclusive/exclusive on the right edges (`>=` vs `>`)? What does midnight mean?
- Are leap seconds, leap days, or month-end rollovers a risk?

Red flags:

- `Date.now()` used to measure elapsed time across a context that may suspend (cold start, sleep).
- "Yesterday" computed by subtracting 24h from now (breaks at DST).
- Cron schedules in local time when the cluster runs in UTC.
- Token expiry compared with mismatched timezones.

## `Schema and Migration Safety` (additive depth)

This complements the migration section in `review-protocol.md`. Use when the change adds, removes, or alters durable schema.

Ask:

- Is the migration backward-compatible with the currently deployed application during rollout overlap?
- Can the application work with both old and new schema for the duration of the rollout window?
- For destructive changes (drop column, drop table, rename), is there a multi-phase plan (deprecate → stop reading → stop writing → drop)?
- Are long-running migrations (large indexes, big backfills) safe under production load? Is `CREATE INDEX CONCURRENTLY` or equivalent used?
- Is rollback explicit? Forward-fix-only is acceptable but must be stated.

Red flags:

- Single-PR drop-column migrations on tables the application still writes.
- `ALTER TABLE` on hot tables without lock-time analysis.
- Schema changes that assume zero-downtime without staging the rollout.

## Tests worth asking for

- Crash between two writes leaves a recoverable state.
- Cache invalidation under concurrent writers does not pin stale data.
- Read-after-write returns the just-written value (or explicitly tolerates lag).
- Monetary aggregation across many rows produces exact results.
- DST transition does not double-run or skip a scheduled job.
- Migration applies cleanly from previous schema and rolls back cleanly.
