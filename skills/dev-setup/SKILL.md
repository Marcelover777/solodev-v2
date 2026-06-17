---
name: dev-setup
description: Configura chaves de API, integrações e variáveis de ambiente sem o iniciante se perder — lê o STACK.md e varre o código pelas env vars em uso, depois gera um .env.example ricamente anotado (o que cada var é, onde pegar a URL, obrigatória vs opcional, placeholder seguro) e um SETUP.md (checklist com o link exato de cada chave). Garante que o .gitignore cobre .env/.env.local e avisa o caveat de segredo em disco. Use quando o usuário disser "/dev-setup", "configurar as chaves", "variáveis de ambiente", "onde ponho a API key", "como pego a chave do Supabase/Stripe/OpenAI", "criar .env", "configurar integrações", "tá pedindo uma key e não sei de onde", ou precisar conectar um serviço externo ao projeto.
---

# /dev-setup — Chaves e integrações sem se perder

O ponto onde o iniciante mais empaca: "o projeto pede uma `SUPABASE_URL` e eu não sei o que é nem de onde tiro". Esta skill resolve isso de forma mastigada: lê o que o projeto usa (`STACK.md` + o código) e gera **dois arquivos** — um `.env.example` anotado (o modelo) e um `SETUP.md` (o checklist com o link exato de cada chave). Depois é copiar pro `.env.local` e preencher.

Ela **não pega a chave por você** (você precisa logar no serviço) e **nunca escreve segredo em arquivo versionado**. Gera o modelo e o passo-a-passo.

## Princípios não-negociáveis

1. **Nunca escrever segredo em arquivo rastreado.** Valores reais vão só pro `.env.local` (que o `.gitignore` ignora). O `.env.example` tem placeholders, nunca a chave de verdade.
2. **Cada var explica onde pegar.** Nome da var sozinho não ajuda o iniciante. Toda var no `SETUP.md` vem com: o que é, link exato de onde tirar, e se é obrigatória ou opcional.
3. **Só nomes de var confirmados.** Use os nomes reais do serviço (do `STACK.md`); nunca invente. Se não souber o nome exato, abra a doc oficial do serviço na hora.
4. **Nunca cravar preço/limite.** Linke a pricing oficial. Free-tier muda; o número envelhece.
5. **Auto-clarity de segurança.** Tudo que envolve segredo é dito em prosa clara, não em fragmento — é a parte onde mal-entendido custa caro.

## Processo

### 1. Descubra quais chaves o projeto precisa

Duas fontes, combinadas:
- **`STACK.md`** (do `/dev-stack`) — diz quais peças o projeto usa e, na seção "env vars por peça", quais vars cada uma exige. É a fonte primária.
- **O código** — varra por uso real: grep por `process.env.`, `import.meta.env.`, `Deno.env.get(` e o `.env.example` se já existir. Pega vars que o `STACK.md` não previu.

Junte as duas listas e remova duplicatas. Se não há `STACK.md` e o código não revela nada, **pare** e sugira `/dev-stack` antes — não chute integrações.

### 2. Classifique cada var

Para cada env var:

| Campo | Como decidir |
|-------|--------------|
| **obrigatória vs opcional** | a app sobe sem ela? Se quebra no boot → obrigatória. Se é feature secundária → opcional. |
| **pública vs secreta** | prefixos `NEXT_PUBLIC_`, `VITE_`, `PUBLIC_` vão pro browser (não são segredo, mas ainda não commitar valor). Sem prefixo = secreta, só servidor. |
| **onde pegar** | o dashboard/página do serviço (tabela de referência abaixo). |
| **placeholder seguro** | um exemplo falso óbvio (`sk_test_xxxxxxxx`), nunca um valor real. |

### 3. Onde pegar cada chave (tabela de referência)

Use os **nomes exatos**. Confira a URL na hora se o serviço mudou o dashboard (acontece). **Nunca crave preço** — siga o link de pricing do `STACK.md`.

