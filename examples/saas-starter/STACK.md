---
project: saas-starter
archetype: web app full-stack (auth + DB)
status: decidido
created: 2026-06-16
brief: ./.plans/BRIEF.md
---

# STACK — SaaS starter (lista de espera + login + cobrança)

> ADR do projeto. Escrito pelo `/dev-stack`. Diz **o que** foi escolhido, **por quê**, **o que foi descartado** e **quais chaves cada peça exige** (alimenta o `/dev-setup`).
>
> Preços e free-tiers mudam rápido — este arquivo **linka a pricing oficial, nunca crava número**. Confira sempre a página antes de decidir (muda rápido).

## Arquétipo

**Web app full-stack com auth + banco de dados** (caso comum). É um SaaS: tem tela de marketing, login, área logada e cobrança. Precisa guardar usuários e dados no servidor.

Não é site estático (tem login/DB), não é só API (tem UI), não é app de jobs (sem workflow longo). Se um dia entrar IA, é aditivo — não muda o arquétipo.

## Escolhas

| Peça | Escolhido | Por quê (1 linha) | Onde pegar a chave / docs |
|------|-----------|-------------------|---------------------------|
| Framework / UI | **Next.js (App Router) + React + TypeScript** | um só projeto cobre marketing, área logada e rotas de API — sem servidor separado | [nextjs.org/docs](https://nextjs.org/docs) |
| Estilo / componentes | **Tailwind v4 + shadcn/ui** | UI já parece desenhada, não cara de bootstrap default (detalhe no `/dev-design`) | [ui.shadcn.com](https://ui.shadcn.com) |
| Backend (DB + Auth + Storage) | **Supabase** | um backend cobre banco, login e arquivos no mesmo free-tier; menos peças pra um iniciante errar | [supabase.com/pricing](https://supabase.com/pricing) · chaves: Project → Settings → API |
| Hospedagem / deploy | **Vercel** | deploy zero-config a partir do GitHub; feito pelo mesmo time do Next.js | [vercel.com/pricing](https://vercel.com/pricing) |
| Cobrança | **Stripe** | padrão de fato pra assinatura/checkout; melhor doc pra iniciante | [stripe.com/pricing](https://stripe.com/pricing) · chaves: Dashboard → Developers → API keys |

## Por que esse combo (e não outro)

- **Um backend só.** Supabase já traz banco + login + arquivos. Juntar Auth de um lugar, DB de outro e storage de um terceiro é onde o iniciante trava. Uma peça, uma conta, um conjunto de chaves.
- **Deploy sem dor.** Vercel conecta no repo do GitHub e publica a cada push. Sem servidor pra configurar, sem Docker.
- **Estética de graça.** shadcn/ui + Tailwind v4 entrega tela bonita sem designer (ver `DESIGN.md`).
- **Free-tier real pra começar.** Dá pra ir da ideia ao no-ar sem cartão — confira os limites atuais nos links de pricing acima (**muda rápido**).

## Alternativa considerada

- **Vercel + Neon + Clerk** (em vez de Supabase). Trocaria o backend único por DB (Neon) + auth dedicado (Clerk). Vantagens reais: Neon **não pausa** o banco depois de dias parado, e Clerk tem a **melhor UX de login** pronta. Descartado **para este projeto** por ser mais peças/contas/chaves pra um primeiro SaaS — Supabase concentra tudo. Se a pausa do Supabase virar dor (ver gotchas) ou o login precisar de social/MFA refinado, migrar pra esse combo é o caminho.

## Gotchas de free-tier (avise o usuário)

> Limites e valores mudam — **confira a pricing oficial linkada acima antes de confiar em qualquer número.** As notas abaixo são o *tipo* de pegadinha, não o número exato.

- **Supabase free pausa o projeto após alguns dias sem atividade.** Volta sozinho ao acessar, mas o primeiro request demora. Pra um SaaS com tráfego real, planeje sair do free — confira a janela atual na [pricing do Supabase](https://supabase.com/pricing).
- **Vercel Hobby é não-comercial.** Protótipo e portfólio, ok. Cobrar cliente nele fere o termo de uso — confira o plano em [vercel.com/pricing](https://vercel.com/pricing) antes de faturar.
- **Stripe não tem mensalidade, mas cobra por transação.** Em modo teste é grátis; produção tem taxa por venda — confira em [stripe.com/pricing](https://stripe.com/pricing).
- Não cravar nenhum desses números aqui: se mudou, o `/dev-status` não tem como saber. **Link > número.**

## Chaves que cada peça exige (entra no `.env.example` via `/dev-setup`)

| Peça | Env vars | Obrigatório |
|------|----------|-------------|
| Supabase | `SUPABASE_URL`, `SUPABASE_ANON_KEY` | sim |
| Supabase (server) | `SUPABASE_SERVICE_ROLE_KEY` | sim — só no servidor, nunca no cliente |
| Stripe | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` | sim (a partir do passo de cobrança) |
| Anthropic (futuro, se entrar IA) | `ANTHROPIC_API_KEY` | opcional |

## Próximo passo

> *"Stack decidido em `STACK.md`. Agora rode `/dev-setup` pra gerar o `.env.example` anotado + `SETUP.md` com o passo-a-passo de onde pegar cada chave. Depois `/dev-design` deixa o projeto bonito, e `/dev-roadmap` monta a lista numerada de passos. Ou, se está começando do zero, deixe o `/dev-start` encadear tudo isso pra você."*
