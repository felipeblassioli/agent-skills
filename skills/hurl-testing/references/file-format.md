# File Format & Requests

## Purpose
Define the structure and syntax rules for Hurl text files.

## Rules
- **MUST** define requests sequentially. Requests are separated by blank lines or HTTP method declarations.
- **MUST** start each request with an HTTP method (GET, POST, PUT, DELETE, etc.) followed by the URL.
- **SHOULD** use variables `{{variable_name}}` for base URLs and environment-specific data.
- **SHOULD** specify headers immediately after the request line (e.g., `Content-Type: application/json`).
- **MUST** use sections like `[Query]`, `[Form]`, `[Multipart]`, `[Cookies]` to structure complex request data.
- **SHOULD** use inline text blocks for JSON or XML bodies, or explicitly reference files for binary data.
- **MUST** use ````graphql` fenced code blocks for GraphQL queries.

## Exceptions
- URLs can contain query parameters directly (`GET https://example.org?page=1`) instead of using a `[Query]` section for simple requests.

## Links
- [Basic REST Template](../assets/templates/basic-rest.hurl)
- [GraphQL Template](../assets/templates/graphql-query.hurl)
