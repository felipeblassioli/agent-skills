# Verification

This file is the committed release companion to `CHANGELOG.md`.

Each meaningful pack release should append:

- the validation commands that were run
- the validation scenario used when applicable
- the outcome
- the diagnosis that explains what still needs improvement

## Release 0.1.0 - 2026-03-08

## Goals

The validation aimed to prove that:

- the pack is structurally valid
- the runtime workflow matches real Cloud Run application logs
- trace-aware investigation is useful in practice
- the pack's production-safety defaults are justified by real output

## Structural verification

The pack passed:

```bash
bash scripts/cursor-pack-verify.sh --pack=gcp-log-investigation
```

The pack also passed dry-run installs for:

- `project-cursor` with `lite`
- `project-cursor` with `strict`
- `user-cursor` with `lite`

Example commands:

```bash
bash scripts/cursor-pack-sync.sh --pack=gcp-log-investigation --target=project --project-root="$PWD" --profile=lite --dry-run
bash scripts/cursor-pack-sync.sh --pack=gcp-log-investigation --target=project --project-root="$PWD" --profile=strict --dry-run
bash scripts/cursor-pack-sync.sh --pack=gcp-log-investigation --target=user --profile=lite --dry-run
```

## Redacted query validation

Validation used a redacted Cloud Run project and service in `us-central1`,
bounded to the last 48 hours with a low limit.

Base filter:

```logql
resource.type = "cloud_run_revision"
resource.labels.service_name = "SERVICE_NAME"
resource.labels.location = "us-central1"
severity>=DEFAULT
-protoPayload.@type="type.googleapis.com/google.cloud.audit.AuditLog"
```

Validation command:

```bash
bash skills/gcloud-logging/scripts/gcloud-log-read.sh \
  --project PROJECT_ID \
  --filter 'resource.type = "cloud_run_revision"
resource.labels.service_name = "SERVICE_NAME"
resource.labels.location = "us-central1"
severity>=DEFAULT
-protoPayload.@type="type.googleapis.com/google.cloud.audit.AuditLog"' \
  --limit 10 \
  --hours 48
```

## What the validation proved

- the service emits logs under `resource.type="cloud_run_revision"`
- the selected labels are valid and useful
- the log stream includes both platform lifecycle events and application events
- trace values are present on relevant application logs
- a low limit such as `10` is enough to validate shape and usefulness before any
  broader investigation

## Trace-focused refinement

The following refinement produced a cleaner investigation sample:

```logql
resource.type = "cloud_run_revision"
resource.labels.service_name = "SERVICE_NAME"
resource.labels.location = "us-central1"
severity>=DEFAULT
trace:*
-protoPayload.@type="type.googleapis.com/google.cloud.audit.AuditLog"
NOT textPayload:"Received SIGTERM"
NOT textPayload:"Starting new instance"
```

Why this helped:

- `trace:*` favored request-correlated application logs
- excluding platform lifecycle messages reduced noise immediately
- the result better matched the pack's intended summary-oriented workflow

## Diagnosis

### 1. Cloud Run lifecycle noise should be first-class guidance

The default service-wide query mixes request logs, application logs, and
platform lifecycle events. The pack should teach users and agents to separate
these earlier.

### 2. Trace-first workflows are especially valuable for this pack

In the validated workload, traces were a strong signal for finding useful
application logs without dumping large unrelated log sets.

### 3. Production-safe summarization is necessary, not optional

Even the low-volume sample included auth- and middleware-related messages. This
justifies the pack's bias toward short redacted excerpts, metadata and counts,
and bounded windows with targeted filters.

### 4. The pack should keep improving its Cloud Run-specific examples

The current pack guidance is correct, but it can become more helpful by showing
starter filters for:

- request logs
- application logs
- platform lifecycle logs
- trace-focused investigation

## Outcome

Release `0.1.0` is verified enough to keep evolving. It is a valid proof point
for the pack-authoring workflow, and the next improvements are already captured
in `ROADMAP.md`.

For the longer-form narrative version of this validation, see
`guides/verification-and-diagnosis.md`.
