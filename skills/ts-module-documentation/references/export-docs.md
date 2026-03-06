# Public Functions & Variables

## Purpose
Functions, methods, and constants exported from a module are the public API of that file. They must be documented so consumers know how to use them without reading the implementation.

## Rules
- **MUST** use JSDoc syntax (`/** ... */`) immediately preceding the `export` keyword.
- **MUST** describe what the function/variable does in the first sentence.
- **MUST** document all parameters using `@param {type} name - description`.
- **MUST** document the return value using `@returns {type} description` if the function returns a value (other than `void`).
- **SHOULD** include a `@example` tag for complex functions.

## Exceptions
- Exported components (React) can omit `@param` if they use a well-documented `Props` interface (see `type-docs.md`).
- Simple, self-evident constants (e.g., `export const MAX_RETRIES = 3;`) can have a single-line JSDoc comment (`/** Maximum number of API retries. */`).

## Links
- [Function JSDoc Template](../assets/templates/function-jsdoc.txt)