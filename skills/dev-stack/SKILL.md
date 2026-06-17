---
name: dev-stack
description: Advisor de infra e conectores — ajuda o iniciante a entender a arquitetura e escolher o stack com recomendação inteligente. Infere ou pergunta o arquétipo (site estático, web app full-stack, API, jobs/cron, app de IA, app realtime), recomenda o default + explica o porquê em 1 linha, oferece 1 alternativa, avisa os gotchas de free-tier e LINKA a página oficial de pricing (nunca crava preço ou limite, que mudam rápido). Escreve STACK.md (um ADR — arquétipo, escolhas, porquê, alternativas descartadas, e as env vars que cada peça exige), que alimenta o /dev-setup e o /dev-design. Use quando o usuário disser "/dev-stack", "que stack uso", "qual banco de dados", "onde faço deploy", "que tecnologia", "qual backend", "preciso de auth", "como hospedo isso", "qual conector", "é grátis?", "quanto custa", ou pedir para escolher a infra/arquitetura do projeto.
---

# /dev-stack — O porquê de cada peça, sem cravar número

> **Doutrina do Crucible — V1 completa, nunca MVP.** Todo projeto mira uma **V1 inteira, poderosa e totalmente funcional** desde o início: implementações reais, todos os estados tratados, tudo que a proposta do produto genuinamente exige. Nada de mock, dado chumbado, meia-feature ou "arrumo depois" como entregável. O escopo é focado (não é o produto dos sonhos infinito), mas **tudo que entra é construído de verdade** — "pronto" é funcional e robusto, não um esqueleto pra mexer depois.

O iniciante trava na infra: banco? auth? onde faz deploy? é grátis? Esta skill responde com **recomendação opinativa + o porquê em 1 linha + 1 alternativa**, avisa as armadilhas de free-tier e **linka a pricing oficial** — nunca decide no escuro nem inventa preço. O resultado vira o `STACK.md` (um ADR), que o `/dev-setup` lê para gerar `.env.example` e o `/dev-design` lê para saber o framework.

Ela **recomenda e registra a decisão**. Não instala nada, não pega chave (isso é `/dev-setup`), não veste a UI (isso é `/dev-design`).

## Princípios não-negociáveis

1. **Recomendar com porquê.** Toda peça vem com 1 linha de "por que esta". Recomendação sem justificativa é palpite — o iniciante não aprende e não confia.
2. **Sempre oferecer alternativa.** Um default + pelo menos 1 caminho diferente. Nunca "só existe um jeito".
3. **Nunca cravar preço ou limite de free-tier.** Os números mudam toda semana. Linke a página oficial de pricing e mande conferir lá. Cravar "500MB grátis" envelhece e vira mentira.
4. **Não empurrar pago quando o free serve.** O default é enviesado para menor fricção e free-tier real para quem está começando. Só sobe pra pago quando o requisito força.
5. **Karpathy.** Recomende o mínimo que o projeto precisa. Não enfie Redis, fila e CDN num CRUD de fim de semana.

## Processo

### 1. Descubra o arquétipo (infira, depois confirme)

O arquétipo decide tudo. Tente **inferir** do que já existe antes de perguntar:

| Sinal | De onde | Sugere |
|-------|---------|--------|
| O que o projeto faz | `BRIEF.md` (Problema + Solução + Goals), `CONTEXT.md`, ou a ideia que o usuário falou | mapeia pro arquétipo a–f |
| Já tem precisa de login? dados por usuário? | BRIEF (seção Produto: Permissões) | full-stack c/ auth+DB vs site estático |
| Tempo real, presença, colaboração? | BRIEF (Goals) | realtime |
| Roda tarefa longa / agendada / em background? | BRIEF (Goals) | jobs/cron |
| Chama LLM / chat / RAG? | BRIEF, ou o usuário menciona IA | app de IA |

Se o BRIEF não fecha o arquétipo, pergunte em **uma** mensagem, com no máximo 2-3 perguntas que separam os caminhos (uma decisão por vez para o leigo):

- *"Tem usuário que faz login, ou é aberto pra todo mundo?"* (separa full-stack de site estático)
- *"Os dados são por pessoa (cada um vê os seus) ou os mesmos pra todos?"* (precisa de DB+auth?)
- *"Precisa de tempo real (atualiza sozinho na tela de todos) ou tarefa que roda sozinha agendada?"* (realtime / jobs)

