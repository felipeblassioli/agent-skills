# Skill PR Review Checklist

Use this checklist before opening or approving a skill PR in this marketplace.

## Scope

- The skill has one clear job.
- The description describes when to use the skill, not the full workflow.
- Heavy reference material lives in `references/`, not in the hot path.
- Copyable templates live in `assets/`.

## Freshness

- `SKILL.md`, `metadata.json`, and `CHANGELOG.md` agree on the current version.
- `last_reviewed` and metadata dates use `YYYY-MM-DD`.
- Skills that teach an upstream contract list their source contracts.
- Source contracts were read during the change.
- Recent upstream workflow or platform changes were checked when relevant.

## Safety

- Deploy, production, cross-repo write, runner, and credential side effects are
  explicit.
- Confirmation policies cover risky environment, secret, permission, or rollout
  changes.
- The skill does not suggest copying private details into public repos or public
  tools.
- No secrets, credentials, private keys, tokens, or full environment dumps are
  committed anywhere in the skill package.

## Release Readiness

- The latest `CHANGELOG.md` entry reads cleanly as standalone GitHub Release
  notes (no broken relative links, no secrets).
- `metadata.json`, `SKILL.md`, and `CHANGELOG.md` agree on the version that will
  be tagged as `<skill-name>/v<version>`.
- The change is intended to ship; if not, do not bump the version (see
  `docs/releasing.md` "When Not To Cut A Release").

## Validation

Run:

```bash
bash scripts/validate-skill.sh plugins/<plugin>/skills/<skill>
bash scripts/test-validate-skill.sh
```

Fix validation errors before requesting review.
