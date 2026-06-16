---
feature: realtime-presence
status: done
created: 2026-06-11
brief: ./BRIEF.md
---

# PLAN — Presença em tempo real (quem está online)

## Context (read this first)

App colaborativa de documentos em Next.js (App Router) + Supabase. A área tocada é a tela de edição de um documento (`/doc/[id]`): hoje ela carrega o documento mas não mostra quem mais está com ele aberto. Esta feature adiciona uma fileira de avatares de presença no topo do editor, alimentada por Supabase Realtime Presence num canal por documento. Auth e RLS de documento já existem; presença é puramente efêmera (nada novo no banco). Convenções do projeto em `CLAUDE.md` (client Supabase em `lib/supabase/`, componentes client com `"use client"`).

## Problem (why)

Dois usuários editam o mesmo documento sem se ver. Não há sinal de "quem está aqui agora", então trabalho é sobrescrito e a colaboração vira adivinhação. Falta o feedback mais básico de copresença.

## Solution (what)

No topo do editor aparece uma fileira de avatares de todos os *outros* usuários com aquele documento aberto agora. Entrou alguém → avatar aparece em ~2s; saiu/caiu → some em ~15s. Tudo ao vivo, sem reload, derivado do estado de presença do canal Supabase.

## Goals (verifiable)

- Abrir o documento renderiza avatares dos outros participantes presentes em ≤2s.
- Fechar aba / perder conexão remove meu avatar para os outros em ≤15s.
- Contagem/ordem dos avatares convergem entre todos os clientes da sala.
- Hover no avatar mostra o nome.
- Mesmo usuário com 2 abas = 1 avatar (dedupe por `user_id`).

## Non-Goals

- Cursores ao vivo / seleção de cada um.
- Indicador "está digitando".
- Histórico de presença ou presença cross-documento.
- Presença de usuários anônimos.

## Constraints

- **Stack:** Next.js App Router + Supabase Realtime Presence; canal por documento `presence:doc:<id>`. Client Supabase já em `lib/supabase/` (ver CLAUDE.md).
- **Performance:** join ≤2s, leave ≤15s, até ~25 participantes por sala.
- **Compliance:** payload de presença só com `user_id`, `name`, `avatar_url`, `online_at`. Nada de e-mail. Identidade derivada da sessão no servidor, não confiada do cliente. RLS de documento já filtra quem entra.

## Decisions

- **Um canal por documento (`presence:doc:<id>`)** — isola estado, payload enxuto, sem vazamento entre salas.
- **Identidade montada/validada no servidor** — `user_id`/name/avatar vêm da sessão Supabase, não de valor forjável no cliente.
- **UI derivada de `presenceState()` completo** — fonte da verdade convergente; nunca acumular join/leave manualmente (evita race fora de ordem).
- **Dedupe por `user_id`** — duas abas do mesmo usuário = 1 avatar.
- **Não renderizar o próprio avatar** — reduz ruído; "você" é implícito.
- **Presença não-bloqueante** — falha de Realtime degrada para "presença offline", nunca trava a edição.
- **+N a partir de 6 participantes** (resolve Q1 do BRIEF) — mostra 5 avatares + badge; entra agora, é barato.

## Discovery

**Timeout de expiração de presence no Supabase Realtime (resolve Q2 do BRIEF)** — Recomendação: confiar na expiração de heartbeat do servidor (`leave` não é garantido em crash) e validar que o SLA de leave ≤15s cai dentro do timeout default do projeto. Alternativas descartadas: heartbeat manual via `broadcast` (reinventa o que o Presence já faz, mais código e mais mensagens); polling de uma tabela `online_users` (persistência desnecessária para estado efêmero, custo de escrita). Confiança: **medium** — o teto de 15s tem folga sobre o default observado; reconfirmar se a sala crescer. Fontes: docs oficiais Supabase Realtime Presence.

## Glossary (termos relevantes)

