# HTMX Quick Reference

Use this file for lookup, not for first-principles design.

## Core Request Attributes

| Attribute | Purpose | Example |
|---|---|---|
| `hx-get` | HTTP GET to URL | `hx-get="/items"` |
| `hx-post` | HTTP POST | `hx-post="/items"` |
| `hx-put` | HTTP PUT | `hx-put="/items/1"` |
| `hx-patch` | HTTP PATCH | `hx-patch="/items/1"` |
| `hx-delete` | HTTP DELETE | `hx-delete="/items/1"` |

## Swap And Target Attributes

| Attribute | Purpose |
|---|---|
| `hx-target` | Where the response lands |
| `hx-swap` | How the response is inserted |
| `hx-select` | Extract a selector from the response before swapping |
| `hx-select-oob` | Pick OOB selectors from the response |
| `hx-swap-oob` | Mark response content for OOB swap |
| `hx-preserve` | Keep an element across swaps |

## Trigger And UX Attributes

| Attribute | Purpose |
|---|---|
| `hx-trigger` | Event plus modifiers such as `delay:500ms`, `throttle:1s`, `once`, or `revealed` |
| `hx-indicator` | Loading indicator selector |
| `hx-sync` | Coordinate concurrent requests |
| `hx-disabled-elt` | Disable elements during a request |
| `hx-confirm` | Confirm before issuing a request |
| `hx-boost` | AJAX navigation for links and forms in a subtree |
| `hx-push-url` | Push a URL into history |
| `hx-replace-url` | Replace current URL without pushing history |
| `hx-request` | Configure timeout, credentials, or header behavior |
| `hx-on::<event>` | Inline lifecycle handler; avoid when CSP should stay strict |

## Response Headers

| Header | Effect |
|---|---|
| `HX-Trigger` | Dispatch custom events on the client |
| `HX-Redirect` | Client-side redirect |
| `HX-Push-Url` | Push browser history |
| `HX-Replace-Url` | Replace current URL |
| `HX-Refresh` | Force full page reload |
| `HX-Retarget` | Override target selector |
| `HX-Reswap` | Override swap strategy |

## Extensions

| Extension | Use When |
|---|---|
| `idiomorph` | Morph swaps should preserve focus or media state |
| `sse` | One-way server-to-client streaming |
| `ws` | Bidirectional live communication |
| `response-targets` | Different HTTP statuses should land in different targets |
| `head-support` | HTMX navigation must merge `<head>` changes |
| `alpine-morph` | Alpine state must survive swaps |
| `safe-nonce` | Inline scripts are unavoidable under strict CSP |

## Lifecycle Hooks

| Hook | Typical Use |
|---|---|
| `htmx:beforeRequest` | cancel or adjust request |
| `htmx:beforeSend` | last moment before XHR leaves |
| `htmx:afterRequest` | metrics or cleanup after request |
| `htmx:afterSwap` | immediate post-swap behavior |
| `htmx:afterSettle` | initialize widgets once DOM is stable |
| `htmx:configRequest` | add headers such as CSRF tokens |
| `htmx:confirm` | async confirmation flow |

## See Also

- `../../references/programming-patterns.md`
- `../../references/lifecycle-and-events.md`
- `../../references/realtime-and-extensions.md`