Na dúvida genuína, o default do v3 é o arquétipo **(b) web app full-stack** — é o caso mais comum do vibe coder. Mas confirme antes de assumir; assumir em silêncio é anti-padrão.

### 2. Recomende o default + porquê + 1 alternativa

Pela linha do arquétipo na **matriz de decisão** (seção abaixo, embutida também no `STACK.md`): diga o **default recomendado**, **por que** (a 1 linha da matriz), e **a alternativa**. Recomendação inline, do jeito v3.

Exemplo de tom (arquétipo b):

> **Recomendo Vercel + Supabase.** Por quê: um backend só (Supabase) cobre banco, login, storage e realtime no plano grátis, e o deploy na Vercel é zero-config. **Alternativa:** Vercel + Neon + Clerk — Neon não pausa o banco depois de 7 dias parado, e o Clerk tem a melhor experiência de login. Confira o free-tier atual de cada um nos links de pricing antes de fechar.

Não recomende mais peças do que o arquétipo pede. Um site estático não precisa de banco; não ofereça um.

### 3. Avise os gotchas de free-tier (sem cravar número)

Para cada peça recomendada, cole o aviso relevante da lista de gotchas (seção abaixo) — mas **sempre como "confira no link"**, nunca com o número. O iniciante precisa saber que *existe* uma pegadinha ("o banco grátis da Supabase pausa se ficar dias sem uso"), não o valor exato (que muda).

### 4. Linke a pricing oficial

Para cada serviço recomendado, dê o link da **página oficial de pricing/free-tier** e mande conferir lá. Esta é a regra dura da fase: **nenhum preço ou limite hardcoded no `STACK.md`** — só links. Se você não tem certeza da URL exata de pricing, linke o domínio oficial do serviço e diga "procure a página Pricing".

### 5. Liste as env vars que cada peça exige

Feche o loop com a Fase 4: para cada peça escolhida, liste os **nomes** das env vars que ela vai exigir (da seção "Env vars por peça" abaixo). Isso é o que o `/dev-setup` consome para gerar o `.env.example` e o que o gate do `/dev-next` checa. Use **só os nomes confirmados** — nunca invente um nome de env var novo. Se uma peça não está na lista, mande o `/dev-setup` confirmar o nome na doc oficial do serviço na hora.

### 6. Escreva o STACK.md

Use [STACK-TEMPLATE.md](STACK-TEMPLATE.md) como esqueleto. Salve `STACK.md` **na raiz** do projeto. Ele é um **ADR** (registro de decisão de arquitetura): o arquétipo, cada escolha com o porquê, as alternativas que foram descartadas (e por quê), os links de pricing, e a lista de env vars por peça. É a fonte que o `/dev-setup` e o `/dev-design` leem — e a memória de "por que escolhemos isso" quando o usuário voltar daqui a um mês.

## Matriz de decisão (por arquétipo) — consulta

Defaults enviesados para menor fricção, free-tier real, menos ops e bom suporte a CLI/Claude Code. **Preços/limites mudam → o STACK.md linka a página oficial, nunca crava número.**

| Arquétipo | Default recomendado | Por quê (1 linha) | Alternativa |
|-----------|---------------------|-------------------|-------------|
| **(a) Site estático / SPA** | **Cloudflare Pages** (ou Vercel se for Next.js) | grátis de verdade, sem restrição comercial | Netlify |
| **(b) Web app full-stack c/ auth+DB** *(caso comum / default do v3)* | **Vercel + Supabase** (DB + Auth + Storage + Realtime num lugar) | um backend cobre tudo no free; deploy zero-config | Vercel + Neon + Clerk (Neon não pausa em 7d; Clerk = melhor UX de auth) |
| **(c) API / backend** | **Render** (web service + Postgres free) | PaaS mais fácil com free-tier real + banco gerenciado | Railway (DX melhor, mas pago — confira o preço) |
| **(d) Jobs / cron / workflows longos** | **Trigger.dev** | TS-native, free, runs longos sem timeout, ótimo p/ Claude Code | Inngest |
| **(e) App de IA (chat/RAG)** | **Vercel + Anthropic API + Supabase (pgvector)** | AI SDK + Claude; o vetor mora no mesmo Postgres free | Neon (pgvector) + OpenAI |
| **(f) App realtime (presença/colab)** | **Supabase Realtime** (+ Vercel) | canais/presence no banco free que o projeto já usa | Cloudflare Workers + Durable Objects |

