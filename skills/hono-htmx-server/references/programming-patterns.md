# Programming Patterns

Use this file when implementing concrete Hono + HTMX behavior.

## Partial Vs Full Page Response

Check `HX-Request` and return either:
- a fragment for HTMX requests
- a full page for direct browser navigation

```tsx
app.get('/dashboard', (c) => {
  const isHtmx = c.req.header('HX-Request') === 'true'
  const content = <Dashboard />

  return c.html(
    isHtmx ? content : <Layout>{content}</Layout>,
    200,
    { 'Vary': 'HX-Request' }
  )
})
```

Use this whenever a route can be reached both by HTMX navigation and normal refresh or direct load.

## CRUD With Form Validation

Prefer rerendering HTML instead of Post/Redirect/Get:

```tsx
app.post('/items', async (c) => {
  const body = await c.req.parseBody()
  const errors = validate(body)

  if (errors.length > 0) {
    return c.html(<ItemForm values={body} errors={errors} />, 422)
  }

  const item = await db.items.create(body)
  return c.html(
    <>
      <ItemRow item={item} hx-swap-oob="beforeend:#item-list" />
      <ItemForm />
    </>
  )
})
```

If validation errors return `422`, ensure HTMX is configured to swap it:

```html
<meta name="htmx-config" content='{
  "responseHandling": [
    {"code":"204", "swap": false},
    {"code":"[^23]..", "swap": true},
    {"code":"422", "swap": true},
    {"code":"[^45]..", "swap": false, "error": true},
    {"code":"...", "swap": true}
  ]
}' />
```

## Out-Of-Band Swaps

Use OOB swaps when one response must update the main target plus independent regions such as badges, lists, or toasts:

```tsx
app.post('/cart/add', async (c) => {
  const cart = await addToCart(...)

  return c.html(
    <>
      <CartItem item={newItem} />
      <span id="cart-count" hx-swap-oob="true">{cart.total}</span>
      <div id="notifications" hx-swap-oob="afterbegin">
        <Toast message="Added to cart!" />
      </div>
    </>
  )
})
```

Important caveat:
- wrap standalone table rows or cells in `<template>` for OOB swaps
- isolate fragments that are both reusable partials and OOB payloads

## HX Response Headers

Prefer HTMX response headers over ad hoc client scripting when the server needs to steer the client:

```typescript
res.setHeader('HX-Redirect', '/dashboard')
res.status(200).send('')

res.setHeader('HX-Trigger', JSON.stringify({
  closeModal: true,
  showToast: 'Saved!'
}))
res.status(200).send(updatedFragment)

res.setHeader('HX-Push-Url', '/items/42')
res.status(200).send(detailFragment)
```

Most useful headers:
- `HX-Trigger`
- `HX-Redirect`
- `HX-Push-Url`
- `HX-Replace-Url`
- `HX-Retarget`
- `HX-Reswap`
- `HX-Refresh`

## Active Search With Debounce

```html
<input
  type="text"
  name="q"
  hx-get="/search"
  hx-trigger="keyup changed delay:500ms"
  hx-target="#search-results"
  hx-indicator="#search-spinner"
  placeholder="Search..."
/>
<span id="search-spinner" class="htmx-indicator">Loading...</span>
<div id="search-results"></div>
```

Use `changed` to avoid duplicate requests and `delay:500ms` to avoid one request per keystroke.

## Infinite Scroll

```html
<div id="posts">
  <div
    hx-get="/posts?page=2"
    hx-trigger="revealed"
    hx-swap="outerHTML"
  >
    Loading more...
  </div>
</div>
```

Use a sentinel element that replaces itself with the next page plus a new sentinel.

## Request Synchronization

Avoid validation-vs-submit races with `hx-sync`:

```html
<form hx-post="/submit">
  <input
    name="email"
    hx-post="/validate/email"
    hx-trigger="blur"
    hx-target="next .error"
    hx-sync="closest form:abort"
  />
  <span class="error"></span>
  <button type="submit">Submit</button>
</form>
```

`hx-sync="closest form:abort"` cancels field validation when the form begins submitting.

## Default Review Heuristics

During implementation or review, check that:
- routes return HTML unless JSON is explicitly needed
- URLs changed by history APIs also work as direct loads
- OOB swaps target stable IDs or containers
- validation and error handling are visible in the DOM
- concurrent requests are synchronized deliberately

## See Also

- `application-architecture.md`
- `lifecycle-and-events.md`
- `realtime-and-extensions.md`
- `security-and-pitfalls.md`
