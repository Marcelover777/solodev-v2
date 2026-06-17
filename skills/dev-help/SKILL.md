---
name: dev-help
description: Mapa de comandos do solodev v3 — mostra a camada de onboarding (do zero ao ROADMAP.md) e o ciclo de engenharia de uma feature, qual skill usar em cada momento, o que cada uma entrega e onde ficam os outputs. Regra de ouro nova: iniciante começa por /dev-start; depois é só "executa o passo 0X". Exibição one-shot (não é modo persistente). Use quando o usuário disser "/dev-help", "ajuda do solodev", "qual skill eu uso agora", "que comando do solodev serve pra isso", "me lembra o fluxo", "como funciona o solodev", "quais são os comandos", "por onde começo", "me perdi", ou parecer perdido sobre o que fazer agora.
---

# /dev-help — Qual comando usar agora

Mapa de comandos do solodev v3. Mostre o conteúdo abaixo, adaptando a recomendação ao que o usuário acabou de dizer. **One-shot:** exiba e saia — não entra em modo nenhum, não fica perguntando.

O v3 tem duas camadas:
- **Onboarding** — do zero ao `ROADMAP.md` numerado. É por onde o iniciante entra.
- **Ciclo** — a disciplina de engenharia de UMA feature (herdada do v2). É o que cada passo do roadmap aciona por baixo.

## Regra de ouro

> **Iniciante começa por `/dev-start`.** Ele fala a ideia uma vez e sai com stack + design + setup + `ROADMAP.md` pronto. Depois disso, o único comando que precisa decorar é **"executa o passo 0X"** — o resto acontece sozinho (gate, execução, registro, próximo passo).

## A jornada do iniciante (caminho feliz)

```
/dev-start            → fala a ideia; sai stack + design + setup + ROADMAP.md numerado
executa o passo 01    → roda o passo; ao fim diz "próximo: executa o passo 02"
executa o passo 02    → se faltar chave, ele PARA e te dá o link exato
   ...
/dev-status           → a qualquer hora: o que está pronto, o que tem erro, e a qualidade
```

Usuário avançado pula o `/dev-start` e chama as sub-skills direto.

## A camada de onboarding

```
          /dev-start  (porta de entrada — orquestra os de baixo)
              │
   ┌──────────┼───────────┬───────────┐
 /dev-stack /dev-design /dev-setup /dev-roadmap ──▶ executa o passo 0X  (/dev-next)
 STACK.md   DESIGN.md   .env.example  ROADMAP.md         gate → ciclo → registro
            scaffold    SETUP.md      steps/0X-*.md
```

| Você quer… | Use | Sai |
|------------|-----|-----|
| Começar do zero, sem saber nada (modo guiado) | `/dev-start` | stack + design + setup + `ROADMAP.md` |
| Entender/escolher a infra (com o porquê de cada peça) | `/dev-stack` | `STACK.md` (escolha + porquê + alternativa + pricing) |
| Deixar o projeto bonito já de cara | `/dev-design` | `DESIGN.md` + scaffold de UI |
| Configurar chaves/integrações de API | `/dev-setup` | `.env.example` anotado + `SETUP.md` |
| Gerar a lista numerada de passos | `/dev-roadmap` | `ROADMAP.md` + `.plans/steps/0X-*.md` |
| Executar o próximo passo (ou um nomeado) | `executa o passo 0X` / `/dev-next` | passo feito, marcado, registrado |
| Git/GitHub no automático (CI, PR, templates) | `/dev-ops` | `.github/*` + `GITHUB.md` + hooks opt-in |
| Ver o estado do projeto a qualquer hora | `/dev-status` | `.solodev/STATUS.md` (progresso + qualidade) |

## O ciclo de uma feature (herdado do v2)

É o que um passo do roadmap aciona por baixo. Você raramente chama isso na mão no modo guiado — o `executa o passo 0X` delega pra cá.

```
/dev-context  ·  /dev-brainstorm  →  /dev-plan  →  /dev-coding  →  /dev-ship
  CONTEXT.md        BRIEF.md           PLAN.md       executa         verifica + fecha
 (1x por projeto)                                        ↑
                                                     /dev-fix  (bug, a qualquer hora)
```

