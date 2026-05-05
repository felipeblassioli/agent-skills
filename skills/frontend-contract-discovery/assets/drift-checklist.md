# Drift Checklist

Use this after drafting `openapi.yaml` and `discover.log.md`.

## Goal

Detect where current frontend usage no longer matches the drafted spec, using a
small evidence protocol instead of broad repo re-analysis.

## Review Steps

1. Pick one operation from the current spec.
2. Re-open the strongest related frontend call sites.
3. Compare the spec against current code for:
   - path and method
   - path params
   - query params
   - headers and auth hints
   - request body fields
   - response fields the UI actually consumes
4. Record drift only when you can cite:
   - at least one code evidence source
   - at least one affected OpenAPI section
5. Append the result to `discover.log.md`.

## Drift Statuses

- `observed`: current code clearly disagrees with the spec
- `suspected`: the code suggests a mismatch, but evidence is incomplete
- `resolved`: the mismatch was reconciled or re-baselined

## Drift Triggers

Flag drift when any of these change:

- endpoint path or method
- added or removed path params
- added or removed query params
- changed request body shape
- changed required headers or auth behavior
- changed response fields the frontend depends on

## Drift Record

Copy this block into `discover.log.md`.

- Status:
- Operation:
- Spec section:
- Code evidence:
- Drift category:
- Description:
- Confidence:
- Follow-up:

## Red Flags

- The spec still exists, but no call site matches it anymore.
- A wrapper changed base URL or auth behavior for several operations.
- A validator now accepts or returns fields not represented in the spec.
- The UI now depends on response fields that were previously undocumented.
- A query hook or service function renamed the operation but the path changed too.

## Do Not

- Mark drift from naming alone without transport evidence.
- Rebuild the entire spec if only one operation needs review.
- Silently edit the spec without leaving a log entry.
- Treat mocks, snapshots, or docs as stronger than active call sites.

