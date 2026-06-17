---
name: dev-ship
description: Fechamento de feature — verificação goal-backward antes de declarar pronto. Roda Must-Haves do PLAN.md, executa o demo script, revisa o diff completo procurando bugs e restos (debug logs, TODOs, código morto), passa lente de segurança nos arquivos tocados, escreve SUMMARY.md e arquiva o plano. Use quando o usuário disser "/dev-ship", "fecha a feature", "pode shippar?", "tá pronto?", "revisa antes de commitar", ou quando /dev-coding terminar a última task de um PLAN.md.
---

# /dev-ship — Pronto é estado verificado, não sensação

> **Doutrina do Crucible — V1 completa, nunca MVP.** Todo projeto mira uma **V1 inteira, poderosa e totalmente funcional** desde o início: implementações reais, todos os estados tratados, tudo que a proposta do produto genuinamente exige. Nada de mock, dado chumbado, meia-feature ou "arrumo depois" como entregável. O escopo é focado (não é o produto dos sonhos infinito), mas **tudo que entra é construído de verdade** — "pronto" é funcional e robusto, não um esqueleto pra mexer depois.

Task ✅ ≠ feature ✅. Esta skill é a barreira entre "terminei as tasks" e "isso pode ir pra produção". Roda no fim de um PLAN.md ou standalone sobre qualquer diff que o usuário queira fechar.

## Processo

### 1. Verificação dura (must_pass global)

Rode, na ordem, o que o projeto tiver (CLAUDE.md diz quais):
1. Typecheck / build
2. Suite de testes completa (não só os módulos tocados)
3. Lint

**Qualquer vermelho para o ship aqui.** Vermelho vira fix-task (ou `/dev-fix`) — nunca "é flaky, ignora".

### 2. Must-Haves do PLAN.md (goal-backward)

Se existe `.plans/<feature>/PLAN.md`:
- **Truths:** cheque cada behavior listado — idealmente via smoke test, não inspeção visual
- **Artifacts:** cada arquivo existe? min_lines? exports/contains corretos?
- **Key Links:** rode os regex declarados — devem casar
- **Demo script:** execute os passos. A feature demonstra em 60s ou não demonstra?

Falhou qualquer um → diagnostique por que a task "completed" não satisfez o goal, crie fix-task no PLAN.md, execute, re-verifique. **Loop até verde. Não mascare.**

### 3. Revisão do diff (você é o reviewer agora)

Leia o diff completo da feature (`git diff <base>...HEAD` ou working tree) com olhos de reviewer, não de autor:

**Caçada a restos:**
- `console.log` / `print` / `dbg!` de debug, prefixos `[DEBUG-*]`
- `TODO`/`FIXME`/`HACK` novos sem issue ou justificativa
- Código comentado, imports não usados, arquivos órfãos
- Dependência adicionada que só se usa em 1 linha trocável

**Caçada a bugs de autor:**
- Edge cases dos Goals que nenhuma task cobriu
- Error paths que engolem erro em silêncio (catch vazio)
- Async sem await / promise solta / race óbvia
- Off-by-one em paginação/slice/loop

### 4. Lente de segurança (só arquivos tocados)

Não é auditoria completa — é o mínimo que evita vergonha:
- Segredo/chave/token hardcoded? (inclusive em teste e fixture)
- Input externo chegando em query/comando/path sem validação?
- Endpoint novo sem auth/permissão onde os vizinhos têm?
- Dado sensível indo pra log?

Achou algo → severidade + fix antes do ship (ou flag explícito ao usuário se for aceito como risco).

### 5. SUMMARY.md + arquivamento

Escreva `.plans/<feature>/SUMMARY.md`:
- O que foi entregue (1 parágrafo)
- Commits envolvidos
- Decisões tomadas durante execução que não estavam no plano (copie de `## Decisions`)
- Follow-ups deferidos (o que apareceu e ficou de fora — candidatos a próximo `/dev-brainstorm`)

Atualize o frontmatter do PLAN.md: `status: done`.

### 6. Entrega final

1 mensagem ao usuário:

```
SHIP CHECK — <feature>
✅ build/test/lint: <verde — comandos rodados>
✅ Must-Haves: <N/N> | Demo: <ok / passos>
✅ Diff review: <limpo | X restos removidos | Y achados>
✅ Security: <limpo | achados + ação>
📦 Commits: <lista curta>  
🔭 Follow-ups: <0-3 itens>
```

Se o repo usa PR: ofereça draft de descrição (o SUMMARY já é 80% dela).

## Modo standalone (sem PLAN.md)

Usuário pediu "revisa antes de commitar" sem plano? Pule a etapa 2, rode 1 + 3 + 4 sobre o diff atual e reporte no mesmo formato. É um pre-commit review disciplinado.

## Anti-padrões

- ❌ Declarar pronto com teste vermelho "não relacionado"
- ❌ Pular o demo script ("os testes passam, tá funcionando")
- ❌ Revisar só os arquivos "principais" do diff
- ❌ Acumular follow-ups dentro do ship (anote e ofereça novo ciclo — não infle o escopo agora)
- ❌ SUMMARY de 3 páginas (1 parágrafo + listas; quem quer detalhe lê o diff)

## Princípio

O vibe coder shippa quando *parece* pronto. Você shippa quando **demonstra** pronto: suite verde + Must-Haves verdes + demo executado + diff limpo. Essa é a diferença inteira.
