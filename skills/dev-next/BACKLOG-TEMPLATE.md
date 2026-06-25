# BACKLOG.md Template (fila de trabalho não-planejado)

Salvar em `.forge/BACKLOG.md` na raiz do projeto do usuário. É a **fila durável** de trabalho que o `/dev-next` consome e o `/dev-audit` semeia. Gerido pelo `/dev-next` (não tem skill própria — evita superfície cognitiva). Linhas concluídas frias migram para `.forge/BACKLOG.archive.md`.

## A regra que mata o double-tracking

> **Feature planejada vive em UM lugar só: o `ROADMAP.md`.** O backlog guarda só trabalho **não-planejado**: `bug | debt | infra | chore | idea`. Uma `idea` aceita é **promovida a passo do ROADMAP** (via CHECKPOINT) e a linha fecha — **nunca é executada do backlog**. `Tipo: feat` é **proibido** aqui.

---

```markdown
# 📋 BACKLOG — <Nome do projeto>

> Fila de trabalho NÃO-planejado: bugs, dívida, infra, chores, ideias, achados de auditoria.
> NÃO é o ROADMAP (feature planejada vive lá). Próximo item: `/dev-next`. Concluir: marca ✅ e registra no PROGRESS.

| ID    | Item                          | Tipo  | Origem       | Prio | Status      | Deps  | Gate        | Aceite (verificável)                          |
|-------|-------------------------------|-------|--------------|------|-------------|-------|-------------|-----------------------------------------------|
| B-001 | Segredo no histórico do git   | infra | audit:sec-01 | P0   | ⛔ gate      | —     | GATE_ROTATE | `git log --all -- .env` → vazio; chave nova   |
| B-007 | Login Google quebra no mobile | bug   | manual       | P0   | ⬜ ready     | —     | —           | `npm test auth` verde; testado no DevTools    |
| B-008 | Extrair util de datas         | debt  | passo-03     | P2   | ⬜ ready     | —     | —           | `grep -rn formatDate src` → 1 definição       |
| B-009 | Rate-limit no /api/contact    | idea  | manual       | P1   | 🧊 icebox    | B-011 | —           | (promover a passo do ROADMAP se aceito)       |
| B-011 | Provisionar Upstash Redis     | infra | manual       | P1   | ⛔ gate      | —     | GATE_REDIS  | `UPSTASH_REDIS_REST_URL` no .env; ping ok     |

<!-- Concluídos migram para .forge/BACKLOG.archive.md (ação explícita, nunca side-effect de leitura). -->
```

---

## Colunas (todas obrigatórias)

| Coluna | Regra |
|--------|-------|
| **ID** | `B-NNN` monotônico, nunca reusado. É o "número de issue" do item. |
| **Item** | O pedido fixo, em 1 linha. Não muta conforme o plano evolui. |
| **Tipo** | `bug \| debt \| infra \| chore \| idea`. **`feat` é proibido** (vai pro ROADMAP). |
| **Origem** | Obrigatória: `manual \| audit:<finding-id> \| passo-NN \| B-xxx`. `passo-NN` tem que existir em `.plans/steps/`. |
| **Prio** | `P0 \| P1 \| P2 \| P3`. Um eixo só (severidade×urgência colapsados). P0 = quebrado/segurança. |
| **Status** | `⬜ ready \| 🏗️ in-progress \| ✅ done \| 🧊 icebox`. **Bloqueio NÃO é status** — deriva de `Deps`+`Gate`. |
| **Deps** | IDs que precisam estar `✅ done` antes (ou `—`). Linha com Dep não-✅ não é selecionável. |
| **Gate** | Frontier nomeado (ex.: `GATE_REDIS`) ou `—`. Não-vazio + chave faltando → `/dev-next` **PARA com o link**. |
| **Aceite** | **Uma linha** grep/test/build-checável. Obrigatória. É o critério de "done" verificável. |

## Estados e seleção

- **Selecionável** = `Status ⬜ ready` **E** todas as `Deps` estão `✅ done` **E** `Gate` vazio-ou-satisfeito.
- **Bloqueado** não é um status — é derivado: uma linha `⬜ ready` com Dep pendente ou Gate vivo simplesmente não entra na seleção (o `/dev-next` reporta o que bloqueia).
- **🧊 icebox** = ideia/parqueada; só entra quando alguém a promove (ready) ou, se `idea`, a promove a passo do ROADMAP.

## Como adicionar um item

- **Manual:** acrescente uma linha com o próximo `B-NNN`, `Origem: manual`, e um `Aceite` verificável.
- **Auditoria:** o `/dev-audit` semeia linhas com `Origem: audit:<id>` (após CHECKPOINT).
- **Derivado de um passo:** bug/dívida que apareceu rodando o passo 03 → `Origem: passo-03`.

## Anti-padrões

- ❌ `Tipo: feat` (double-track com o ROADMAP) · ❌ bloqueio como `Status` (deriva de Deps+Gate)
- ❌ `Aceite` vago/subjetivo (tem que ser grep/test/build) · ❌ `Origem` vazia
- ❌ reusar um `ID` · ❌ `Deps` apontando ID inexistente
- ❌ arquivar como efeito colateral de uma leitura (arquivar é ação explícita)
