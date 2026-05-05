# Scheduled Work Checklist

- [ ] Overlapping runs are either prevented or proven safe.
- [ ] Singleton assumptions use a real enforcement mechanism when required.
- [ ] Progress is checkpointed so reruns can resume safely.
- [ ] Item-level and run-level idempotency boundaries are explicit.
- [ ] Crash after partial side effects does not duplicate irreversible work.
- [ ] Retryable and terminal failures are classified intentionally.
- [ ] Batch parallelism is bounded and compatible with downstream quotas.
- [ ] CronJob fields such as `concurrencyPolicy`, deadlines, and retry limits are intentional.
- [ ] Rollout overlap between old and new versions is safe.
- [ ] Logs and metrics show started, skipped, completed, failed, and partial-progress runs.