- **presence:** conjunto vivo de quem tem o documento aberto agora; estado efêmero, não persistido.
- **sala / canal:** `presence:doc:<documentId>` — Realtime channel escopado ao documento.
- **presence state:** payload publicado via `track()` — `{ user_id, name, avatar_url, online_at }`.
- **heartbeat:** conexão WebSocket viva que mantém a presença; cai a conexão, o servidor expira a presença.
- **stale / fantasma:** presença de quem já saiu sem `leave` limpo; some na expiração do heartbeat.
- **sync / join / leave:** eventos do canal — `sync` = estado completo; `join`/`leave` = deltas.

> Glossário espelha o do BRIEF. Se nascer CONTEXT.md, citar de lá.

## Affected Areas

- `lib/realtime/presence.ts` — novo: cria/gerencia o canal de presence de um documento, expõe API para o hook.
- `lib/realtime/presence-identity.ts` — novo: monta o presence state a partir da sessão Supabase (server-validated).
- `hooks/use-presence.ts` — novo: hook client que assina o canal e devolve a lista deduplicada de participantes + status de conexão.
- `components/presence/PresenceBar.tsx` — novo: a fileira de avatares (+N, hover-nome, estados loading/erro/vazio).
- `app/doc/[id]/page.tsx` — modify: montar o `PresenceBar` no topo do editor passando `documentId` e identidade do usuário.
- `lib/supabase/` — read-only: reusar o client existente, não criar outro.

---

## Tasks

### task-01: criar canal de presence por documento + identidade server-validated

- **type:** `auto`
- **effort:** `M`
- **slice:** vertical (toca: realtime lib + identidade/sessão)
- **depends_on:** []
- **read_first:**
  - `lib/supabase/` — como o projeto instancia o client (server vs browser) e lê a sessão
  - `CLAUDE.md` — convenção de onde vivem helpers de `lib/`
- **files_modified:**
  - `lib/realtime/presence.ts` (new)
  - `lib/realtime/presence-identity.ts` (new)
- **action (subtasks):**
  1. `presence-identity.ts`: função que, a partir da sessão Supabase autenticada, devolve `{ user_id, name, avatar_url, online_at }` — recusa se não houver sessão (presença só para autenticado).
  2. `presence.ts`: função que abre o canal `presence:doc:<documentId>`, faz `track()` com o presence state da identidade e expõe `presenceState()` + handlers de `sync`/`join`/`leave` e um `unsubscribe`.
  3. Garantir payload mínimo (sem e-mail/dado sensível) e dedupe lógico por `user_id` na leitura do estado.
- **acceptance:**
  - [ ] `lib/realtime/presence.ts` exporta função que monta canal `presence:doc:` (grep `presence:doc:`)
  - [ ] `lib/realtime/presence-identity.ts` exporta a função de identidade e referencia a sessão Supabase (grep `auth.getUser` ou equivalente do projeto)
  - [ ] presence state não inclui `email` (grep nega `email` no payload)
- **must_pass:** `npm run typecheck`

### task-02: hook use-presence (estado deduplicado + status de conexão)

- **type:** `tdd`
- **effort:** `M`
- **slice:** vertical (toca: hook client + lógica de dedupe/derivação de estado)
- **depends_on:** [`task-01`]
- **read_first:**
  - `lib/realtime/presence.ts` — API exposta pela task-01
  - `hooks/` — convenção de hooks client do projeto
- **files_modified:**
  - `hooks/use-presence.ts` (new)
  - `hooks/__tests__/use-presence.test.ts` (new)
- **action (subtasks):**
  1. RED: teste — dado um `presenceState` com 2 conexões do mesmo `user_id`, o hook retorna 1 participante (dedupe).
  2. GREEN: derivar lista de participantes do `presenceState()` completo, deduplicando por `user_id`.
  3. RED/GREEN: teste — participante com `user_id === currentUserId` é filtrado da lista (não renderiza o próprio avatar).
  4. RED/GREEN: teste — estado de conexão do canal (`connecting` / `online` / `offline`) é exposto e cai para `offline` em erro de subscribe.
