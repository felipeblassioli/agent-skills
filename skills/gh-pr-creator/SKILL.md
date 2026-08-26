---
name: gh-pr-creator
description: Create and update GitHub pull requests using gh CLI for repositories that use a `.github/pull_request_template.md` with comment markers. PRs are written in Brazilian Portuguese and staged in `.work/` body files. Use when the user asks to create a PR, open a PR, update a PR description, or prepare a PR body.
---

# GitHub PR Creator (PT-BR)

## Principles

- All PR content is written in **Brazilian Portuguese**.
- The PR body must follow the repo's `.github/pull_request_template.md` exactly, preserving comment markers. **Always read the repo's live template at runtime** (step 1); the reference copy in [assets/pull_request_template.md](assets/pull_request_template.md) is only a fallback and may lag the repo. Fill whatever subsections the repo's template defines — do not hardcode a fixed set.
- PR body files are staged in `.work/` before submission (never deleted — they serve as history).
- Use `gh pr create --body-file` / `gh pr edit --body-file` to avoid shell escaping issues.
- Commit titles follow Conventional Commits: `type(scope): description` (title in English is acceptable; body in PT-BR).
- The body earns its length. Draft, then run the **reviewer pass** (step 5) before submitting —
  it is a mandatory step, not an optional polish.

## Binding rules — honesty and scope (read before writing anything)

A PR template can shape a body but cannot enforce honesty; the authoring agent must.
These are hard constraints, not style preferences. When you (an agent) write a PR body,
you MUST NOT:

- **Fabricate evidence.** Only paste command output you actually ran and observed in this
  session. Never invent test counts, coverage %, timings, SHAs, revision names, error
  rates, or issue numbers. If a command wasn't run, write `não executado` — never
  `deve passar` / "should pass" / "provavelmente verde". A plausible-sounding guess is a
  lie with better grammar.
- **Check a human-only box.** Any checkbox that asserts a *human* action — e.g.
  `- [ ] Um humano revisou o diff COMPLETO` — stays `[ ]`. Marking it yourself is a false
  attestation of something you cannot do. Leave it for the human and say so if asked.
- **Claim rigor you didn't produce.** The *"Testado adversarialmente"* checkbox may be
  `[x]` only when a real break-the-fix proof exists — point to it in "Risco antes do
  merge". No proof → leave `[ ]`.
- **Misstate provenance.** "Gerado por" names the real author: model + version + harness
  when you wrote it; `humano` only when a human did. Don't launder agent-written text as
  human-authored.
- **Overstep the verify skills.** You author the body; you do not run `pre-merge-verify` /
  `post-deploy-verify` unless they were actually invoked. If they weren't, the subsection
  states the gap (`pendente: rodar pre-merge-verify`) instead of manufacturing their
  evidence.
- **Author only falsifiable proofs.** Every `[PD-n]` you write into "Verificação
  pós-deploy" — and every break-the-fix you claim in "Risco antes do merge" — must **fail
  when the change didn't happen**. Apply the test before writing it down: *if this PR had
  done nothing and you ran this query against the new revision, would it still pass?* If
  yes, the proof is **non-discriminating** — tighten it (scope to the new `revision_name` +
  post-deploy window, assert the new field/value, not "logs exist") or don't write it. A
  green non-discriminating check is worse than none: it manufactures false confidence. This
  is `post-deploy-verify`'s core discipline; you honor it at *authoring* time, which is not
  the same as running the skill.
- **`INCONCLUSIVE` is an honest verdict, never a PASS.** When a proof *ran* but couldn't
  resolve (no creds, unresolved `sha→revision`, undetermined runtime surface), the honest
  state is `INCONCLUSIVE` — never upgrade it to PASS by guessing. It sits alongside `não
  executado` (never ran) and a substantiated PASS/FAIL; don't collapse the three.
- **Redact secrets in provenance.** `Prompt/origem` is optional context — strip tokens,
  PII, and internal hostnames. It is context, never the proof of rigor.

When you cannot substantiate a field, write what you *don't* know. An honest gap is
reviewable; a confident fabrication wastes the reviewer's trust and the whole point of
the template.

## What makes a good PR

These guidelines reduce reviewer burden and accelerate merge cycles.

### Focused scope

Keep PRs short. If a diff exceeds ~500 lines, consider splitting. Separate refactoring from behavioral changes — a reviewer should not have to untangle "no-brainer rename" from "new feature logic" in the same diff.

### Explain intent, not just mechanics

