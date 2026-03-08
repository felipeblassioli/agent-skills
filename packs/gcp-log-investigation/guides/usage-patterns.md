# Usage Patterns

This pack provides the runtime helper layer for GCP log investigations.

## Use the pack when

- the agent needs an installed `log-reader` subagent at `.cursor/agents/log-reader.md`
- log investigation will involve multiple iterative queries
- the parent context should stay clean while the subagent processes verbose log output
- trace correlation across request and application logs is likely part of the workflow

## Use the `gcloud-logging` skill when

- the main need is Cloud Logging DSL help
- the agent needs resource-type guidance or query recipes
- the user wants a single filter expression or a direct explanation
- the environment has the skill repository available and the helper scripts are useful

## Recommended workflow

1. Start with the `gcloud-logging` skill to clarify resource type, labels, and query shape.
2. Delegate to `log-reader` when the investigation becomes iterative or noisy.
3. Sample one entry first to learn payload shape and correlation fields.
4. Narrow the query before increasing limits.
5. Return a concise summary with redacted excerpts instead of raw JSON dumps.

## Platform-specific reminders

- Cloud Run services and 2nd gen functions usually appear as `cloud_run_revision`
- 1st gen functions use `cloud_function`
- GKE logs often need `k8s_container` or `k8s_pod` plus cluster and namespace labels
- request logs and application logs may need separate queries before trace correlation is useful

## Poor fits for this pack

- one-off requests to build a single filter for the user
- cases where the user explicitly wants raw command output in the main thread
- environments without `gcloud` access or permission to read the target project
