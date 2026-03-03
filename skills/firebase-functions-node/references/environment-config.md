# Environment Configuration

How to configure Firebase Cloud Functions: parameterized config, environment
variables, secrets, and the deprecated `functions.config()` migration path.

Source: [Firebase docs — Configure your environment](https://firebase.google.com/docs/functions/config-env)

## Parameterized Configuration (recommended for v2)

Define typed parameters declaratively. Values are validated at deploy time —
deployment blocks if any parameter is missing.

```javascript
const {onRequest} = require('firebase-functions/v2/https');
const {defineInt, defineString} = require('firebase-functions/params');

const minInstances = defineInt('HELLO_WORLD_MININSTANCES');
const welcomeMessage = defineString('WELCOME_MESSAGE');

exports.helloWorld = onRequest(
  {minInstances: minInstances},          // pass directly for deploy-time options
  (req, res) => {
    res.send(`${welcomeMessage.value()}! I am a function.`);  // .value() at runtime
  }
);
```

### Parameter types

| Type | Factory | Notes |
|------|---------|-------|
| String | `defineString()` | Default type |
| Integer | `defineInt()` | |
| Boolean | `defineBoolean()` | |
| Float | `defineFloat()` | |
| List | `defineList()` | Node.js only |
| Secret | `defineSecret()` | Stored in Cloud Secret Manager |
| JSON Secret | `defineJsonSecret()` | Parsed automatically, Node.js only |

### `onInit()` for global-scope initialization

Parameters have no value at deploy time (global scope). Use `onInit()` to
safely initialize globals that depend on parameter values:

```javascript
const {defineSecret} = require('firebase-functions/params');
const {onInit} = require('firebase-functions/v2/core');

const apiKey = defineSecret('GOOGLE_API_KEY');

let client;
onInit(() => {
  client = new SomeClient(apiKey.value());
});
```

### Built-in parameters

Available from `firebase-functions/params` without defining them:

- `projectID` — Cloud project ID
- `databaseURL` — Realtime Database URL (if enabled)
- `storageBucket` — Cloud Storage bucket (if enabled)

### Parameter expressions

Use built-in comparators for deploy-time branching (not `.value()`):

```javascript
const {defineString} = require('firebase-functions/params');
const environment = defineString('ENVIRONMENT', {default: 'dev'});
const minInstances = environment.equals('PRODUCTION').thenElse(10, 1);

exports.api = onRequest({minInstances}, (req, res) => { /* ... */ });
```

## Secrets (Cloud Secret Manager)

Secrets are bound per-function. Only functions that declare the secret can
access it:

```javascript
const {onRequest} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');

const discordApiKey = defineSecret('DISCORD_API_KEY');

exports.postToDiscord = onRequest(
  {secrets: [discordApiKey]},
  (req, res) => {
    const key = discordApiKey.value();
    // ...
  }
);
```

### JSON secrets

Group related config values in a single secret:

```javascript
const {defineJsonSecret} = require('firebase-functions/params');
const apiConfig = defineJsonSecret('SOMEAPI_CONFIG');

exports.myApi = onRequest(
  {secrets: [apiConfig]},
  (req, res) => {
    const {apiKey, webhookSecret} = apiConfig.value();
    // ...
  }
);
```

### Secret management CLI

```bash
firebase functions:secrets:set SECRET_NAME         # create/update
firebase functions:secrets:access SECRET_NAME      # view value
firebase functions:secrets:destroy SECRET_NAME     # delete
firebase functions:secrets:get SECRET_NAME         # list versions
firebase functions:secrets:prune                   # clean unused
```

## Environment Variables (.env files)

For simpler cases, use dotenv-style `.env` files in `functions/`:

```
# functions/.env
PLANET=Earth
AUDIENCE=Humans
```

Access via `process.env`:

```javascript
exports.hello = onRequest((req, res) => {
  res.send(`Hello ${process.env.PLANET} and ${process.env.AUDIENCE}`);
});
```

### Per-project overrides

| File | Loaded when |
|------|-------------|
| `.env` | Always |
| `.env.<project_id>` or `.env.<alias>` | When deploying to that project |
| `.env.local` | Emulator only (overrides all others) |

### Reserved keys

Do not use keys starting with `X_GOOGLE_`, `EXT_`, `FIREBASE_`, or any of:
`CLOUD_RUNTIME_CONFIG`, `ENTRY_POINT`, `GCP_PROJECT`, `GCLOUD_PROJECT`,
`GOOGLE_CLOUD_PROJECT`, `FUNCTION_TRIGGER_TYPE`, `FUNCTION_NAME`,
`FUNCTION_MEMORY_MB`, `FUNCTION_TIMEOUT_SEC`, `FUNCTION_IDENTITY`,
`FUNCTION_REGION`, `FUNCTION_TARGET`, `FUNCTION_SIGNATURE_TYPE`,
`K_SERVICE`, `K_REVISION`, `PORT`, `K_CONFIGURATION`.

## `functions.config()` — DEPRECATED

**Deadline: March 2027.** After that date, deployments using
`functions.config()` will fail.

### Migration path

1. Export existing config to Cloud Secret Manager:
   ```bash
   firebase functions:config:export
   ```
2. Update code to use `defineJsonSecret`:
   ```javascript
   // Before (v1)
   const functions = require('firebase-functions/v1');
   const apiKey = functions.config().someapi.key;

   // After (v2)
   const {defineJsonSecret} = require('firebase-functions/params');
   const config = defineJsonSecret('RUNTIME_CONFIG');
   exports.myFn = onRequest({secrets: [config]}, (req, res) => {
     const apiKey = config.value().someapi.key;
   });
   ```
3. Deploy: `firebase deploy --only functions:<function-name>`

## Emulator Support

- `.env` and `.env.<project>` are loaded by the emulator
- `.env.local` overrides everything (emulator only)
- `.secret.local` overrides secret values locally (useful in CI)
- Emulator tries to access production secrets via application default
  credentials; use `.secret.local` if permissions are restricted

## See Also

- [trigger-patterns.md](trigger-patterns.md) — How to use config in trigger definitions
- [v1-to-v2-migration.md](v1-to-v2-migration.md) — Full migration guide including config
- [../assets/quickref/v1-vs-v2.md](../assets/quickref/v1-vs-v2.md) — Version comparison
