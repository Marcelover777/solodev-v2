---
name: dev-context
description: Gera a memória de projeto (CONTEXT.md) que serve de fonte de vocabulário para todo o ciclo Forger — one-liner, mapa de arquitetura, glossário canônico, convenções, invariantes, comandos e boundaries externos. Explora o repo em silêncio (manifests, estrutura, CLAUDE.md/AGENTS.md, schema) e só pergunta o que o código não responde. Use quando o usuário disser "/dev-context", "gera o contexto do projeto", "monta o CONTEXT.md", "preciso de memória de projeto pra IA", "documenta a arquitetura", "bootstrap do projeto", ou ao começar a trabalhar num repo que ainda não tem memória estruturada.
---

# /dev-context — Memória de projeto, fonte de vocabulário

Esta skill produz `CONTEXT.md` — a **memória de projeto** que `/dev-brainstorm` e `/dev-plan` citam quando dizem *"se o projeto tem CONTEXT.md, alinhe ao vocabulário"*. Não é doc de feature: é o vocabulário, a arquitetura e os invariantes que não mudam a cada task.

## Propósito

Um projeto sem memória força cada sessão a reaprender o domínio do zero — e o vibe coder reinventa termos, ignora invariantes e contradiz a arquitetura sem perceber. `CONTEXT.md` é a fonte de verdade do **vocabulário**: o glossário canônico, o mapa de quem-faz-o-quê, as regras "nunca faça X" e os comandos do projeto. As outras skills alinham a ele; esta o cria.

## Quando rodar

| Situação | Roda? |
|----------|-------|
| Começo de projeto novo (ou primeiro contato com repo sem memória) | **Sim — 1x.** É o bootstrap. |
| Arquitetura mudou (novo módulo de peso, troca de stack, boundary novo) | **Sim — atualize o CONTEXT.md.** |
| Vocabulário do domínio evoluiu (termo renomeado, conceito novo virou central) | **Sim — atualize o glossário.** |
| Nova feature, bug, mudança pontual | **Não.** Isso é `/dev-brainstorm` → `/dev-plan`, não CONTEXT.md. |

**CONTEXT.md roda por projeto, não por feature.** Se você está documentando "como vou construir X", parou na skill errada — volte pra `/dev-brainstorm`.

## Processo

### 1. Explore o repo em silêncio

Antes de qualquer pergunta, leia o que o código já responde. Não pergunte o que está no disco. Use Grep/Read para cobrir:

- **Manifests:** `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `composer.json` — stack, deps, scripts.
- **Scripts/comandos:** `package.json` scripts, `Makefile`, `justfile`, `Taskfile`, CI workflows — como buildar/testar/rodar.
- **Estrutura de pastas:** os diretórios de topo e o que cada um concentra (módulos-chave).
- **Docs existentes:** `CLAUDE.md`, `AGENTS.md`, `README.md`, ADRs, `docs/`.
- **Schema/dados:** migrations, `schema.prisma`, `*.sql`, modelos ORM — entidades centrais do domínio.
- **Boundaries externos:** clientes de DB, SDKs de API, filas, env vars (`.env.example`) — com quem o sistema fala.

### 2. Pergunte só o que o código NÃO responde

O código mostra a arquitetura; ele **não** mostra a intenção. Pergunte (uma por vez, sempre com recomendação inline, máximo 3-6 no total) apenas o que precisa de cabeça humana:

- **Domínio/intenção:** o que esse projeto é, em uma frase, na perspectiva de quem usa.
- **Glossário ambíguo:** termo que aparece no código com sentido específico do negócio ("conta", "pedido", "cancelamento" raramente significam o óbvio).
- **Invariantes de negócio:** os "nunca faça X" que não estão escritos em lugar nenhum mas todo mundo na equipe sabe ("nunca deletar pedido — só soft-delete", "toda escrita passa por tal serviço").

Formato de cada pergunta:

```
Pergunta: <pergunta concreta e fechada>
Recomendação: <o que o código sugere + 1 frase do porquê>
```

Se o código já sugere a resposta, proponha-a e peça só confirmação — não transforme exploração em interrogatório.

### 3. Escreva o CONTEXT.md

Use [CONTEXT-TEMPLATE.md](CONTEXT-TEMPLATE.md) como esqueleto. Preencha do que descobriu na exploração + nas respostas. Curto e denso — fonte de verdade do vocabulário, não um romance.

## Regra DRY — não duplicar o CLAUDE.md

Se o projeto já tem `CLAUDE.md` (ou `AGENTS.md`), **cite, não copie.** CONTEXT.md cobre o que o CLAUDE.md não cobre — sobretudo **glossário do domínio** e **invariantes de negócio**, que CLAUDE.md raramente tem. Para convenções/comandos que já estão no CLAUDE.md, escreva *"ver CLAUDE.md § Comandos"* em vez de redigitar. Memória que repete memória vai destoar na primeira edição.

## Saída

- **Local:** `CONTEXT.md` na **raiz** do projeto (default). Se o projeto concentra documentação em `docs/`, escreva `docs/CONTEXT.md` e cite o caminho.
- **Tamanho:** denso. Cada seção paga seu espaço ou sai. Glossário gigante com termos que ninguém usa é ruído, não memória.
- **Frescor:** atualize quando arquitetura ou vocabulário mudam — não deixe virar ficção que contradiz o código.

## Anti-padrões

- ❌ Duplicar o que o CLAUDE.md já diz (cite com `ver CLAUDE.md § X`)
- ❌ CONTEXT.md gigante (memória densa > memória completa; ninguém lê 5 páginas a cada sessão)
- ❌ Inventar arquitetura/módulo que não existe no código (você explora primeiro, descreve o que está lá)
- ❌ Glossário com termos que ninguém usa (só o vocabulário real do domínio entra)
- ❌ Perguntar o que o código responde (preguiça mascarada — leia os manifests e o schema antes)
- ❌ Documentar uma feature aqui (isso é BRIEF/PLAN — CONTEXT.md é o projeto, não a task da semana)
- ❌ Invariantes vagos ("código limpo") em vez de regras verificáveis ("toda escrita em `orders` passa por `OrderService`")

## Próximo passo

Quando o CONTEXT.md estiver escrito, sugira explicitamente:

> *"CONTEXT.md pronto na raiz — é a memória de vocabulário do projeto. As próximas skills (`/dev-brainstorm`, `/dev-plan`, `/dev-coding`, `/dev-ship`) vão alinhar a ele. Pronto pra `/dev-brainstorm` estressar a primeira ideia?"*
