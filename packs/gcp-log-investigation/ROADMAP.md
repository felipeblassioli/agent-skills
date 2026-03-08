# Roadmap

Next steps for `gcp-log-investigation`.

## Near term

- Add Cloud Run query recipes that separate request logs, application logs, and
  platform lifecycle logs.
- Add a trace-first investigation example based on the validated
  `SERVICE_NAME` workload.
- Refine the `log-reader` prompt with explicit heuristics for when to add
  `trace:*`, when to split queries, and when to exclude lifecycle noise.
- Expand production-safety examples with clearer redaction examples for auth,
  tokens, headers, and customer payloads.

## Medium term

- Validate the pack against additional resource types:
  - Cloud Functions 1st gen
  - Cloud Functions 2nd gen / Cloud Run-backed functions
  - GKE `k8s_container`
  - GKE `k8s_pod`
- Add workload-specific usage notes for GKE label selection and noisy cluster
  logs.
- Decide whether a small guide dedicated to trace correlation patterns would
  improve usability.

## Pack evolution

- Evaluate whether `strict` should remain rule-only or eventually include
  narrowly scoped hooks after real usage proves they are necessary.
- Keep the pack focused on runtime investigation help and avoid duplicating the
  full `gcloud-logging` skill.
- Capture more real validation notes before changing the pack archetype or
  expanding its artifact set.
- Keep `CHANGELOG.md` and `VERIFICATION.md` updated on every meaningful release.

## Success signals

- Real investigations reach useful summaries with low query limits first.
- Agents avoid broad raw log dumps by default.
- Cloud Run and GKE examples cover the common failure patterns without requiring
  ad hoc prompt rewriting.
- The pack continues to complement `gcloud-logging` instead of replacing it.
