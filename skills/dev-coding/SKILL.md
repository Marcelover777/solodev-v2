---
name: dev-coding
description: Executa um PLAN.md task por task — lê read_first, aplica a action, verifica acceptance, marca [x], faz commit atômico com referência à task. Mostra progresso (X/N), guarda de escopo quando a task infla, protocolo de drift quando a implementação diverge do plano. Suporta TDD vertical (tracer bullet red-green-refactor), checkpoints HITL. Use quando o usuário disser "/dev-coding", "executa o plano", "implementa o PLAN.md", "next task", "continua do task-XX", ou pedir para começar/continuar implementação a partir de um PLAN.md existente.
---

# /dev-coding — Executar PLAN.md task por task

> **Doutrina do Crucible — V1 completa, nunca MVP.** Todo projeto mira uma **V1 inteira, poderosa e totalmente funcional** desde o início: implementações reais, todos os estados tratados, tudo que a proposta do produto genuinamente exige. Nada de mock, dado chumbado, meia-feature ou "arrumo depois" como entregável. O escopo é focado (não é o produto dos sonhos infinito), mas **tudo que entra é construído de verdade** — "pronto" é funcional e robusto, não um esqueleto pra mexer depois.

Esta skill assume que existe `.plans/<feature>/PLAN.md` produzido por `/dev-plan` (ou compatível). Executa uma task por vez, com verificação dura no fim de cada uma.

## Pré-condições

- Existe `<workspace>/.plans/<feature>/PLAN.md` (ou usuário aponta o path)
- Você pode escrever e executar comandos no projeto

Se não houver PLAN.md, **pare e sugira `/dev-plan` antes**. Se for bug isolado sem plano, sugira `/dev-fix`.

## Ritual de início de sessão

Na primeira execução da sessão (e após cada reset de contexto):

```
PLAN: <feature> — [████████░░░░] 4/9 tasks ✅
Próxima: task-05 (<tipo>, effort <S/M/L>) — <título>
```

1 mensagem, depois execute. O usuário sempre sabe onde está sem perguntar.

## Processo por task

### 1. Carregue o contexto mínimo

1. **Read** `.plans/<feature>/PLAN.md` integralmente
2. **Read** `CLAUDE.md` do projeto + sub-CLAUDEs citados em `## Affected Areas`
3. Identifique a próxima task com `status: [ ]` cuja dependência (`depends_on`) já está `[x]`
4. **Read** todos os `read_first` da task escolhida ANTES de qualquer edit

### 2. Despache pelo tipo

#### `type: auto` (execução direta)

1. Anuncie em 1 frase: *"task-XX: <título> — vou tocar <files>."*
2. Execute as subtasks da `action` em ordem
3. Rode o `must_pass` (typecheck, build, test, lint conforme aplicável)
4. Cheque cada `acceptance` — grep / curl / output esperado
5. Marque `[x]` em cada acceptance no PLAN.md
6. Atualize `## Status Log` com timestamp + identificador (commit hash se for committar)
7. Reporte ao usuário em 2-3 linhas: o que mudou, o que verificou, próxima task

#### `type: tdd` (red-green-refactor vertical)

**Princípio:** tracer bullets, NÃO horizontal slicing. UM teste → UMA implementação → REPETE. Nunca escrever todos os testes primeiro.

Por subtask:
```
RED:   escreva 1 teste para 1 behavior — rode → vê falhar
GREEN: código mínimo para passar — rode → vê passar
       (não antecipe próximos testes; não adicione features especulativas)
[Após todas as subtasks GREEN: REFACTOR — só quando GREEN, nunca quando RED]
```

Regras de teste:
- Testar **behavior** via interface pública, não implementação interna
- Sem mocks de colaboradores internos (mock só boundary externo — DB, HTTP)
- Teste deve sobreviver a refactor que não muda behavior
- Se renomear função interna quebra o teste, o teste estava errado

#### `type: checkpoint:decision`

1. Pare a execução
2. Apresente ao usuário (1 mensagem): o que decidir (`decision`), por que importa, opções com pros/cons
3. **Espere resposta.** Não escolha sozinho.
4. Após escolha, registre no PLAN.md → seção `## Decisions` e siga para próxima task.

#### `type: checkpoint:human-verify`

1. Execute o setup (start dev server, run command, etc.)
2. Confirme que o ambiente está pronto (HTTP 200, port aberta, build ok)
3. Apresente: URL/comando para verificar + 2-4 checks visuais/funcionais específicos
4. **Espere "approved" ou descrição do problema.**
5. Se aprovado → marque `[x]`, mate o server se for o caso
6. Se reprovado → mude para `/dev-fix` (diagnose loop) com o problema descrito

