# Quality Gate

Use this checklist before signing off on plugin/skill changes.

## Structure

- `SKILL.md` frontmatter is `name` + `description` only (Agent Skills standard).
- `metadata.json` carries `version`, `author`, `date`, `abstract`; `CHANGELOG.md`
  has a matching-version entry.
- Heavy guidance is in `references/`, not the hot path; human prompts in `README.md`.
- No empty placeholder directories or filler files.
- Bundled scripts referenced via `${CLAUDE_SKILL_DIR}`; no cross-package relative links.

## Skill Boundary

- The job states in one sentence.
- Trigger phrases match realistic user requests; anti-triggers prevent overlap.
- Cross-skill handoffs are by name.

## Source Freshness

- Source contracts read before guidance changed; recorded in `metadata.json` and
  the `CHANGELOG.md` Source Contracts section.
- External provenance uses canonical GitHub URLs; missing local paths are
  warnings, not failures.

## Plugin & Marketplace

- The skill lives in the right plugin/tier; `plugin.json` version bumped for a
  releasable change.
- `.claude-plugin/marketplace.json` lists the plugin; `claude plugin validate
  . --strict` passes.

## Safety And Privacy

- Production/deploy/credential/cross-repo-write risks are explicit where relevant,
  and the confirmation policy covers them.
- Private or credentialed details stay out of a public marketplace skill.

## Validation

```bash
claude plugin validate ./plugins/<plugin> --strict
claude plugin validate . --strict
bash scripts/validate-skill.sh plugins/<plugin>/skills/<skill>
bash scripts/test-validate-skill.sh
```
