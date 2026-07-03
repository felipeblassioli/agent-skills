# Repo Governance — skill-maintainer

`/repo-governance:skill-maintainer` helps maintainers author, update, version,
validate, and promote this marketplace's own plugins and skills without drifting
from the Claude-first governance contract (see `docs/marketplace-governance.md`).

Use it when a task changes a plugin/skill package, `marketplace.json`, a
`plugin.json`, governance docs, or the validation/release tooling.

## Useful Prompt Shape

```text
Use /repo-governance:skill-maintainer to <create/update/version/validate/promote>
<skill> in the <plugin> plugin. Source contracts: <paths/URLs>. Include
metadata.json, CHANGELOG.md, README prompts, marketplace/plugin manifest updates,
and validation.
```

## Example Prompts

### Create a new skill in a plugin

```text
Use /repo-governance:skill-maintainer to create a skill in the example-plugin
plugin for reviewing its API usage. Define triggers/anti-triggers, record source
contracts, add README prompts, list it in marketplace.json if new, and validate.
```

### Promote a sandbox skill

```text
Use /repo-governance:skill-maintainer to promote <skill> from the blassioli
sandbox plugin to an official plugin: move the package, reconcile frontmatter,
update both manifests and the marketplace, and validate strict.
```

### Update after source drift

```text
Use /repo-governance:skill-maintainer to update a skill after its upstream source
contract changed: check the source contract, bump metadata.json version if
guidance changed, update CHANGELOG.md, and validate.
```

### Quality review

```text
Use /repo-governance:skill-maintainer as a strict reviewer for this plugin/skill
package: trigger precision, anti-triggers, source contracts, changelog, manifest
versions, privacy, and validator output.
```

## Expected Outputs

- package files internally consistent (`SKILL.md` name+description;
  `metadata.json` version/date; `CHANGELOG.md` entry)
- source contracts reviewed and recorded
- `marketplace.json` / `plugin.json` updated for new or releasable changes
- `claude plugin validate --strict` and `validate-skill.sh` run with passing output
