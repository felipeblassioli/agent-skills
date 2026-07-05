# Repo-local Claude Code hooks

Thin triggers wired in [`.claude/settings.json`](../../.claude/settings.json).
Each hook keeps its real logic in a standalone, **harness-agnostic** script here,
so CI or another runtime can reuse it directly (Claude Code is only the trigger).

| Script | Event | Purpose |
|--------|-------|---------|
| `validate-skill-on-edit.sh` | `PostToolUse` (Edit/Write) | Runs `scripts/validate-skill.sh` when a `SKILL.md`/`metadata.json` is edited. Fail-open (warns, never blocks). |
| `scope-guard-pretooluse.sh` → `scope-guard.sh` | `PreToolUse` (Bash) | On `git commit` / `git push`, scans the diff and **blocks (fail-closed)** if it finds leak-shaped content in this public repo. |

## scope-guard: what it checks

`scope-guard.sh` reads a unified diff on stdin and inspects added (`+`) lines for:

1. **Generic secret/credential shapes** — PEM private keys, AWS/Google keys,
   Slack/GitHub tokens, JWTs, credentials embedded in URLs. These patterns match
   secret *values*, not names, so they are safe to keep in this committed file.
2. **Emails outside an allowlist** — default `gmail.com` + GitHub noreply.
   Override with `SCOPE_GUARD_ALLOWED_EMAIL_DOMAINS=a.com,b.com`.
3. **Private denylist terms** — loaded from a file **outside the repo** so private
   / employer identifiers never enter this public history. Default:
   `~/.claude/scope-guard-denylist.txt` (one term per line, `#` comments, absent → skipped).
   Override the path with `SCOPE_GUARD_DENYLIST=/path/to/list`.

By design it does **not** flag generic `password=…` style assignments — too noisy
for a docs-heavy repo. Put project-specific strings in the denylist file instead.

## Overriding a false positive

If a finding is verified safe, re-run with the guard disabled:

```bash
SCOPE_GUARD_SKIP=1 git commit -m "…"
```

## Reuse outside Claude Code

`scope-guard.sh` is a plain diff filter — wire it as a git `pre-commit` hook or a
CI step with no Claude dependency:

```bash
git diff --cached | scripts/hooks/scope-guard.sh   # exit 1 on findings
```
