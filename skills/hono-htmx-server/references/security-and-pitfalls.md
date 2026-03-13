# Security And Pitfalls

## Security Defaults

Follow these rules:
1. only issue HTMX requests to routes you control
2. use auto-escaping rendering paths
3. never inject untrusted data into scripts, style blocks, attribute names, or tag names
4. use secure auth cookies with `Secure`, `HttpOnly`, and `SameSite=Lax`

These are the non-negotiable defaults. The fastest HTMX app is still unsafe if swapped HTML carries untrusted content or routes out to arbitrary origins.

## HTMX Hardening

Prefer a hardened HTMX config:
- `selfRequestsOnly: true`
- `allowEval: false` when possible
- `allowScriptTags: false`
- `historyCacheSize: 0` when local history snapshots are undesirable

```html
<meta name="htmx-config" content='{
  "selfRequestsOnly": true,
  "allowEval": false,
  "allowScriptTags": false,
  "historyCacheSize": 0
}' />
```

## CSRF

Treat `SameSite=Lax` as a baseline, not the whole story.
When needed, attach a CSRF token through `htmx:configRequest`:

```javascript
document.body.addEventListener('htmx:configRequest', (evt) => {
  evt.detail.headers['X-CSRF-Token'] = getTokenFromMeta()
})
```

## CSP

Be careful with `hx-on` because inline evaluation conflicts with strict CSP.

Prefer:
- disabling eval when `hx-on` is unnecessary
- nonce-based CSP when inline behavior is required
- avoiding inline scripting where possible

## Common Pitfalls

### History And Direct Access
Every URL pushed into history must render a valid full page on direct visit or refresh.

Use this as a hard review rule:
- if `hx-push-url` or `HX-Push-Url` changes the browser URL, that route must support direct navigation

### 4xx And 5xx Not Swapped By Default
Configure HTMX response handling or response-target extensions if validation or error fragments must be visible.

Typical options:
- configure `responseHandling` in `htmx-config`
- use the `response-targets` extension when different status codes should land in different regions

### Race Conditions
Use `hx-sync` for field validation plus submit flows.

### Alpine State Loss
Full swaps can destroy Alpine state. Keep boundaries clean or use the correct extension if Alpine is intentionally part of the design.

### OOB Fragment Reuse
Reusable partials can misbehave when also used as OOB fragments. Isolate OOB-capable fragments when needed.

### Table OOB Swaps
Wrap standalone table rows or cells in `<template>`.

### Partial Response Caching
Without `Vary: HX-Request`, direct navigation can receive cached fragments.

### Multi-Step Flows
Wizards and drafts require explicit server-side state design, cleanup rules, and multi-tab behavior choices. Server-side HTMX is not a free replacement for SPA wizards; design the persistence and cleanup behavior intentionally.

### WebSocket And HTMX Collision
Keep WebSocket-connected DOM regions separate from normal `hx-post` or polling regions.

### Production Asset Strategy
Self-host HTMX instead of relying on a CDN in production.

## Review Checklist

Before finalizing, verify:
- cache behavior is correct
- pushed URLs work directly
- swapped error states are visible
- CSP and CSRF choices are explicit
- untrusted HTML is escaped
- container boundaries are safe for OOB, SSE, and WebSockets
- extension choices are justified rather than added by default

## See Also

- `application-architecture.md`
- `programming-patterns.md`
- `realtime-and-extensions.md`
- `../assets/quickref/htmx-reference.md`
