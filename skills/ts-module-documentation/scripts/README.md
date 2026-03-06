# Scripts

Scripts to automate the verification of documentation coverage.

## `audit-exports.mjs`
Finds undocumented `export` statements in a TypeScript file.
**Output Contract**: Returns a JSON array of objects representing undocumented exports:
```json
[
  {
    "line": 12,
    "type": "function",
    "name": "calculateTotal"
  }
]
```