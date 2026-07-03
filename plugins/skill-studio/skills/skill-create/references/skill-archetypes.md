# Skill Archetypes — Selection and Patterns

Choose the smallest archetype that fits the approved skill contract.

## Archetypes at a glance

| Archetype | Use when | Typical `SKILL.md` role |
|---|---|---|
| Knowledge Hub | The skill mainly routes domain questions to focused references | Dispatcher |
| Tool Runner | The skill mainly chooses and runs deterministic scripts or commands | Controller |
| Workflow Executor | The skill mainly follows a sequential procedure end to end | Playbook |
| Hybrid | One dominant archetype needs a narrow secondary pattern | Dispatcher with explicit limits |

## Selection rules

- Start from one dominant archetype.
- Use Hybrid only when one secondary behavior is clearly necessary.
- If the skill needs multiple equally strong archetypes, re-check whether the
  skill actually contains multiple jobs.

## Default section set

| Section | Knowledge Hub | Tool Runner | Workflow Executor |
|---|:---:|:---:|:---:|
| Applicability Gate | yes | yes | optional |
| Routing or Decision Table | yes | yes | no |
| Numbered Workflow | optional | optional | yes |
| Procedure | yes | yes | implicit |
| Confirmation Policy | yes | optional | yes |

## File-tree rules

Scaffold only what the archetype justifies:

| Path | Create when |
|---|---|
| `SKILL.md` | Always |
| `metadata.json` | Always (version/author/date/abstract; governance, not frontmatter) |
| `CHANGELOG.md` | Always (matching-version entry) |
| `references/` | The skill needs on-demand doctrine or focused explanations |
| `assets/` | The skill benefits from copyable templates, checklists, or quick references |
| `scripts/` | Deterministic execution or compact machine-readable output is required |

## Anti-bloat rules

- Do not create `assets/` or `scripts/` "just in case".
- Do not create README placeholders for empty directories.
- Keep references one link deep from `SKILL.md` (the One-Hop Rule).
- If `SKILL.md` starts becoming a dump, move detail into references.

---

## Exemplars (patterns from production skills)

The three archetype templates live in
`assets/templates/skill-archetypes/` (`knowledge-hub.md`, `tool-runner.md`,
`workflow-executor.md`); reuse them when scaffolding. The notes below capture
the distinguishing patterns of each.

### 1. Knowledge Hub

Pure dispatcher with a routing table:

```markdown
| Question | Route to |
|----------|----------|
| "What tier should this test be?" | assets/choose-tier.md |
| "Should I mock/stub/fake this?" | references/test-doubles.md |
| "Is my test suite healthy?" | references/suite-health.md |
```

Applicability gate with explicit redirect:

```markdown
## Applicability Gate

Apply this skill when ANY of the following are true:
- You need to decide which test tier a test belongs to
- You need to choose a test double type

Do NOT apply when:
- Deciding file suffixes or naming -> testing-organization
- Configuring test runners -> vitest-monorepo
```

Confirmation policy stating when to pause:

```markdown
## Confirmation Policy
Do NOT apply changes without explicit user confirmation.
Present proposed code as diffs and wait for approval.
```

**Choose when**: the skill is reference material (taxonomies, specs, guides),
users ask different questions at different times, the agent loads only the
relevant subset, and material volume is large (>500 lines across references).

### 2. Tool Runner

Decision table mapping inputs to actions:

```markdown
| Changed path pattern | Tiers to run |
|---|---|
| `domain/services/*.js` | unit |
| `domain/repositories/*.js` | unit + integration |
| Multiple layers touched | unit + functional (minimum) |
```

Delegation guidance — hand verbose, read-heavy work to a subagent:

```markdown
**Delegate** (use a subagent) when:
- Running a full tier or multiple tiers (output exceeds ~50 lines)
- Running coverage (long-running, verbose)

**Use directly** when:
- Running a single targeted test file
- Reading an existing coverage report
```

Output contract — the exact markdown the skill produces:

```markdown
## Verification Report
- **Changed files:** file1.js, file2.js
- **Tiers run:** unit, functional

### Results
| Tier | Passed | Failed | Duration |
|------|--------|--------|----------|
| unit | 47 | 0 | 4.2s |
```

**Choose when**: the skill executes scripts/commands, there is decision logic
for what to run, output needs a structured format for downstream consumers,
scripts are the core value. Reference bundled scripts via
`${CLAUDE_SKILL_DIR}/scripts/<name>`.

### 3. Workflow Executor

Principles upfront, before any steps:

```markdown
## Principles
- All PR content in Brazilian Portuguese.
- PR body must follow the repo template exactly, preserving comment markers.
- Use gh pr create --body-file to avoid shell escaping issues.
```

Numbered workflow with code per step:

```markdown
### 1. Discover repo and template
### 2. Gather context
### 3. Draft the body
### 4. Create or update the PR
```

Sizing table adapting depth to situation:

```markdown
| PR size | Guideline |
|---------|-----------|
| Small / trivial | 1-3 sentences |
| Medium | 1 paragraph + optional context table |
| Complex / high-risk | Up to ~15 lines; include threat tables |
```

**Choose when**: the skill is a sequential process the agent follows
end-to-end, steps are mostly inline, a complete worked example beats reference
documents, the workflow is relatively stable.

---

## Hybrid skills

When material spans archetypes, pick the dominant one as the base structure
and incorporate specific patterns from others:

| Dominant | Borrow from | Pattern to borrow |
|---|---|---|
| Knowledge Hub | Tool Runner | Add an output contract section |
| Knowledge Hub | Workflow Executor | Add a numbered procedure |
| Tool Runner | Knowledge Hub | Add a routing table for reference material |
| Tool Runner | Workflow Executor | Number the decision-table + execution steps |
| Workflow Executor | Knowledge Hub | Move deep reference material to `references/` |
| Workflow Executor | Tool Runner | Add scripts for automatable steps |

Key constraint: **SKILL.md stays under 500 lines.** If adding borrowed
patterns pushes it over, move content to supporting files.