## Gotchas de free-tier (avisar — sempre "confira no link")

O iniciante precisa saber que a pegadinha **existe**; o número exato fica no link de pricing.

- **Vercel Hobby** é **não-comercial** — vendeu algo, precisa subir de plano. (confira os termos)
- **Supabase free** **pausa o projeto** depois de alguns dias sem atividade — acorda no dashboard. (confira o limite atual)
- **Render free** **dorme** quando ocioso (primeira request demora pra acordar) e o **Postgres free expira** depois de um tempo — confira o prazo atual.
- **PlanetScale** e **Fly.io** **não têm free tier** — confira o preço antes de escolher.
- **n8n cloud** é só **trial**; o self-host é grátis. (confira)
- **Turso** cobra por **linhas lidas** — modelo de preço diferente, confira como conta.
- **Neon free** é o caminho pra fugir do "pausa em 7 dias" da Supabase — mas confira o limite dele também.

> Todos marcados "confira": linke a página oficial. Nunca escreva o número no `STACK.md`.

## Env vars por peça (para o /dev-setup — só nomes confirmados)

Formas portáveis. **Fora de Next.js, dropar o prefixo `NEXT_PUBLIC_`.** Não invente nome novo — se a peça não está aqui, mande o `/dev-setup` confirmar na doc do serviço.

| Peça | Env vars que exige |
|------|--------------------|
| **Supabase** | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` |
| **Clerk** (auth) | `CLERK_SECRET_KEY`, `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` |
| **Stripe** (pagamento) | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` |
| **Anthropic** (IA) | `ANTHROPIC_API_KEY` |
| **OpenAI** (IA) | `OPENAI_API_KEY` |
| **Postgres / Neon** | `DATABASE_URL` (+ `DIRECT_URL` p/ Neon/Prisma) |
| **Upstash Redis** | `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN` |
| **Trigger.dev** (jobs) | `TRIGGER_SECRET_KEY` |
| **MongoDB** | `MONGODB_URI` |
| **Auth.js** (next-auth) | `AUTH_SECRET`, `AUTH_URL` |

## Anti-padrões

- ❌ **Cravar preço ou limite de free-tier** — linke a página oficial; marque "confira". É a regra dura da fase.
- ❌ **Recomendar sem explicar o porquê** — toda peça tem 1 linha de justificativa, senão o iniciante não aprende.
- ❌ **Não oferecer alternativa** — sempre um default + pelo menos 1 caminho diferente.
- ❌ **Empurrar serviço pago** quando há free-tier que serve o iniciante.
- ❌ **Assumir o arquétipo em silêncio** (principalmente Next.js) — infira, mas confirme antes de escrever o `STACK.md`.
- ❌ **Inventar nome de env var / endpoint / serviço** — só os confirmados aqui; o resto, o `/dev-setup` confere na doc na hora.
- ❌ **Superdimensionar** — não enfiar Redis/fila/CDN num projeto que não pediu (Karpathy).
- ❌ **STACK.md sem o porquê das alternativas descartadas** — o ADR existe pra lembrar a decisão; sem o "por que não X" ele não serve.

## Quando cair pra prosa normal (auto-clarity)

- **Explicar conceitos de infra ao leigo** (o que é banco, auth, deploy, free-tier, env var): em frases inteiras antes de recomendar. O iniciante precisa entender o vocabulário antes da decisão.
- **Trade-off real entre dois caminhos** (ex.: "a Supabase é mais fácil, mas pausa o banco; a Neon não pausa, mas você cuida do auth separado"): explique a escolha em prosa, não em fragmento — é uma decisão que ele vai carregar.
- **Quando o caminho default tem um custo escondido** (ex.: Vercel Hobby ser não-comercial e o projeto pretende vender): pare e diga claramente antes de escrever o `STACK.md`.

## Próximo passo

Após escrever o `STACK.md`:

> *"STACK.md salvo na raiz — arquétipo, escolhas com o porquê, alternativas e as env vars que cada peça exige. Próximo: `/dev-design` para vestir a UI (ele lê o framework daqui), e `/dev-setup` para gerar o `.env.example` e o checklist de chaves (ele lê as env vars daqui). Confira o free-tier atual nos links de pricing do STACK.md antes de criar conta."*