| Você está com… | Use | Sai |
|----------------|-----|-----|
| Projeto novo / repo sem memória pra IA | `/dev-context` | `CONTEXT.md` na raiz |
| Ideia bruta, falada, ainda difusa | `/dev-brainstorm` | `BRIEF.md` + Risk Radar |
| BRIEF fechado, quer estruturar | `/dev-plan` | `PLAN.md` atômico (sem código) |
| PLAN pronto, hora de executar | `/dev-coding` | código + commits `[task-XX]` |
| Algo quebrou (bug, stack trace) | `/dev-fix` | causa raiz + fix + regressão |
| "Tá pronto?" / fechar a feature | `/dev-ship` | `SUMMARY.md` + ship check |

## Regras de ouro

- **Iniciante começa por `/dev-start`** — ele encadeia stack→design→setup→roadmap. Depois é só `executa o passo 0X`.
- **Um verbo só.** Não precisa decorar o ciclo: `executa o passo 0X` chama a skill certa por baixo (`/dev-coding`, `/dev-plan`, `/dev-ship`…).
- **Gate antes de tudo.** Se um passo precisa de chave/config que falta, o `/dev-next` **para** e te dá o link exato. Resolve, e roda de novo. Nunca avança bloqueado.
- **Stack tem porquê, não palpite.** `/dev-stack` sempre explica a escolha, oferece uma alternativa e **linka a pricing oficial** — nunca crava preço nem limite de free-tier (muda rápido).
- **Chave nenhuma vai pro git.** `/dev-setup` põe o segredo em `.env.local` (ignorado) e só o **modelo anotado** em `.env.example` (versionado).
- **`/dev-context` roda 1x por projeto** (e quando a arquitetura muda) — não por feature.
- **Tarefa S (≤30 min, 1-2 arquivos)** não precisa de roadmap nem PLAN — o `/dev-brainstorm` tria e oferece executar direto.
- **Bug não precisa de plano** — vai direto pro `/dev-fix`.
- **`ROADMAP.md` e `PLAN.md` são memória externa.** Pode dar `/clear` no meio: os arquivos carregam o resto.
- **Pronto = demonstrado, não sentido.** `/dev-ship` só fecha o que roda verde + demo.
- **Status não inventa número.** `/dev-status` deriva tudo de arquivo real (`ROADMAP.md`, `git`, must_pass). Sem fonte → `❓ sem dado`.
- **Memória se preenche sozinha.** `.solodev/PROGRESS.md` cresce a cada passo do `/dev-next` — você não escreve journal na mão.

## Onde ficam os arquivos

Memória do projeto (escrita pelas skills, lida entre sessões — fica na pasta `.solodev/`):
- `.solodev/PROGRESS.md` — journal append-only, blocos `## YYYY-MM-DD — …` (escrito pelo `/dev-next` a cada passo; fonte do `/dev-status jornada`).
- `.solodev/STATUS.md` — painel de estado/qualidade (escrito pelo `/dev-status`, sobrescrito a cada run).

Raiz do projeto (artefatos versionáveis, renderizam no GitHub):
- `ROADMAP.md` — a lista numerada de passos. Cada item `## 0X — título` linka um `.plans/steps/0X-<slug>.md`.
- `STACK.md` — decisão de infra (do `/dev-stack`). `SETUP.md` + `.env.example` — chaves (do `/dev-setup`).
- `DESIGN.md` — estética (do `/dev-design`). `GITHUB.md` — git pra leigo (do `/dev-ops`).
- `CONTEXT.md` — vocabulário do projeto (do `/dev-context`).

Por feature:
- `.plans/<feature-slug>/` — `BRIEF.md`, `PLAN.md`, `DISCOVERY.md` (opcional), `SUMMARY.md`.
- `.plans/steps/0X-<slug>.md` — o detalhe de cada passo do roadmap.

## Próximo passo

Sugira o comando que encaixa no momento do usuário, nesta ordem de leitura:

> - **Nunca programou / projeto vazio?** Comece por `/dev-start` — ele monta tudo e te diz o primeiro passo.
> - **Já tem `ROADMAP.md`?** É só `executa o passo 0X` (ou `/dev-next` pro próximo livre).
> - **Não sabe qual stack usar?** `/dev-stack` te explica e recomenda. Faltam chaves? `/dev-setup`.
> - **Quer saber como está?** `/dev-status` (ou `/dev-status jornada` pra história do projeto).
> - **Algo quebrou?** `/dev-fix`, direto.
