# Module-Level Documentation

## Purpose
Every TypeScript file (`.ts`, `.tsx`) in the project should clearly explain what it provides, especially when containing multiple exports. This helps developers understand the file's role without reading every function.

## Rules
- **MUST** include a top-level block comment at the beginning of the file using the `@module` tag (or a clear introductory sentence).
- **MUST** state the primary responsibility or domain of the file (e.g., "Provides utilities for manipulating dates").
- **SHOULD** list or group the main exported APIs if the file is large.

## Exceptions
- Test files (`*.test.ts`, `*.spec.ts`) do not need module-level docs.
- Configuration files (`jest.config.ts`, etc.) do not need module-level docs.
- Index files (`index.ts`) that merely re-export other files do not need exhaustive module docs.

## Links
- [Module JSDoc Template](../assets/templates/module-jsdoc.txt)