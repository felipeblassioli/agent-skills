# Kubernetes Worker Checklist

- [ ] `terminationGracePeriodSeconds` is set intentionally.
- [ ] Worker handles `SIGTERM`.
- [ ] Readiness behavior prevents new work during shutdown where applicable.
- [ ] Liveness does not kill slow-but-healthy workers.
- [ ] Startup probe exists when boot may be slow.
- [ ] CPU and memory requests exist.
- [ ] Limits are intentional and compatible with concurrency.
- [ ] HPA signal matches workload bottleneck.
- [ ] Rollout strategy does not amplify unsafe duplicate work.
- [ ] PDB exists for critical workloads where appropriate.
- [ ] Service account has least privilege.
- [ ] Secrets and env vars avoid accidental exposure.
