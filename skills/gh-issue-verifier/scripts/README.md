# Scripts

Scripts in this directory should gather compact facts and emit machine-readable output with minimal noise.

## Included Script

- `collect-evidence.sh`
  Collect compact issue, PR, branch, and commit evidence via `gh`, git, and `jq`.

## Run Model

Prefer direct execution from the repository root:

From skill root (e.g. `~/.cursor/skills/gh-issue-verifier/` or `skills/gh-issue-verifier/`):

```bash
bash scripts/collect-evidence.sh --issue 123
```

Example with repo and PR context:

```bash
bash scripts/collect-evidence.sh --repo owner/name --issue 123 --pr 456
```

Example with branch comparison:

```bash
bash scripts/collect-evidence.sh --issue 123 --branch feat/fix-issue-123
```

## Output Contract

Scripts should emit JSON to stdout with fields like:

```json
{
  "repo_detected": "owner/name",
  "repo_autodetected": true,
  "issue": {
    "number": 123,
    "title": "Example issue",
    "body_excerpt": "First meaningful lines only",
    "body_truncated": false
  },
  "target": {
    "mode": "issue-vs-pr"
  },
  "linked_prs": [],
  "all_candidate_prs_count": 2,
  "linked_prs_cap": 3,
  "has_more_candidate_prs": false,
  "referenced_prs": [],
  "linked_commits": [],
  "recent_commits": [],
  "candidate_file_limit": 40,
  "candidate_test_limit": 20,
  "candidate_file_count_total": 7,
  "candidate_test_count_total": 2,
  "has_more_candidate_files": false,
  "has_more_candidate_tests": false,
  "candidate_files": [],
  "candidate_tests": [],
  "api_errors": [],
  "gaps": [],
  "notes": []
}
```

## Policy

- Keep script output compact and deterministic.
- Prefer facts over prose.
- Do not make verdict decisions inside scripts unless explicitly designed for that purpose.
- Use the script before falling back to raw `gh` commands.
- Treat script output as a starting point, not final proof.
- If `has_more_candidate_files`, `has_more_candidate_tests`, or `api_errors` are present, treat the collection as bounded or incomplete.

## Cross-Links

- Verification workflow: `../references/git-and-gh-workflow.md`
- Evidence ranking: `../references/evidence-ranking.md`
- Report template: `../assets/templates/verification-report.md`
