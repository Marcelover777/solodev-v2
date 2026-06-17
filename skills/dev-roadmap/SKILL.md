---
name: dev-roadmap
description: Transforma uma ideia, CONTEXT.md ou BRIEF.md na lista numerada de passos do projeto — o ROADMAP.md que o usuário executa com um verbo só ("executa o passo 0X"). Cada passo é uma fatia demoável (uma feature ponta a ponta, não micro-tarefa), declara objetivo observável, qual skill do ciclo aciona, os gates (chaves/config que precisa antes) e as dependências. Escreve o ROADMAP.md e um .plans/steps/0X-<slug>.md por passo. Use quando o usuário disser "/dev-roadmap", "monta o roadmap", "lista de passos", "quais os passos do projeto", "por onde vou", "quebra em etapas", "plano do projeto inteiro", ou tiver uma ideia/CONTEXT/BRIEF e quiser a sequência numerada para executar.
---

# /dev-roadmap — A lista numerada que vira o projeto

Esta skill produz o `ROADMAP.md`: a sequência numerada de passos que leva da ideia ao projeto pronto. É a peça que torna o v3 simples para o iniciante — depois dela, o único comando que ele precisa decorar é **"executa o passo 0X"** (o `/dev-next` cuida do resto).

Ela **planeja o projeto inteiro em fatias grandes**. Não é o `/dev-plan` (que detalha UMA feature em tasks atômicas) nem o `/dev-coding` (que executa). É o nível acima: o mapa dos epics/features, na ordem certa, com os gates explícitos.

## Princípios não-negociáveis

1. **Passo = fatia demoável, não micro-tarefa.** Cada passo entrega algo que o usuário VÊ funcionando (uma feature ponta a ponta: schema → API → UI → teste). Um SaaS de waitlist → login → cobrança são ~6 passos, não 40 tasks. Micro-granularidade é trabalho do `/dev-plan`, dentro de um passo.
2. **Numeração estável + um verbo só.** Os passos são `## 01`, `## 02`… e o usuário roda `executa o passo 0X`. A numeração não muda depois de criada (inserir vira `03b` ou um passo no fim) — o `/dev-next` depende dela.
3. **Gates explícitos.** Todo passo que precisa de chave/config declara isso. É o que deixa o `/dev-next` parar e dar o link antes de travar o iniciante.
4. **Ordem por dependência real, não por capricho.** O passo bonito-sem-gate (scaffold + landing) vem primeiro de propósito: o iniciante vê algo no ar antes de mexer em config. Depois, a ordem segue `depends_on` de verdade.
5. **Karpathy.** Não invente fases, épicos fantasmas nem passos especulativos. Se a versão completa cabe em 5 passos, são 5. O roadmap descreve o caminho real — sem fluff, mas sem cortar função essencial nem entregar meia-feature.

## Processo

### 1. Carregue o contexto

Na ordem, pulando o que não existir:
1. **Read** `CONTEXT.md` (se houver — vocabulário e arquitetura do projeto).
2. **Read** `BRIEF.md` (de `/dev-brainstorm`, em `.plans/<feature>/BRIEF.md` ou na raiz — Problema, Goals, Non-Goals).
3. **Read** `STACK.md` (se houver — define o framework e quais chaves cada feature vai exigir, alimentando os gates).
4. Se nada disso existe, faça um grilling curto (3-5 perguntas) para fechar: o que o produto faz, quem usa, e o que a **V1 completa** precisa ter para ser genuinamente funcional e poderosa (não "o mínimo para mostrar").

### 2. Defina o destino (a versão completa)

Antes de fatiar, diga em 1-2 linhas qual é o **estado final** deste roadmap: a versão **completa e funcional** que entrega a proposta do produto de verdade — implementações reais, não meia-feature. O escopo é focado (o que é genuinamente fora de escopo vira roadmap futuro), mas o que entra na V1 sai inteiro e robusto.

### 3. Fatie em passos (fatias demoáveis, em ordem)

Heurísticas de granularidade:
- **Cada passo melhora algo observável.** Depois de rodá-lo, o usuário consegue *ver* ou *fazer* algo novo.
- **Quantos passos a versão completa exigir.** ~5-12 é o comum; se precisar de mais, tudo bem. Corte só o que é especulativo/fora de escopo, nunca função essencial.
- **Primeiro passo sem gate.** Scaffold + uma tela bonita (via `/dev-design`) — algo no ar sem precisar de nenhuma chave. Motivação antes de fricção.
- **Agrupe por feature vertical, não por camada.** "Login" é um passo (schema + API + UI + teste), não três passos ("todos os schemas", "todas as APIs"…).

