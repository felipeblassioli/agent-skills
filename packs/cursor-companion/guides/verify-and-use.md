# Verify and use cursor-companion (project install)

## How to verify the pack is installed

### 1. Check the install manifest

From any machine, the pack is installed in a project if that project has a manifest and the pack entry exists:

```bash
# Replace with your project root
PROJECT="/Users/you/dev/tmp/example-service"

# Pack is installed if this prints version and profile
jq -r '.packs["cursor-companion"] | "\(.version) profile=\(.profile) installedAt=\(.installedAt)"' \
  "$PROJECT/.cursor/.cursor-pack-manifest.json"
```

Expected: e.g. `0.1.1 profile=strict installedAt=2026-03-09T00:10:27Z`

### 2. Check expected files exist

For a **strict** profile project install, the pack copies agents, rules, hooks, and the MCP example:

```bash
PROJECT="/Users/you/dev/tmp/example-service"

# Agents (at least the pack’s three)
ls "$PROJECT/.cursor/agents/cursor-pack-auditor.md" \
   "$PROJECT/.cursor/agents/hook-policy-reviewer.md" \
   "$PROJECT/.cursor/agents/mcp-config-reviewer.md"

# Rules from the pack
ls "$PROJECT/.cursor/rules/10-surface-selection.mdc" \
   "$PROJECT/.cursor/rules/20-subagent-delegation-policy.mdc" \
   "$PROJECT/.cursor/rules/30-mcp-safety.mdc" \
   "$PROJECT/.cursor/rules/40-hook-guardrails.mdc"

# Hooks (strict only)
test -f "$PROJECT/.cursor/hooks.json" && test -d "$PROJECT/.cursor/hooks"

# MCP example (do not rename to mcp.json until reviewed)
test -f "$PROJECT/.cursor/mcp.example.json"
```

If all of these succeed, the pack is installed and complete for that project.

### 3. One-liner sanity check

```bash
PROJECT="/Users/you/dev/tmp/example-service"
jq -e '.packs["cursor-companion"]' "$PROJECT/.cursor/.cursor-pack-manifest.json" >/dev/null && echo "cursor-companion is installed" || echo "cursor-companion is NOT installed"
```

---

## How to use it

Once installed in a project, Cursor uses the pack’s assets automatically when you work in that project (with the project root as the workspace).

### Rules (`.cursor/rules/*.mdc`)

- **Automatic:** Cursor loads rules based on your settings (e.g. always-on or when files match `globs`).
- **10-surface-selection:** When to use skills, AGENTS.md, rules, subagents, hooks, MCP.
- **20-subagent-delegation-policy:** When and how to delegate to subagents.
- **30-mcp-safety:** Safe MCP configuration and review.
- **40-hook-guardrails:** What hooks enforce and how to keep them understandable.

No extra steps: open the repo in Cursor and the rules apply according to Cursor’s rule system.

### Subagents (`.cursor/agents/*.md`)

- **Invoke by name/description:** In Cursor, use the subagent picker or ask the agent to “run the cursor-pack-auditor” (or hook-policy-reviewer, mcp-config-reviewer).
- **cursor-pack-auditor:** Audits the project’s Cursor setup (rules, agents, hooks, MCP).
- **hook-policy-reviewer:** Reviews hook config and scripts for safety and clarity.
- **mcp-config-reviewer:** Reviews MCP config before you promote `mcp.example.json` to `mcp.json`.

Use them when you want a focused audit or review without bloating the main chat.

### Hooks (strict profile)

- **Automatic at runtime:** `hooks.json` and `.cursor/hooks/` are configured so Cursor runs the hook scripts (e.g. block dangerous shell commands, protect sensitive reads) when the agent runs commands or reads files.
- **No extra step:** If you installed with `--profile=strict`, hooks are active. Adjust `.cursor/hooks.json` or scripts in `.cursor/hooks/` only if you need to customize or disable something.

### MCP example

- **Not active by default:** The pack installs `mcp.example.json`, not `mcp.json`.
- **To use MCP:** Copy or rename to `mcp.json` only after reviewing the config (and using the mcp-config-reviewer subagent if you want). Never paste secrets into the file; use env interpolation where supported.

---

## Quick reference

| What you want | What to do |
|---------------|------------|
| Confirm install in a project | `jq '.packs["cursor-companion"]' <project>/.cursor/.cursor-pack-manifest.json` |
| Rely on rules | Open the project in Cursor; rules apply per Cursor settings |
| Run an audit | Ask the agent to use the cursor-pack-auditor (or other) subagent |
| Enforce guard-rails | Use a strict install; hooks run automatically |
| Use MCP | Review `mcp.example.json`, then copy to `mcp.json` and configure safely |
