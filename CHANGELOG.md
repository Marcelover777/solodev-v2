# Changelog

Todas as mudanças relevantes deste projeto são documentadas aqui.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e o projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [2.0.0] - 2026-06-15

Primeira release pública do solodev v2 — o ciclo de engenharia completo para o dev solo, em PT-BR. Estende o [solodev original de calneymgp](https://github.com/calneymgp/solodev) (3 skills) para as seis fases do ciclo de vida, mais empacotamento e docs.

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

O solodev v2 estende o **[solodev de calneymgp](https://github.com/calneymgp/solodev)**, a baseline (v1) de 3 skills. Licença MIT, com os créditos ao trabalho original preservados em `LICENSE` e no `README`.

[2.0.0]: https://github.com/Marcelover777/solodev-v2/releases/tag/v2.0.0
