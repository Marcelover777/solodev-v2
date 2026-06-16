# PLAN.md Template

Salvar em `.plans/<feature-slug>/PLAN.md`. Auto-suficiente — sessão nova lendo só este arquivo + CLAUDE.md do projeto consegue executar a feature inteira.

---

```markdown
---
feature: <kebab-case-slug>
status: ready | in-progress | done
created: YYYY-MM-DD
brief: ./BRIEF.md         # se aplicável
---

# PLAN — <Feature Title>

## Context (read this first)

<5-10 linhas. O essencial pra alguém que nunca viu esta feature entender em 30 segundos:
- O projeto (1 frase)
- A área específica que esta feature toca (1-2 frases)
- Por que esta feature existe (1-2 frases)
- Stack/convenções relevantes que afetam a implementação (1-2 linhas)>

## Problem (why)

<3-5 linhas. A dor que motiva isso, na perspectiva de quem sente.>

## Solution (what)

<2-3 frases. O que vai existir quando isto for executado, ainda da perspectiva do usuário/sistema.>

## Goals (verifiable)

- <Comportamento observável 1>
- <Comportamento observável 2>
- <Comportamento observável 3>

## Non-Goals

- <Explicitamente fora de escopo>
- <Risco comum de scope creep cortado aqui>

## Constraints

- **Stack:** <restrição relevante; se já está em CLAUDE.md, citar e não repetir>
- **Performance:** <SLA/latência/throughput se importam>
- **Compliance:** <LGPD, RLS, auditoria se aplica>

## Decisions

- **<Decisão 1>** — <1 linha do porquê>
- **<Decisão 2>** — <1 linha do porquê>
- **<Decisão 3>** — <1 linha do porquê>

## Discovery (opcional)

> Apagar esta seção se a feature não precisou de research

**<Tópico investigado>** — Recomendação: `<resposta>`. Alternativas descartadas: `<B>` (razão), `<C>` (razão). Confiança: **high** | medium | low. Fontes: <doc oficial / Context7 / discussion link>.

## Glossary (termos relevantes)

- **<Termo>:** <definição precisa neste contexto>

> Se o projeto tem glossário canônico (CONTEXT.md, schema_catalog.yaml), cite e não duplique.

## Affected Areas

- `<path/file>` — <o que muda aqui>
- `<path/file>` — <o que muda aqui>
- `<path/dir>` — <novos arquivos esperados>

---

## Tasks

### task-01: <verb + object — ação clara>

- **type:** `auto` | `tdd` | `checkpoint:decision` | `checkpoint:human-verify`
- **effort:** `S` | `M` | `L`  <!-- L provavelmente deveria ser dividida -->
- **slice:** vertical (toca: <camadas: schema, API, UI, ...>)
- **depends_on:** [] | [`task-XX`]
- **rollback:** <OBRIGATÓRIO se toca migration/contrato público/dado de prod — 1 linha de como desfazer; omitir se sem risco>
- **read_first:**
  - `<path>` — <por que ler antes>
  - `<path>` — <convenção do projeto a respeitar>
- **files_modified:**
  - `<path>` (modify)
  - `<path>` (new)
- **action (subtasks):**
  1. <Subtask 1.1: passo concreto, com valores/identificadores exatos>
  2. <Subtask 1.2: passo concreto>
  3. <Subtask 1.3: passo concreto>
- **acceptance:**
  - [ ] `<arquivo>` exporta `<símbolo>` (grep verificável)
  - [ ] `<comando de test>` passa
  - [ ] `<algo medível>` igual a `<valor exato>`
- **must_pass:** `<comando(s) que devem rodar verde no fim>`

> 🔄 bom ponto de /clear — o plano carrega o resto

### task-02: <verb + object>

- **type:** `tdd`
- **effort:** `M`
- **slice:** vertical (toca: <camadas>)
- **depends_on:** [`task-01`]
- **read_first:**
  - `<path>`
- **files_modified:**
  - `<path>`
- **action:**
  1. <Subtask>
  2. <Subtask>
- **acceptance:**
  - [ ] <critério>
  - [ ] <critério>
- **must_pass:** `<comando>`

<!-- exemplo de checkpoint -->

### task-NN: <decisão durante execução>

- **type:** `checkpoint:decision`
- **decision:** <o que decidir>
- **options:**
  - **A:** <opção> — pros: <>, cons: <>
  - **B:** <opção> — pros: <>, cons: <>
- **resume_signal:** usuário responde "A" ou "B"

<!-- exemplo de visual verify -->

### task-NN: visual smoke

- **type:** `checkpoint:human-verify`
- **what_built:** <o que ficará rodando — ex.: dev server em http://localhost:3000/x>
- **how_to_verify:** <passos curtos de teste manual — só visual/funcional, não CLI>
- **resume_signal:** usuário responde "approved" ou descreve o problema

---

## Must-Haves (goal-backward verification)

Rodadas no fim por `/dev-coding`. Se qualquer uma falhar, geramos fix-tasks.

### Truths (observable behaviors)
- [ ] <User/sistema consegue X>
- [ ] <Sistema rejeita Y inválido>
- [ ] <Z aparece no log/UI conforme esperado>

### Artifacts (arquivos com substância real)
- `<path>` — min N linhas, exports: `[X, Y]`
- `<path>` — contém `<padrão regex>`

### Key Links (conexões críticas)
- `<from>` → `<to>` via `<como>` — regex: `<padrão>`
- `<from>` → `<to>` via `<como>` — regex: `<padrão>`

### Demo Script (a feature em 60 segundos)
1. `<comando>` — <o que observar>
2. `<ação>` — <o que deve aparecer>
3. `<verificação final>` — <valor/estado esperado>

> Se não dá pra escrever o demo script, a feature não tem critério de pronto observável — volte aos Goals.

---

## Reset Protocol

Para retomar do zero em uma nova sessão:

1. **Read** este arquivo (`.plans/<feature>/PLAN.md`) integralmente
2. **Read** `CLAUDE.md` do projeto + sub-CLAUDEs relevantes citados em `## Affected Areas`
3. **Read** os `read_first` da próxima task com status `[ ]`
4. Executar via `/dev-coding` a partir da primeira task pendente
5. Marcar `[x]` em `acceptance` à medida que progride; atualizar `## Status Log` no fim

---

## Status Log

Atualizado por `/dev-coding` durante execução. Não preencher antes.

- <YYYY-MM-DD HH:MM> — task-01 ✅ (commit `<hash>`)
- <YYYY-MM-DD HH:MM> — task-02 in progress
```

---

## Notas para quem escreve o PLAN

- **Contexto vence quantidade.** Melhor 3 linhas de contexto preciso que 30 linhas vagas.
- **Citações > duplicação.** Se CLAUDE.md já tem a convenção, cite (`ver CLAUDE.md § X`) em vez de copiar.
- **Critério verificável > prosa.** Cada `acceptance` deve dar pra checar via grep/test/build sem julgamento humano.
- **`read_first` é proteção.** Executor não modifica arquivo sem entender o estado atual.
- **must_pass dá rede de segurança.** Comando que rodaria em CI — se quebra, a task falhou.
- **Vertical slice preferido.** task-01 = (schema + API + UI + test) de uma fatia da feature, NÃO task-01 = todos os schemas.
