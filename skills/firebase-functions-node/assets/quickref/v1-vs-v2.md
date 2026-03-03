# v1 vs v2 — Quick Identification and Comparison

## How to identify the version

The **import path** is the definitive marker:

| Version | Import pattern | Example |
|---------|---------------|---------|
| **v1** (1st gen) | `require('firebase-functions/v1')` or `require('firebase-functions')` | `const functions = require('firebase-functions/v1');` |
| **v2** (2nd gen) | `require('firebase-functions/v2/<module>')` | `const {onRequest} = require('firebase-functions/v2/https');` |

v2 uses **modular imports** — you import specific triggers from subpackages:

```javascript
// v2 — import only what you need
const {onRequest} = require('firebase-functions/v2/https');
const {onMessagePublished} = require('firebase-functions/v2/pubsub');
const {onDocumentCreated} = require('firebase-functions/v2/firestore');
```

```javascript
// v1 — single namespace import
const functions = require('firebase-functions/v1');
// triggers accessed via: functions.https.onRequest, functions.firestore.document, etc.
```

**Important:** The bare import `require('firebase-functions')` without `/v1`
resolves to v1. Always use the explicit `/v1` or `/v2/<module>` path.

## Feature comparison

| Feature | v1 (1st gen) | v2 (2nd gen) |
|---------|-------------|-------------|
| Infrastructure | Cloud Functions | Cloud Run + Eventarc |
| HTTP request timeout | Up to 9 min | Up to 60 min |
| Event-triggered timeout | Up to 9 min | Up to 9 min |
| Instance size | Up to 8 GB RAM, 2 vCPU | Up to 16 GiB RAM, 4 vCPU |
| Concurrency | 1 request per instance | Up to 1000 per instance |
| Image registry | Container Registry or Artifact Registry | Artifact Registry only |
| Default service account | App Engine (`PROJECT_ID@appspot.gserviceaccount.com`) | Compute Engine (`PROJECT_NUMBER-compute@developer.gserviceaccount.com`) |
| Configuration | `functions.config()` (deprecated March 2027) | Parameterized config (`defineString`, `defineSecret`, etc.) |
| Runtime options | `.runWith({...}).region(...)` chaining | Inline options object + `setGlobalOptions()` |

## Limitations of v2

- **No Analytics event triggers** — use v1 for Analytics triggers
- **Partial Auth event support** — v2 supports Auth blocking events but not the
  same basic Authentication events as v1

## Coexistence

v1 and v2 functions can coexist **side-by-side in the same source file**. The
Firebase CLI determines deployment generation from the import path. This enables
incremental migration.

```javascript
// v2 function
const {onRequest} = require('firebase-functions/v2/https');
exports.myV2Function = onRequest((req, res) => { /* ... */ });

// v1 function (for Analytics trigger not available in v2)
const functions = require('firebase-functions/v1');
exports.myAnalyticsFunction = functions.analytics.event('event').onLog((event) => { /* ... */ });
```

## Recommendation

Use **v2 for all new functions** unless you specifically need Analytics events
or basic Auth triggers not available in v2.

## See Also

- [references/v1-to-v2-migration.md](../references/v1-to-v2-migration.md) — Step-by-step migration guide
- [assets/checklists/migration-checklist.md](../assets/checklists/migration-checklist.md) — Migration checklist
