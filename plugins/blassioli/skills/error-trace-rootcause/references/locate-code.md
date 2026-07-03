# Locate the code — from a stack frame to the buggy line (read-only)

Once the trail has named the origin (`references/correlation-playbook.md`), turn the stack
into a concrete `file:line` and read it. This skill **locates and explains** — it does not
edit. Resolution is **local first, then GitHub via `gh`** (no clone, no working-tree
changes). The GitHub org/owner is a parameter you supply — set `ORG` to your org before
running the `gh` commands below.

## Step 1 — extract the call site from the stack

A structured JSON logger (e.g. pino / winston / bunyan) emits stacks with
container-absolute frames:
```
at Object.getOrderById (/workspace/domain/services/order-lookup.service.js:102:18)
at async fetchBundle (/workspace/domain/services/product-enrichment.service.js:150:46)
```
- `/workspace/` is the build root inside the container. **Strip it** → the repo-relative
  path: `domain/services/order-lookup.service.js`.
- Frames under `node_modules/` are library code — **skip them**. The first
  non-`node_modules` `/workspace/...` frame is the application call site.
- Keep the **function name** (`getOrderById`) — it is the most reliable anchor (see
  the `.js`-vs-`.ts` caveat below).

## Step 2 — map the service to a repo

Identify which repo owns the code from the entry's labels:

| Signal on the entry | Repo location |
|---|---|
| `resource.type="cloud_run_revision"` + `resource.labels.service_name` matches a service dir | the Cloud Run service's own repo/dir (`<service_name>`) |
| `labels."goog-drz-cloudfunctions-id"` set, `labels."goog-managed-by"="cloudfunctions"` | a **Firebase Functions** monorepo — a different layout from the Cloud Run repos. The function name (`goog-drz-cloudfunctions-id`, e.g. `orders_api`) and `jsonPayload.application` identify it; the repo is the project's functions repo in your GitHub org |
| `resource.type="k8s_container"` (GKE) | the service's own repo/dir where `<name>` = `resource.labels.namespace_name` / `jsonPayload.application` (e.g. `orders-api`). GKE apps are ordinary app repos — grep locally first. Pin the deployed commit via `labels."k8s-pod/otel/version"` (a git SHA) |
| neither / unknown | resolve by searching the org for the stack path or symbol (Step 3) |

`resource.labels.project_id` (e.g. `acme-services`) tells you which product/project owns
the service, which narrows the GitHub repo.

## Step 3 — resolve and read (local → gh)

**Local first** — grep the workspace for the path or, more robustly, the symbol:
```bash
# by repo-relative path
fd -H -p 'domain/services/order-lookup.service' .
# by symbol (survives .ts/.js and path differences)
rg -n 'getOrderById' --glob '!**/node_modules/**'
```
If found, read the file around the reported line and confirm the function matches.

**Else GitHub via `gh`** (no clone). Set `ORG` to your GitHub org/owner, resolve the repo,
then read the file:
```bash
ORG=your-org   # the GitHub org/owner that hosts the service repos

# find which repo/file defines the symbol in the org
gh search code 'getOrderById path:domain/services' --owner "$ORG" --limit 10

# read a file's contents at a specific ref (raw)
gh api -H 'Accept: application/vnd.github.raw' \
  "repos/$ORG/<repo>/contents/domain/services/order-lookup.service.ts?ref=<sha-or-branch>"

# list candidate repos if the owner is unclear
gh repo list "$ORG" --limit 200 | rg -i 'orders|inventory|functions'
```
Produce a permalink for the handoff:
```
https://github.com/$ORG/<repo>/blob/<sha>/<path>#L<line>
```

## Step 4 — pin the right version, then confirm the match

- **Pin the revision.** The trace was produced by a specific deploy. For Cloud Run, that
  is `resource.labels.revision_name`; for Firebase Functions, the `firebase-functions-hash`
  label identifies the deployed build. Resolve the matching commit SHA when possible and
  read at that `ref` — `main` may have moved.
- **`.js` vs `.ts` line drift.** The stack reports the **compiled** `.js` (`…service.js:102`),
  but the source is usually TypeScript (`…service.ts`). Compiled line numbers do **not**
  reliably map to source lines. **Match by function/symbol name**, then read the body; treat
  the `.js` line number as a hint, not a coordinate. The same applies to bundled/minified
  output.
- **Confirm before concluding.** The code at the call site should plausibly throw the
  observed error (e.g. `makeRequest` wraps an `AbortController` with an 8000 ms timeout and
  no retry). If the code cannot produce the error, the version is wrong or the frame was
  mis-mapped — recheck Steps 1–3.

## Output: the root-cause report (deliverable)

This skill stops at a **read-only diagnosis** — locate and explain, do not fix. Hand off a
report with:

1. **Error identity** — group id, `error.name`, message, `statusCode`; frequency/first-seen
   if available.
2. **The trail** — the ordered causal chain (from `trace-trail.sh`), trace id, revision.
3. **Root cause** — the first failure and *why*, in one or two sentences.
4. **Location** — `file:line` (local path or GitHub permalink at the pinned ref) + the
   relevant snippet, with the `.js`/`.ts` caveat noted if line numbers are approximate.
5. **Hypothesis & direction** — what is missing/wrong and the kind of fix indicated (e.g.
   "add a timeout+retry or circuit-breaker around `getOrderById`; the downstream
   `/products` is the latency source") — **without** writing the patch.
6. **Handoff** — to a human, or compose with a fixing skill/agent. Use `gcp-log-triage` to
   quantify blast radius (how many traces/users this group affects) before prioritizing.
