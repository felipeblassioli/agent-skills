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

Use a global JSX augmentation so Hono JSX accepts HTMX attributes:

```typescript
// src/global.d.ts
import 'typed-htmx'

declare module 'hono/jsx' {
  namespace JSX {
    interface HTMLAttributes extends HtmxAttributes {}
  }
}
```

Bootstrap with a shared HTML shell:

```tsx
import { Hono } from 'hono'

const app = new Hono()

const Layout = ({ children }: { children: any }) => (
  <html>
    <head>
      <script src="/static/htmx.min.js" />
    </head>
    <body hx-boost="true">{children}</body>
  </html>
)

app.get('/', (c) => c.html(<Layout><h1>Hello HTMX</h1></Layout>))
```

## Default Layout Guidance

- Self-host `htmx.min.js`
- Prefer a shared `Layout` component
- Use `hx-boost="true"` only where navigation semantics are intentional and every navigable URL can render a full page
- Keep long-lived client state minimal; prefer server-rendered fragments
- Load extensions deliberately from `public/htmx-ext/` rather than CDN URLs

## Suggested Folder Shape

```text
src/
  app.ts              # Hono app, route registration
  routes/
    items.tsx         # Route handlers plus route-local partials
    auth.tsx
  components/
    Layout.tsx        # Shared HTML shell
    ItemList.tsx      # Page and fragment components
    ItemForm.tsx
    Toast.tsx
  lib/
    db.ts
    auth.ts
  global.d.ts         # typed-htmx augmentation
public/
  htmx.min.js
  htmx-ext/
```

## Route Design Rules

- One route may serve both full-page and partial HTML
- Check `HX-Request` when full and partial rendering differ
- Return full pages for URLs that may be refreshed or directly opened
- Add `Vary: HX-Request` whenever cacheable output changes by request mode
- Keep domain logic in `src/lib/` or service modules; route handlers should mostly orchestrate parsing, calling domain code, and rendering fragments

## Route Handler Baseline

Use one consistent route pattern before introducing special cases:

```tsx
export const itemRoutes = new Hono()

itemRoutes.get('/', async (c) => {
  const items = await db.items.findAll()
  const isHtmx = c.req.header('HX-Request') === 'true'
  const content = <ItemList items={items} />

  return c.html(
    isHtmx ? content : <Layout title="Items">{content}</Layout>,
    200,
    { 'Vary': 'HX-Request' }
  )
})
```

## Loading States

HTMX's built-in classes cover most loading-state needs:

```css
.htmx-indicator { opacity: 0; transition: opacity 200ms; }
.htmx-request .htmx-indicator { opacity: 1; }
.htmx-request.htmx-indicator { opacity: 1; }

form.htmx-request button[type="submit"] {
  pointer-events: none;
  opacity: 0.7;
}
```

## Default Mindset

Prefer:
- HTML fragment responses
- server-owned state
- route handlers that return renderable results directly
- URLs that work for both HTMX navigation and direct page loads

Avoid:
- JSON-first flows unless the user explicitly wants an API
- SPA-style client orchestration for simple CRUD and navigation
- external CDN dependency for HTMX in production
- mixing too many fragment responsibilities into one response when a simple target plus an occasional OOB update would do

## See Also

- `application-architecture.md`
- `programming-patterns.md`
- `security-and-pitfalls.md`
