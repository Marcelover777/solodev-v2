---
name: dev-help
description: Cartão de referência rápida do solodev — mostra o ciclo de vida das skills, qual usar em cada momento, o que cada uma entrega e onde ficam os outputs. Exibição one-shot (não é um modo persistente). Use quando o usuário disser "/dev-help", "ajuda do solodev", "qual skill eu uso agora", "que comando do solodev serve pra isso", "me lembra o fluxo", "como funciona o solodev", ou parecer perdido sobre qual fase do ciclo está.
---

# /dev-help — Qual skill usar agora

Cartão de referência. Mostre o conteúdo abaixo, adaptando a recomendação ao que o usuário acabou de dizer. **One-shot:** exiba e saia — não entra em modo nenhum, não fica perguntando.

## O ciclo

```
/dev-context  ·  /dev-brainstorm  →  /dev-plan  →  /dev-coding  →  /dev-ship
  CONTEXT.md        BRIEF.md           PLAN.md       executa         verifica + fecha
 (1x por projeto)                                       ↑
                                                    /dev-fix  (bug, a qualquer hora)
                                                    /dev-help (este cartão)
```

## Qual usar

| Você está com… | Use | Sai |
|----------------|-----|-----|
| Projeto novo / repo sem memória pra IA | `/dev-context` | `CONTEXT.md` na raiz |
| Ideia bruta, falada, ainda difusa | `/dev-brainstorm` | `BRIEF.md` + Risk Radar |
| BRIEF fechado, quer estruturar | `/dev-plan` | `PLAN.md` atômico |
| PLAN pronto, hora de executar | `/dev-coding` | código + commits `[task-XX]` |
| Algo quebrou (bug, stack trace) | `/dev-fix` | causa raiz + fix + regressão |
| "Tá pronto?" / fechar a feature | `/dev-ship` | `SUMMARY.md` + ship check |
| Perdido no fluxo | `/dev-help` | este cartão |

## Regras de ouro

- **`/dev-context` roda 1x por projeto** (e quando a arquitetura muda) — não por feature.
- **Tarefa S (≤30 min, 1-2 arquivos)** não precisa de BRIEF nem PLAN — o `/dev-brainstorm` tria e oferece executar direto.
- **Bug não precisa de plano** — vai direto pro `/dev-fix`.
- **`PLAN.md` é memória externa.** Pode dar `/clear` no meio: o plano carrega o resto.
- **Pronto = demonstrado, não sentido.** `/dev-ship` só fecha o que roda verde + demo.

## Onde ficam os arquivos

- `CONTEXT.md` — raiz do projeto (memória de vocabulário, fonte que as outras citam).
- `.plans/<feature-slug>/` — `BRIEF.md`, `PLAN.md`, `DISCOVERY.md` (opcional), `SUMMARY.md`.

## Próximo passo

Sugira o comando que encaixa no momento do usuário. Sem contexto, o ponto de partida natural é `/dev-context` (projeto novo) ou `/dev-brainstorm` (já tem CONTEXT e uma ideia na cabeça).
