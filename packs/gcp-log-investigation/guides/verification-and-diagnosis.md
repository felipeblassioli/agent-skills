# Verification And Diagnosis

This document records how the pack was validated against a redacted Google Cloud
project and what the first diagnosis suggests about the next improvements.

## Verification goals

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

Example validation command:

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

## What the redacted query proved

- the service emits logs under `resource.type="cloud_run_revision"`
- the selected labels are valid and useful
- the log stream includes both platform lifecycle events and application events
- trace values are present on relevant application logs
- a low limit such as `10` is enough to validate shape and usefulness before any
  broader investigation

## Observed log patterns

The broad validation query returned a mix of:

- platform lifecycle noise such as startup probes and `SIGTERM`
- deployment-rollout lifecycle messages
- application logs with trace IDs
- middleware and routing events such as request handling and route resolution
- lower-level debug events such as MySQL connection acquisition and release

This mix confirms that discovery-first and narrowing guidance is necessary.

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

The pack works, but the real query surfaced a few concrete improvement needs.

### 1. Cloud Run lifecycle noise should be first-class guidance

The default service-wide query mixes:

- request/application logs
- platform lifecycle logs
- deployment-health events

The pack should teach users and agents to separate these earlier.

### 2. Trace-first workflows are especially valuable for this pack

In the validated workload, traces were a strong signal for finding useful
application logs without dumping large unrelated log sets.

### 3. Production-safe summarization is necessary, not optional

Even the low-volume sample included auth- and middleware-related messages.
This justifies the pack's bias toward:

- short redacted excerpts
- metadata and counts
- bounded windows and targeted filters

### 4. The pack should keep improving its Cloud Run-specific examples

The current pack guidance is correct, but it can become more helpful by showing
opinionated starter filters for:

- request logs
- application logs
- platform lifecycle logs
- trace-focused investigation

## Suggested improvements from this diagnosis

- add a Cloud Run noise-reduction recipe to `guides/usage-patterns.md`
- add a trace-first example to the main pack guidance
- add examples that split request logs from application logs
- keep reinforcing data-minimization and redaction language for production

## Validation outcome

The validation was successful because it demonstrated:

- the pack is installable and verifiable
- the `log-reader` prompt matches a real Cloud Run workload
- the production-safety posture is supported by actual log patterns
- the pack is a credible proof point for the pack-authoring workflow
