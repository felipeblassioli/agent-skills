# Security And Pitfalls

## Security Defaults

Follow these rules:
- only issue HTMX requests to routes you control
- use auto-escaping rendering paths
- never inject untrusted data into scripts, style blocks, attribute names, or tag names
- use secure auth cookies with `Secure`, `HttpOnly`, and `SameSite=Lax`

## HTMX Hardening

Prefer a hardened HTMX config:
- `selfRequestsOnly: true`
- `allowEval: false` when possible
- `allowScriptTags: false`
- `historyCacheSize: 0` when local history snapshots are undesirable

## CSRF

Treat `SameSite=Lax` as a baseline, not the whole story.
When needed, attach a CSRF token through `htmx:configRequest`.

## CSP

Be careful with `hx-on` because inline evaluation conflicts with strict CSP.

Prefer:
- disabling eval when `hx-on` is unnecessary
- nonce-based CSP when inline behavior is required
- avoiding inline scripting where possible

## Common Pitfalls

### History And Direct Access
Every URL pushed into history must render a valid full page on direct visit or refresh.

### 4xx And 5xx Not Swapped By Default
Configure HTMX response handling or response-target extensions if validation or error fragments must be visible.

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
Wizards and drafts require explicit server-side state design, cleanup rules, and multi-tab behavior choices.

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
