---
name: dev-status
description: Painel de estado do projeto, derivado de arquivos reais — lê ROADMAP.md, .plans/*/PLAN.md, git status e o resultado dos must_pass e escreve .crucible/STATUS.md com % de progresso, qualidade por parte (build/test/lint/security ✅/⚠️/❌), onde estão os erros, blockers e o próximo passo. Modo jornada vira resumo narrativo motivacional do .crucible/PROGRESS.md. Use quando o usuário disser "/dev-status", "como está o projeto", "o que falta", "o que já está pronto", "tem erro?", "qual o próximo passo", "resumo do progresso", "modo jornada", "conta a história do projeto", ou parecer perdido sobre o estado atual.
---

# /dev-status — O painel que não inventa número

Foto do projeto AGORA: quanto andou, o que tem erro, qual a qualidade de cada parte, o que está travado, e o próximo passo. **Tudo derivado de arquivo real** — ROADMAP.md, PLAN.md, `git status`, saída dos `must_pass`. Nada de % chutado.

Duas saídas:
- **Painel** (default) → escreve `.crucible/STATUS.md` + mostra um resumo no chat.
- **Jornada** (`/dev-status jornada`) → resumo narrativo motivacional do `.crucible/PROGRESS.md`. Sem painel, sem números de token.

## Princípios não-negociáveis

1. **Status deriva de arquivo, nunca de palpite.** Se não há sinal real (ROADMAP, PLAN, git, must_pass), a célula é `❓ sem dado` — não `✅`, não um % inventado.
2. **One-shot.** Lê → escreve `.crucible/STATUS.md` → mostra resumo → sai. Não entra em modo, não fica perguntando.
3. **Read-only sobre o projeto.** A skill só LÊ código/git e ESCREVE `.crucible/STATUS.md`. Nunca edita código, nunca commita, nunca roda comando destrutivo.
4. **Karpathy.** Reporta o que existe. Não inventa risco, não enche de seção vazia, não duplica o que o ROADMAP já diz.

## Processo (modo painel)

### 1. Colete os sinais (read-only)

Na ordem, pulando o que não existir:

| Sinal | De onde | Para quê |
|-------|---------|----------|
| Progresso | `ROADMAP.md` (conta `- [x]` vs `- [ ]`) | % de passos done |
| Progresso fino | `.plans/<feature>/PLAN.md` (Status Log + `acceptance` marcados) | tasks done por feature |
| Mudanças pendentes | `git status --porcelain` + `git log --oneline -5` | o que mexeu, último commit |
| Qualidade | saída dos `must_pass` dos passos/tasks (rodar os que existirem) | build/test/lint/security |
| Blockers | gates de `/dev-next` (chave/conector faltando, conferidos via `SETUP.md`) + Risk Radar do `BRIEF.md` (em `.plans/<feature>/BRIEF.md`) | o que trava o avanço |

> Se não há `ROADMAP.md` nem `.plans/`: diga em 1 linha que o projeto ainda não tem roadmap e aponte `/dev-roadmap` (ou `/dev-start` p/ iniciante). Não invente painel.

### 2. Calcule o progresso (só com número real)

- **% de passos:** `passos [x] / total de passos` no `ROADMAP.md`. Mostre a fração também (`6/14`), não só o %.
- **Por feature:** se há `.plans/<feature>/PLAN.md`, conte `acceptance` marcados vs total. Sem PLAN, omita a linha — não estime.
- Arredonde sempre pra baixo. `5/14` é `35%`, não `36%`.

### 3. Avalie qualidade por parte (✅ / ⚠️ / ❌ / ❓)

Quatro partes fixas. Rode os `must_pass` que existirem; nunca presuma verde sem rodar.

| Parte | Como medir | ✅ | ⚠️ | ❌ |
|-------|-----------|----|----|----|
| **build** | comando de build/typecheck do projeto | compila limpo | warnings | falha |
| **test** | suite de testes | todos passam | flaky / coverage baixa | falhando |
| **lint** | linter/formatter | limpo | warnings | erros |
| **security** | audit de deps + `.env*` no `.gitignore` + ausência de segredo commitado | sem alerta | alerta de severidade baixa | segredo exposto / CVE alta |

Regra das células:
- **❓ sem dado** quando o comando não existe no projeto ou não foi possível rodar. É honesto e melhor que um ✅ falso.
- **security** é a parte onde a prosa normal vale: se achar segredo commitado ou `.env.local` rastreado pelo git, escreva em frase clara o arquivo, o risco e o passo de remediação — não comprima isso em fragmento.

### 4. Localize os erros

Para cada `⚠️`/`❌`, registre o **endereço**, não só o veredito: `arquivo:linha — comando que falhou — 1 linha do erro`. Sem isso o painel não ajuda. Se a saída do teste/build dá o ponto, cite-o; se não dá, diga "sem localização na saída".

### 5. Junte blockers

Uma lista do que impede avançar AGORA:
- Gate de `/dev-next` pendente (chave/conector faltando) → inclua o item + aponte o `SETUP.md` (a fonte da URL; não recopie a chave nem a URL crua aqui).
- `❌` em build/test/security que bloqueia o próximo passo.
- `depends_on` não satisfeito de uma task/passo pendente.

Se não há blocker, escreva `Nenhum` — não invente risco especulativo.

### 6. Escreva o STATUS.md e mostre o resumo

Use [STATUS-TEMPLATE.md](STATUS-TEMPLATE.md) como esqueleto. Salve em `.crucible/STATUS.md` (crie a pasta `.crucible/` se faltar). No chat, mostre só: % + fração, as 4 partes em 1 linha, o blocker mais urgente (ou "sem blocker"), e o próximo passo. O arquivo guarda o detalhe.

## Processo (modo jornada)

Acionado por `/dev-status jornada` (ou "conta a história do projeto", "resumo do progresso").

1. **Read** `.crucible/PROGRESS.md` (journal append-only, blocos `## YYYY-MM-DD — ...`).
2. Costure os blocos em 4-8 frases: de onde o projeto partiu → marcos que venceu → onde está hoje → o próximo passo natural.
3. Tom motivacional e honesto: celebra o que andou, nomeia o que travou, sem exagero.
4. **Não** escreve arquivo. **Não** calcula token/custo (não há DB — isso é o que separa do claude-mem). É narrativa, não contabilidade.
5. Se `PROGRESS.md` não existe ou está vazio: diga em 1 linha que ainda não há journal e que ele se preenche sozinho conforme `/dev-next` roda.

## Anti-padrões

- ❌ **% inventado** — todo número sai de contagem real de `[x]`/`[ ]` ou de `acceptance`. Sem fonte → `❓ sem dado`.
- ❌ **✅ sem rodar o must_pass** — verde presumido é mentira no painel.
- ❌ **Veredito sem endereço** — `test ❌` sem `arquivo:linha` não ajuda ninguém.
- ❌ **Editar/commitar/rodar destrutivo** — a skill é leitura + escreve só o `STATUS.md`.
- ❌ **Token-economics no modo jornada** — não há DB; é resumo, não contabilidade.
- ❌ **Recopiar URL de chave no painel** — aponte o `SETUP.md`, que é a fonte.
- ❌ **Painel cheio de seção vazia** quando o projeto nem tem roadmap — aponte `/dev-roadmap` e pare.
- ❌ **Inventar blocker/risco** que nenhum arquivo sustenta.

## Onde ficam os arquivos

- `.crucible/STATUS.md` — o painel que esta skill escreve (sobrescrito a cada run).
- `.crucible/PROGRESS.md` — o journal (fonte do modo jornada; escrito por `/dev-next`, não por esta skill).
- `ROADMAP.md` — raiz; fonte do progresso.
- `.plans/<feature>/PLAN.md` — progresso fino por feature.

## Próximo passo

Após escrever o painel, sugira o passo que encaixa no que ele revelou:

> *"Painel salvo em `.crucible/STATUS.md`. Próximo: `executa o passo 0X` (passo desbloqueado). Se há `❌`, comece pelo `/dev-fix`. Se um gate travou, resolva o item do `SETUP.md` e rode de novo. Para a história do projeto: `/dev-status jornada`."*
