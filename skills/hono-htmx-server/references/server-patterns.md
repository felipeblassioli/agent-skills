# Server Patterns

## Partial Vs Full Page Response

Use `HX-Request` to decide whether to return:
- a fragment for HTMX
- a full document for direct navigation

Always send `Vary: HX-Request` when behavior differs.

## Forms And Validation

Prefer re-rendering HTML directly instead of Post/Redirect/Get.

Pattern:
- parse request body
- validate on the server
- return a fragment with inline errors on failure
- return updated fragments on success

If using `422`, ensure HTMX is configured to swap it.

## Out-Of-Band Updates

Use OOB swaps when one response must update:
- the primary target
- plus independent UI regions like counters, toasts, or status banners

Be careful with table fragments and nested reusable fragments.

## Response Headers

Use HX response headers when the server should direct the client:
- `HX-Redirect`
- `HX-Trigger`
- `HX-Push-Url`
- `HX-Replace-Url`
- `HX-Retarget`
- `HX-Reswap`

Prefer these headers over ad hoc client-side JavaScript when possible.

## Search And Progressive Loading

Common patterns:
- debounced search with `hx-trigger="keyup changed delay:500ms"`
- infinite scroll with `revealed`
- loading indicators via `hx-indicator`
- disabled submit elements during active requests

## Request Synchronization

Use `hx-sync` to prevent validation and form-submit races.

Default example:
- field validation on `blur`
- `hx-sync="closest form:abort"`

## SSE

Prefer SSE for one-way server-to-client updates:
- notifications
- progress streams
- append-only event feeds

Use HTMX SSE extension and swap named events into target regions.

## WebSockets

Use WebSockets only for true bidirectional interaction:
- chat
- collaborative updates
- low-latency server echo

Do not mix WebSocket-driven swaps and ordinary `hx-post` updates in the same target container.

## Review Heuristics

During review, check that:
- routes return HTML, not unnecessary JSON
- full-page fallback exists for pushed URLs
- OOB swaps only update stable targets
- sync and response handling cover concurrent or error cases
