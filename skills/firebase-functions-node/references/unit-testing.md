# Unit Testing Cloud Functions

How to write unit tests for Firebase Cloud Functions using the
`firebase-functions-test` companion SDK.

Source: [Unit testing of Cloud Functions](https://firebase.google.com/docs/functions/unit-testing)

## Setup

```bash
npm install --save-dev firebase-functions-test mocha
```

Add to `functions/package.json`:

```json
"scripts": {
  "test": "mocha --reporter spec"
}
```

## Initialization Modes

### Online mode (recommended)

Tests interact with a real Firebase project. Database writes, user creates,
etc. actually happen.

```javascript
const test = require('firebase-functions-test')({
  databaseURL: 'https://PROJECT_ID.firebaseio.com',
  storageBucket: 'PROJECT_ID.firebasestorage.app',
  projectId: 'PROJECT_ID',
}, 'path/to/serviceAccountKey.json');
```

### Offline mode

Fully isolated, no side effects. Methods that interact with Firebase
products must be stubbed.

```javascript
const test = require('firebase-functions-test')();
```

**Note:** Offline mode greatly increases test complexity for Firestore/RTDB
functions. Prefer online mode for those.

## Importing Functions

**Always** initialize `firebase-functions-test` and mock config **before**
importing your functions:

```javascript
// 1. Initialize test SDK
const test = require('firebase-functions-test')();

// 2. Mock config if needed
test.mockConfig({stripe: {key: '23wr42ewr34'}});

// 3. Import functions
const myFunctions = require('../index.js');
```

For offline mode with `admin.initializeApp()` in your function code, stub
it first:

```javascript
const admin = require('firebase-admin');
const sinon = require('sinon');

const adminInitStub = sinon.stub(admin, 'initializeApp');
const myFunctions = require('../index');
```

## Testing Background (non-HTTP) Functions

### Pattern: wrap → build data → invoke → assert

```javascript
const wrapped = test.wrap(myFunctions.makeUppercase);

// Construct test data
const snap = test.database.makeDataSnapshot('input', 'messages/11111/original');

// Invoke and assert
const result = await wrapped(snap);
assert.equal(result, true);
```

### `test.wrap()` API

`wrapped(data, eventContextOptions)`:

- **data** (required) — test data for the function
- **eventContextOptions** (optional) — override event context fields:

```javascript
wrapped(data, {
  eventId: 'abc',
  timestamp: '2018-03-23T17:27:17.099Z',
  params: {pushId: '234234'},
  auth: {uid: 'jckS2Q0'},       // RTDB only
  authType: 'USER',              // RTDB only
});
```

### Constructing test data

#### Firestore

```javascript
// Single snapshot (onCreate / onDelete)
const snap = test.firestore.makeDocumentSnapshot({foo: 'bar'}, 'collection/docId');
wrapped(snap);

// Change object (onUpdate / onWrite)
const before = test.firestore.makeDocumentSnapshot({foo: 'bar'}, 'collection/docId');
const after = test.firestore.makeDocumentSnapshot({foo: 'baz'}, 'collection/docId');
const change = test.makeChange(before, after);
wrapped(change);

// Example data (no customization needed)
const exampleSnap = test.firestore.exampleDocumentSnapshot();
const exampleChange = test.firestore.exampleDocumentSnapshotChange();
```

#### Realtime Database

```javascript
const snap = test.database.makeDataSnapshot('input', 'messages/11111/original');
```

#### Offline mode — stubbed data

When using offline mode, create plain objects with stubs instead of real
snapshots:

```javascript
const sinon = require('sinon');

const childStub = sinon.stub();
const setStub = sinon.stub();

const snap = {
  val: () => 'input',
  ref: {
    parent: {
      child: childStub,
    }
  }
};

childStub.withArgs('uppercase').returns({set: setStub});
setStub.withArgs('INPUT').returns(true);
```

## Testing HTTP `onRequest` Functions

HTTP functions take `(req, res)` — test with fake objects:

```javascript
const req = {query: {text: 'input'}};
const res = {
  redirect: (code, url) => {
    assert.equal(code, 303);
    assert.equal(url, 'new_ref');
    done();
  }
};

myFunctions.addMessage(req, res);
```

For v2 HTTP functions, the same pattern applies. The `onRequest` handler
receives standard Express-compatible `(req, res)` objects.

### Integration with supertest

For more thorough HTTP testing (middleware, routing, status codes), use
supertest against the Express app directly. This maps to the
**Functional-HTTP** tier in the project's test pyramid.

## Testing Pub/Sub Functions

### With `test.wrap()`

```javascript
const wrapped = test.wrap(myFunctions.processMessage);

// Construct a Pub/Sub event-like object
wrapped({
  data: {
    message: {
      json: {hello: 'world'},
      attributes: {foo: 'bar'},
    }
  }
});
```

### Direct invocation (v2)

For v2 `onMessagePublished` functions, you can also invoke the handler
directly with a constructed event object matching the CloudEvent shape.

## Cleanup

Call at the end of your test suite to unset environment variables and
delete Firebase apps created during tests:

```javascript
// In afterAll or after block
test.cleanup();
```

## Mapping to Project Test Tiers

| Testing approach | Project tier | When to use |
|-----------------|-------------|-------------|
| `firebase-functions-test` offline + stubs | **Unit** | Domain logic, rule evaluation, scoring |
| `firebase-functions-test` online | **Emulator** | Firebase lifecycle, triggers, Auth |
| supertest against Express app | **Functional-HTTP** | HTTP pipeline, middleware, routing |
| Testcontainers MySQL | **Integration** | SQL queries, repository contracts |

See [../assets/quickref/test-tiers.md](../assets/quickref/test-tiers.md)
for the full tier table with npm scripts and coverage info.

## See Also

- [local-development.md](local-development.md) — Emulator and interactive shell
- [../assets/quickref/test-tiers.md](../assets/quickref/test-tiers.md) — 8-tier pyramid reference
- [trigger-patterns.md](trigger-patterns.md) — v2 trigger definitions
