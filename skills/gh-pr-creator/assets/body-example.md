# Body file example

A worked `.work/body-pr-<slug>.md` for turbi-guard's three-subsection template,
shown **after** the step-5 reviewer pass — this is what survives the cut, not a
first draft. Copy the shape, not the content — every field must reflect *this* PR's
real evidence (see the **Binding rules** in `SKILL.md`: no fabricated output,
human-only checkbox stays `[ ]` unless a human checked it).

File: `.work/body-pr-seed-safety.md`

```markdown
## Por que? <!-- why:init:required -->

Os scripts de seed rodam `DROP DATABASE` e `TRUNCATE TABLE` sem nenhuma checagem de
ambiente. O `.env` aponta para prod por padrão em máquina nova, então um `make mysql-seed`
antes de trocar a config derruba a base da análise de risco. Já aconteceu quase-erro em
onboarding (ver [ADR-0006](docs/ADR/ADR-0006-seed-safety-guardrails.md)).

<!-- why:end -->

## Como? <!-- how:init:required -->

Guard em duas camadas independentes: o `Makefile` barra o alvo antes de chamar o
cliente, e o próprio SQL aborta via `_assert_local_env`.

Não bastou o guard no `Makefile`: o seed também é executado à mão
(`mysql < seed.sql`), que não passa pelo alvo. Por isso a checagem vive dentro do
SQL, onde nenhum caminho de execução escapa dela.

Invariante: nenhum caminho — alvo do Make ou `mysql` direto — executa `DROP`/`TRUNCATE`
sem `_assert_local_env` passar primeiro. É isso que o diff deve mostrar.

| Arquivo | Mudança |
|---------|---------|
| `functions/db/schema/guard.schema.sql` | `_assert_local_env` lê `@@hostname`, não uma env var — env var é falsificável pelo chamador |
| `functions/db/seed/guard.seed.sql` | `CALL` no topo, antes de qualquer DDL; sem isso o `DROP` inline roda primeiro |

### Validação executada
- `npx jest --passWithNoTests` → **30 suites pass, 0 fail**
- `make lint` → exit 0

### Safe to merge
- Escopo focado em DX/dev tooling + docs
- Sem regressão nos testes
- Código de produção inalterado

<!-- how:end -->

## Comentários: <!-- comments:init -->

### Autoria e rigor
Gerado por: Claude Code / Opus 4.8. Prompt/origem: "proteger os scripts de seed contra execução em produção".
- [x] Um humano revisou o diff COMPLETO antes de submeter.
- [x] Testado adversarialmente, não só o happy path (ver break-the-fix em "Risco antes do merge").

### Risco antes do merge
- SHA `abc1234` · escopo: `Makefile` + 2 SQLs de seed; **não** toca código de produção nem migrações.
- Regressão: superset estrito — só adiciona guards; caminho feliz local inalterado.
- Break-the-fix: removendo `CALL _assert_local_env()` do seed, o teste `seed-guard` **falha**; restaurando, passa.
- Teto: rodei `jest` + `make lint` local; **não** cobre Sonar new-code (S3776/S3358/S4144) nem `typecheck:ci` — fecha só no CI.

### Verificação pós-deploy
N/A — mudança de tooling/DX (Makefile + SQL de seed); nada observável em produção. Sem deploy, sem query.

**Riscos aceitos:**
- `DROP DATABASE` no `make mysql-seed` roda inline — protegido por L1 + L2.

**Follow-ups:**
- TODO: renomear config key confusa no `.runtimeconfig.dev.json`

<!-- comments:end -->
```
