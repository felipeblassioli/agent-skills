# Plugin Improvement Review

Use this reference when the target artifact is a Claude Code **plugin**:
a directory with `.claude-plugin/plugin.json` that bundles one or more
skills under `skills/`, helper subagents under `agents/`, and optional
commands and hooks.

The unit of leverage in a plugin is the *set* of surfaces the model
sees, not any one skill. Review the plugin as a portfolio.

## Review Dimensions

Check the plugin in this order:

1. **Current job**
   - Is the plugin's purpose clear in one sentence?
   - Is it bundling unrelated concerns that should be separate plugins?

2. **Skill boundaries**
   - Does each bundled skill have a single reusable job?
   - Do two skills overlap enough that their descriptions collide and
     the wrong one triggers? (A trigger collision is the most common
     plugin-level defect.)
   - Is there a job with no home, or a job split awkwardly across two
     skills?

3. **Cross-skill duplication**
   - Do multiple `SKILL.md` files repeat the same doctrine, phrasing, or
     tables? Shared doctrine belongs in one reference that the skills
     point to, not copied into each skill.
   - Does the plugin `README.md` duplicate a skill's intent-router
     table? Prefer a one-line pointer over a mirrored table.

4. **Hot path and token economy**
   - Plugin hot path = every bundled skill's frontmatter `description`
     (all shipped to the model for routing) + `plugin.json`
     `description` + every subagent `description` under `agents/`.
     Bundled scripts, references, and skill bodies are cold path.
   - Because every skill description is always in the routing payload,
     tightening descriptions across the plugin is often the
     highest-leverage change.
   - Cite measured character/line counts (for example
     `plugin.json` description length, per-skill description length,
     per-agent description length) as evidence, not token estimates.

5. **Subagent design**
   - Which subagent runs often, and which rarely?
   - Does a frequent subagent re-discover context it could read from a
     small local contract written once?
   - Are subagent descriptions thin routing nudges, or do they restate
     the whole workflow?
   - Fewer subagents with clearer jobs beat many overlapping ones.

6. **plugin.json manifest**
   - Is the `description` accurate and tight (it is always in the hot
     path)?
   - Are `version`, `author`, `homepage`, and `repository` present and
     consistent with the bundled skills' `metadata.json`?

7. **Behavior**
   - Does the change improve which skill activates and the quality of
     its decisions?
   - Does it reduce steady-state context cost?

## Diagnostic Questions

Ask only what is missing:

- What reusable capability is this plugin supposed to provide?
- Where is the pain: wrong-skill triggering, duplicated doctrine, bloated
  descriptions, weak subagent boundaries, or an inaccurate manifest?
- What doctrine is copied across skills that should live in one place?
- What should a subagent learn once (a bootstrap contract) instead of
  re-learning every run?
- What outcome matters most: better routing, lower token cost, less
  duplication, or clearer subagent boundaries?

## Common Recommendations

| Problem | Recommendation | Expected outcome |
|---|---|---|
| Two skills trigger on the same prompts | Sharpen each description with anti-triggers, or merge/split the jobs | Correct skill activates; fewer false positives |
| Same doctrine copied across skills | Extract to one shared reference; point skills at it | Less duplication, cheaper maintenance |
| README mirrors a skill's intent table | Replace with a one-line pointer | Lower doc overhead, single source of truth |
| Skill descriptions are long and prose-heavy | Trim every description to WHAT + WHEN + anti-triggers | Smaller routing payload, better routing |
| Frequent subagent re-reads plugin/repo context | Add a bootstrap-once local contract it reads first | Faster, cheaper steady-state runs |
| Many overlapping subagents | Consolidate to fewer with clearer jobs | Clearer dispatch, less confusion |
| `plugin.json` description is stale or vague | Rewrite it to match what the bundled skills actually do | Accurate top-level routing |

## Recommendation Bias

Default to:

- sharper triggering across the portfolio before better prose in any one skill
- one shared reference over duplicated doctrine
- smaller descriptions before more examples
- fewer subagents with clearer jobs
- a new bundled skill only when a job truly has no home
