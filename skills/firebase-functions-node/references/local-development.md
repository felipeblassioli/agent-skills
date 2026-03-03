# Local Development — Emulator and Functions Shell

How to run and test Firebase Cloud Functions locally before deploying.

Sources:
- [Run functions locally](https://firebase.google.com/docs/functions/local-emulator)
- [Test functions interactively](https://firebase.google.com/docs/functions/local-shell)

## Firebase Emulator Suite

### Prerequisites

- Firebase CLI: `npm install -g firebase-tools`
- `firebase-admin` >= 8.0.0
- `firebase-functions` >= 3.0.0

### Starting the emulator

```bash
# Start all emulators configured in firebase.json
firebase emulators:start

# Start only the functions emulator
firebase emulators:start --only functions

# Run a test suite after emulators start, then shut down
firebase emulators:exec "./my-test.sh"
```

`emulators:exec` is ideal for CI — it starts emulators, runs the command,
and tears everything down automatically.

### HTTPS function URLs

Each HTTPS function is served at:

```
http://$HOST:$PORT/$PROJECT/$REGION/$NAME
```

Example: `http://localhost:5001/my-project/us-central1/helloWorld`

### Admin credentials (optional)

Required only for functions calling non-Firestore/non-RTDB Google APIs
(Auth, FCM, Cloud Translation, etc.):

```bash
export GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json"
firebase emulators:start
```

Firestore and RTDB triggers have sufficient credentials without this step.

### Cross-emulator interaction

When multiple emulators run together, they wire automatically:

| Source | Behavior |
|--------|----------|
| Admin SDK writes to **Firestore** | Sent to Firestore emulator → triggers Cloud Functions emulator |
| Admin SDK writes to **Storage** | Sent to Storage emulator → triggers functions (Admin SDK >= 9.7.0) |
| Admin SDK writes to **Auth** | Sent to Auth emulator → triggers functions (Admin SDK >= 9.3.0) |
| **Pub/Sub** emulator | Triggers `onMessagePublished` functions |
| **Eventarc** emulator | Triggers v2 custom event handlers |
| **Hosting** emulator | Uses local HTTP functions as proxies |

### Environment variables in the emulator

| File | Priority | Scope |
|------|----------|-------|
| `.env` | Lowest | All environments |
| `.env.<project>` | Medium | Specific project |
| `.env.local` | Highest | Emulator only |

`.secret.local` overrides Cloud Secret Manager values locally.

### Logging

The emulator streams all `console.log()`, `console.info()`, `console.error()`,
and `console.warn()` output to the terminal.

## Cloud Functions Shell

An interactive REPL for invoking functions with test data. Supports all
trigger types.

### Starting the shell

```bash
firebase functions:shell
```

If using `functions.config()`, first export config:

```bash
firebase functions:config:get > .runtimeconfig.json
firebase functions:shell
```

### Invoking HTTPS functions

```javascript
// Basic invocation
myHttpsFunction()
myHttpsFunction.get()
myHttpsFunction.post()

// With sub-path
myHttpsFunction('/path')
myHttpsFunction.get('/path')

// With POST form data
myHttpsFunction.post('/path').form({foo: 'bar'})
```

### Invoking Callable functions

```javascript
myCallableFunction({foo: 'bar'})

// With FCM token
myCallableFunction('test data', {instanceIdToken: 'sample token'})
```

### Invoking Pub/Sub functions

```javascript
// JSON message with attributes
myPubsubFunction({
  data: new Buffer('{"hello":"world"}'),
  attributes: {foo: 'bar'}
})
```

### Invoking Firestore functions

```javascript
// onCreate / onDelete
myFirestoreFunction({foo: 'new'})

// onUpdate / onWrite
myFirestoreFunction({before: {foo: 'old'}, after: {foo: 'new'}})

// With wildcard params
myFirestoreFunction({foo: 'new'}, {params: {group: 'a', id: 123}})
```

### Invoking Realtime Database functions

```javascript
// onCreate
myDatabaseFunction('new_data')

// onUpdate / onWrite
myDatabaseFunction({before: 'old_data', after: 'new_data'})

// With wildcard params
myDatabaseFunction('data', {params: {group: 'a', id: 123}})

// As unauthenticated user
myDatabaseFunction('data', {authMode: 'USER'})

// As specific user
myDatabaseFunction('data', {auth: {uid: 'abcd'}})
```

### Invoking Storage / Auth functions

Pass test data matching the expected format:

- Storage: [`ObjectMetadata`](https://firebase.google.com/docs/reference/functions/firebase-functions.storage.objectmetadata)
- Auth: [`UserRecord`](https://firebase.google.com/docs/reference/functions/firebase-functions.auth#authuserrecord)

Only include fields your function actually reads.

### Loading test data from files

```javascript
var data = require('./path/to/testData.json');
myFunction(data);
```

## See Also

- [unit-testing.md](unit-testing.md) — Programmatic testing with `firebase-functions-test`
- [../assets/quickref/test-tiers.md](../assets/quickref/test-tiers.md) — Which tier to use
- [trigger-patterns.md](trigger-patterns.md) — v2 trigger definitions
