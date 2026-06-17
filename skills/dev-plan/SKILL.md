---
name: dev-plan
description: Transforma um BRIEF (ou ideia já discutida) em PLAN.md atômico — tasks com critério verificável, vertical slices, must-haves observáveis, esforço estimado e pontos de reset de contexto. Sem código no plano. Auto-suficiente para reset — uma nova sessão consegue retomar lendo só o PLAN.md. Use quando o usuário disser "/dev-plan", "monta o plano", "transforma em plano", "vamos planejar", "quero plano atômico", "preciso resetar contexto e ter o plano pronto", ou pedir para estruturar tasks/subtasks após brainstorming.
---

# /dev-plan — Plano atômico, reset-friendly, sem código

> **Doutrina do Crucible — V1 completa, nunca MVP.** Todo projeto mira uma **V1 inteira, poderosa e totalmente funcional** desde o início: implementações reais, todos os estados tratados, tudo que a proposta do produto genuinamente exige. Nada de mock, dado chumbado, meia-feature ou "arrumo depois" como entregável. O escopo é focado (não é o produto dos sonhos infinito), mas **tudo que entra é construído de verdade** — "pronto" é funcional e robusto, não um esqueleto pra mexer depois.

Esta skill produz `.plans/<feature>/PLAN.md` — um documento auto-suficiente. Uma sessão nova de Claude Code, lendo só esse arquivo + o CLAUDE.md do projeto, deve conseguir executar a feature inteira via `/dev-coding`.

## Princípios não-negociáveis

1. **Sem código no plano.** Sem snippets de implementação, sem TypeScript, sem SQL. Apenas: decisões, áreas afetadas, contratos de interface (prose), critérios de aceite verificáveis. Exceção rara: snippet de tipo/schema/state-machine quando isso encoda a decisão de forma mais precisa que prosa.

2. **Tasks atômicas com critério verificável.** Cada task tem `acceptance` que pode ser checada via grep / build / test, não "feito quando funcionar".

3. **Vertical slices preferidos.** Cada task corta TODAS as camadas (schema → API → UI → test) em uma fatia fina, NÃO uma camada inteira por vez. Antipadrão: task-01 = todos os models, task-02 = todas as APIs, task-03 = toda UI.

4. **Reset protocol embutido.** O plano contém a seção `## Reset Protocol` no fim — instruções para sessão nova retomar do zero.

5. **Karpathy mínimo necessário.** Não invente fases, milestones, OKRs, riscos especulativos. Se a feature cabe em 5 tasks, são 5 tasks — não invente sub-sprints.

## Processo

### 1. Carregue contexto

Em ordem:
1. **Read** `.plans/<feature>/BRIEF.md` se existir → fonte primária
2. **Read** `CLAUDE.md` do projeto + sub-CLAUDEs relevantes (ex.: `src/app/CLAUDE.md`)
3. **Read** glossário/schema/CONTEXT do projeto se aplicável
4. Se não houver BRIEF, faça grilling rápido (3-5 perguntas críticas) — modo `/dev-brainstorm` condensado

### 2. Explore o codebase (read-only)

Grep + Read das áreas afetadas. Não escreva nada de código ainda — só entenda:
- Padrões atuais (convenções, estilo, testes)
- Pontos de extensão naturais
- Dependências que vão ser tocadas
- Riscos de quebra (migrations, contratos públicos, schemas)

### 3. Discovery (quando há unknown)

Se há decisão pendente sobre lib / API / approach que o BRIEF não fechou, ativar **discovery curto**:
- 1-3 fontes: docs oficiais > Context7 > web search
- Saída no fim da seção `## Discovery` do PLAN com: recomendação + 1-2 alternativas descartadas + nível de confiança (high/medium/low)

**Quando NÃO fazer discovery:** padrão já estabelecido no projeto, decisão trivial, ou o BRIEF já fechou.

### 4. Quebra em tasks (vertical slices)

Heurísticas de granularidade:
- **2-5 subtasks por task.** Se passou disso, divida.
- **1 task = 1 vertical slice demoável.** Após completar, algo observável melhorou (mesmo que feature flag).
- **Tasks independentes em paralelo** se não compartilham arquivos.
- **Tasks com dependência genuína** marcam `depends_on`.

Tipos de task:
- `auto` — Claude consegue executar fim-a-fim sozinho
- `tdd` — vale red-green-refactor (heurística: dá pra escrever `expect(fn(in)).toBe(out)` antes de `fn`?)
- `checkpoint:decision` — pausa para o user escolher entre opções
- `checkpoint:human-verify` — pausa para o user testar visualmente / em produção

Campos novos por task:
- **effort:** `S` (minutos) | `M` (até ~1h) | `L` (1 sessão). Se alguma task é L, provavelmente deve ser dividida.
- **rollback:** OBRIGATÓRIO para task que toca migration, contrato público, dado de produção ou config de deploy. 1 linha: como desfazer. Tasks sem risco: omitir o campo.

