---
name: dev-audit
description: Audita um projeto que JÁ existe (não nasceu no Forger) — lê stack, código e git e gera um diagnóstico verificável SEM tocar no código. Roda read-only, pontua dimensões (config, arquitetura, segurança, saúde de deps, testes, DX, performance, UI/UX, observabilidade) com ✅/⚠️/❌/⏭️, banding por tipo-de-projeto e por fase, escreve .forge/AUDIT-<data>.md e, com confirmação, semeia o .forge/BACKLOG.md com itens gated e verificáveis. Reaproveita o /dev-stack (perfil do projeto) e o /dev-status (modelo de nota). Use quando o usuário disser "/dev-audit", "audita meu projeto", "herdei esse código", "o que tem de errado aqui", "diagnóstico do repo", "está bom esse projeto?", "o que dá pra melhorar", ou apontar um repositório que não tem ROADMAP.md/.forge/.
---

# /dev-audit — Diagnóstico verificável de um projeto existente

A porta de entrada para o código que **já existe**. Enquanto o `/dev-start` parte de uma ideia, o `/dev-audit` parte de um repositório: lê o que está lá, pontua cada dimensão com evidência, e transforma o que achou numa **fila de trabalho** (`.forge/BACKLOG.md`) que o `/dev-next` executa. Não conserta nada sozinho — diagnostica e enfileira.

## Invariantes não-negociáveis

1. **READ-ONLY.** A skill só LÊ o projeto e ESCREVE em `.forge/`. Nunca edita código, nunca roda comando que muta o repo. Remédio destrutivo (rotacionar segredo, `git filter-repo`, deletar arquivo) **nunca é feito inline** — vira item de backlog marcado **RED**.
2. **Nunca ecoa valor de segredo** num arquivo commitado (re-vaza a chave). Referencie sempre `arquivo:linha`, jamais o valor.
3. **Phase-aware.** Leia a fase do projeto (`.forge/PROGRESS.md`/`STATUS.md`, ou maturidade do git). Dimensão que não é devida na fase atual = `⏭️ ainda-não`, **nunca `❌`**. Projeto de 3 dias não leva vermelho por não ter observabilidade.
4. **Banding por tipo-de-projeto.** O tipo vem do `/dev-stack` (arquétipo a–f). CLI/lib/API pulam dimensões web (`⏭️ (motivo)`). Não existe nota global ≥90 — cada dimensão é avaliada na sua régua.
5. **Ferramenta ausente ou que falhou = `⏭️ não-avaliado (motivo)`, NUNCA `✅`.** Não rodou `npm audit`? Então a dimensão "saúde de deps" é `⏭️`, com o link de como instalar — não um verde presumido.
6. **Achado subjetivo precisa de âncora.** Arquitetura e UI/UX levam `🔍 leitura subjetiva` **+** `arquivo:linha` (ou referência de componente). Sem âncora, não escreve o achado.

## Processo

### 1. Perfil do projeto (reusa o /dev-stack — não re-detecta stack)

Antes de pontuar, estabeleça o **perfil** lendo o que existe (read-only):

- **Tipo/arquétipo:** se há `STACK.md`, use-o. Se não, infira o arquétipo (a–f do `/dev-stack`) do `package.json`/manifesto, da estrutura de pastas e do ecossistema — e **delegue ao `/dev-stack`** a detecção fina (ecossistema, lockfile, **comando de audit** do ecossistema). O `/dev-audit` **não** reimplementa a detecção de stack.
- **Fase/maturidade:** `.forge/PROGRESS.md`/`STATUS.md` se existirem; senão, idade e volume do git (`git log --oneline | wc -l`, primeira data de commit) como proxy. Isso decide o banding (invariante 3).
- **Sem `CONTEXT.md`?** O audit pode sugerir gerar um via `/dev-context` (não obriga).

### 2. Pontue as dimensões (✅ / ⚠️ / ❌ / ⏭️) — modelo do /dev-status

Importe o modelo de severidade do `/dev-status` **verbatim** (✅ ok · ⚠️ avisa · ❌ bloqueia · `⏭️` não-avaliado/não-devido). Só pontue a dimensão que faz sentido para o tipo e a fase; o resto é `⏭️` com o motivo.

| # | Dimensão | Sinais (read-only) | Régua / nota |
|---|----------|--------------------|--------------|
| 1 | **Config / Setup** | tem `.env.example`? segredo fora do git? lockfile commitado? scripts sãos? | 12-factor |
| 2 | **Arquitetura** | acoplamento, deus-módulos, camadas — `🔍` + âncora `arquivo:linha` | subjetivo, ancorado |
| 3 | **Segurança** | validação de input, authn/z, segredo em `git log`, deps com CVE | severidade C/H/M/L |
| 4 | **Saúde de deps** | comando de audit **derivado do stack** (`npm audit --json` / `osv-scanner` / `pip-audit`) | falhou/ausente → `⏭️` |
| 5 | **Testes** | suíte verde? cobre os caminhos críticos? testa bordas? | só se a fase já pede |
| 6 | **DX** | scripts (`build`/`test`/`lint`), CI, tempo de build | só se a fase já pede |
| 7 | **Performance** | bundle, N+1, imagens — **só web/com URL** | Lighthouse, senão `⏭️` |
| 8 | **Criativo / UI-UX** | heurísticas de Nielsen nas telas — `🔍` + referência de componente | subjetivo, ancorado |
| 9 | **Observabilidade** | logs estruturados, error tracking | só se a fase já pede |

