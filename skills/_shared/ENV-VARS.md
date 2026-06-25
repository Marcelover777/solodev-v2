# ENV-VARS — lista canônica de variáveis de ambiente

> **Fonte única da verdade dos NOMES de env var** que o Crucible reconhece.
> Não é uma skill (a pasta `_shared/` é ignorada pelo validador). É um catálogo citado por
> `/dev-next` (gate) e `/dev-setup` (geração do `.env.example`/`SETUP.md`).
>
> **Regra de ouro:** use só os nomes desta lista. Serviço fora dela → abra a doc oficial,
> ache a página "API keys"/"Connect" e use o nome **exato** que ela manda. **Nunca invente.**
> Onde pegar cada chave (URLs) vive na tabela do `/dev-setup` — aqui é só o catálogo de nomes.

## Nomes confirmados (por serviço)

| Serviço | Env vars | Público? |
|---------|----------|----------|
| **Supabase** | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` | URL+ANON públicas; SERVICE_ROLE **secreta** |
| **Anthropic** | `ANTHROPIC_API_KEY` | secreta |
| **OpenAI** | `OPENAI_API_KEY` | secreta |
| **Perplexity** | `PERPLEXITY_API_KEY` | secreta |
| **Cohere** | `COHERE_API_KEY` | secreta |
| **Groq** | `GROQ_API_KEY` | secreta |
| **Stripe** | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` | só a `*_PUBLISHABLE_KEY` é pública |
| **Clerk** | `CLERK_SECRET_KEY`, `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` | só a `*_PUBLISHABLE_KEY` é pública |
| **Postgres / Neon** | `DATABASE_URL`, `DIRECT_URL` | secretas |
| **Trigger.dev** | `TRIGGER_SECRET_KEY` | secreta |
| **Upstash Redis** | `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN` | secretas |
| **Auth.js (NextAuth)** | `AUTH_SECRET`, `AUTH_URL` | secretas |
| **MongoDB Atlas** | `MONGODB_URI` | secreta |

## Prefixos "público" por framework

Var com prefixo de framework é embutida no bundle do browser — **não é segredo**, mas o valor real ainda fica só no `.env.local`. Sem prefixo = secreta, só servidor.

| Framework | Prefixo público |
|-----------|-----------------|
| Next.js | `NEXT_PUBLIC_` |
| Vite (React/Vue/Svelte) | `VITE_` |
| Astro / SvelteKit | `PUBLIC_` |
| Expo / React Native | `EXPO_PUBLIC_` |
| Create React App | `REACT_APP_` |

> Fora de Next.js, dropar o `NEXT_PUBLIC_` e usar o prefixo do framework (ou nenhum, se for só servidor).

## Anti-padrões

- ❌ Inventar nome de env var fora desta lista (ou da doc oficial do serviço).
- ❌ Marcar como pública uma var sem prefixo de framework.
- ❌ Cravar preço/limite de free-tier (URLs de pricing vivem no `/dev-stack`/`/dev-setup`).
