---
project: saas-starter
generated_by: /dev-status
generated_at: 2026-06-16 16:40
roadmap: ../ROADMAP.md
---

# STATUS — SaaS starter

> Painel de estado. Vive em `.crucible/STATUS.md`, escrito pelo `/dev-status` — **derivado de arquivos reais** (`ROADMAP.md`, `git status`, resultado dos testes), nunca de número inventado. Rode `/dev-status` a qualquer hora pra atualizar.

## Progresso

**2 de 6 passos prontos — 33%.**

```
[██████░░░░░░░░░░░░░░] 33%
01 ✅  02 ✅  03 ⬜  04 ⬜  05 ⬜  06 ⬜
```

## Qualidade por parte

| Parte | Build | Test | Lint | Segurança |
|-------|:-----:|:----:|:----:|:---------:|
| Landing (passo 01) | ✅ | ✅ | ✅ | ✅ |
| Lista de espera (passo 02) | ✅ | ✅ | ⚠️ | ✅ |
| Login (passo 03) | — | — | — | — |
| Dashboard (passo 04) | — | — | — | — |
| Cobrança (passo 05) | — | — | — | — |
| Deploy (passo 06) | — | — | — | — |

Legenda: ✅ verde · ⚠️ passa com aviso · ❌ quebrado · — ainda não feito.

## Onde estão os erros / avisos

- ⚠️ **Lint no passo 02:** `app/api/waitlist/route.ts` tem um import não usado (`headers`). Não quebra o build; limpar quando passar por ali. Não é blocker.
- Nenhum ❌ no momento — nada quebrado.

## Blockers / gates abertos

- **Passo 05 (cobrança)** vai bloquear até as chaves Stripe entrarem no `.env.local`: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`. Onde pegar: Stripe Dashboard → Developers → API keys ([instruções no `SETUP.md`](../SETUP.md)).
- **Passo 06 (deploy)** precisa de conta Vercel + o repo no GitHub. Sem isso, o `/dev-next` para e te dá o link.
- Passos 03 e 04 **não** têm gate novo — usam as chaves Supabase que o passo 02 já configurou.

## Próximo passo

> *"Você está no passo 03 (login). Não há gate novo — as chaves Supabase do passo 02 servem. Rode: **executa o passo 03**. Quando chegar no passo 05, separe ~5 min pra pegar as chaves Stripe (link acima) antes — senão o sistema vai parar ali."*

## Modo jornada (resumo do `PROGRESS.md`)

> Resumo narrativo do que já rolou — lido do `.crucible/PROGRESS.md`. Sem números de token (não há DB; é tudo arquivo).

Você saiu de um diretório vazio e, em duas sessões, já tem um SaaS com **landing bonita no ar** e **lista de espera capturando e-mails de verdade** no Supabase. As fundações (UI + banco) estão de pé e verdes. Falta a parte que transforma visitante em usuário (login → dashboard) e usuário em cliente (cobrança), e aí é só publicar. Mais da metade do caminho até o no-ar. Próximo verbo: **executa o passo 03**.
