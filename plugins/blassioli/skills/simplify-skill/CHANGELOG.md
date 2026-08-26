# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
as recorded in `metadata.json`.

## 0.1.0 - 2026-08-26

### Added

- Initial release. A second lens on skill authoring: instead of asking whether a skill is
  complete, it asks which of its lines are actually load-bearing.
- **Writes beside, never over.** The deliverable is a comparison, so overwriting the
  original destroys the artifact being produced.
- **Load-bearing vs scaffolding** as the classification, with the `CHANGELOG.md` as
  evidence: a rule added after something actually went wrong is load-bearing by
  demonstration, not by the author's preference. That is the one signal in a skill package
  that distinguishes an earned rule from a defensive one.
- **A load-bearing rule may break the register**, and the report says which ones did.
  Without that escape hatch the skill would be a line-count optimiser, and the first thing
  a line-count optimiser deletes is an invariant.
- **The frontmatter description is exempt from simplification.** Length there buys
  triggering; a skill that no longer fires has been simplified to zero.
- Closes on what the simple version can no longer do — including "nothing", which is the
  most useful possible finding about the original.

### Not yet evidenced

- `evals/evals.json` ships as a suite, with no `evals/baselines/` snapshot: no runs have
  been executed. Per the marketplace governance rules, the first behavioral bump should
  cite a baseline (pass-rate delta + model + date).
