# Codex Best Practices

When auditing or improving skills targeted for GitHub Copilot, Codex, or generic markdown-based agent systems.

## 1. Flat and Explicit Structure
Codex models benefit from flat, unambiguous declarative statements.
- **Rule**: Use active voice, verb-first naming.
- **Check**: Are the instructions clear, imperative, and formatted in bullet points or numbered lists?

## 2. Strict Markdown Parsing
- **Rule**: Avoid complex Graphviz (`.dot`) or Mermaid graphs if a simple Markdown list suffices, unless explicitly visualizing for the human partner via SVG rendering.
- **Check**: If a flowchart is present in `SKILL.md`, verify it only represents a non-obvious decision point. Remove it if it is just a linear process.

## 3. Single Source of Truth
- **Rule**: Prevent duplicate instructions across files, as this confuses models that cannot prioritize context well.
- **Check**: Ensure `SKILL.md` does not repeat the exact same instructions found in `references/`.

## 4. Modality Explicitness
- **Rule**: Use normative keywords strictly (`MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`).
- **Check**: Audit for weak language ("it would be good to", "try to") and propose replacements with normative keywords.
