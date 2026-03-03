# v1 → v2 Migration Checklist

Use this checklist when migrating a Firebase Cloud Function from 1st gen (v1)
to 2nd gen (v2). See
[references/v1-to-v2-migration.md](../../references/v1-to-v2-migration.md)
for detailed guidance on each step.

## Pre-migration

- [ ] Verify Firebase CLI >= 12.00 (`firebase --version`)
- [ ] Verify `firebase-functions` >= 4.3.0 in `package.json`
- [ ] Identify all v1 functions to migrate (search for `require('firebase-functions/v1')` or `require('firebase-functions')`)
- [ ] Check if any functions use **Analytics triggers** or **basic Auth triggers** (these must remain v1)
- [ ] Check for `functions.config()` usage — plan migration to parameterized config / secrets
- [ ] Audit global variables for concurrency safety (mutable globals shared across requests)
- [ ] Verify the function is **idempotent** (both v1 and v2 versions will run simultaneously during migration)
- [ ] Check if custom permissions were granted to the App Engine default service account

## During migration (per function)

- [ ] Update imports: `firebase-functions/v1` → `firebase-functions/v2/<module>`
- [ ] Update trigger definition to v2 API (inline options, single `event` callback)
- [ ] Replace `functions.config()` with `defineSecret()` / `defineString()` / `defineJsonSecret()`
- [ ] Replace `.runWith({...}).region(...)` with inline options + `setGlobalOptions()`
- [ ] If custom service account permissions exist: set `serviceAccountEmail` explicitly
- [ ] Set `concurrency` (default 80 is fine for most cases, or `1` temporarily if global vars need auditing)
- [ ] Rename function for traffic migration: `myFunction` → `myFunctionV2`
- [ ] Deploy and verify both versions run side-by-side
- [ ] For HTTP/callable: update clients to use new function name/URL
- [ ] For background triggers: verify both versions handle events correctly
- [ ] Delete the old v1 function: `firebase functions:delete myFunction`
- [ ] (Optional) Rename v2 function back to original name and redeploy

## Post-migration

- [ ] Remove `concurrency: 1` / `cpu: 'gcf_gen1'` temporary workarounds
- [ ] Remove unused v1 imports (`require('firebase-functions/v1')`) if no v1 functions remain
- [ ] Run full test suite across relevant tiers (see [test-tiers.md](../quickref/test-tiers.md))
- [ ] Verify Cloud Secret Manager secrets are bound correctly (no `undefined` in logs)
- [ ] Monitor for permission errors from service account change
- [ ] Delete any stale `.runtimeconfig.json` files after `functions.config()` removal
- [ ] Update documentation and AGENTS.md if function names or entry points changed
