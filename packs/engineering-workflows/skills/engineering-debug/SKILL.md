---
name: engineering-debug
description: Use when behavior diverges from expectations, an error or stack trace needs diagnosis, or something broke after a deploy and the root cause is not yet obvious.
---

# Engineering Debug

Run a structured debugging session to reproduce, isolate, diagnose, and fix a
problem systematically.

## Good Fits

- a production issue with unclear cause
- a regression that appeared after a deploy or dependency change
- a bug report where the symptom is obvious but the root cause is not

## Workflow

1. Reproduce the issue and clarify expected versus actual behavior.
2. Isolate the component, service, or code path involved.
3. Diagnose root cause by testing hypotheses, not just collecting symptoms.
4. Propose the fix plus regression prevention.

## Input That Helps

- exact error text or stack trace
- steps to reproduce
- recent deploys or config changes
- logs, metrics, or screenshots
- expected behavior versus actual behavior

## Output Shape

```markdown
## Debug Report: [Issue Summary]

### Reproduction
### Root Cause
### Fix
### Prevention
```

## Connected Tools

If connector categories are available:

- monitoring: pull logs, metrics, and alert windows
- source control: inspect recent commits and PRs
- project tracker: search for related incidents or bug tickets

## Common Mistakes

- jumping to fixes before locking down reproduction
- stopping at the first plausible cause instead of the real root cause
- patching the symptom without adding a regression prevention step