The **Por que?** section answers "why does this change exist?" so the reviewer understands the goal before reading code. Without it, the reviewer must reverse-engineer intent from the diff — slow and error-prone. A cryptic title and empty body is the fastest way to get a PR ignored.

### Organized commits

When a PR contains multiple logical changes, split them into separate commits within the PR. This lets the reviewer examine each piece in isolation. When addressing reviewer feedback, add new commits instead of squashing — the reviewer can quickly verify their comments were addressed.

### Tests as proof

Every PR should include tests or explain why not. Choose the right tier: unit test for isolated logic, integration/smoke for behavior changes. Include the test run output in the PR body ("Validação executada") or as a proof comment.

### Track follow-ups explicitly

When deferring work to a later PR, open an issue (or add a `TODO(<issue>)`) and reference it in the **Comentários** section. This gives reviewers confidence that follow-ups won't be forgotten.

### Earn every sentence

The reviewer already has the diff open and reads code faster than prose. Prose only wins
when it carries what the diff cannot show. Six things qualify:

| Keep | The question it answers | Where it lands |
|------|------------------------|----------------|
| **Intent** | What broke or fails today, in observable terms | `Por que?` |
| **Constraints** | What boxed the solution in (API contract, compat window, runner limits, data already in prod) | `Por que?` / `Como?` |
| **Decisions** | Why this approach and not the obvious one; what was rejected and why | `Como?` |
| **Invariants** | What must stay true after the change; what it must not break | `Como?` / `Risco antes do merge` |
| **Risks** | What can still break, blast radius, rollback trigger | `Risco antes do merge` / `Verificação pós-deploy` |
| **Verification** | Commands actually run + real results; falsifiable proofs; named gaps | `Validação executada` / `Risco` / `Verificação pós-deploy` |

Everything else is a delete candidate. Two tests, applied **per sentence**:

1. **Diff-redundancy** — would the reviewer learn this faster from the diff itself? Delete it.
2. **Decision** — does it change how the reviewer understands or reviews the change? If not,
   delete it. "True but inert" is still a delete.

`Decisions` and `Invariants` are what a machine-drafted body most often lacks and a reviewer
most wants: a reviewer who knows what you rejected won't re-propose it, and one who knows the
invariant reviews *against* it instead of guessing at one.

Length tracks diff size — a one-line rename gets one line of `Por que?`. Empty scaffolding
says `N/A — <motivo concreto>`, never padding. `parece seguro` / `deve funcionar` /
`provavelmente passa no CI` are not evidence and hide what you didn't run; name the command,
the result, and the gap.

This is the discipline the template's HTML comments ask for (`Evidência > opinião`) — but
those comments vanish in the rendered PR, so the burden is on the author. Apply it as a
distinct pass in step 5; the cut-list, the release-notes tells, and worked before/after
rewrites live in [references/reviewer-pass.md](references/reviewer-pass.md).

## Workflow

### 1. Discover repo and template

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
```

Read `.github/pull_request_template.md`. The standard template pattern uses comment markers required by the CI pipeline:

```markdown
## Por que? <!-- why:init:required -->
<!-- why:end -->

## Como? <!-- how:init:required -->
<!-- how:end -->

## Comentários: <!-- comments:init -->
<!-- comments:end -->
```

Content goes **between** the opening marker line and its corresponding `<!-- ...:end -->`. Never remove or reorder the markers.

### 2. Gather context

Run in parallel to understand the full change set:

```bash
git log --oneline main..HEAD
git diff main..HEAD --stat
git diff main..HEAD
```

Adjust `main` to the actual base branch when stacking PRs.

### 3. Draft the body in `.work/`

```bash
mkdir -p .work
```

Name the file `body-pr-<slug>.md` — slug is a short descriptor (branch name, feature, or PR number for updates).

### 4. Section guidelines

#### Por que? (required)

**Why does this change exist?** Focus on the problem, motivation, or business need.
State the **concrete failure or observed behaviour** that motivates the change — "o que
quebrou / o que falha hoje" — not a vague "melhorar X". "Improving" is not a problem
statement; name what broke or what the user experienced.

| PR size | Guideline |
|---------|-----------|
| Small / trivial | 1–3 sentences |
| Medium | 1 paragraph + optional context table |
| Complex / high-risk | Up to ~15 lines; include threat/impact tables, ADR references |

Good patterns:
- Lead with the core motivation in one sentence
- Include risk/impact context when relevant (threat tables, probability/impact matrices)
- Reference ADRs, issues, or prior art: a markdown link to the ADR under `docs/ADR/`, or `Fixes #123`
- If the PR addresses a tracked issue, link it here

