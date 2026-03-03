# Migrating v1 Functions to v2

Step-by-step guide for upgrading 1st gen (v1) Firebase Cloud Functions to
2nd gen (v2) in Node.js.

Source: [Upgrade 1st gen Node.js functions to 2nd gen](https://firebase.google.com/docs/functions/2nd-gen-upgrade)

## Prerequisites

- Firebase CLI >= 12.00
- `firebase-functions` >= 4.3.0

## Migration Strategy

v1 and v2 functions **coexist side-by-side** in the same file. Migrate one
function at a time, test, then proceed.

## Step 1 — Update Imports

The import path determines which generation the CLI deploys:

**Before (v1):**

```javascript
const functions = require('firebase-functions/v1');
```

**After (v2):**

```javascript
const {onRequest} = require('firebase-functions/v2/https');
const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const {onMessagePublished} = require('firebase-functions/v2/pubsub');
```

Import only the specific triggers you need (modular imports).

## Step 2 — Update Trigger Definitions

**Before (v1):**

```javascript
exports.date = functions.https.onRequest((req, res) => {
  // ...
});

exports.uppercase = functions.firestore
  .document('my-collection/{docId}')
  .onCreate((change, context) => {
    // ...
  });
```

**After (v2):**

```javascript
exports.date = onRequest({cors: true}, (req, res) => {
  // ...
});

exports.uppercase = onDocumentCreated('my-collection/{docId}', (event) => {
  // event.data is the snapshot, event.params has wildcards
});
```

Key differences:
- v2 callbacks receive a single `event` object (not `(change, context)`)
- Options are passed as an inline object (first argument)
- v2 `onRequest` supports `cors` option natively

## Step 3 — Migrate Configuration

**Before (v1) — DEPRECATED, fails March 2027:**

```javascript
const functions = require('firebase-functions/v1');
const apiKey = functions.config().someapi.key;
```

**After (v2) — Parameterized config:**

```javascript
const {defineSecret} = require('firebase-functions/params');
const apiKey = defineSecret('API_KEY');

exports.getQuote = onRequest(
  {secrets: [apiKey]},
  async (req, res) => {
    const key = apiKey.value();
    // ...
  }
);
```

For bulk migration from `functions.config()`:

```bash
firebase functions:config:export
# Creates a Cloud Secret Manager secret with all config values
```

Then use `defineJsonSecret('RUNTIME_CONFIG')` to access the exported config.

## Step 4 — Update Runtime Options

**Before (v1):**

```javascript
exports.date = functions
  .runWith({minInstances: 5})
  .region('southamerica-east1')
  .https.onRequest((req, res) => { /* ... */ });
```

**After (v2):**

```javascript
const {setGlobalOptions} = require('firebase-functions/v2');

setGlobalOptions({region: 'southamerica-east1'});

exports.date = onRequest(
  {minInstances: 5},
  (req, res) => { /* ... */ }
);
```

- Use `setGlobalOptions()` for settings shared across all functions
- Per-function options override globals

## Step 5 — Handle Service Account Changes

| Generation | Default service account |
|------------|----------------------|
| v1 | App Engine: `PROJECT_ID@appspot.gserviceaccount.com` |
| v2 | Compute Engine: `PROJECT_NUMBER-compute@developer.gserviceaccount.com` |

If you've granted special permissions to the v1 service account, explicitly
set it on migrated functions:

```javascript
setGlobalOptions({
  serviceAccountEmail: '<PROJECT_ID>@appspot.gserviceaccount.com'
});
```

Skip this step if you haven't modified default service account permissions.

## Step 6 — Enable Concurrency

v2 supports up to 1000 concurrent requests per instance (default: 80):

```javascript
exports.date = onRequest(
  {concurrency: 500},
  (req, res) => { /* ... */ }
);
```

### Audit global variables first

v1 functions assumed 1 request per instance. Global variables set per-request
can cause bugs under concurrency:

```javascript
// DANGER: shared mutable state across concurrent requests
let currentUser = null;

exports.api = onRequest((req, res) => {
  currentUser = req.user;     // race condition with concurrent requests!
  // ...
});
```

**Temporary workaround** while auditing:

```javascript
exports.api = onRequest(
  {cpu: 'gcf_gen1', concurrency: 1},
  (req, res) => { /* ... */ }
);
```

Remove this once global variable usage is safe.

## Step 7 — Migrate Traffic

You **cannot** upgrade a function in-place (same name, v1→v2). The CLI
will error:

> Upgrading from GCFv1 to GCFv2 is not yet supported.

### Traffic migration procedure

1. **Rename** the function: `resizeImage` → `resizeImageV2`
2. **Deploy** — both v1 and v2 versions run simultaneously
3. **Redirect traffic:**
   - HTTP/callable/task queue: update client code to use the new function name/URL
   - Background triggers: both respond to every event immediately
4. **Delete** the v1 function: `firebase functions:delete resizeImage`
5. (Optional) Rename v2 back to the original name

**Important:** Ensure the function is **idempotent** before this step — both
versions will process the same events during the migration window.

## See Also

- [../assets/quickref/v1-vs-v2.md](../assets/quickref/v1-vs-v2.md) — Feature comparison
- [../assets/checklists/migration-checklist.md](../assets/checklists/migration-checklist.md) — Pre/during/post checklist
- [environment-config.md](environment-config.md) — Full config and secrets reference
- [trigger-patterns.md](trigger-patterns.md) — All v2 trigger patterns
