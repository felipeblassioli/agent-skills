# Architecture And Setup

## Recommended Stack

Prefer `hono` + `hono/jsx` + `typed-htmx` for TypeScript-first server-rendered HTMX apps.

Why:
- JSX/TSX keeps HTML generation in TypeScript
- `typed-htmx` adds type-checking and completion for `hx-*` attributes
- Hono route handlers stay small and explicit

## Base Setup

Install:
- `hono`
- `typed-htmx` as a dev dependency
- `htmx.org` and serve it locally in production

Use a global JSX augmentation so Hono JSX accepts HTMX attributes.

## Default Layout Guidance

- Self-host `htmx.min.js`
- Prefer a shared `Layout` component
- Use `hx-boost="true"` only where navigation semantics are intentional
- Keep long-lived client state minimal; prefer server-rendered fragments

## Suggested Folder Shape

- `src/app.ts` for app bootstrap and route registration
- `src/routes/` for Hono route handlers
- `src/components/` for reusable page and fragment components
- `src/lib/` for database and domain helpers
- `src/global.d.ts` for `typed-htmx` augmentation
- `public/` for `htmx.min.js` and extension scripts

## Route Design Rules

- One route may serve both full-page and partial HTML
- Check `HX-Request` when full and partial rendering differ
- Return full pages for URLs that may be refreshed or directly opened
- Add `Vary: HX-Request` whenever cacheable output changes by request mode

## Default Mindset

Prefer:
- HTML fragment responses
- server-owned state
- route handlers that return renderable results directly

Avoid:
- JSON-first flows unless the user explicitly wants an API
- SPA-style client orchestration for simple CRUD and navigation
- external CDN dependency for HTMX in production
