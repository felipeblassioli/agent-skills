# Lifecycle And Events

Use this file when HTMX behavior needs custom JS interop or post-swap initialization.

## Request Lifecycle

HTMX follows a predictable lifecycle:

```text
1. Element triggered
2. htmx:beforeRequest
3. htmx:beforeSend
4. Add htmx-request class
5. XHR in flight
6. htmx:afterRequest
7. Add htmx-swapping class
8. Optional swap delay
9. DOM swap occurs
10. htmx:afterSwap
11. Optional settle delay
12. htmx:afterSettle
13. Remove swapping/settling classes
```

Use `htmx:beforeRequest` to block or modify a request, and `htmx:afterSettle` to initialize behavior once the new DOM is stable.

## Lifecycle CSS Classes

| Class | Present During |
|---|---|
| `htmx-request` | Active request in flight |
| `htmx-swapping` | Swap phase |
| `htmx-settling` | Settle delay |
| `htmx-added` | Newly inserted content |

These cover most loading and transition-state styling without a custom extension.

## Event Hook Patterns

### Toggle a loading spinner

```javascript
document.addEventListener('htmx:beforeRequest', () => {
  document.getElementById('spinner')?.classList.remove('hidden')
})

document.addEventListener('htmx:afterSettle', () => {
  document.getElementById('spinner')?.classList.add('hidden')
})
```

### Override error content before swap

```javascript
document.body.addEventListener('htmx:beforeOnLoad', (evt) => {
  if (evt.detail.xhr.status >= 500) {
    evt.detail.shouldSwap = true
    evt.detail.serverResponse = '<div class="error">Server error</div>'
  }
})
```

### Initialize widgets after HTMX updates

```javascript
htmx.onLoad((target) => {
  target.querySelectorAll('.my-widget').forEach(initWidget)
})
```

### Inject CSRF headers

```javascript
document.body.addEventListener('htmx:configRequest', (evt) => {
  evt.detail.headers['X-CSRF-Token'] = getTokenFromMeta()
})
```

### Async confirmation flows

```javascript
document.body.addEventListener('htmx:confirm', (evt) => {
  if (evt.target.matches('[data-confirm]')) {
    evt.preventDefault()
    myModal.confirm(evt.target.dataset.confirm).then((ok) => {
      if (ok) evt.detail.issueRequest()
    })
  }
})
```

## Integration Guidance

Use lifecycle hooks when:
- a third-party widget must be initialized after fragment replacement
- a request needs auth, tracing, or CSRF headers added centrally
- swap timing must coordinate with transitions or loading UI

Avoid lifecycle JS for behavior the server can already model with HTML fragments, OOB swaps, or HX response headers.

## See Also

- `programming-patterns.md`
- `realtime-and-extensions.md`
- `security-and-pitfalls.md`
- `../assets/quickref/htmx-reference.md`
