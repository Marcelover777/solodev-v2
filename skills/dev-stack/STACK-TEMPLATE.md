# STACK.md Template (ADR)

Salvar em `STACK.md` na **raiz** do projeto do usuário. É um ADR — registro de decisão de arquitetura: o que foi escolhido, por quê, o que foi descartado, e as env vars que cada peça exige. Lido pelo `/dev-setup` (gera `.env.example`) e pelo `/dev-design` (lê o framework). **Nunca crave preço ou limite de free-tier — só linke a página oficial de pricing.**

---

```markdown
# STACK — <Nome do projeto>

> ADR de infra. Escrito por `/dev-stack` em <YYYY-MM-DD>. Fonte do framework para o `/dev-design` e das env vars para o `/dev-setup`. Free-tiers mudam — os números reais estão nos links de pricing, não aqui.

## Arquétipo

**<(b) Web app full-stack c/ auth+DB>** — <1 linha do porquê: o que o projeto faz que define esse arquétipo>

<!-- um de: (a) site estático/SPA · (b) web app full-stack · (c) API/backend · (d) jobs/cron · (e) app de IA · (f) app realtime -->

## Escolhas (o quê + por quê + onde conferir o free-tier)

| Peça | Escolha | Por quê (1 linha) | Pricing oficial (confira o free-tier) |
|------|---------|-------------------|----------------------------------------|
| Deploy / hosting | <Vercel> | <deploy zero-config> | <link da página de pricing> |
| Banco + Auth + Storage | <Supabase> | <um backend cobre tudo no free> | <link da página de pricing> |
| <Pagamento, IA, jobs… se houver> | <…> | <…> | <link> |

<!-- só as peças que o arquétipo realmente pede. Site estático não lista banco. -->

## Gotchas de free-tier a lembrar

<!-- avisar que a pegadinha EXISTE; o número fica no link de pricing acima -->

- <ex.: Vercel Hobby é não-comercial — vendeu algo, sobe de plano. (confira os termos)>
- <ex.: Supabase free pausa o projeto depois de dias sem uso — acorda no dashboard. (confira o limite atual)>
- <ex.: nenhum — arquétipo sem peça com pegadinha conhecida>

## Alternativas descartadas (e por quê não)

<!-- o coração do ADR: lembrar a decisão daqui a um mês -->

- **<Alternativa 1>** — descartada porque <1 linha>. (quando reconsiderar: <gatilho>)
- **<Alternativa 2>** — descartada porque <1 linha>.

## Env vars que este stack exige

<!-- só nomes confirmados; o /dev-setup transforma isto no .env.example anotado. Fora de Next.js, dropar NEXT_PUBLIC_. -->

| Peça | Env vars | Obrigatória? |
|------|----------|--------------|
| <Supabase> | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` | sim |
| <Anthropic> | `ANTHROPIC_API_KEY` | <sim / só se usar IA> |
| <…> | <…> | <…> |

> Onde pegar cada chave: o `/dev-setup` escreve o checklist com os links exatos no `SETUP.md`. Aqui ficam só os nomes.

## Notas

- <ex.: arquétipo pode evoluir — se ganhar pagamento, adicionar Stripe e rodar `/dev-stack` de novo.>
```

---

## Matriz de decisão (referência embutida — consulta rápida)

> Esta tabela fica no template para o usuário consultar sem reabrir a skill. Defaults enviesados para menor fricção e free-tier real. **Os preços/limites mudam — confira sempre no link oficial, nunca confie num número escrito aqui.**

| Arquétipo | Default recomendado | Por quê (1 linha) | Alternativa |
|-----------|---------------------|-------------------|-------------|
| (a) Site estático / SPA | **Cloudflare Pages** (ou Vercel se Next.js) | grátis de verdade, sem restrição comercial | Netlify |
| (b) Web app full-stack c/ auth+DB *(default do v3)* | **Vercel + Supabase** | um backend cobre tudo no free; deploy zero-config | Vercel + Neon + Clerk |
| (c) API / backend | **Render** (web service + Postgres free) | PaaS fácil com free-tier real + DB gerenciado | Railway (DX melhor, pago — confira) |
| (d) Jobs / cron / workflows longos | **Trigger.dev** | TS-native, free, runs longos sem timeout | Inngest |
| (e) App de IA (chat/RAG) | **Vercel + Anthropic API + Supabase (pgvector)** | AI SDK + Claude; vetor no mesmo Postgres free | Neon (pgvector) + OpenAI |
| (f) App realtime (presença/colab) | **Supabase Realtime** (+ Vercel) | canais/presence no DB free que já se usa | Cloudflare Workers + Durable Objects |

### Gotchas conhecidos (avisar que existem — número no link)

- Vercel Hobby = não-comercial. · Supabase free pausa após dias sem uso. · Render free dorme + Postgres free expira. · PlanetScale e Fly.io sem free tier. · n8n cloud só trial (self-host grátis). · Turso cobra por linhas lidas. · Neon free não pausa o banco (caminho pra fugir do gotcha da Supabase).
```
