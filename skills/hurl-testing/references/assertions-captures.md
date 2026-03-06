# Assertions & Captures

## Purpose
Define how to validate HTTP responses and extract data for subsequent requests.

## Rules
- **MUST** specify the expected HTTP status code immediately after the request block (e.g., `HTTP 200`). Use `HTTP *` if the status code shouldn't be strictly validated before assertions.
- **SHOULD** use the `[Asserts]` section to validate response headers, body, and performance metrics.
- **MUST** use `jsonpath` to validate JSON responses (e.g., `jsonpath "$.status" == "RUNNING"`).
- **MUST** use `xpath` to validate HTML or XML responses (e.g., `xpath "string(//head/title)" == "Example"`).
- **SHOULD** use the `[Captures]` section before `[Asserts]` to extract values from the response into variables.
- **MUST** define captures with a name followed by an extractor (e.g., `token: jsonpath "$.access_token"`).

## Exceptions
- Implicit response asserts (like expected headers) can be defined right after the `HTTP 200` line without an `[Asserts]` block, but `[Asserts]` is preferred for clarity and complex logic.

## Links
- [Auth Flow Template (shows captures)](../assets/templates/auth-flow.hurl)
