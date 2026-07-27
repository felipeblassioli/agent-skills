---
name: artifact-catalog
description: >-
  Keep the cross-repo artifact catalog current. Use whenever an artifact is produced or
  mentioned that should be tracked — a working doc, writeup, plan, review, verification report,
  before/after visual, architecture explainer, dependency map, or a published claude.ai artifact.
  Triggers on "catalog this", "add this to the artifact catalog", "track this artifact/doc",
  "update the artifact catalog", "did I catalog X", and on audit phrasing: "audit the catalog",
  "what artifacts are untracked", "reconcile the catalog against the tree", "is the catalog stale".
  Also invoke proactively right after you generate a bin/ doc or publish an Artifact, to offer to
  file it. The catalog only holds its value if it is updated the moment an artifact is created —
  a stale catalog is worse than none, so lean toward using this skill rather than skipping it.
---

# Artifact catalog

Maintains a personal, cross-repo index of working artifacts so nothing gets lost and each one
lands in the right place. The catalog is only useful if it stays current and honest about *where
each artifact should live* — that routing decision is the whole point, not just a list of files.

## The two homes

- **Master** — `~/agent-knowledge/catalog/ARTIFACT-CATALOG.md`. Cross-repo, personal, holds
  *everything* including private `claude.ai/code/artifact/...` URLs. This is the source of truth.
  Always update it. It lives in the private `agent-knowledge` repo — **commit after editing**;
  it was unbacked until 2026-07-25 and an unrecoverable edit would lose the routing for every
  artifact it indexes.
- **Repo slice** (optional) — e.g. `docs/artifact-catalog.md` in a repo. Repo-scoped, committed via
  a docs PR. It lists only that repo's durable docs + the routing convention. **Never put private
  claude.ai artifact URLs in a committed slice** — teammates can't open them and they don't belong
  in shared history. Reference repo docs by path and evidence by PR/issue number instead.

Match the existing table structure in each file rather than inventing new columns. Edits to the
master are personal notes, but they live in a git repo — **commit them**. Slice changes ride a docs PR — use the
`gh-pr-creator` skill.

## Routing tiers — the classification

Every artifact gets exactly one tier. The distinction is about *lifespan*, not format:

- **commit** — a durable decision or reference: ADR, RFC, proposal, runbook, threat model, guide.
  Outlives any single revision → belongs versioned under `docs/`.
- **convert** — durable knowledge trapped in a one-off format (an `.html` explainer, a published
  artifact): schema/data-flow explainers, dependency maps, issue maps, design docs. Same lifespan
  as `commit`, just the wrong file type → turn it into markdown under `docs/`.
- **attach** — point-in-time evidence: post-deploy / pre-merge verifications, PR/code reviews,
  before/after visuals, infra diffs, per-issue implementation plans. It is tied to a specific
  revision/PR and rots the moment that revision moves on → **link it on its PR/issue, do not
  commit it.** The PR template's risk / post-deploy subsections are its home.
- **cross** — belongs to a different repo (a sibling service, a shared library, a tooling repo).
  Record it in the master under Cross-repo with the target repo; file it there when ready.
- **discard** — not an artifact: empty files, curl/scratch (`err.txt`, `out.txt`, `teste.txt`,
  `foo*.json`), patches, log exports, config snapshots, ad-hoc CSVs. List under Discard so they can
  be gitignored; never track them as knowledge.

When a filename references a specific `pr-NNN` / `issue-NNN` and describes a check or review, it is
almost always **attach**. When it explains how something *works* (schema, flow, topology), it is
**commit** or **convert**. When in doubt, say which way you're leaning and why, and let the user
correct — the tier drives real actions (a PR vs a link), so a wrong guess wastes effort.

## Mode A — add / update one artifact

1. Identify it: a local path, or a published artifact (get its title + URL from the Artifact tool's
   `list` action).
2. **Reconcile first.** Grep the master for the same subject/PR/issue. If a row exists, *update* it
   (status, path, URL) — don't append a duplicate. If it looks like a near-dupe of another artifact
   (same topic, different cut), flag the pair and recommend which is canonical, as a reconciliation
   note — don't silently keep both.
3. Classify into a tier using the rules above.
4. Add/update the row in the master, in the right section (repo + tier). If it's a repo `commit`/
   `convert` item and that repo has a slice, offer to update the slice too (no private URLs).