### 5. Pontos de reset de contexto

Contexto é recurso finito. Marque no plano onde vale resetar:

- Após tasks que geram muito ruído de exploração (discovery, leitura de schema grande), insira a linha `> 🔄 bom ponto de /clear — o plano carrega o resto` entre tasks.
- Heurística: feature com 6+ tasks → pelo menos 1 ponto de reset no meio.
- O PLAN.md é a memória externa; a sessão é descartável. É isso que torna o reset barato.

### 6. Defina Must-Haves (goal-backward)

Após listar tasks, escreva o que precisa ser VERDADE quando tudo acabar. 3 categorias enxutas:
- **Truths:** behaviors observáveis (ex.: *"user consegue criar X via UI"*)
- **Artifacts:** arquivos que devem existir com substância real (ex.: `src/foo/bar.ts` > 30 linhas, exporta `[X, Y]`)
- **Key Links:** conexões críticas via regex (ex.: `src/api/route.ts` faz `fetch('/api/x')` — regex `fetch\(['"]/api/x`)

Mais uma, nova:
- **Demo script:** 3-6 passos para demonstrar a feature funcionando em até 60 segundos (comando + o que observar). Se você não consegue escrever o demo script, a feature não tem critério de pronto observável — volte aos Goals.

Por que isso importa: task ✅ ≠ goal ✅. Uma task "criar componente Chat" pode "completar" criando um placeholder vazio. Must-Haves capturam o que precisa funcionar de verdade.

### 7. Escreva o PLAN.md

Use [PLAN-TEMPLATE.md](PLAN-TEMPLATE.md) como esqueleto. Resultado final em `.plans/<feature>/PLAN.md`.

### 8. Quiz curto (1 turn)

Antes de fechar, mostre ao usuário em 1 mensagem:
- Lista numerada de tasks (título + tipo + effort + 1 linha do que faz)
- Esforço total estimado (soma dos S/M/L)
- Pergunta: *"Granularidade ok? Alguma task deveria ser dividida ou fundida? Algum critério de aceite que vai falhar como `must_pass`?"*

Itere se necessário.

## Estrutura recomendada do diretório

```
.plans/<feature>/
├── BRIEF.md          (output de /dev-brainstorm — opcional)
├── PLAN.md           (output desta skill — source of truth)
├── DISCOVERY.md      (opcional, quando lib choice precisa de research)
└── SUMMARY.md        (output de /dev-ship ao terminar)
```

## Critérios de aceite (escrever bem)

Bom critério de aceite:
- ✅ `src/foo/bar.ts` exporta `someFn` (grep verificável)
- ✅ `<test runner> test foo` passa (`npm test`, `pytest tests/foo`, `cargo test foo`, etc.)
- ✅ Endpoint `POST /api/x` retorna 201 com body válido em smoke
- ✅ Migration `2026XX_foo.sql` cria tabela `foo` com PK `id uuid`

Mau critério de aceite:
- ❌ "Funciona corretamente"
- ❌ "Está bem implementado"
- ❌ "Sem regressão"
- ❌ "User pode usar a feature"

## Anti-padrões

- ❌ **Snippets de implementação no PLAN.md** (vai stale rápido — código vive em código)
- ❌ **Tasks horizontais** (task-01 = "todos os models" → mata paralelismo, esconde bugs de integração)
- ❌ **Critério vago** ("funciona", "está ok", "user consegue usar")
- ❌ **Reflexive chaining** (task-03 `depends_on: [02]` só porque vem depois)
- ❌ **Sem `read_first`** (executor modifica arquivo sem ler estado atual)
- ❌ **Fases/sprints/epics inventados** (solo dev — chama de task e subtask)
- ❌ **Documentar coisa que CLAUDE.md já documenta** (DRY com o repo)
- ❌ **Must-Haves de mais** (3-5 truths, não 20 — caso contrário não testamos no fim)
- ❌ **Task com migration sem `rollback`** (o campo existe para te salvar às 23h de uma sexta)

## Plan Mode interaction

Esta skill funciona bem dentro do Plan Mode do Claude Code. Se você está em plan mode:
1. Faça toda exploração e discovery
2. Apresente o PLAN.md ao usuário via `ExitPlanMode`
3. Após aprovação, salve em `.plans/<feature>/PLAN.md` e sugira `/dev-coding`

Se NÃO está em plan mode: escreva o arquivo direto e mostre resumo ao usuário.

## Próximo passo

Após PLAN.md fechado:

> *"PLAN.md salvo em `.plans/<feature>/PLAN.md`. Pronto pra `/dev-coding` executar task-01? Você pode resetar contexto agora — o plano é auto-suficiente."*
