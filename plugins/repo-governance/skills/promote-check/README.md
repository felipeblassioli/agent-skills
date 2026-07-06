# promote-check

Human-facing notes for maintainers. The agent-facing contract is in
[SKILL.md](SKILL.md); gate details are in [references/gates.md](references/gates.md).

## What it is

A **user-invoked** promotion preflight gate. Given a candidate skill directory it
runs four gates — `audit` → `alignment` → `version` → `changelog` — and prints a
**go / no-go** verdict citing every failing gate. Audit-first: it blocks on any
unresolved mechanical audit finding, so a promotion has to *fix* what the audit
surfaces, not waive it.

It only decides go / no-go. Fixing findings is `skill-studio:skill-enhance`; the
version/CHANGELOG/marketplace move is `repo-governance:skill-maintainer`.

## Run it

```bash
# from the repo root
bash "${CLAUDE_SKILL_DIR}/scripts/promote-check.sh" plugins/<plugin>/skills/<skill>
bash "${CLAUDE_SKILL_DIR}/scripts/promote-check.sh" plugins/<plugin>/skills/<skill> --json
```

Exit codes: `0` = go, `1` = no-go, `2` = usage/environment error.

## Validate this skill package

```bash
bash scripts/validate-skill.sh plugins/repo-governance/skills/promote-check
bash -n  plugins/repo-governance/skills/promote-check/scripts/promote-check.sh
shellcheck plugins/repo-governance/skills/promote-check/scripts/promote-check.sh
```