| Serviço | Env vars | Onde pegar |
|---------|----------|-----------|
| **Supabase** | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` | dashboard → Project Settings → API (https://supabase.com/dashboard) |
| **Anthropic** | `ANTHROPIC_API_KEY` | https://console.anthropic.com/settings/keys |
| **OpenAI** | `OPENAI_API_KEY` | https://platform.openai.com/api-keys |
| **Stripe** | `STRIPE_SECRET_KEY`, `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` | https://dashboard.stripe.com/apikeys |
| **Stripe (webhook)** | `STRIPE_WEBHOOK_SECRET` | https://dashboard.stripe.com/webhooks (crie o endpoint → "Signing secret") |
| **Clerk** | `CLERK_SECRET_KEY`, `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` | https://dashboard.clerk.com → API Keys |
| **Postgres (Neon)** | `DATABASE_URL`, `DIRECT_URL` | https://console.neon.tech → Connection string |
| **Trigger.dev** | `TRIGGER_SECRET_KEY` | https://cloud.trigger.dev → projeto → API keys |
| **Upstash Redis** | `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN` | https://console.upstash.com → database → REST API |
| **Auth.js (NextAuth)** | `AUTH_SECRET`, `AUTH_URL` | gere o secret com `npx auth secret`; `AUTH_URL` = a URL do app |
| **MongoDB Atlas** | `MONGODB_URI` | https://cloud.mongodb.com → Database → Connect → Drivers |

> Var de serviço que não está aqui: abra a doc oficial do serviço, ache a página "API keys"/"Connect", e use o nome exato que ela manda. Não invente.

### 4. Gere o .env.example (o modelo anotado)

Use [ENV-EXAMPLE-TEMPLATE.md](ENV-EXAMPLE-TEMPLATE.md). Salve `.env.example` na raiz. Agrupe por serviço, e para cada var: um comentário com o que é + onde pegar, marca de obrigatória/opcional, e um placeholder falso. **Este arquivo é versionado** (entra no git) — por isso, zero valor real.

### 5. Gere o SETUP.md (o checklist)

Use [SETUP-TEMPLATE.md](SETUP-TEMPLATE.md). Salve `SETUP.md` na raiz. É a versão "faça isto agora" para o iniciante: um checklist por serviço, com o link de onde pegar e o que copiar pra onde. É a fonte que o gate do `/dev-next` aponta quando um passo bloqueia.

### 6. Garanta o .gitignore (segurança — prosa clara)

Confirme que o `.gitignore` cobre os arquivos de segredo. Se faltar, adicione:

```
.env
.env.local
.env*.local
```

**Aviso importante, em prosa:** o `.gitignore` impede o arquivo de ser **commitado** no git — ele não impede que ferramentas locais (inclusive agentes de IA rodando na sua máquina) **leiam** o `.env.local` do disco. Não cole segredos de produção num projeto de teste, e troque qualquer chave que você suspeite ter vazado. Se um `.env.local` já foi commitado antes, removê-lo do `.gitignore` não basta — a chave já está no histórico; rotacione-a no serviço.

### 7. Diga o que falta agora

Liste em 1 bloco as chaves obrigatórias ainda não preenchidas no `.env.local`, cada uma com o link. Esse é exatamente o formato que o `/dev-next` usa no gate — assim o iniciante já sabe o que resolver antes do próximo passo.

## Anti-padrões

- ❌ **Valor real no `.env.example`** (ou em qualquer arquivo versionado) — só placeholder falso.
- ❌ **Inventar nome de env var** — use o nome exato do serviço (tabela acima / doc oficial).
- ❌ **Cravar preço/limite de free-tier** — linke a pricing; mande conferir.
- ❌ **Ecoar o valor de uma chave** ao checar o `.env.local` — só o nome importa.
- ❌ **Var sem "onde pegar"** no `SETUP.md` — nome sozinho não ajuda o iniciante.
- ❌ **Assumir que `.gitignore` protege segredo em disco** — protege do commit, não da leitura local.
- ❌ **Pedir todas as chaves de uma vez** quando o passo atual só precisa de uma — priorize o que o próximo passo exige.

## Onde ficam os arquivos

- `.env.example` — raiz, **versionado**, modelo anotado (placeholders).
- `.env.local` — raiz, **ignorado pelo git**, onde vão os valores reais (o usuário preenche).
- `SETUP.md` — raiz, **versionado**, o checklist com links.
- Lê: `STACK.md` + o código (grep por env vars).

## Próximo passo

Com os modelos gerados:

> *"`.env.example` e `SETUP.md` prontos. Copie `.env.example` → `.env.local` e preencha as chaves obrigatórias (links no SETUP.md). As que faltam pro próximo passo: <lista>. Depois é só **executa o passo 0X** — o sistema confere as chaves antes de rodar."*