Para cada passo, decida e registre:

| Campo | O que é |
|-------|---------|
| **número + título** | `## 0X — <verbo + objeto>` (ex.: `## 03 — Login (auth)`) |
| **objetivo observável** | o que o usuário vê/faz depois que o passo passa |
| **skill do ciclo** | qual skill executa por baixo: `/dev-design`, `/dev-plan`+`/dev-coding`, `/dev-ship`… |
| **gate** | chaves/config/contas que precisam existir antes (ou _Sem gate_). Use os nomes de env var do `STACK.md` |
| **depends_on** | passos anteriores que precisam estar `[x]` (ou `[]`) |

### 4. Escreva o ROADMAP.md + um arquivo por passo

- **`ROADMAP.md`** na raiz — use [ROADMAP-TEMPLATE.md](ROADMAP-TEMPLATE.md). Cada passo é um `- [ ]` com `## 0X — título` e o link para o detalhe.
- **`.plans/steps/0X-<slug>.md`** por passo — use [STEP-TEMPLATE.md](STEP-TEMPLATE.md). É o detalhe que o `/dev-next` lê para checar gate e delegar. O usuário não precisa abrir; existe para o sistema (e para quem quiser auditar).

Mantenha os dois em sincronia: o `ROADMAP.md` é o índice, os `steps/0X-*.md` são o conteúdo.

### 5. Marque os gates com clareza

No `ROADMAP.md`, cada passo com gate diz em 1 linha o que falta (ex.: `_Gate: chaves Supabase._`). No `steps/0X-*.md`, liste os **nomes exatos** das env vars (do `STACK.md`; nunca invente) — é o que o `/dev-next` confronta com o `SETUP.md`/`.env.local`. Se o projeto ainda não tem `STACK.md`/`SETUP.md`, aponte `/dev-stack` e `/dev-setup` antes de marcar gates a esmo.

### 6. Mostre o roadmap e confirme

Em 1 mensagem: a lista numerada (título + 1 linha do que faz + gate), o destino, e a pergunta: *"a ordem faz sentido? Falta algum passo para ficar genuinamente funcional? Algum é especulativo e pode sair?"*. Itere — corte o que é fluff fora de escopo, sem cortar função essencial.

## Anti-padrões

- ❌ **Passo = micro-tarefa** ("criar arquivo X") — isso é task do `/dev-plan`, não passo do roadmap.
- ❌ **Passos horizontais** ("todos os models", depois "todas as APIs") — mata o demoável e esconde bugs de integração.
- ❌ **Renumerar passos já criados** — quebra o "executa o passo 0X"; insira no fim ou use sufixo.
- ❌ **Gate omitido** — passo que precisa de chave sem declarar trava o iniciante no meio da execução.
- ❌ **Inventar nome de env var** no gate — use só os confirmados no `STACK.md`.
- ❌ **Passo que entrega meia-feature** (mock, dado chumbado, "arrumo depois") — o que entra no roadmap sai completo e funcional.
- ❌ **Roadmap inflado** — escopo focado; o especulativo vira roadmap futuro, mas o que fica é construído de verdade.
- ❌ **Primeiro passo com gate pesado** — comece por algo visível sem config (scaffold/landing).

## Onde ficam os arquivos

- `ROADMAP.md` — raiz; o índice numerado (este arquivo é a fonte do progresso do `/dev-status`).
- `.plans/steps/0X-<slug>.md` — o detalhe de cada passo.
- Lê: `CONTEXT.md`, `BRIEF.md`, `STACK.md`.

## Próximo passo

Com o roadmap fechado:

> *"ROADMAP.md pronto com <N> passos. Agora é só pedir: **executa o passo 01**. O `/dev-next` roda um por vez, checa as chaves antes (e te dá o link se faltar), e marca o progresso. A qualquer hora, `/dev-status` mostra como está."*

Se o projeto ainda não tem stack/design/setup: sugira `/dev-start` (que encadeia tudo) ou rodar `/dev-stack` → `/dev-design` → `/dev-setup` antes de executar o passo 01.