**Localize cada `⚠️`/`❌` com endereço** (`arquivo:linha — o que — por que importa`), igual ao `/dev-status`. Veredito sem endereço não ajuda ninguém.

### 3. Escreva o AUDIT-<data>.md (versionado por run, nunca sobrescreve)

Use o [AUDIT-TEMPLATE.md](AUDIT-TEMPLATE.md). Salve em `.forge/AUDIT-<YYYY-MM-DD>.md` — **um arquivo por auditoria**, nunca sobrescreve o anterior (dá pra comparar a evolução). Um pointer curto `.forge/AUDIT.md` aponta sempre o último run. Estrutura: placar por dimensão + achados priorizados (severidade × esforço), cada achado com **evidência verificável** e **por que importa**.

### 4. Semeie o BACKLOG (FASE gated — CHECKPOINT)

Antes de escrever qualquer linha no `.forge/BACKLOG.md`, **CHECKPOINT**: *"Achei N itens acionáveis. Semeio no `.forge/BACKLOG.md`?"*. Só depois do "pode", cada achado vira **uma linha** no schema do backlog (ver `skills/dev-next/BACKLOG-TEMPLATE.md`):

- **`Tipo`** pela classe do achado (`bug`/`debt`/`infra`/`chore`; melhoria de produto vira `idea` → vira passo do ROADMAP, não executa do backlog).
- **`Prio`** pela severidade (segurança/quebrado = **P0**).
- **`Aceite`** = o **inverso verificável** do que você detectou (ex.: detectou `.env` rastreado → Aceite `git ls-files .env` vazio).
- **`Origem`** = `audit:<finding-id>` (dedup estável — re-auditar não duplica linhas).
- Achado que precisa de chave/conta → `Status ⛔ gate` + `Gate` nomeado.
- Achado destrutivo (rotação de segredo, reescrita de histórico) → **RED**: o item descreve o remédio, mas **tocar o código do app exige um segundo CHECKPOINT** explícito. O `/dev-audit` nunca o executa.

### 5. Aponte o próximo

> *"Auditoria em `.forge/AUDIT-<data>.md`: <X>✅ <Y>⚠️ <Z>❌. Semeei <N> itens no `.forge/BACKLOG.md`. Próximo: `/dev-next` pega o P0 — ou `/dev-status` pro painel. Os itens RED (destrutivos) só rodam com sua confirmação explícita."*

## Reuso (não reinventa)

- **`/dev-stack`** → tipo de projeto, ecossistema, lockfile, comando de audit. O `/dev-audit` **nunca re-detecta** o stack.
- **`/dev-status`** → o modelo ✅/⚠️/❌ e a régua de severidade, importados idênticos. `❓ sem dado` do status = `⏭️ não-avaliado` do audit.
- **`/dev-next` + `.forge/BACKLOG.md`** → o destino dos achados. O audit **enfileira**; o `/dev-next` executa.
- **`/dev-context`** → se falta `CONTEXT.md`, o audit pode sugerir gerá-lo.

## Anti-padrões

- ❌ Tocar/consertar o código durante a auditoria (é READ-ONLY; conserto vira item de backlog)
- ❌ Pontuar **todas** as dimensões num projeto de 3 dias (ruído / vermelho onde é ok) — use `⏭️` por fase
- ❌ Nota global ≥90 (cada dimensão tem a sua régua; não há média)
- ❌ `✅` quando a ferramenta não rodou (é `⏭️ não-avaliado` + link)
- ❌ Ecoar o valor de um segredo no `AUDIT.md` (referencie `arquivo:linha`)
- ❌ Remédio destrutivo inline (`git filter-repo`, deletar) — vira item **RED**, com segundo CHECKPOINT
- ❌ Sobrescrever o `AUDIT.md` (versiona por data; o pointer aponta o último)
- ❌ Achado de arquitetura/UI sem `🔍` + `arquivo:linha`
- ❌ Semear o backlog sem CHECKPOINT
- ❌ Re-detectar o stack em vez de delegar ao `/dev-stack`

## Quando cair pra prosa normal (auto-clarity)

- **Achado de segurança sério** (segredo no histórico, auth quebrada): frase clara com o arquivo, o risco e o remédio — fora da tabela, igual ao `/dev-status`.
- **CHECKPOINT de semear o backlog**: explique em 1-2 frases o que vai entrar, antes de escrever.
- **Item RED**: descreva o porquê de ser irreversível antes de propor.

## Onde ficam os arquivos

- `.forge/AUDIT-<YYYY-MM-DD>.md` — o diagnóstico de cada run (versionado, não sobrescreve).
- `.forge/AUDIT.md` — pointer curto pro último run.
- `.forge/BACKLOG.md` — onde os achados viram trabalho (semeado após CHECKPOINT).
- Lê (read-only): `STACK.md`, `CONTEXT.md`, `package.json`/manifesto, código, `git log`.
