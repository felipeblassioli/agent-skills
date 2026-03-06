---
name: hurl-testing
description: Write, execute, and assert HTTP requests safely using Hurl text files. Triggers on API testing, HTTP request generation, REST/GraphQL validation, or when .hurl files are mentioned. Do NOT use this skill for UI/browser testing or for internal unit testing.
---

# Hurl Testing

## Applicability Gate
- **Use when:** The user wants to test HTTP endpoints, validate REST/GraphQL APIs, create API integration tests, or work with `.hurl` files.
- **Do NOT use when:** The task involves UI end-to-end testing (browser-based), internal code unit testing, or non-HTTP interactions.

## Routing Table
| Topic | Reference |
|-------|-----------|
| Hurl syntax & request chaining | `references/file-format.md` |
| Assertions & variable captures | `references/assertions-captures.md` |
| Login flows & cookies | `references/authentication.md` |
| Boilerplate templates | `assets/templates/` |

## Procedure
1. Identify the endpoints to test and the authentication requirements.
2. Check `assets/templates/` for a matching boilerplate.
3. Review `references/` for specific syntax (e.g., JSONPath, GraphQL).
4. Create the `.hurl` file and run it via the `hurl` CLI tool (e.g., `hurl --test my_test.hurl`).

## Confirmation Policy
Do not execute Hurl tests against production endpoints without explicit user confirmation.
