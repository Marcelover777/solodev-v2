---
project: saas-starter
status: em-andamento
created: 2026-06-16
stack: ./STACK.md
setup: ./SETUP.md
---

# ROADMAP — SaaS starter

> Lista numerada de passos. Escrita pelo `/dev-roadmap`. Você executa um por vez com um verbo só: **"executa o passo 0X"**.
>
> Cada passo tem um checkbox de status e linka o detalhe em `.plans/steps/0X-<slug>.md`. Antes de rodar, o `/dev-next` checa os **gates** (chaves/config). Se faltar algo, ele **para e te dá o link exato** — você resolve e roda de novo.
>
> Granularidade: cada passo é uma fatia demoável (uma feature inteira, ponta a ponta), não micro-tarefa. SaaS de waitlist → login → cobrança em 6 passos.

## O produto em 1 linha

Uma landing page com lista de espera que vira um SaaS com login e assinatura paga. Stack em [`STACK.md`](./STACK.md): Next.js + Supabase + Vercel + Stripe.

## Passos

- [x] **## 01 — Scaffold + landing bonita** → [.plans/steps/01-scaffold.md](./.plans/steps/01-scaffold.md)
  - Projeto Next.js no ar com Tailwind + shadcn e uma landing page estética. _Sem gate._
- [x] **## 02 — Lista de espera (captura de e-mail)** → [.plans/steps/02-waitlist.md](./.plans/steps/02-waitlist.md)
  - Form que grava e-mails numa tabela Supabase. _Gate: chaves Supabase._
- [ ] **## 03 — Login (auth)** → [.plans/steps/03-auth.md](./.plans/steps/03-auth.md)
  - Cadastro/login via Supabase Auth + área logada protegida. _Gate: chaves Supabase (mesmas do passo 02)._
- [ ] **## 04 — Dashboard logado** → [.plans/steps/04-dashboard.md](./.plans/steps/04-dashboard.md)
  - Tela interna que só usuário logado vê, lendo dados dele do banco. _Gate: passo 03 concluído._
- [ ] **## 05 — Cobrança (Stripe Checkout + webhook)** → [.plans/steps/05-billing.md](./.plans/steps/05-billing.md)
  - Assinatura paga via Stripe; webhook marca quem pagou. _Gate: chaves Stripe (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`)._
- [ ] **## 06 — Deploy na Vercel** → [.plans/steps/06-deploy.md](./.plans/steps/06-deploy.md)
  - Site no ar a cada push, com as variáveis de ambiente configuradas na Vercel. _Gate: conta Vercel + repo no GitHub._

## Como executar

```
executa o passo 03        → o /dev-next roda o próximo passo pendente (ou o que você nomear)
                            e, no fim, diz: "próximo: executa o passo 04"
```

- O sistema **só avança um passo por vez** e marca `[x]` aqui quando ele passa.
- Faltou uma chave? O passo **fica bloqueado** com o link de onde pegar — não trava você adivinhando.
- A qualquer hora, `/dev-status` mostra o que está pronto, o que tem erro e a qualidade de cada parte.

## Próximo passo

> *"Passos 01 e 02 prontos. O próximo é o 03 (login). Rode: **executa o passo 03**. Ele usa as mesmas chaves Supabase que o passo 02 já configurou, então não deve bloquear."*
