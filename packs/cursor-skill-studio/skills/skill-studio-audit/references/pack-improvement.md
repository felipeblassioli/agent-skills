# Pack Improvement Review

Use this reference when the target artifact lives under `packs/`.

## Review Dimensions

Check the pack in this order:

1. **Current job**
   - Is the pack's runtime purpose clear in one sentence?
   - Is it bundling unrelated runtime concerns?

2. **Reusable versus local boundary**
   - What should remain reusable across repositories?
   - What should be discovered once and stored in repo-local overlays?
   - Is the pack carrying repository-specific noise?

3. **Subagent design**
   - Which subagent should run often?
   - Which subagent should run rarely?
   - Does a frequent subagent re-discover too much context?

4. **Steady-state context cost and Token Economy**
   - Pack hot path = every bundled skill's frontmatter `description`
     (always shipped) + `pack.json` `description` + rules with
     `alwaysApply: true` + subagent descriptions under
     `.cursor/agents/`. Bundled scripts, references, and
     `alwaysApply: false` rules are cold path.
   - What does the frequent path read today?
   - Can a bootstrap step write a small local contract so the common path stays
     cheap?
   - Run `python3 skills/skill-studio-audit/scripts/skill_hot_path_audit.py <pack> --json`
     and inspect `pack.cross_skill_duplication_buckets`. The named
     buckets are:
     - `multi_skill_shared_phrase` — identical 8+ word phrase across
       multiple bundled `SKILL.md` files (candidate for a shared
       reference).
     - `pack_readme_duplicates_intent_table` — README mirrors a
       bundled skill's intent-router table (recommend a one-line
       pointer instead).
   - Are there prompt-visible surfaces (long bundled skill
     descriptions, `pack.json.description`, agent descriptions) that
     bloat the payload? Cite
     `pack.pack_json_description_chars` and
     `pack.agents[].description_chars` for evidence.

5. **Rules and docs**
   - Are strict rules thin routing nudges, or are they reteaching the whole pack?
   - Does the README explain purpose and install shape without duplicating assets?

5b. **Bundled skills (`kind: "skill"` in `pack.json`)**
   - Are bundled skills **skill-shaped** (`SKILL.md`, `metadata.json` under
     `packs/<name>/skills/<folder>/`) rather than duplicated into rules or README?
   - Does each `skillId` follow a **pack-scoped** naming convention to limit
     collisions with `skill-registry.json` skills in `~/.cursor/skills/`?
   - Does `SKILL.md` frontmatter `name` match `skillId` (verifier expectation)?

6. **Install and safety**
   - Are targets and profiles clear?
   - Are examples still examples, not accidental live config?
   - Are project-only assets kept project-only?

## Diagnostic Questions

Ask only what is missing:

- What reusable runtime capability is this pack supposed to provide?
- What pain happens on the frequent path: too much noise, too much reading,
  weak routing, or unclear install/runtime behavior?
- What should be learned once during bootstrap instead of re-learned every run?
- What should the default summary look like when the pack is working well?
- What outcome matters most: cheaper runs, faster decisions, lower noise, safer
  installs, or clearer subagent boundaries?

## Verifier-Style Pattern

For noisy verification packs such as `node-test-verifier`, prefer this shape:

1. **Bootstrapper runs rarely**
   - scans `package.json`, local `AGENTS.md`, local rules, and project guidance
   - writes a small repo-local contract

2. **Verifier runs often**
   - reads the local contract first
   - selects the smallest meaningful tier set
   - checks prerequisites explicitly
   - returns a compact summary instead of raw logs

3. **Strict rule stays thin**
   - route to the verifier
   - route to the bootstrapper when the contract is missing or stale
   - do not reteach the full verification doctrine

4. **Stale-contract detection**
   - if scripts or local guidance changed materially, recommend rerunning the
     bootstrapper instead of broad rediscovery on every invocation

## Common Recommendations

| Problem | Recommendation | Expected outcome |
|---|---|---|
| Frequent subagent re-reads repo context | Add a bootstrap-once local contract | Faster and cheaper steady-state runs |
| Strict rule is too large | Reduce it to routing and guard-rails | Less noise in persistent guidance |
| Pack README duplicates runtime details | Keep README focused on purpose, profiles, and boundaries | Better discoverability with lower doc overhead |
| Repo-specific logic lives in reusable assets | Move it into local overlays | Better reuse across repositories |
| Frequent path returns raw output | Summarize failures, prerequisites, and coverage only | Faster informed decisions |

## Recommendation Bias

Default to:

- bootstrap once, run cheaply many times
- reusable runtime in the pack, repo specifics in local overlays
- fewer subagents with clearer jobs
- concise summaries over raw tool output
