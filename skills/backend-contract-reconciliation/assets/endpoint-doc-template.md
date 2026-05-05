---
title: '{VERB} {/path/to/endpoint}'
status: {draft|review|final}
date: {YYYY-MM-DD}
owner: {Team or Owner}
---
# {VERB} {/path/to/endpoint}

## 1 · Path & Verb
- **Verb:** `{VERB}`
- **Path:** `{/path/to/endpoint}`

## 2 · Auth / Headers
State the authentication middleware or required headers protecting this endpoint.

| Header | Description | Source |
| :--- | :--- | :--- |
| `Authorization` | `Bearer <token>` | `AuthenticationHandler` |

## 3 · Request Contract
List path parameters, query parameters, and the request body schema.

- **Path Parameters:**
  - `paramId` (type, required/optional) - description
- **Query Parameters:**
  - `field` (type, required/optional) - description
- **Body:**
  - `options` (object, optional) - description
    - `nestedField` (boolean, optional, default: `false`) - description

## 4 · Success Response
State the success status code and provide an example of the payload.

A `200 OK` response is returned with the final object.

```json
{
  "success": true,
  "data": {
    "id": 123
  }
}
```

## 5 · Error Responses
List the HTTP error codes, internal error codes, and messages returned by the endpoint.

| HTTP | `error.code` | `message` |
| :--- | :--- | :--- |
| 404  | `RESOURCE_NOT_FOUND` | Returned when the resource does not exist. |
| 409  | `STATE_CONFLICT` | Returned when the operation conflicts with current state. |
| 500  | (unhandled) | Message from the thrown `Error` object. |

## 6 · Domain Logic Summary
Describe the execution flow, validations, state mutations, and side effects.
- **Pre-route / Middleware:** Any logic that runs before the main controller.
- **Orchestration:** How the service aggregates data or runs rules.
- **Persistence:** Database mutations (e.g., `UPDATE transactions SET ...`).
- **Side Effects:** Notifications, events published, or metrics emitted.

## 7 · Current Implementation Paths
List the specific execution path (Router → Controller → Service → Repository).

- `application/routes/resource.route.js`
  → `application/controllers/resource.controller.js`
  → `domain/services/resource.service.js`
  → `domain/repositories/resource.repository.js`

## 8 · Source Trace
Every non-obvious claim must link directly to the code.
*(Favor git remote permalinks (e.g. `https://github.com/.../blob/<sha>/path/to/file.ts#L10-L20`) if possible. Fallback to local paths if unavailable).*

- `application/routes/resource.route.js`
- `domain/services/resource.service.js`

## 9 · Appendix
Include sequence diagrams (Mermaid) or key implementation excerpts if the logic is highly complex (> 3 hops).

---
## Changelog

| Date       | Author | Change | Version |
| ---------- | ------ | ------ | ------- |
| {YYYY-MM-DD} | codex (assistant) | Reconciled endpoint contract with backend implementation. | 1.0 |
