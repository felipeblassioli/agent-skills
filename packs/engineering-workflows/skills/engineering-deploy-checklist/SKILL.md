---
name: engineering-deploy-checklist
description: Use when preparing to deploy a service or release, especially when verifying tests, approvals, migrations, feature flags, rollback triggers, or post-deploy checks.
---

# Engineering Deploy Checklist

Generate a pre-deployment checklist customized to the release being shipped.

## Good Fits

- regular service deploys
- releases with migrations, feature flags, or API changes
- rollouts where rollback criteria should be explicit before release

## Baseline Checklist

- pre-deploy: tests, approvals, known risks, migrations, rollback plan
- deploy: staging verification, smoke tests, canary or production rollout
- post-deploy: metrics check, stakeholder update, release notes, ticket cleanup

## Output Shape

```markdown
## Deploy Checklist: [Service or Release]

### Pre-Deploy
### Deploy
### Post-Deploy
### Rollback Triggers
```

## Customization Signals

- database migration
- feature flags
- breaking API changes
- canary or phased rollout
- stakeholder communication requirements

## Connected Tools

If connector categories are available:

- source control: release diff and approval status
- CI/CD: pipeline status and deployment checks
- monitoring: baseline metrics and rollback thresholds

## Common Mistakes

- treating rollback as a vague fallback instead of defining triggers
- forgetting post-deploy verification because pre-deploy checks looked good
- reusing the same checklist when the risk profile changed materially
