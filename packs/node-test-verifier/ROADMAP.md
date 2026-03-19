# Roadmap

## Near term

- Add one or two richer bootstrap examples built around
  `.cursor/test-verifier.contract.json`, including a repo with multiple Jest
  configs and build-before-test prerequisites.
- Add a compact contract template snippet that repositories can adopt before
  their first bootstrap run.
- Validate the pack against at least one real project install beyond dry-run.

## Later

- Consider optional helper scripts for parsing Jest JSON and coverage summaries
  when that improves reuse without forcing repo-specific paths.
- Explore a companion example overlay for repositories that want a ready-made
  tier matrix template.
- Evaluate whether a future version should support other Node test runners, or
  whether that belongs in a different pack.
