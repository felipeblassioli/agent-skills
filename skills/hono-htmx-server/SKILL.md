---
name: hono-htmx-server
description: Build and review server-side HTMX applications with Hono using HTML fragment responses, typed HTMX attributes, and production-safe server patterns. Use when creating or modifying Hono routes, HTMX-driven forms, partial page updates, or server-rendered interactive flows in TypeScript/Node.js.
---

# Hono HTMX Server

## Applicability Gate
- Use when: the user wants to build, modify, or review a server-side HTMX application with Hono, especially with Hono JSX/TSX, `typed-htmx`, fragment responses, form validation, OOB swaps, or HX response headers.
- Do NOT use when: the task is primarily a React/Next.js SPA, a generic JSON API without HTMX, CI/deployment work, browser automation, or a non-Hono backend unless only making a brief comparison.

## Routing Table
| If you need to... | Route to... |
|---|---|
| Set up Hono JSX, `typed-htmx`, self-hosted HTMX, or folder layout | `references/architecture-and-setup.md` |
| Implement partial/full responses, forms, OOB swaps, HX headers, search, infinite scroll, sync, SSE, or WebSockets | `references/server-patterns.md` |
| Harden security, handle CSP/CSRF, avoid cache/history bugs, or review common HTMX pitfalls | `references/security-and-pitfalls.md` |

## Procedure
1. Confirm the task is truly a server-side HTMX flow on Hono, not a JSON-first SPA or plain API task.
2. Prefer Hono JSX/TSX plus `typed-htmx` so `hx-*` attributes are type-checked in server-rendered markup.
3. Design routes around HTML responses first: return fragments for HTMX requests and full documents for direct navigation when needed.
4. For pages that behave differently for HTMX vs direct requests, check `HX-Request` and send `Vary: HX-Request`.
5. Use the server patterns reference for forms, validation, OOB updates, HX response headers, and concurrent request control.
6. Review the security and pitfalls reference before finalizing flows that use history, inline events, SSE, WebSockets, or swapped user content.
7. Hand off to sibling skills when the main problem is testing, TypeScript quality, or deployment rather than Hono + HTMX behavior.

## Confirmation Policy
- Do not run destructive migrations or large framework rewrites without user confirmation.
- Do not introduce client-heavy state management when a server-rendered HTMX flow is sufficient unless the user explicitly asks for it.

## Verification Checklist
- [x] The skill is narrowly scoped to server-side HTMX apps with Hono.
- [x] Triggers are specific to Hono + HTMX authoring and review.
- [x] Anti-triggers exclude SPA, generic API, CI, and unrelated frontend tasks.
- [x] Routing links point to focused reference files.
