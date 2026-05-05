# Topology Review Checklist

## PR Validation

- PR workflows do not mutate shared environments.
- Self-hosted runner jobs are blocked for fork PRs unless explicitly safe.
- Same-repository PR code execution is intentional and documented.
- Aggregator checks normalize conditional jobs and are suitable for branch
  protection.
- Required checks represent the merge contract, not incidental job names.
- Dry-runs are clearly labeled and do not claim deployment.

## Main Quality

- Main quality is separate from dev deployment when downstream deploys should
  depend only on quality.
- Quality includes build, lint, typecheck, tests, and coverage appropriate to
  the repo.
- Main quality runs on the merged commit.
- Concurrency does not cancel in-flight mutating workflows.

## Dev Deployment

- Dev deployment starts only after the intended gate succeeds.
- Parallel deploy lanes are documented as parallel, not implied dependencies.
- If one dev lane is used as evidence for another lane, that dependency is
  explicit.
- Shared dev mutation emits durable run evidence or manifest output.
- Live smoke tests are either enforced or explicitly deferred with rationale.

## Production Promotion

- Production is manual or approval-gated.
- Promotion identifies an exact artifact or source revision.
- Rebuilding from a mutable branch is treated as a limitation, not true
  promotion.
- Production verifies prior successful integration evidence for the same
  identity.
- Rollback semantics are explicit: immutable artifact rollback, source revert,
  or mutable-ref redeploy.
- Approval inputs are validated before deploy.

## Release Identity Manifest

A useful manifest should include, when applicable:

- schema version;
- environment;
- git SHA;
- lockfile or package identity hash;
- image reference and digest;
- upstream quality workflow run ID;
- integration workflow run ID;
- deploy workflow run ID;
- manually approved reason or approver context;
- deployed function/service list;
- chart or infrastructure dependency versions;
- runtime matrix;
- known limitations such as mutable-ref deployment.

The manifest must not claim that components shipped together unless the workflow
proves they did.

## Preview Environment Readiness

- Preview environments are isolated per PR, branch, or deployment ID.
- Preview teardown is deterministic and runs on close or merge.
- Secrets and production data are not exposed to untrusted preview code.
- Preview deploys have cost, quota, and cleanup controls.
- Preview URLs and evidence are attached to the PR without becoming merge gates
  unless intended.

## Cache And Artifact Policy

- Caches are optimization only, never deployment evidence.
- Artifacts are used for same-run handoffs and durable evidence.
- Deployment artifacts are immutable when possible.
- Cache keys include lockfile or dependency identity.
- Cache restores cannot hide missing build steps or stale generated output.

## Security And Permissions

- Jobs use least-privilege `permissions`.
- OIDC is limited to jobs that need cloud auth.
- Secrets are unavailable to untrusted fork PR code.
- Production uses GitHub environments or equivalent approval gates.
- Branch protection requires stable aggregator checks.
- Reusable workflow contracts are documented, especially checkout ref behavior.

## Documentation Drift

- Diagrams match trigger and `needs` relationships.
- Workflow names in docs match actual files.
- Docs distinguish implemented behavior from target state.
- Known limitations are explicit and not hidden in optimistic language.
- Operator runbooks reference the exact evidence fields they need.
