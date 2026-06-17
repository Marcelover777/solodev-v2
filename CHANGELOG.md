# Changelog

Todas as mudanças relevantes deste projeto são documentadas aqui.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e o projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [3.1.0] - 2026-06-16

Rebrand do projeto e uma doutrina nova de ambição.

### Changed

- **Renomeado para Crucible.** Novo nome, repositório, plugin (`crucible@crucible`, comandos namespaced `/crucible:dev-*`) e docs. Os comandos puros das skills (`/dev-*`) seguem iguais, assim como os créditos ao [solodev de calneymgp](https://github.com/calneymgp/solodev). A pasta de memória do projeto passou a ser `.crucible/`; os hooks viraram `crucible-session-start.js` / `crucible-autocommit.js`; a env var de opt-in, `CRUCIBLE_AUTOCOMMIT`.
- **Doutrina "V1 completa, nunca MVP".** `/dev-start`, `/dev-brainstorm`, `/dev-roadmap`, `/dev-plan`, `/dev-coding`, `/dev-ship` e `/dev-stack` agora miram uma **V1 inteira, funcional e poderosa** desde o primeiro passo: implementações reais, todos os estados tratados, sem mock, dado chumbado, meia-feature ou "arrumo depois". Escopo focado, mas tudo que entra é construído de verdade.

## [3.0.0] - 2026-06-16

O sistema operacional do vibe coder. O v2 cobria a disciplina de engenharia de uma feature (sete skills, ciclo `dev-context → dev-ship`). O v3 envelopa isso numa camada de onboarding zero-fricção: o iniciante fala a ideia uma vez e recebe stack explicado, projeto estético, chaves mapeadas e uma lista numerada de passos. O único comando que ele precisa decorar é **"executa o passo 0X"**. Oito skills novas, memória entre sessões e git no automático — tudo file-based, zero infra.

### Added

- **`/dev-start` (skill nova)** — porta de entrada do iniciante: espelha a ideia, encadeia `/dev-stack → /dev-design → /dev-setup → /dev-roadmap` mostrando o que monta a cada etapa, e termina dizendo "Agora é só pedir: executa o passo 01".
- **`/dev-stack` (skill nova)** — advisor de infra e conectores: infere o arquétipo, recomenda o default + o porquê em 1 linha, oferece 1 alternativa, avisa os gotchas de free-tier e **linka a pricing oficial** (nunca crava preço). Escreve `STACK.md` (um ADR).
- **`/dev-design` (skill nova)** — estética instantânea: para web, scaffolda Tailwind v4 + shadcn/ui + um tema tweakcn (daisyUI/Tremor como atalhos) e escreve `DESIGN.md`. O projeto nasce desenhado, não com cara de template.
- **`/dev-setup` (skill nova)** — chaves de API e variáveis de ambiente sem se perder: lê `STACK.md` + varre o código, gera um `.env.example` ricamente anotado e um `SETUP.md` (checklist com o link exato de cada chave), e garante o `.gitignore`.
- **`/dev-roadmap` (skill nova)** — transforma ideia/`CONTEXT.md`/`BRIEF.md` na lista numerada de passos: escreve o `ROADMAP.md` e um `.plans/steps/0X-<slug>.md` por passo, cada um com objetivo observável, skill do ciclo, gates e dependências.
- **`/dev-next` (skill nova)** — executa o próximo passo com um verbo só: roda os gates antes de tudo (faltou chave → **PARA e dá o link**), delega ao ciclo v2, marca `[x]` no `ROADMAP.md`, registra no journal e imprime o próximo passo.
- **`/dev-status` (skill nova)** — painel de estado derivado de arquivos reais (`ROADMAP.md`, `PLAN.md`, `git status`, `must_pass`): escreve `.crucible/STATUS.md` com % de progresso, qualidade por parte (build/test/lint/security), erros, blockers e próximo passo. Tem modo "jornada" narrativo.
- **`/dev-ops` (skill nova)** — git/GitHub no automático: scaffolda `.github/workflows/ci.yml`, `dependabot.yml`, `PULL_REQUEST_TEMPLATE.md` e `ISSUE_TEMPLATE/`, escreve um `GITHUB.md` para leigos, define a política de timing de testes e abre PR via `gh pr create --fill`.
- **Memória entre sessões (`.crucible/`)** — nova pasta na raiz do projeto: `PROGRESS.md` (journal append-only do que mudou) e `STATUS.md` (painel). O projeto lembra de si mesmo sem o usuário reexplicar nada — file-based, sem worker, DB ou porta.
- **Hooks opt-in (`src/hooks/`)** — um hook `SessionStart` que injeta o `.crucible/PROGRESS.md` como contexto ao abrir a sessão (continuidade), e um hook `Stop` de auto-commit com mensagem Conventional Commits. Silent-fail, respeitam `CLAUDE_CONFIG_DIR`, instalados só com flag explícita — nunca push silencioso para `main`.
- **`GLOSSARY.md`** — o que é repo, commit, deploy, API key e os termos do fluxo, em 1 linha cada, para quem nunca programou.
- **Exemplo `examples/saas-starter/`** — walkthrough do fluxo v3: `STACK.md`, `ROADMAP.md`, `.plans/steps/01-scaffold.md` e `.crucible/STATUS.md` mostrando `/dev-start → executa o passo 0X` na prática.

### Changed

- `plugin.json` foi para a versão `3.0.0` e passou a anunciar **quinze skills**; `README.md`, `README.en.md`, `INSTALL.md` e os instaladores (`install.sh`, `install.ps1`) atualizados para incluir as oito skills novas.

## [2.1.0] - 2026-06-15

Polimento de pacote: uma skill utilitária a mais, auto-validação e guia de contribuição.

### Added

- **`/dev-help` (skill nova)** — cartão de referência in-session: mostra o ciclo, qual skill usar em cada momento e onde ficam os outputs. Exibição one-shot, não é um modo persistente.
- **Auto-validação (`scripts/validate.mjs`)** — valida o pacote sem dependências: frontmatter de cada skill (`name`/`description`), templates referenciados existem, JSON dos manifests válido e coerente, e que **toda skill** aparece nos instaladores e nos READMEs.
- **CI (`.github/workflows/validate.yml`)** — roda o validador e `bash -n install.sh` a cada push/PR.
- **`CONTRIBUTING.md`** — layout do projeto, como adicionar uma skill e como rodar o validador.

### Changed

- `plugin.json` ganhou `version` e passou a anunciar sete skills; READMEs, `INSTALL.md` e instaladores atualizados para incluir `/dev-help`.

## [2.0.0] - 2026-06-15

Primeira release pública do Crucible — o ciclo de engenharia completo para o dev solo, em PT-BR. Estende o [solodev original de calneymgp](https://github.com/calneymgp/solodev) (3 skills) para as seis fases do ciclo de vida, mais empacotamento e docs.

### Added

- **`/dev-context` (skill nova)** — gera o `CONTEXT.md` na raiz do projeto: one-liner, mapa de arquitetura, glossário canônico, convenções, invariantes, comandos e boundaries externos. É a memória que brainstorm/plan/coding/ship citam.
- **`/dev-fix` (skill nova)** — loop de diagnóstico disciplinado para bugs: triagem trivial/real/arquitetural, feedback loop reproduzível, hipóteses falsificáveis, um probe por hipótese, fix com teste de regressão e cleanup.
- **`/dev-ship` (skill nova)** — "pronto" virou estado verificado: suite completa + Must-Haves + demo script + revisão de diff (restos, bugs) + lente de segurança + `SUMMARY.md` + arquivamento do plano.
- **Espelho de entendimento** no `/dev-brainstorm` — devolve em 3 bullets o que entendeu da ideia falada antes de grilhar.
- **Triagem S/M/L** no `/dev-brainstorm` — tarefa pequena não ganha BRIEF; tarefa grande não escapa do grilling.
- **Lente de produto** no `/dev-brainstorm` — estado vazio, erro, loading e permissões viram perguntas explícitas.
- **Risk Radar** — todo BRIEF fecha com top-3 "isso vai te morder" + mitigação.
- **effort + rollback por task** no `/dev-plan` — o plano diz quanto custa e como desfazer o que é perigoso.
- **Pontos de /clear** no `/dev-plan` — o plano marca onde resetar contexto; o `PLAN.md` é a memória externa.
- **Guarda de escopo + protocolo de drift** no `/dev-coding` — task inflou 2×? Implementação divergiu? Para, registra a verdade, re-planeja.
- **Empacotamento como plugin do Claude Code** — `plugin.json` e `marketplace.json` para instalar via `/plugin`.
- **Installers cross-platform** — `install.sh` (POSIX) e `install.ps1` (Windows), com suporte a `curl|bash` / `irm|iex`.
- **Exemplo end-to-end** — `examples/realtime-presence/` com `BRIEF.md`, `PLAN.md` e `SUMMARY.md`.
- **Docs bilíngues** — `README.md` (PT-BR) e `README.en.md` (EN), mais `INSTALL.md`.

### Baseado em

O Crucible estende o **[solodev de calneymgp](https://github.com/calneymgp/solodev)**, a baseline (v1) de 3 skills. Licença MIT, com os créditos ao trabalho original preservados em `LICENSE` e no `README`.

[3.1.0]: https://github.com/Marcelover777/crucible/releases/tag/v3.1.0
[3.0.0]: https://github.com/Marcelover777/crucible/releases/tag/v3.0.0
[2.1.0]: https://github.com/Marcelover777/crucible/releases/tag/v2.1.0
[2.0.0]: https://github.com/Marcelover777/crucible/releases/tag/v2.0.0
