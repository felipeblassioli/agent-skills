---
name: gcp-log-investigation
version: "0.1.0"
description: Portable GCP log-investigation pack with a reusable log-reader subagent and production-safe guidance.
---

# GCP Log Investigation

`gcp-log-investigation` packages the runtime layer for investigating application
logs in Google Cloud while keeping the deeper query language and resource-type
knowledge in the `gcloud-logging` skill.

This pack is for:

- Cloud Run services and Cloud Run-backed 2nd gen functions
- Cloud Functions 1st gen
- GKE and Kubernetes workloads
- production troubleshooting where trace correlation and redaction discipline matter

## Profiles

- `lite`: installs the portable `log-reader` subagent only
- `strict`: installs the same subagent plus a project rule for bounded queries,
  redaction, and concise summaries

## Target support

- `project-cursor`: installs into a repository's `.cursor/` directory
- `user-cursor`: installs into `~/.cursor/`

Project installs can include `.cursor/rules/` for the `strict` profile.
User installs skip rules because Cursor user rules are managed in settings
rather than a `~/.cursor/rules/` directory.

## Included runtime assets

- `.cursor/agents/log-reader.md`
- optional strict project rule at `.cursor/rules/10-log-investigation-safety.mdc`

## How it works with `gcloud-logging`

Use the `gcloud-logging` skill when the agent needs:

- Cloud Logging DSL help
- resource type guidance
- reusable query recipes
- helper scripts from the skill repository

Use this pack when the agent needs:

- a portable installed subagent at `.cursor/agents/log-reader.md`
- isolated log investigation that keeps noisy JSON out of the parent context
- persistent project guidance for production-safe summaries in `strict` mode

## Guides

- [guides/usage-patterns.md](guides/usage-patterns.md)
- [guides/production-safety.md](guides/production-safety.md)
- [guides/verification-and-diagnosis.md](guides/verification-and-diagnosis.md)

## Release Artifacts

- [CHANGELOG.md](CHANGELOG.md)
- [VERIFICATION.md](VERIFICATION.md)
- [RELEASE-POLICY.md](RELEASE-POLICY.md)
- [ROADMAP.md](ROADMAP.md)
