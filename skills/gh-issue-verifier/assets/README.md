# Assets

Use assets as copy-then-customize templates. They are for output shape and working notes, not doctrine.

## Included Templates

- `templates/verification-report.md`
  Main report format for issue verification results.
- `templates/issue-input-template.md`
  Fallback input form when issue data is pasted manually.
- `templates/quick-checklist.md`
  Compact operational checklist for the verification workflow.
- `templates/adversarial-skill-review-prompt.md`
  Fresh-window prompt for adversarial review of the skill's quality, trigger precision, and token efficiency.

## Usage

1. Pick the closest template.
2. Copy its structure into the working response.
3. Replace placeholders with evidence gathered from `gh`, git, code, docs, and tests.
4. Keep the report strictly observational.

## Boundary

- Put standards and rubrics in `references/`.
- Put automation and structured collection in `scripts/`.

## Cross-Links

- Verification doctrine: `../references/README.md`
- Script contract: `../scripts/README.md`
