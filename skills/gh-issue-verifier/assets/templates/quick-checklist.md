# Quick Checklist

- [ ] Run `scripts/collect-evidence.sh` first.
- [ ] Confirm `repo_detected`, truncation flags, and any `api_errors`.
- [ ] Extract the problem statement and acceptance criteria.
- [ ] Identify issue fingerprints: symbols, paths, errors, endpoints, configs.
- [ ] Determine verification mode: issue-only or issue-vs-branch-or-pr.
- [ ] Inspect linked PRs, commits, and timeline events.
- [ ] Inspect relevant code changes.
- [ ] Inspect relevant docs and specs.
- [ ] Inspect relevant tests and judge whether they target the scenario.
- [ ] If candidate files are empty, search from issue fingerprints before broadening further.
- [ ] Record evidence for and against resolution.
- [ ] Audit issue clarity and scope ambiguity.
- [ ] Return `RESOLVED`, `NOT RESOLVED`, or `INCONCLUSIVE`.
- [ ] Keep the report strictly observational.
