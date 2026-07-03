# Source Notes

The skill is designed around these public documentation anchors:

- Cursor: Agent Skills are dynamic capabilities; Rules are static project context. See Cursor Docs and Cursor's agent best practices.
- Google Cloud Pub/Sub: default subscriptions are at-least-once and subscribers must handle duplicate delivery with idempotent processing. Subscriber flow control should cap outstanding messages and outstanding bytes.
- Kubernetes: Pod termination has a grace period; PreStop runs before TERM and consumes the same grace period. Probes and termination grace settings must match workload behavior.

Keep this file short. Prefer links to source documentation over copying large excerpts.
