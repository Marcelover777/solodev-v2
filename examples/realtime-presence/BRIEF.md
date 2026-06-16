---
feature: realtime-presence
size: M
status: ready-for-plan
created: 2026-06-10
last_updated: 2026-06-11
---

# BRIEF — Presença em tempo real (quem está online)

## Problema

Numa app colaborativa de documentos, dois usuários editam a mesma página sem saber que o outro está ali. Pisam um no trabalho do outro, mandam mensagem perguntando "você está vendo isso?" e descobrem tarde demais que estavam no mesmo lugar. Falta o sinal mais básico de colaboração: *quem está aqui agora*. O usuário não pede um chat — pede saber que não está sozinho na sala.

## Solução (high-level)

Na barra superior do documento aparece uma fileira de avatares de quem está com aquele documento aberto neste momento. Entrou alguém, o avatar surge; fechou a aba, some em segundos. Sem recarregar a página.

## Goals (comportamentos observáveis)

- Abrir o documento mostra avatares de todos os outros usuários com o mesmo documento aberto, dentro de ~2s.
- Fechar a aba (ou perder conexão) remove meu avatar para os outros em até ~15s.
- A contagem e a ordem dos avatares são iguais para todos os participantes da mesma sala (estado convergente).
- Passar o mouse num avatar mostra o nome do usuário.

## Non-Goals (out of scope agora)

- Cursores ao vivo / posição de seleção de cada um no documento (presença é "quem", não "onde").
- Indicador de "está digitando".
- Histórico de presença ("esteve aqui há 5 min") — só o agora.
- Presença cross-documento ("Fulano está online no app") — escopo é por documento.
- Avatares de usuários anônimos / não autenticados.

## Constraints

- **Stack:** Next.js (App Router, React Server + Client Components) + Supabase. Presença via Supabase Realtime Presence (canal por documento). Auth já existe via Supabase Auth.
- **Performance:** join/leave refletido em ≤2s para join e ≤15s para leave; sala-alvo até ~25 participantes simultâneos sem degradar.
- **Compliance:** só expõe `user_id`, display name e avatar_url de usuários autenticados — nada de e-mail ou dado sensível no payload de presença. RLS do documento já controla quem entra na sala.
- **Prazo:** 1 sessão (feature M).

## Produto (UI / usuário final)

- **Estado vazio:** só eu no documento → nenhum avatar de terceiro; não mostrar meu próprio avatar na fileira (eu sei que estou aqui). Fileira simplesmente não aparece.
- **Estado de erro:** canal de Realtime não conecta (rede/token) → fileira mostra um indicador discreto "presença offline" em cinza, sem quebrar a edição do documento. Presença é enhancement, não bloqueia o core.
- **Loading:** entre montar o componente e o primeiro `sync` do canal (~1-2s) → skeleton de 1 avatar fantasma (pulse), não tela em branco nem layout shift.
- **Permissões:** quem não tem acesso ao documento (RLS nega) nem carrega a página, logo não entra no canal. Não há caminho para ver presença de um documento que você não pode abrir.

## Glossário (termos do domínio)

- **presence (presença):** conjunto vivo de quem está com um documento aberto agora. Estado efêmero, não persiste em tabela.
- **sala (room / channel):** canal de Realtime escopado a um documento — `presence:doc:<documentId>`. Quem entra na sala publica seu estado.
- **presence state:** o payload que cada cliente publica via `track()` — `{ user_id, name, avatar_url, online_at }`. Sem campos sensíveis.
- **heartbeat:** sinal periódico que mantém a presença viva. No Supabase Realtime é implícito pela conexão WebSocket aberta; se cai, o servidor expira a presença daquele cliente.
- **stale (fantasma):** presença que ficou registrada mas o dono não está mais lá (aba crashou sem leave limpo). Resolve via expiração de heartbeat do lado do servidor.
- **sync / join / leave:** eventos do canal de presence. `sync` = estado completo da sala; `join` = alguém entrou; `leave` = alguém saiu.

> Se o projeto ganhar um CONTEXT.md, mover este glossário pra lá e só citar aqui.

## Decisões tomadas no grilling

- **Um canal por documento (`presence:doc:<id>`)** — isola o estado por sala, evita vazar presença entre documentos e mantém o payload pequeno.
- **Identidade vem do servidor, não do cliente** — o `user_id`/name/avatar do `track()` é montado a partir da sessão Supabase no servidor (ou validado), não confiando em valor que o cliente possa forjar.
- **Não renderizar o próprio avatar na fileira** — reduz ruído visual; o "você" é implícito.
- **Leave depende de expiração de heartbeat, não só de evento `leave`** — aba que crasha não dispara leave limpo; confiamos no timeout do servidor para sumir o fantasma.
- **Presença é não-bloqueante** — falha de Realtime degrada para "presença offline", nunca impede editar o documento.
- **Dedupe por `user_id`** — mesmo usuário com 2 abas conta como 1 avatar (set por user_id, não por conexão).

## Open Questions (precisam de resposta antes do plano)

- **Q1:** Limite visual de avatares antes do "+N"? — *proposed:* mostrar até 5 avatares, excedente vira badge "+N". Decidir no PLAN se entra agora ou vira follow-up.
- **Q2:** Qual o timeout exato de expiração de presença do lado do Supabase para o nosso projeto? — *needs:* discovery (config do Realtime) — afeta o SLA de "≤15s para leave".

## Edge cases descobertos

- Mesmo usuário com 2 abas abertas → 1 avatar só (dedupe por `user_id`).
- Aba crasha / mata processo sem `leave` → avatar fantasma some quando o heartbeat expira (não fica preso para sempre).
- Reconexão após queda de rede → cliente re-emite `track()` no `sync`; não duplica avatar.
- Sala com só você → fileira vazia, sem erro.
- Documento com 25+ pessoas → não pode estourar layout nem render (ligado à Q1).

## Risk Radar (top-3 "isso vai te morder")

1. **Conexões fantasma após crash de aba** — presença fica "presa" mostrando gente que já saiu. Mitigação: não depender só do evento `leave`; confiar na expiração de heartbeat do servidor e validar o timeout real no discovery (Q2). Testar matando a aba à força, não fechando educadamente.
2. **Custo / volume de broadcast em salas grandes** — cada join/leave propaga para todos; sala movimentada pode gerar mensagens demais. Mitigação: escopar canal por documento (já decidido), renderizar a partir do estado de `sync` (não acumular eventos), e tratar 25 participantes como teto desta iteração (acima disso é nova feature).
3. **Race de join/leave fora de ordem** — eventos chegando trocados deixam a fileira inconsistente entre clientes. Mitigação: derivar a UI sempre do `presenceState()` completo (fonte da verdade convergente), nunca de um acumulado manual de join/leave; dedupe por `user_id`.
