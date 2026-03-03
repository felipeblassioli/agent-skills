# Go Package Documentation (doc.go)

A structured repository for Go package documentation conventions following
official Go standards. These patterns ensure documentation renders correctly in
`go doc`, `godoc`, and `pkg.go.dev`.

## Structure

- `rules/` - Individual rule files (one per rule)
  - `_sections.md` - Section metadata (titles, impacts, descriptions)
  - `_template.md` - Template for creating new rules
  - `area-description.md` - Individual rule files
- `metadata.json` - Document metadata (version, organization, abstract)
- **`AGENTS.md`** - Compiled output (generated)

## Rules

### Structure (CRITICAL)

- `structure-package-clause.md` - No blank line between comment and package
  clause
- `structure-first-sentence.md` - Must start with "Package <name>"

### Formatting (HIGH)

- `format-present-tense.md` - Use "provides", "implements" (not past/future)
- `format-complete-sentences.md` - All documentation uses complete sentences
- `format-code-blocks.md` - Indent with 4 spaces or 1 tab
- `format-headings.md` - Use `#` syntax for sections

### Content Guidelines (MEDIUM)

- `content-purpose-first.md` - Start with purpose, then implementation
- `content-usage-examples.md` - Include practical, runnable examples
- `content-thread-safety.md` - Document concurrency safety

## Core Principles

1. **Package name first** — "Package <name> provides..." is mandatory
2. **Present tense** — "provides", "implements" (not "will provide")
3. **Complete sentences** — No fragments
4. **Purpose before implementation** — What before how

## Creating a New Rule

1. Copy `rules/_template.md` to `rules/area-description.md`
2. Choose the appropriate area prefix:
   - `structure-` for Structure
   - `format-` for Formatting
   - `content-` for Content Guidelines
3. Fill in the frontmatter and content
4. Ensure you have clear examples with explanations

## Impact Levels

- `CRITICAL` - Foundational requirements, documentation won't render properly
- `HIGH` - Significant clarity and standards compliance
- `MEDIUM` - Good practices for professional documentation