#### Como? (required)

**How was it done?** This is the technical narrative.

Lead with the decision, not the inventory: what approach was taken, what was rejected, and
the invariant the reviewer should check the diff against.

Good patterns:
- Lead with branch/stacking info if relevant: `**Branch:** \`patch/12-foo\` stacked on \`patch/11-bar\``
- A file table is for **orienting on a diff too large to hold in the head** — not an
  inventory. Each row must say something the path doesn't (a decision, an invariant, a
  gotcha); rows that restate the filename duplicate `--stat`. Drop the table when no row
  survives:
  ```markdown
  | Arquivo | Mudança |
  |---------|---------|
  | `path/file.js` | O que não é óbvio olhando o arquivo |
  ```
- Group changes by theme when the diff spans multiple areas: "Infraestrutura", "Código", "Testes", "Documentação"
- Include a **Validação executada** subsection with actual commands and their results:
  ```markdown
  ### Validação executada
  - `npx jest --passWithNoTests` → **30 suites pass, 0 fail**
  - `make lint` → exit 0
  ```
- End with a **Safe to merge** bullet list summarizing why merge is safe (scope containment, no regressions, feature-flagged, etc.)

#### Comentários

When the repo's template defines `###` subsections inside the `comments` block, fill them
(they are `###` headings **inside** the parsed `comments` markers — never add new top-level
`## … <!-- marker -->` sections). turbi-guard defines three, mapped to the verify skills:

