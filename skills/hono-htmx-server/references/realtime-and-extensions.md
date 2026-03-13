# Realtime And Extensions

Use this reference when plain request/response HTMX is not quite enough.

## Choose The Smallest Realtime Tool

| Need | Default choice |
|---|---|
| Append-only server updates | SSE |
| Bidirectional live interaction | WebSockets |
| Occasional freshness check | ordinary HTMX polling |
| Client-local UI state only | Alpine or small custom JS |

Start with ordinary HTMX requests. Add SSE, WebSockets, or Alpine only when the feature truly needs them.

## SSE

Prefer SSE for unidirectional streaming from server to browser:
- notifications
- progress streams
- append-only feeds

```html
<script src="/htmx-ext/sse.js"></script>
<div hx-ext="sse" sse-connect="/events">
  <div id="notifications" sse-swap="notification" hx-swap="beforeend"></div>
</div>
```

```tsx
app.get('/events', (c) => {
  return streamSSE(c, async (stream) => {
    await stream.writeSSE({
      event: 'notification',
      data: '<li>New item added</li>'
    })
  })
})
```

Use SSE when proxy-friendliness and simplicity matter more than duplex communication.

## WebSockets

Use WebSockets only when the browser must both send and receive live updates:
- chat
- collaborative editing
- low-latency interactive streams

```html
<script src="/htmx-ext/ws.js"></script>
<div hx-ext="ws" ws-connect="/chat-ws">
  <div id="messages"></div>
  <form ws-send>
    <input name="message" />
    <button type="submit">Send</button>
  </form>
</div>
```

```tsx
app.get('/chat-ws', upgradeWebSocket(() => ({
  onMessage: async (event, ws) => {
    const { message } = JSON.parse(event.data.toString())
    ws.send(renderToString(<ChatMessage text={message} />))
  }
})))
```

Do not mix `hx-ext="ws"` and ordinary `hx-post` updates that target the same container.

## Alpine And HTMX Boundaries

HTMX owns server communication. Alpine should only own local UI state such as:
- dropdown open/close state
- tabs
- transitions
- minor client-only toggles

If Alpine state must survive swaps:
- prefer smaller HTMX swap regions
- or use the `alpine-morph` extension with a morph swap strategy

```html
<script src="/htmx-ext/alpine-morph.js"></script>
<div hx-get="/component" hx-swap="morph" hx-ext="alpine-morph">
  <div x-data="{ count: 0 }">
    <button @click="count++">Count: <span x-text="count"></span></button>
  </div>
</div>
```

## Recommended Extensions

| Extension | Use When |
|---|---|
| `idiomorph` | Preserve focus or media state with morph-style swaps |
| `sse` | Server-Sent Events streaming |
| `ws` | WebSocket communication |
| `response-targets` | Route different HTTP statuses to different targets |
| `head-support` | Merge `<head>` changes during HTMX navigation |
| `alpine-morph` | Preserve Alpine state across swaps |
| `safe-nonce` | Keep inline scripts CSP-compatible when unavoidable |

## Extension Selection Rules

- Prefer no extension unless core HTMX is clearly insufficient.
- `response-targets` is often worth adding for validation and error routing.
- `idiomorph` is safer than full replacement when preserving DOM state matters.
- Treat community extensions as opt-in dependencies, not baseline defaults.

## See Also

- `application-architecture.md`
- `programming-patterns.md`
- `lifecycle-and-events.md`
- `security-and-pitfalls.md`