- **acceptance:**
  - [ ] `hooks/use-presence.ts` exporta `usePresence`
  - [ ] `npm test -- use-presence` passa (dedupe + filtro do self + status)
  - [ ] derivação parte do snapshot completo do canal: hook lê `presenceState()`/recebe o estado completo a cada evento e mapeia para a lista (grep `presenceState`); o teste de dedupe garante que reemitir o mesmo `sync` não acumula participantes (lista é recalculada, não somada entre `join`/`leave`)
- **must_pass:** `npm test -- use-presence && npm run typecheck`

> 🔄 bom ponto de /clear — o plano carrega o resto; tasks 03+ são a camada de UI

### task-03: PresenceBar — fileira de avatares com loading/erro/vazio e +N

- **type:** `auto`
- **effort:** `M`
- **slice:** vertical (toca: componente UI + estados de produto)
- **depends_on:** [`task-02`]
- **read_first:**
  - `hooks/use-presence.ts` — shape retornado (participantes + status)
  - `components/` — convenção de componentes/avatar existente para reusar
- **files_modified:**
  - `components/presence/PresenceBar.tsx` (new)
- **action (subtasks):**
  1. Renderizar até 5 avatares; excedente vira badge `+N`. Hover mostra o nome (title/tooltip).
  2. Estado loading (status `connecting`, antes do primeiro `sync`): skeleton de 1 avatar com pulse — sem layout shift.
  3. Estado erro (status `offline`): indicador discreto "presença offline" em cinza; não some o editor.
  4. Estado vazio (0 outros participantes): não renderizar a fileira.
- **acceptance:**
  - [ ] `components/presence/PresenceBar.tsx` exporta `PresenceBar`
  - [ ] componente trata os 4 estados (grep por `connecting`/`offline` e por branch de lista vazia)
  - [ ] com >5 participantes só 5 avatares renderizam e o restante colapsa num badge de excedente que mostra `+` seguido da contagem restante (verificável no teste/snapshot do componente: 7 participantes → 5 avatares + badge com texto começando em `+`; grep no JSX por um marcador `+` de overflow, ex.: regex `\+\{?\s*\w+`)
- **must_pass:** `npm run typecheck && npm run lint`

### task-04: montar PresenceBar no editor do documento

- **type:** `auto`
- **effort:** `S`
- **slice:** vertical (toca: página do documento, fechando o slice ponta-a-ponta)
- **depends_on:** [`task-03`]
- **read_first:**
  - `app/doc/[id]/page.tsx` — onde está o header do editor e de onde vem `documentId` + sessão
  - `lib/realtime/presence-identity.ts` — como obter a identidade server-side
- **files_modified:**
  - `app/doc/[id]/page.tsx` (modify)
- **action (subtasks):**
  1. No topo do editor, montar `<PresenceBar documentId={id} currentUserId={session.user.id} />`.
  2. Passar a identidade derivada no servidor para o cliente (sem expor campos sensíveis).
  3. Garantir que falha de presença não derruba o render do documento (boundary não-bloqueante).
- **rollback:** remover o `<PresenceBar/>` de `app/doc/[id]/page.tsx`; presença é aditiva, não há migration nem mudança de contrato — revert do componente não afeta o resto do editor.
- **acceptance:**
  - [ ] `app/doc/[id]/page.tsx` importa e renderiza `PresenceBar` (grep `PresenceBar`)
  - [ ] `PresenceBar` recebe `documentId` e `currentUserId` (grep ambos os props)
  - [ ] `npm run build` passa
- **must_pass:** `npm run build`

### task-05: verificar copresença ao vivo (2 sessões)

