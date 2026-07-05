# Repo-local Claude Code subagents

Read-only Claude Code subagents wired for *this* repository. Each keeps its
behaviour in a harness-agnostic system prompt (action language, model **aliases**
not raw slugs, minimal read-only tools) so the ADR-0004 export adapter can
retarget it to Codex / Cursor / other harnesses.

| Agent | Model alias | Tools | Purpose |
|-------|-------------|-------|---------|
| `personal-scope-auditor` | `haiku` | Read, Grep, Bash (read-only) | Adversarial LLM check for private / employer work references before a commit or push. |
| `marketplace-consistency-reviewer` | `haiku` | Read, Grep, Bash (read-only) | Cross-artifact drift review over the marketplace tier (manifests, versions, overlap). Wraps `scripts/marketplace-consistency.sh`. |

## personal-scope-auditor: dual-harness parity

This auditor runs in **both** harnesses:

- **Cursor:** `.cursor/agents/personal-scope-auditor.md` (`model: fast`,
  `readonly: true`). Note: `.cursor/` is gitignored in this repo, so that file is
  local-only.
- **Claude Code:** `.claude/agents/personal-scope-auditor.md` (`model: haiku`,
  `tools: Read, Grep, Bash`).

Both preserve the **same permitted-identity policy** and the **same read-only
posture**. Intentional differences, so the public file stays leak-free and keeps a
single source of truth:

- Forbidden employer/private seed terms are **not** embedded in the committed
  Claude file. Both harnesses load them from the same external, out-of-repo file
  the deterministic guard uses (`~/.claude/scope-guard-denylist.txt`), and rely on
  model judgment for paraphrased leaks the seed list would miss.
- `model: fast` (Cursor) ↔ `model: haiku` (Claude) are the same tier expressed as
  each harness's alias — the export adapter maps aliases per target.

## personal-scope-auditor: relationship to the deterministic guard

The auditor is the **judgment** layer; `scripts/hooks/scope-guard.sh` (wired as a
`PreToolUse` hook in [`.claude/settings.json`](../settings.json)) is the
**deterministic** gate. They are complementary — the hook fails closed on known
secret shapes / non-permitted emails / literal denylist terms; the auditor catches
paraphrased and employer-shaped leaks a regex cannot. Neither replaces the other.

## marketplace-consistency-reviewer

The **judgment** wrapper over the deterministic
[`scripts/marketplace-consistency.sh`](../../scripts/marketplace-consistency.sh).
The script owns the mechanical, CI-runnable checks (marketplace ↔ `plugin.json`,
`metadata.json` ↔ `CHANGELOG.md` ↔ `skill-registry.json` versions, duplicate skill
names) and exits non-zero on drift; the subagent runs it, reports its findings
verbatim, and adds the checks a regex cannot do — **semantic overlap / silent
duplication** and description drift.

It complements `scripts/validate-skill.sh`, which checks a single skill in
isolation. The deterministic helper is the harness-agnostic piece a Codex/CI path
reuses directly; the subagent is the ergonomic Claude wrapper over it.
