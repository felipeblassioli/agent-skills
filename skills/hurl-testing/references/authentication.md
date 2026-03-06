# Authentication & State

## Purpose
Define patterns for authenticating requests and managing state (like cookies) across chained requests.

## Rules
- **MUST** use the `[BasicAuth]` section for Basic Authentication (e.g., `user: password`), or provide an explicit `Authorization: Basic ...` header.
- **SHOULD** chain requests in the same file to share cookie storage automatically.
- **MUST** use `[Captures]` to extract JWTs, session IDs, or CSRF tokens from login responses, and inject them into subsequent requests using `{{variable_name}}`.
- **SHOULD** use the `[Form]` section for `application/x-www-form-urlencoded` login payloads.

## Links
- [Auth Flow Template](../assets/templates/auth-flow.hurl)
