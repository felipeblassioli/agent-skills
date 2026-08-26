# The reviewer pass

The subtractive edit that turns a drafted body into one a reviewer can use. Run it
**after** the draft is complete and **before** `gh pr create` / `gh pr edit` — never
while drafting. Drafting is generative; this pass is adversarial to what drafting
produced, and the two stances do not mix in one read.

## Stance

Re-read the body as the reviewer who **already has the diff open**. That reviewer can
read code faster than prose. Every sentence competes with `git diff` for their
attention, and prose only wins when it carries something the diff cannot show:
why the change exists, what boxed it in, what was decided against, what must stay
true, what can break, and what was actually run.

Two tests, applied per sentence — not per section:

1. **Diff-redundancy test** — *would the reviewer learn this faster from the diff itself?*
   If yes, delete it. `--stat` names the files; the hunk shows the mechanics.
2. **Decision test** — *does this sentence change how the reviewer understands or reviews
   the change?* If it changes neither, delete it. "True but inert" is still a delete.

A body that survives both tests is usually much shorter than the draft. That is the
expected outcome, not a sign something is missing.

## Keep-list

Six things survive. Everything else is a delete candidate until argued otherwise.

| Keep | The question it answers | Where it lands |
|------|------------------------|----------------|
| **Intent** | What broke or what fails today, in observable terms | `Por que?` |
| **Constraints** | What boxed the solution in — API contract, compat window, runner limits, deadline, data already in prod | `Por que?` / `Como?` |
| **Decisions** | Why *this* approach and not the obvious one; alternatives rejected and why | `Como?` |
| **Invariants** | What must stay true after this change; what the change must not break | `Como?` / `Risco antes do merge` |
| **Risks** | What can still break, blast radius, rollback trigger | `Risco antes do merge` / `Verificação pós-deploy` |
| **Verification** | Commands actually run + real results; falsifiable proofs; named gaps | `Validação executada` / `Risco` / `Verificação pós-deploy` |

`Decisions` and `Invariants` are the two most often missing from a machine-drafted body,
and the two a reviewer most wants. A reviewer who knows what you rejected does not
re-propose it in a comment; a reviewer who knows the invariant reviews *against* it
instead of guessing at one.

## Cut-list

| Tell | Why it fails | Do instead |
|------|--------------|-----------|
| File-by-file inventory mirroring `--stat` | The reviewer has `--stat`; a table of paths + restated filenames is slower | Keep only rows carrying a non-obvious note (a decision, an invariant, a gotcha). Cut the rest; drop the table if no row survives |
| `Added X / Updated Y / Refactored Z` bullets | This is a changelog, not a review aid — the canonical release-notes shape | One sentence of intent, then only what is non-obvious |
| Restating what a function/flag does | Its name and body say it faster | Say why it exists, or cut |
| A `Resumo` that recaps `Por que?` + `Como?` | Pure duplication; costs a read, adds nothing | Delete. The sections *are* the summary |
| Explaining well-known tooling | The reviewer knows jest, ArgoCD, Terraform | Cut. Explain only your *use* of it when surprising |
| Marketing adjectives (`robusto`, `abrangente`, `significativamente`, `cuidadosamente`, `simplesmente`) | Overclaim, unfalsifiable, filler | State the fact: "cobre o caso X" |
| Emoji-decorated headings / bullets, symmetric heading scaffolding | Release-notes and generated-text tells | Plain headings; drop sections with nothing real (see honest-gap floor) |
| `Este PR introduz…` / `This PR adds…` openers | Wastes the first line, the one most likely to be read | Open on the problem or the decision |
| Padding to fill a section | Length signals importance; inflating a trivial change misleads | `N/A — <motivo concreto>` or one line |
| Hedging (`deve passar`, `provavelmente verde`, `parece seguro`) | Hides what was not run | Name what ran locally, and name the gap |
| Three paragraphs on a one-line rename | Length must track diff size | One or two sentences |

## Two hard limits on this pass