| Subseção | Skill | Preencher com |
|----------|-------|---------------|
| **Autoria e rigor** | *author* (this skill) | `Gerado por` (modelo/versão + harness, ou "humano"); `Prompt/origem` (opcional, **redigido** — sem segredos/PII/hosts); os dois checkboxes. O checkbox *"testado adversarialmente"* é satisfeito pela break-the-fix de "Risco antes do merge" — aponte, não duplique. **Nunca marque a caixa "um humano revisou o diff" nem invente a break-the-fix** — ver [Binding rules](#binding-rules--honesty-and-scope-read-before-writing-anything). |
| **Risco antes do merge** | `pre-merge-verify` | SHA + escopo do diff, análise de regressão, prova break-the-fix, teto local≠CI, testes com resultado REAL |
| **Verificação pós-deploy** | `post-deploy-verify` (PLAN) | **Apenas a *declaração* estável (só isso vai no corpo):** classifique a mudança em **UMA** classe (`behavior`/`tracing-correlation`/`tracing-otel`/`logger`/`process-safety`/`infra` — se abranger várias, separe os artefatos ou divida o PR); pares `[OB-n]`↔`[PD-n]`, cada um escopado à `revision_name` + janela pós-deploy e que **passa no teste de falseabilidade** ([Binding rules](#binding-rules--honesty-and-scope-read-before-writing-anything)); guarda RED (vs. a revision anterior como baseline); gatilho de rollback explícito. O corpo **aponta** para o comentário `<!-- post-deploy-verification -->` (aberto como *stub*, resultados ⬜ TODO, em PLAN) — **não duplique** ali a evidência que evolui. N/A com justificativa concreta se nada for observável. |

Anything else that doesn't fit above also goes here:
- Accepted risks (with justification)
- Follow-ups with issue references: `TODO: #45 — adicionar guard equivalente para MongoDB`
- Stacking notes / merge order dependencies
- WIP disclaimers if using draft PRs for early feedback

### 5. Reviewer pass (mandatory, before submitting)

Re-read the drafted file once, as the reviewer who already has the diff open. Apply the two
tests from [Earn every sentence](#earn-every-sentence) sentence by sentence and cut what
fails. Two hard limits on this pass:

- **Delete-only.** It removes and tightens; it never adds a factual claim. Adding here —
  after context has faded — is where invented test counts, SHAs, and revision names appear.
  If a keep-list gap is real, go get the evidence and re-draft.
- **Honest-gap floor.** Never cut `não executado`, `INCONCLUSIVE`, an `N/A` plus its concrete
  reason, the local≠CI ceiling, the unchecked human-review box, an `[OB-n]`/`[PD-n]` pair, a
  break-the-fix proof, an accepted risk, or a follow-up reference. Those *are* keep-list
  content (risk and verification). A shorter body that dropped a named gap now overclaims.

Expect the result to be noticeably shorter than the draft; that is the point, not a loss.
See [references/reviewer-pass.md](references/reviewer-pass.md) for the cut-list, the
release-notes tells, worked before/after rewrites, and the exit checklist.

### 6. Create or update the PR

**Create:**

```bash
gh pr create \
  --title "type(scope): concise description" \
  --body-file .work/body-pr-<slug>.md \
  --base main
```

**Draft PR for early feedback** (prefix title with `WIP:` or use `--draft`):

```bash
gh pr create \
  --draft \
  --title "WIP: type(scope): concise description" \
  --body-file .work/body-pr-<slug>.md \
  --base main
```

**Update existing:**

```bash
gh pr edit <NUMBER> --body-file .work/body-pr-<slug>.md
```

Add `-R OWNER/REPO` when running from outside the repo or from a different clone.

### 7. Add proof comments

After PR creation, attach test evidence as a PR comment:

```bash
gh pr comment <NUMBER> --body "$(cat <<'EOF'
### Proof: test run

```
<paste test output>
```
EOF
)"
```

## Body file example

A full worked `.work/body-pr-<slug>.md` covering all three Comentários subsections
lives in [assets/body-example.md](assets/body-example.md). Copy its **shape**, never
its content — every field must reflect the real PR (see [Gotchas](#gotchas) and the
Binding rules above).

## Quick reference

| Action | Command |
|--------|---------|
| List open PRs | `gh pr list --base main --state open` |
| View PR body | `gh pr view <N> --json body -q .body` |
| Create PR | `gh pr create --title "..." --body-file .work/body-pr-<slug>.md` |
| Create draft PR | `gh pr create --draft --title "WIP: ..." --body-file .work/body-pr-<slug>.md` |
| Update PR body | `gh pr edit <N> --body-file .work/body-pr-<slug>.md` |
| Add comment | `gh pr comment <N> --body "..."` |
| Check CI status | `gh pr checks <N>` |
| Cross-repo | Add `-R OWNER/REPO` to any command |

## Gotchas

The traps that actually break a PR body — *trap → do this instead → where to check*:

- **The template is machine-parsed; the markers are load-bearing.** The registration
  pipeline reads `<!-- why:init:required -->` / `<!-- how:init:required -->` /
  `<!-- comments:init -->` (and their `:end`). Removing, reordering, or duplicating a
  marker — or adding a **new** top-level `## … <!-- marker -->` section — breaks the
  pipeline. Put new fields as `###` subsections *inside* the existing `comments` block.
  Check: exactly one of each `:init`/`:end` pair, none nested, none renamed.
- **HTML comments don't nest.** A guiding `<!-- … -->` cannot contain another
  `<!-- … -->`: the first `-->` closes the outer comment early and leaks the rest as
  visible text into the rendered PR. Keep marker explanations in prose *outside* the
  template, and never wrap a comment around a block that already has one. Check: render
  the body (or `gh pr view <N>`) and confirm no guide text is visible.
- **The `assets/` reference copy drifts.** `assets/pull_request_template.md` is a
  *fallback*, not the source of truth — the repo's live template changes independently.
  Always read `.github/pull_request_template.md` from the target repo at runtime (step 1)
  and fill whatever subsections *it* defines. Check: did you `cat` the repo template this
  run, or assume the bundled copy?
- **Fabrication and human-only fields (see [Binding rules](#binding-rules--honesty-and-scope-read-before-writing-anything)).**
  The template can't stop an agent from inventing `30 suites pass` or ticking
  "um humano revisou o diff". Only paste output you actually ran; leave the human-review
  checkbox `[ ]`; mark "testado adversarialmente" only when a real break-the-fix exists.
  Check: can you point to the command output / proof behind every claim and checkbox?
- **A conciseness pass that deletes an honest gap makes the PR worse.** Step 5 cuts prose,
  not disclosure — a named gap that vanishes silently becomes an implied PASS, and a claim
  that appears at edit time is usually invented. Keep the [honest-gap
  floor](#5-reviewer-pass-mandatory-before-submitting). Check: diff the draft against the
  submitted body — did any gap or proof disappear, or any new claim appear?
- **A non-discriminating post-deploy proof is a green that proves nothing.** A `[PD-n]` not
  pinned to *this deploy's* `revision_name` + post-deploy window — or that only asserts
  "logs exist" — passes even with the PR reverted: a false PASS worse than no check. Scope
  to the new revision, assert the specific new field/value, and mentally revert the PR — if
  the proof still passes, tighten it. This is `post-deploy-verify`'s run-time discipline;
  honor it when you *author* the declaration. Check: every `[PD-n]` names the new
  `revision_name` and the concrete new signal, not just a log's existence.
