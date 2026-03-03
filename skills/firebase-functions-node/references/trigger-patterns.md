# Trigger Patterns (v2)

How to define Firebase Cloud Function triggers in v2. All examples use
Node.js CommonJS (`require`). The same patterns apply to ESM and TypeScript
with adjusted import syntax.

Source: [Firebase docs — various trigger pages](https://firebase.google.com/docs/functions)

## HTTP Triggers

```javascript
const {onRequest} = require('firebase-functions/v2/https');

exports.myApi = onRequest(
  {
    cors: true,                    // v2 has built-in CORS support
    memory: '512MiB',
    timeoutSeconds: 30,
    maxInstances: 200,
  },
  (req, res) => {
    res.json({status: 'ok'});
  }
);
```

### Callable functions

```javascript
const {onCall, HttpsError} = require('firebase-functions/v2/https');

exports.addMessage = onCall((request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be signed in');
  }
  const text = request.data.text;
  // ... process and return result
  return {result: `Message: ${text}`};
});
```

## Pub/Sub Triggers

```javascript
const {onMessagePublished} = require('firebase-functions/v2/pubsub');
const logger = require('firebase-functions/logger');

exports.processMessage = onMessagePublished(
  {
    topic: 'my-topic',
    memory: '256MiB',
    maxInstances: 5,
  },
  (event) => {
    // JSON payload (auto-decoded)
    const jsonData = event.data.message.json;

    // Raw base64 payload (for non-JSON)
    const rawData = event.data.message.data
      ? Buffer.from(event.data.message.data, 'base64').toString()
      : null;

    // Message attributes
    const attrs = event.data.message.attributes;

    logger.info('Received message', {jsonData, attrs});
  }
);
```

### Pub/Sub message structure

| Property | Type | Description |
|----------|------|-------------|
| `event.data.message.json` | object | Auto-parsed JSON body (throws if not valid JSON) |
| `event.data.message.data` | string | Base64-encoded raw message body |
| `event.data.message.attributes` | object | Key-value message attributes |

## Firestore Triggers

```javascript
const {onDocumentCreated} = require('firebase-functions/v2/firestore');

exports.onUserCreated = onDocumentCreated('users/{userId}', (event) => {
  const snapshot = event.data;
  const userData = snapshot.data();
  const userId = event.params.userId;
  // ...
});
```

Other Firestore triggers: `onDocumentUpdated`, `onDocumentDeleted`,
`onDocumentWritten` — all from `firebase-functions/v2/firestore`.

For `onDocumentUpdated` / `onDocumentWritten`, access before/after:

```javascript
const {onDocumentUpdated} = require('firebase-functions/v2/firestore');

exports.onProfileUpdate = onDocumentUpdated('profiles/{profileId}', (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  // ...
});
```

## Realtime Database Triggers

```javascript
const {onValueCreated} = require('firebase-functions/v2/database');

exports.onNewMessage = onValueCreated('/messages/{pushId}', (event) => {
  const data = event.data.val();
  const pushId = event.params.pushId;
  // ...
});
```

Other: `onValueUpdated`, `onValueDeleted`, `onValueWritten`.

## Auth Triggers

```javascript
const {beforeUserCreated, beforeUserSignedIn} = require('firebase-functions/v2/identity');

exports.beforeCreate = beforeUserCreated((event) => {
  const user = event.data;
  // Modify or block user creation
  if (user.email?.endsWith('@blocked.com')) {
    throw new HttpsError('permission-denied', 'Blocked domain');
  }
});
```

**Note:** v2 supports Auth *blocking* events. Basic Auth triggers
(`onCreate`, `onDelete`) remain v1-only.

## Storage Triggers

```javascript
const {onObjectFinalized} = require('firebase-functions/v2/storage');

exports.processUpload = onObjectFinalized(
  {bucket: 'my-bucket'},
  (event) => {
    const filePath = event.data.name;
    const contentType = event.data.contentType;
    // ...
  }
);
```

## Runtime Options

### Per-function options

Pass options as the first argument to any trigger:

```javascript
exports.heavyWork = onRequest(
  {
    memory: '1GiB',
    timeoutSeconds: 300,
    minInstances: 2,
    maxInstances: 100,
    concurrency: 80,
    cpu: 1,
    region: 'southamerica-east1',
    secrets: [mySecret],
  },
  handler
);
```

### Global options

Set defaults for all functions in the file:

```javascript
const {setGlobalOptions} = require('firebase-functions/v2');

setGlobalOptions({
  region: 'southamerica-east1',
  memory: '256MiB',
  maxInstances: 10,
});
```

Per-function options override global options.

### Common option reference

| Option | Type | Default | Notes |
|--------|------|---------|-------|
| `region` | string | `us-central1` | |
| `memory` | string | `256MiB` | `128MiB` to `16GiB` |
| `timeoutSeconds` | number | 60 | HTTP: up to 3600, event: up to 540 |
| `minInstances` | number | 0 | Warm instances to reduce cold starts |
| `maxInstances` | number | — | Concurrency cap |
| `concurrency` | number | 80 | Requests per instance (v2 only) |
| `cpu` | number/string | auto | `1`, `2`, `4`, or `'gcf_gen1'` |
| `secrets` | array | `[]` | Secret parameters to bind |
| `cors` | boolean/string/array | `false` | HTTP triggers only |

## See Also

- [environment-config.md](environment-config.md) — Parameterized config and secrets
- [../assets/quickref/v1-vs-v2.md](../assets/quickref/v1-vs-v2.md) — Version comparison
- [local-development.md](local-development.md) — Testing triggers with emulator/shell
