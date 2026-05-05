---
title: '{VERB} {/path/to/endpoint}'
status: draft
date: {YYYY-MM-DD}
owner: unknown
confidence: {high|medium|low}
---
# {VERB} {/path/to/endpoint}

> Brief description based only on frontend usage evidence. If purpose is unclear,
> say `unknown` and cite the strongest evidence available.

## 1 · Path & Verb
- **Verb:** `{VERB}`
- **Path:** `{/path/to/endpoint}`

## 2 · Auth / Headers
If auth or headers are not directly evidenced, write `unknown` and do not keep a
mostly-empty table just for structure.

| Header | Description | Source |
| :--- | :--- | :--- |
| `Authorization` | `Bearer <token>` if evidenced, else `unknown` | How the frontend injects it (e.g., `apiClient.ts`) |

## 3 · Request Contract
If path params, query params, or body fields are only partially visible, list the
observed fields and note the rest as `unknown` instead of filling in framework
conventions.

If no concrete query params or body fields are evidenced, say so in one line
instead of creating placeholder rows full of `unknown`.

- **Path Parameters:**
  - `paramId` (type or `unknown`) - description or `unknown`
- **Query Parameters:**
  - `field` (type or `unknown`) - optional/required if evidenced, else `unknown`
- **Body:** object / primitive / none / `unknown`
  
| Field | Type | Default | Validation (if known) |
| :--- | :--- | :--- | :--- |
| `example` | observed or `unknown` | `unknown` | Observed validation or `unknown` |

## 4 · Success Response
State only the success status codes and payload traits the frontend actually
uses. If the frontend only checks for "success" without reading the body, say
so explicitly.

- **Observed success status:** `200` / `201` / `unknown`
- **Observed payload shape:** JSON object / array / empty body / `unknown`
- **Notes:** Brief evidence-backed summary

*(If the payload is large, extract it to `{VERB}_{path_segments}.response.json`
and reference it here. Do not invent fields that are not evidenced.)*

```json
{
  "success": true
}
```

## 5 · Error Responses
List only errors evidenced by frontend branching, toast messages, retries,
special handling, or typed error parsing. If only a generic failure path is
visible, use one `unknown` row instead of enumerating likely HTTP codes.

| HTTP | Code | When |
| :--- | :--- | :--- |
| `400` | `VALIDATION_ERROR` or `unknown` | Only if evidenced |
| `401` | `unknown` | Only if evidenced |
| `unknown` | `unknown` | Generic failure branch with no visible transport details |

## 6 · Domain Logic Summary
- **Inferred behavior:** What the frontend appears to expect from the server. Use
  `unknown` when the backend effect is not visible from the client. Do not turn
  route names or function names into facts unless UI behavior or state
  transitions support that inference.
- **Frontend side effects:** Local state changes, invalidations, toasts,
  redirects, or navigation triggered on success/failure.

## 7 · Assumptions & Unknowns
- **Assumptions:** Derived but not directly observed facts.
- **Unknowns:** Contract details the frontend does not reveal.
- **Drift risk:** What is most likely to diverge between frontend usage and
  backend reality.

## 8 · Source Trace
*(Favor git remote permalinks (e.g. `https://github.com/.../blob/<sha>/path/to/file.ts#L10-L20`) if possible. Fallback to local paths if unavailable).*

- `frontend/src/api/client.ts`
- `frontend/src/hooks/useEndpoint.ts`

## 9 · References
- **OpenAPI:** `openapi.yaml` (path: `{VERB} {/path/to/endpoint}`)

---
## Changelog

| Date       | Author | Change |
| ---------- | ------ | ------ |
| {YYYY-MM-DD} | codex (assistant) | Discovered from frontend contract inference. |