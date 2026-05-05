# Roadmap

Next steps for `agentic-artifact-discovery`.

## Near term

- Extend the committed `verification-outputs/` set beyond `tmp/BMAD-METHOD` to
  cover `tmp/superpowers` and `tmp/claude-plugin-engineering`.
- Add sharper heuristics for identifying actor roles, trigger phrases, and
  cross-file workflow boundaries in large agentic systems.
- Tighten guidance for catalog-driven systems where routing lives in CSV, YAML,
  or manifest files rather than obvious root docs.
- Pressure test anti-triggers so the pack avoids drifting into generic repo
  mapping, migration work, or debugging.
- Refine the report template based on real usage and reviewer feedback.

## Medium term

- Decide whether a second bounded helper role is justified for comparison or
  ambiguity resolution.
- Add optional examples for recurring agentic patterns such as slash-command
  bundles, skill trees, and mixed plugin manifests.
- Decide whether committed prompt matrices should stay hand-curated or grow into
  a small repeatable eval loop.

## Pack evolution

- Keep the pack focused on discovery and explanation rather than conversion,
  import, or enforcement.
- Avoid adding hooks, MCP examples, or persistent rules until real usage proves
  they are necessary.
- Keep the bundled skill compact and move heavy heuristics into one-hop
  references.
- Keep `CHANGELOG.md` and `VERIFICATION.md` updated on every meaningful release.
- Keep committed validation artifacts curated and small; raw iteration outputs
  stay in `.work/`.

## Success signals

- Investigations quickly separate roles, artifacts, flows, and use cases without
  flooding the parent context.
- The bundled skill routes to the exploration subagent before large reads.
- The workflow stays accurate across skill ecosystems, workflow frameworks, and
  Claude-style plugin bundles.
- The pack continues to complement migration and import skills rather than
  replacing them.
