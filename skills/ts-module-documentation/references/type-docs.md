# Exported Types, Interfaces & Classes

## Purpose
Types and interfaces define the shape of data in the application. Documenting them ensures developers know what each field represents and any constraints on the data.

## Rules
- **MUST** document the overall purpose of the `interface`, `type`, or `class`.
- **MUST** document individual fields/properties within the interface if their purpose is not immediately obvious from the name.
- **SHOULD** indicate if a field is optional, nullable, or has specific constraints (e.g., "Must be an ISO 8601 date string").

## Exceptions
- Internal types (not exported) do not require formal documentation, though it is encouraged.
- Highly generic wrapper types (e.g., `type Nullable<T> = T | null;`) may only need a single-line explanation.

## Links
- [Type JSDoc Template](../assets/templates/type-jsdoc.txt)