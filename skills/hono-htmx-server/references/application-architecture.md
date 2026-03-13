# Application Architecture

Use this reference before building a new Hono + HTMX app or a major feature.

## Architectural Defaults

Start from these defaults:
- one HTML shell plus many server-rendered fragments
- route handlers own request parsing and response selection
- domain and persistence logic live outside the route file
- URLs remain directly visitable even when navigation is HTMX-boosted
- client state stays minimal unless pure UI interaction justifies Alpine or custom JS

## Design The Shell First

Choose the stable page shell before modeling endpoints:
- `Layout` owns `<html>`, `<head>`, scripts, and long-lived navigation
- page components own the main content area for full requests
- fragment components own replaceable regions such as lists, forms, detail panes, badges, and toasts

Good shell boundaries:
- nav, global toast container, and page wrapper stay stable
- list rows, forms, tabs, and detail panels are fragment-sized

Bad shell boundaries:
- swapping the entire document for a small CRUD action
- making a fragment depend on parent-only state it cannot render alone

## Route And Component Split

Use route files to orchestrate and component files to render:

- `src/routes/*.tsx`: parse body/query params, call domain logic, choose full vs partial response, set HX headers
- `src/components/*.tsx`: page shells, reusable fragments, rows, forms, banners, and OOB payload fragments
- `src/lib/*.ts`: DB access, auth, validation helpers, and domain workflows

Keep reusable fragment components renderable in isolation. If a fragment can be swapped into the DOM, it should not secretly depend on page-only wrapper markup.

## Direct-URL-Safe Navigation

Whenever using `hx-boost`, `hx-push-url`, or `HX-Push-Url`, every pushed URL must render a full page on direct load.

Design rule:
- if the browser URL can change, that route must support non-HTMX navigation

Default pattern:
- `GET /items` returns a full page for direct access and a fragment for HTMX refreshes
- `GET /items/:id` returns a detail page for direct access and a fragment for in-page navigation

## State Placement

Prefer server-owned state for:
- CRUD data
- validation errors
- wizard progress persisted in session or DB
- notification content

Use Alpine or custom JS only for:
- open/closed UI state
- tabs, dropdowns, and local transitions
- minor client-only interactions that do not justify a round-trip

If the state must survive full fragment replacement, either preserve the DOM region carefully or keep the state on the server.

## Pattern Selection Matrix

| Need | Default pattern |
|---|---|
| CRUD form with inline errors | POST returning a rerendered form or OOB updates |
| Search/filter UI | `hx-get` + debounced `hx-trigger` |
| Paginated feeds | sentinel + `revealed` infinite scroll |
| Detail panes/modals | fragment GET with explicit target |
| Cross-region update | OOB swaps plus optional `HX-Trigger` |
| One-way realtime | SSE |
| Two-way interactive stream | WebSockets |

## When To Add Alpine Or Realtime

Add Alpine only when the problem is mostly client-local interaction. If the UI is driven by server data and HTML fragments, plain HTMX is usually enough.

Add SSE when:
- the server pushes append-only updates
- proxy-friendliness matters
- the browser does not need to send frequent bidirectional messages

Add WebSockets only when:
- users must send and receive live messages
- lower-latency duplex communication matters
- the target DOM region is isolated from ordinary `hx-post`/polling behavior

## Architecture Review Questions

Before implementation, answer these:
- Which routes need both full-page and fragment responses?
- Which regions are stable shell vs replaceable fragments?
- Which URLs must support refresh and direct navigation?
- Which updates need OOB swaps vs a single target?
- Which parts truly need client-side state?
- Which features require lifecycle hooks, SSE, or WebSockets?

## See Also

- `architecture-and-setup.md`
- `programming-patterns.md`
- `realtime-and-extensions.md`
- `security-and-pitfalls.md`