**Delete-only.** The pass removes and tightens. It does not add claims. Adding at edit
time — after context has faded — is where invented test counts, SHAs, and revision names
appear. If a keep-list gap is real, go get the evidence and re-draft; do not write the
sentence you wish were true. See **Binding rules** in `SKILL.md`.

**Honest-gap floor.** Conciseness never justifies deleting:

- `não executado` / `INCONCLUSIVE` / an `N/A` plus its concrete reason
- the local≠CI ceiling
- the unchecked human-review checkbox
- any `[OB-n]`/`[PD-n]` pair or break-the-fix proof
- an accepted risk or a follow-up issue reference

These *are* keep-list content — verification and risk. A shorter body that dropped a
named gap is not cleaner; it is a body that now overclaims. Cutting an honest gap to
look concise is the one way this pass makes a PR worse than the draft it replaced.

## Voice

Concise human engineer, not generated release notes. Concretely: varied sentence length,
no forced parallel structure, no bullet list where two sentences do the job, first
person when it is honest ("não consegui reproduzir localmente"), and plain statements
of uncertainty instead of confident vagueness. A body that reads as *symmetric* almost
always reads as generated.

## Worked example — trivial PR

Draft (release-notes voice, 9 lines):

```markdown
## Por que? <!-- why:init:required -->
Este PR realiza uma melhoria significativa na consistência de nomenclatura do
código, renomeando cuidadosamente a variável `usr` para `user` em todo o módulo
de autenticação, o que aumenta a legibilidade e a manutenibilidade do código.

### Arquivos alterados
| Arquivo | Mudança |
|---------|---------|
| `src/auth/session.ts` | Renomeia `usr` → `user` |
| `src/auth/token.ts` | Renomeia `usr` → `user` |
<!-- why:end -->
```

After the pass (2 lines):

```markdown
## Por que? <!-- why:init:required -->
`usr` colidia com o parâmetro `usr` do middleware em `session.ts`, o que já causou
uma leitura errada em review. Rename puro, sem mudança de comportamento.
<!-- why:end -->
```

What went and why: the adjectives (`significativa`, `cuidadosamente`) overclaimed a
rename; the file table repeated `--stat`; "aumenta a legibilidade" is unfalsifiable.
What arrived: the concrete trigger (a real misread caused by a real collision) and the
invariant the reviewer should check the diff against (no behavior change).

## Worked example — medium PR

Draft `Como?` (release-notes voice):

```markdown
Refatoramos de forma abrangente o cliente HTTP para adicionar retry.

| Arquivo | Mudança |
|---------|---------|
| `src/http/client.ts` | Adiciona retry |
| `src/http/backoff.ts` | Novo arquivo com backoff exponencial |
| `src/http/index.ts` | Exporta `backoff` |
| `test/http/client.test.ts` | Novos testes |
| `package.json` | Nenhuma dependência nova |
```

After the pass:

```markdown
Retry no cliente HTTP, com backoff exponencial próprio em `src/http/backoff.ts`.

Não usei `p-retry`: o cliente roda dentro de uma Cloud Function gen2 e a lib puxa
3 dependências transitivas — não vale o cold start para ~40 linhas.

Invariante: retry só em 5xx e timeout. 4xx continua propagando na primeira
tentativa; `test/http/client.test.ts` cobre isso (um 409 não deve ser reenviado,
porque o endpoint de cobrança não é idempotente).

### Validação executada
- `npx jest test/http` → **12 pass, 0 fail**
- Sonar new-code: só no CI, não rodei local.
```

What went: four of five table rows (an export line, a test file, and a "no new deps"
row the reviewer reads off `package.json`). What arrived: the rejected alternative with
its reason, the invariant with the domain reason it exists, and a real command with a
real result plus a named gap. Same change, fewer lines, and now reviewable.

## Exit criteria

Before submitting, confirm:

- [ ] Every remaining sentence maps to one of the six keep-list categories.
- [ ] No sentence restates something `--stat` or a hunk shows faster.
- [ ] Body length tracks diff size.
- [ ] The pass only removed and tightened — it added no new factual claim.
- [ ] Every honest gap that was in the draft is still in the body.
- [ ] Read aloud, it sounds like an engineer explaining the change, not a release note.