5. Report the tier and the concrete next action ("→ link on PR #461", "→ convert to
   `docs/reference/<topic>.md`", "already filed in PR #552").

## Mode B — sweep / audit

Enumerate everything, diff against the catalog, surface gaps. Sweep **four** sources — current
repo, sibling repos, the personal workbench (`.blassioli/` on the `blassioli` branch), and
published artifacts. Skipping the sibling-repo sweep is how a cross-repo doc goes missing (a
service decommission plan once lived in a sibling repo and stayed invisible to a current-repo-only
sweep for weeks — reconciliation note in the master).

The sibling sweeps below assume `$WORKSPACE_ROOT` is the directory holding your repo clones
(`export WORKSPACE_ROOT=~/src` or wherever they live) and `$CURRENT_REPO` is the basename of the
one you're in.

1. **Current-repo candidates** (the repo you're in):
   ```bash
   git ls-files --others --exclude-standard bin/ docs/
   git ls-files --others --exclude-standard . | grep -vE '^(bin/|docs/|\.)' | grep -E '\.(md|html)$'
   ```
   Triage tiny/empty/scratch files into **discard** (check size + first line, don't assume).
2. **Sibling-repo candidates** — every other repo under `$WORKSPACE_ROOT`. These are almost all
   **cross** tier (they already live in their own repo); the sweep's job is to catch ones the
   master's Cross-repo section doesn't list yet, *not* to re-file them into the current repo.
   ```bash
   for d in "$WORKSPACE_ROOT"/*/; do
     name=$(basename "$d")
     [ "$name" = "$CURRENT_REPO" ] || [ "$name" = worktrees ] && continue   # skip current repo + worktrees (node_modules, 4k+ files)
     if [ -d "$d/.git" ]; then
       git -C "$d" ls-files 'docs/**/*.md' 'docs/**/*.html'                # tracked docs
       git -C "$d" ls-files --others --exclude-standard '*.md' '*.html'    # untracked loose artifacts (respects .gitignore)
     else
       find "$d" -maxdepth 3 \( -name '*.md' -o -name '*.html' \) -not -path '*/.*' 2>/dev/null | sed "s#^$d##"   # non-git fallback; strip abs prefix, skip dot-dirs
     fi | sed "s#^#$name/#"
   done
   ```
   `worktrees/` MUST be excluded — it's git worktree checkouts (node_modules, thousands of files),
   not repos. Guard on `.git` presence; plain directories get the `find` fallback.
3. **Personal-workbench candidates** — `blassioli` is the durable personal fork in *every* repo,
   and `.blassioli/` is its committed artifact home (e.g. `.blassioli/docs/00_triage/*.html`). Read
   it from the ref, not the working tree, so it's visible no matter which branch each repo has
   checked out (and a repo with no `blassioli` branch is silently skipped):
   ```bash
   for d in "$WORKSPACE_ROOT"/*/; do
     name=$(basename "$d"); [ "$name" = worktrees ] && continue
     git -C "$d" ls-tree -r --name-only blassioli -- .blassioli 2>/dev/null \
       | grep -E '\.(md|html)$' | sed "s#^#$name/#"
   done
   ```
   Assumes a local `blassioli` ref; `git fetch origin blassioli` first for a repo you only have it
   on the remote. `.blassioli/…/00_triage/` is a **staging location, not a tier** — an artifact
   parked there keeps whatever Target/tier it already had (an `attach` before/after visual is still
   `→ PR #465`; a `convert` explainer is still `→ docs/…`). Record its path in the row's *Location*,
   never let `00_triage` overwrite its *Target*.
4. **Published candidates:** Artifact tool, `action: "list"`.
5. Diff all four against the master. For each artifact not yet listed: classify + propose a row
   (sibling-repo items → Cross-repo section, keyed by target repo).
6. Flag likely duplicate pairs and stale rows (e.g. a `convert` item that's since been committed —
   promote its status). Keep the Discard list and Reconciliation notes current.
7. Present the proposed changes grouped by tier before writing, then apply to the master.

## Guardrails

- **Idempotent:** re-running must not create duplicate rows. Update in place; key on subject +
  PR/issue, never on line position.
- **Moves are rewrites, not rediscoveries:** when a batch of artifacts relocates (e.g.
  `bin/*` → `.blassioli/artifacts/`), don't re-sweep and reclassify — that risks dropping
  status/Target. Rewrite the *Location* column in place with one pass, e.g.
  `sd '`bin/([A-Za-z0-9._-]+\.(html|md))`' '`.blassioli/artifacts/$1`' ~/agent-knowledge/catalog/ARTIFACT-CATALOG.md`.
  A move changes only *where the file is*; tier and Target are unaffected.
- **Deletion is keyed on tier, not on PR state.** Before deleting an artifact, all three must hold:
  its tier is **attach**, its PR/issue is merged/closed, *and* no *open* case file references it.
  A merged PR is not permission — a `convert`-tier explainer outlives the PR that produced it, and
  an `attach` verification is still evidence while its ticket is open. Applying "merged ⇒ delete"
  on PR state alone destroyed a `convert` explainer and an in-use verification on 2026-07-25; both
  were unrecoverable because neither had been committed anywhere. Check the tier column first.
- **Privacy:** private claude.ai URLs → master only. Redact secrets/PII/internal hostnames from any
  content you commit (the master is personal and can hold more, but still no credentials).
- **Don't over-file:** most `bin/*` files are `attach`-tier evidence — the right action is a link on
  the PR/issue, not a new committed doc. Committing evidence is the common mistake this catalog exists
  to prevent.