- **type:** `checkpoint:human-verify`
- **what_built:** dev server em `http://localhost:3000/doc/<id>` com `PresenceBar` montado.
- **how_to_verify:**
  1. Abrir o mesmo documento em 2 navegadores autenticados como usuários diferentes → cada um vê o avatar do outro em ≤2s, e NÃO vê o próprio.
  2. Hover num avatar → aparece o nome certo.
  3. Fechar uma aba (X) → o avatar some na outra em ≤15s.
  4. Matar a aba à força (kill do processo, simulando crash) → o avatar fantasma também some em ≤15s (não fica preso).
- **resume_signal:** usuário responde "approved" ou descreve o problema.

---

## Must-Haves (goal-backward verification)

Rodadas no fim por `/dev-coding` (e re-verificadas por `/dev-ship`). Se qualquer uma falhar, geramos fix-tasks.

### Truths (observable behaviors)
- [ ] Dois usuários no mesmo documento veem o avatar um do outro em ≤2s.
- [ ] Fechar/crashar a aba remove o avatar para os outros em ≤15s.
- [ ] Mesmo usuário com 2 abas aparece como 1 avatar.
- [ ] Usuário não vê o próprio avatar na fileira.
- [ ] Falha de Realtime mostra "presença offline" e mantém o editor utilizável.

### Artifacts (arquivos com substância real)
- `lib/realtime/presence.ts` — min 30 linhas, exports: `[createPresenceChannel]` (ou equivalente), referencia `presence:doc:`
- `hooks/use-presence.ts` — min 30 linhas, exports: `[usePresence]`
- `components/presence/PresenceBar.tsx` — trata loading/erro/vazio/+N

### Key Links (conexões críticas)
- `app/doc/[id]/page.tsx` → `PresenceBar` via import/render — regex: `PresenceBar`
- `hooks/use-presence.ts` → `lib/realtime/presence.ts` via import — regex: `from ['\"].*realtime/presence['\"]`
- payload de presença → sem campo sensível — regex (deve NÃO casar): `email`

### Demo Script (a feature em 60 segundos)
1. `npm run dev` e abrir `http://localhost:3000/doc/demo` em 2 navegadores (usuários A e B) — observar: cada um vê 1 avatar (o do outro).
2. Hover no avatar em A — observar: nome de B aparece.
3. Fechar a aba de B — observar: avatar de B some em A dentro de ~15s; A volta à fileira vazia.

> Se não dá pra escrever o demo script, a feature não tem critério de pronto observável — volte aos Goals.

---

## Reset Protocol

Para retomar do zero numa nova sessão:

1. **Read** este arquivo (`.plans/realtime-presence/PLAN.md`) integralmente
2. **Read** `CLAUDE.md` do projeto + qualquer sub-CLAUDE citado em `## Affected Areas`
3. **Read** os `read_first` da próxima task com status `[ ]`
4. Executar via `/dev-coding` a partir da primeira task pendente
5. Marcar `[x]` em `acceptance` à medida que progride; atualizar `## Status Log` no fim

---

## Status Log

Atualizado por `/dev-coding` durante execução.

> Neste exemplo o log já vem preenchido porque é uma feature **já entregue** (`status: done`) — serve de referência de como fica no fim. Num PLAN novo, esta seção começa vazia: o `/dev-coding` a escreve à medida que executa, nunca antes.

- 2026-06-11 14:02 — task-01 ✅ (commit `a1b2c3d`)
- 2026-06-11 14:48 — task-02 ✅ (commit `e4f5a6b`)
- 2026-06-11 15:05 — /clear (contexto resetado; plano carrega o resto)
- 2026-06-11 15:39 — task-03 ✅ (commit `c7d8e9f`)
- 2026-06-11 15:54 — task-04 ✅ (commit `b0c1d2e`)
- 2026-06-11 16:20 — task-05 ✅ human-verify approved (2 sessões: join ~1s, leave ~11s, crash-kill limpou fantasma)
