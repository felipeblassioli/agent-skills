<!-- Este arquivo é usado por um processo automatizado, favor respeitar o preenchimento dentro dos campos de comentário. Caso o padrão não seja seguido, a pipeline irá falhar durante o processo de registro. -->

## Por que? <!-- why:init:required -->

<!-- why:end -->

## Como? <!-- how:init:required -->

<!-- how:end -->

## Comentários: <!-- comments:init -->

<!-- Preencha as subseções abaixo. Elas transformam a disciplina das skills
     pre-merge-verify e post-deploy-verify em campos fixos do PR: proveniência,
     risco falseável ANTES do merge e prova executável DEPOIS do deploy.
     Evidência > opinião. -->

### Autoria e rigor
<!-- Proveniência da mudança. Evidência > cerimônia — mantenha enxuto.
     - Gerado por: modelo + versão + harness (ex.: Claude Code / Opus 4.8), ou "humano".
     - Prompt/origem (opcional): pedido que originou a mudança.
       REDIJA segredos/PII/hosts internos. É contexto, NÃO é a prova de rigor. -->
- [ ] Um humano revisou o diff COMPLETO antes de submeter.
- [ ] Testado adversarialmente, não só o happy path (a prova break-the-fix em "Risco antes do merge" já satisfaz isto).

### Risco antes do merge
<!-- Skill: pre-merge-verify. Preencha com EVIDÊNCIA, não com "parece seguro":
     - SHA verificado + escopo do diff (o que muda / o que NÃO é tocado)
     - Análise de regressão (é superset? tem migração? billing intocado?)
     - Prova break-the-fix: reverter a linha do fix => o teste FALHA; restaurar => passa
     - Teto: verde local != verde CI (Sonar new-code S3776/S3358/S4144, typecheck:ci, coverage)
     - Testes executados e resultado REAL (não "deve passar") -->

### Verificação pós-deploy
<!-- Skill: post-deploy-verify. Cada afirmação observável [OB-n] tem uma prova [PD-n]:
     - Query read-only, escopada à revision do deploy + janela pós-deploy (dev turbi-dev / prod t-secure)
     - Teste de falseabilidade: se o PR não tivesse feito nada, a query PASSARIA? Se sim, aperte.
     - Guarda de não-regressão (RED): taxa de erro / p99 / nova classe de erro na revision nova
     - Gatilho de rollback explícito
     - Projeção de campos = redação (nunca headers/authorization/cookie).
     Escreva N/A com justificativa se nada for observável em produção. -->

<!-- comments:end -->
