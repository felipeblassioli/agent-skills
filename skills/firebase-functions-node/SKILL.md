---
name: firebase-functions-node
description: >-
  Guide writing, configuring, testing, and migrating Firebase Cloud Functions
  for Node.js (JavaScript/TypeScript). Distinguish v1 (deprecated) from v2
  functions by import path. Use when writing a new Cloud Function, adding a
  trigger (HTTP, PubSub, Firestore), configuring environment or secrets,
  testing functions locally or with firebase-functions-test, or migrating v1
  functions to v2. Do NOT use for client-side Firebase SDK integration, GCP
  services unrelated to Cloud Functions, or test-tier selection methodology
  (see tdd-classicist).
---

# Firebase Cloud Functions — Node.js

Authoritative reference for writing, configuring, testing, and migrating
Firebase Cloud Functions targeting Node.js (JavaScript and TypeScript).
Covers v2 (recommended) with v1 awareness for legacy code.

## Applicability Gate

Apply this skill when ANY of the following are true:

- Writing or modifying a Firebase Cloud Function (HTTP, PubSub, Firestore, RTDB, Auth, Storage)
- Configuring function environment variables, parameterized config, or secrets
- Testing functions locally (emulator, shell, or `firebase-functions-test` SDK)
- Identifying whether existing code uses v1 or v2
- Migrating a function from v1 to v2

Do NOT apply when:

- Working with client-side Firebase SDKs (Auth, Firestore client) → Firebase client docs
- Choosing test tier or test double type → **tdd-classicist**
- Running the project's multi-tier test suite → **test-verifier**

## Routing Table

### Version identification and comparison

| Question | Route to |
|----------|----------|
| "Is this function v1 or v2?" | [assets/quickref/v1-vs-v2.md](assets/quickref/v1-vs-v2.md) |
| "What are the differences between v1 and v2?" | [assets/quickref/v1-vs-v2.md](assets/quickref/v1-vs-v2.md) |
| "How do I migrate from v1 to v2?" | [references/v1-to-v2-migration.md](references/v1-to-v2-migration.md) |
| "Migration checklist?" | [assets/checklists/migration-checklist.md](assets/checklists/migration-checklist.md) |

### Writing functions

| Question | Route to |
|----------|----------|
| "How do I add an HTTP, PubSub, or Firestore trigger?" | [references/trigger-patterns.md](references/trigger-patterns.md) |
| "How do I configure env vars, params, or secrets?" | [references/environment-config.md](references/environment-config.md) |

### Testing functions

| Question | Route to |
|----------|----------|
| "How do I test locally with the emulator or shell?" | [references/local-development.md](references/local-development.md) |
| "How do I unit test with firebase-functions-test?" | [references/unit-testing.md](references/unit-testing.md) |
| "Which test tier should I use for this function?" | [assets/quickref/test-tiers.md](assets/quickref/test-tiers.md) |

## Procedure

1. **Identify the task.** Is the user writing, configuring, testing, or migrating?
2. **Check version.** If existing code is involved, determine v1 vs v2 using
   [assets/quickref/v1-vs-v2.md](assets/quickref/v1-vs-v2.md) — the import
   path is the definitive marker.
3. **Route to reference.** Load only the reference file(s) needed from the
   routing table above.
4. **Apply patterns.** Follow the normative guidance from the loaded reference.
   Always prefer v2 patterns for new code.
5. **Validate.** For new functions, confirm they follow v2 import conventions.
   For tests, map to the appropriate tier per
   [assets/quickref/test-tiers.md](assets/quickref/test-tiers.md).

## Confirmation Policy

Do NOT apply changes derived from these references without explicit user
confirmation. Present proposed code as diffs and wait for approval.

## Related Skills

- **tdd-classicist** — Test methodology, tier selection, test double taxonomy
- **test-verifier** — Run the project's multi-tier test suite and collect coverage
- **migrate-turbi-libs** — Migrate deprecated @turbi/* libraries when editing function code