### 3. Guarda de escopo (a task inflou)

Pare e re-planeje quando, no meio de uma task:
- Os arquivos tocados passam de **2× o `files_modified`** declarado
- Aparece decisão de design que o plano não previu
- A "correção rápida no caminho" está virando uma sub-feature

Protocolo: pare, escreva no PLAN.md o que descobriu, proponha: dividir a task / criar task nova / decisão de checkpoint. **Não engula escopo em silêncio** — é assim que plano vira ficção.

### 4. Protocolo de drift (implementação divergiu do plano)

Quando a realidade do código contradiz o plano (API não existe como descrito, lib não suporta o approach, schema diferente):

1. **Não improvise em silêncio.** Pare a task.
2. Registre em `## Decisions` do PLAN.md: o que o plano dizia → o que a realidade é → o novo approach (1-3 linhas).
3. Se a mudança afeta tasks futuras, ajuste-as agora (títulos/acceptance), não depois.
4. Continue. O PLAN.md deve sempre contar a verdade — uma sessão nova que ler o plano não pode herdar a mentira.

### 5. Commits atômicos

Ao fim de cada task verde (se o repo usa git e o usuário não disse o contrário):
- 1 task = 1 commit. Mensagem: `<tipo>(<área>): <o que mudou> [task-XX]`
- Tipos convencionais: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`
- Nunca `git add .` cego — adicione os arquivos da task
- Hash vai para o `## Status Log`

### 6. Atualize o PLAN.md ao vivo

Cada task completed → mark `[x]` em cada `acceptance` + entrada no `## Status Log`. Não acumule pra escrever no fim.

### 7. Ao terminar a última task

Não declare "pronto" aqui. Anuncie:

> *"Todas as tasks executadas. Rodando `/dev-ship` para verificação final, Must-Haves e fechamento?"*

`/dev-ship` roda Must-Haves, demo script, revisão de diff e fechamento. Se o usuário recusar, rode ao menos os Must-Haves do PLAN.md você mesmo (Truths, Artifacts, Key Links) antes de declarar done — falhou algo, crie fix-task, não mascare.

## Princípios de execução (Karpathy)

- **Cirurgia, não reforma.** Toque só o que a task pede. Não refatore código adjacente, não "melhore" formatação, não adicione tipos onde não havia. Se notar algo, mencione — não delete.
- **Mínimo necessário.** Resolva a task. Não adicione abstração para uso único. Não preveja features futuras.
- **Critério de sucesso primeiro.** Antes de codar, releia `acceptance` e `must_pass`. Sua execução tem como meta acender esses verdes.
- **Verify before done.** Rode o `must_pass`. Cheque cada `acceptance`. Não declare done com base em vibes.
- **Sem error handling especulativo.** Só valide em boundary (input externo). Confie em garantias internas.

## Anti-padrões

- ❌ Pular `read_first` ("é rápido, sei o que tem ali")
- ❌ Escrever todos os testes TDD juntos antes de qualquer implementação
- ❌ Refatorar enquanto está RED
- ❌ Marcar `[x]` sem rodar a verificação
- ❌ Reescrever arquivo inteiro quando 5 linhas resolvem
- ❌ Skip de hooks/lint/typecheck para "ir mais rápido"
- ❌ Esconder falha mudando o teste em vez de corrigir o código
- ❌ Mockar colaborador interno (vai dar verde com behavior quebrado)
- ❌ Auto-aprovar checkpoint HITL ("não vou perguntar, já sei a resposta")
- ❌ Engolir drift/escopo em silêncio (o plano precisa contar a verdade)

## Comunicação com o usuário

**Antes de cada task:** 1 frase — "task-XX: vou tocar X, Y."

**Durante:** silêncio relativo. Não narre tool calls. Comunique só obstáculo ou descoberta surpreendente.

**Depois de cada task:** 2-3 linhas — o que mudou, o que verificou, próxima task ID.

## Quando parar e perguntar (mesmo em modo auto)

- A task tem `acceptance` ambíguo na prática
- A mudança implica decisão de design não prevista no plano
- O `must_pass` falha de forma que sugere problema arquitetural (não bug local)
- Vai tocar arquivo sensível não listado em `files_modified`
- Vai rodar comando destrutivo (force push, drop table, rm -rf)

**Não improvise nessas.** Pare, reporte, pergunte.
