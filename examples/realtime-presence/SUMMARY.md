---
feature: realtime-presence
status: shipped
shipped: 2026-06-11
plan: ./PLAN.md
brief: ./BRIEF.md
---

# SUMMARY — Presença em tempo real (quem está online)

## O que foi entregue

Uma fileira de avatares no topo do editor de documento que mostra ao vivo quem mais está com aquele documento aberto. Alimentada por Supabase Realtime Presence num canal por documento (`presence:doc:<id>`), com identidade montada/validada no servidor (payload só com `user_id`, nome, avatar e `online_at` — sem dado sensível). A UI deriva sempre do estado completo de presença (convergente entre clientes), deduplica por `user_id` (2 abas = 1 avatar), oculta o próprio avatar, colapsa o excedente em `+N` a partir de 6 participantes e trata loading/erro/vazio sem derrubar a edição — presença é enhancement não-bloqueante. Join reflete em ~1s e leave em ~11s nos testes manuais, dentro dos SLAs de ≤2s/≤15s, inclusive com aba crashada à força (fantasma some na expiração do heartbeat).

## Commits envolvidos

- `a1b2c3d` — feat(realtime): canal de presence por documento + identidade server-validated [task-01]
- `e4f5a6b` — feat(realtime): hook usePresence com dedupe por user_id e status de conexão [task-02]
- `c7d8e9f` — feat(presence): PresenceBar com avatares, +N, loading/erro/vazio [task-03]
- `b0c1d2e` — feat(doc): montar PresenceBar no editor do documento [task-04]

## Decisões tomadas durante execução

Copiadas de `PLAN.md § Decisions` (todas se mantiveram na execução — não houve drift):

- **Um canal por documento (`presence:doc:<id>`)** — isola estado, payload enxuto, sem vazamento entre salas.
- **Identidade montada/validada no servidor** — `user_id`/name/avatar vêm da sessão Supabase, nunca de valor forjável do cliente.
- **UI derivada de `presenceState()` completo** — fonte da verdade convergente; sem acumular join/leave manualmente (mata a race de ordem).
- **Dedupe por `user_id`** — duas abas do mesmo usuário contam como 1 avatar.
- **Não renderizar o próprio avatar** — "você" é implícito; menos ruído.
- **Presença não-bloqueante** — falha de Realtime degrada para "presença offline", nunca trava o editor.
- **+N a partir de 6 participantes** (resolveu a Q1 do BRIEF) — 5 avatares visíveis + badge.
- **Timeout: confiar na expiração de heartbeat do servidor** (resolveu a Q2 do BRIEF) — `leave` não é garantido em crash; o teto de 15s tem folga sobre o default do Realtime (confiança medium — reconfirmar se a sala crescer).

## Follow-ups deferidos

Apareceram durante a feature e ficaram fora de escopo — candidatos a próximo `/dev-brainstorm`:

- **Salas grandes (>25 participantes):** o teto desta iteração é ~25; acima disso, volume de broadcast e o timeout de heartbeat precisam ser reavaliados (Risk Radar #2). É feature nova, não fix.
- **Cursores / seleção ao vivo:** Non-Goal explícito; é a evolução natural de "quem" para "onde".
- **Reconfirmar o timeout real de expiração** se o perfil de uso mudar (discovery ficou em confiança medium).

## SHIP CHECK — realtime-presence

```
SHIP CHECK — realtime-presence
✅ build/test/lint: verde — npm run build, npm test, npm run lint
✅ Must-Haves: 5/5 | Demo: ok (2 sessões — join ~1s, leave ~11s, crash-kill limpou fantasma)
✅ Diff review: limpo — sem console.log/TODO; payload de presença sem campos sensíveis confirmado
✅ Security: limpo — identidade server-validated, sem segredo hardcoded, sem email no payload, RLS de documento já filtra a sala
📦 Commits: a1b2c3d, e4f5a6b, c7d8e9f, b0c1d2e
🔭 Follow-ups: salas >25; cursores ao vivo; reconfirmar timeout de heartbeat
```
