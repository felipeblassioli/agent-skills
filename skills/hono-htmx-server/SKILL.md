---
name: hono-htmx-server
description: Build and review server-side HTMX applications with Hono using typed HTMX attributes, architecture-first route design, and production-safe server patterns. Use when creating a new Hono + HTMX app, choosing page and fragment boundaries, or implementing HTMX-driven forms, navigation, realtime flows, and partial page updates in TypeScript/Node.js.
---

# Hono HTMX Server

## Applicability Gate
- Use when: the user wants to design, build, modify, or review a server-side HTMX application with Hono, especially with Hono JSX/TSX, `typed-htmx`, fragment responses, direct-URL-safe navigation, form validation, OOB swaps, HX response headers, or realtime HTML updates.
- Do NOT use when: the task is primarily a React/Next.js SPA, a generic JSON API without HTMX, CI/deployment work, browser automation, or a non-Hono backend unless only making a brief comparison.

## Routing Table
| If you need to... | Route to... |
|---|---|
| Set up Hono JSX, `typed-htmx`, self-hosted HTMX, or default project structure | `references/architecture-and-setup.md` |
| Design a new Hono + HTMX application architecture before writing routes | `references/application-architecture.md` |
| Implement route and fragment behavior such as partial/full responses, forms, OOB swaps, HX headers, search, infinite scroll, or `hx-sync` | `references/programming-patterns.md` |
| Integrate widget initialization, HTMX lifecycle hooks, loading states, or custom request handling | `references/lifecycle-and-events.md` |
| Choose SSE vs WebSockets, add Alpine safely, or pick HTMX extensions | `references/realtime-and-extensions.md` |
| Check security defaults, CSP/CSRF, history/caching issues, or common failure modes | `references/security-and-pitfalls.md` |
| Look up core attributes, response headers, extensions, or lifecycle hooks quickly | `assets/quickref/htmx-reference.md` |

## Procedure
1. Confirm the task is truly a server-side HTMX flow on Hono, not a JSON-first SPA or plain API task.
2. If the user is starting a new feature or app, begin with `references/application-architecture.md` to decide shell boundaries, direct-URL-safe routes, fragment ownership, and state placement before writing handlers.
3. Prefer Hono JSX/TSX plus `typed-htmx` so `hx-*` attributes are type-checked in server-rendered markup.
4. Design routes around HTML responses first: return fragments for HTMX requests and full documents for direct navigation when needed, and send `Vary: HX-Request` when those differ.
5. Use `references/programming-patterns.md` for CRUD, validation, OOB updates, HX response headers, search, infinite scroll, and concurrent request control.
6. Use `references/lifecycle-and-events.md` and `references/realtime-and-extensions.md` when the feature needs JS interop, widgets, SSE, WebSockets, Alpine, or non-core HTMX extensions.
7. Review `references/security-and-pitfalls.md` before finalizing flows that use history, inline events, SSE, WebSockets, swapped user content, or multi-step server-side state.
8. Use `assets/quickref/htmx-reference.md` for compact lookup instead of loading every reference file.
9. Hand off to sibling skills when the main problem is testing, TypeScript quality, or deployment rather than Hono + HTMX behavior.

## Confirmation Policy
- Do not run destructive migrations or large framework rewrites without user confirmation.
- Do not introduce client-heavy state management when a server-rendered HTMX flow is sufficient unless the user explicitly asks for it.
- Do not add Alpine, WebSockets, or custom inline JS as a default. Start with plain HTMX and add richer client behavior only when the architecture path shows a real need.

## Related Skills
- `typescript-quality` for validation, error handling, logging, and client wrappers once the Hono + HTMX interaction model is settled.
- `tdd-classicist` for testing strategy after route, fragment, and request-boundary choices are clear.
- `gh-pr-creator` or `commit-hygiene` when the work moves from implementation into release or PR packaging.

## Verification Checklist
- [x] The skill is narrowly scoped to server-side HTMX apps with Hono.
- [x] Triggers are specific to Hono + HTMX authoring, review, and architecture design.
- [x] Anti-triggers exclude SPA, generic API, CI, and unrelated frontend tasks.
- [x] Routing links point directly to focused reference files and quick references.
