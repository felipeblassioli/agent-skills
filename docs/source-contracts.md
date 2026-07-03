# Source Contracts

A source contract is an upstream file or document whose behavior the skill
teaches. Source contracts usually live outside this repository — for example an
upstream library's public documentation, a tool's reference pages, or a public
API spec.

## When To Use

Add `source_contracts` when a skill describes:

- reusable CI/workflow behavior
- deploy, diff, runner, or GitOps behavior
- configuration/value conventions of an upstream tool
- runtime platform contracts
- operational procedures that can drift from their implementation

## Metadata Shape

Use this shape in `metadata.json`:

```json
{
  "source_contracts": [
    {
      "path": "https://kubernetes.io/docs/reference/kubectl/",
      "reviewed_at": "2026-04-30"
    }
  ]
}
```

Use canonical, publicly reachable URLs (upstream docs, a tool's reference pages,
or a public repository file) so anyone can re-review the contract. Use
repository-relative paths only for files that live inside this repository itself.

## Frontmatter Shape

Use a lightweight path list in `SKILL.md` frontmatter so agents see freshness
without reading `metadata.json` first:

```yaml
source_contracts:
  - https://kubernetes.io/docs/reference/kubectl/
  - https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
```

## Review Rule

Before updating a source-contract skill:

1. Read the source contract files.
2. Check recent upstream changes when the source is a git repository.
3. Update the skill, references, templates, metadata, and changelog together.
4. Run `bash scripts/validate-skill.sh plugins/<plugin>/skills/<skill>`.

If the source contract changed but the skill is still correct, bump only when
agent-visible guidance changed. Otherwise update `last_reviewed`,
`source_contracts[].reviewed_at`, and the changelog note in the next related
skill release.
