# .env.example Template

Salvar como `.env.example` na **raiz** do projeto. Este arquivo **é versionado** (entra no git) — serve de modelo. Por isso: **só placeholders falsos, nunca valor real.** O usuário copia para `.env.local` (ignorado pelo git) e preenche.

Agrupe por serviço. Cada var leva um comentário com (1) o que é, (2) onde pegar, (3) obrigatória/opcional. Inclua só os serviços que o `STACK.md` escolheu.

---

```bash
# ──────────────────────────────────────────────────────────────
# <Nome do projeto> — variáveis de ambiente
# Copie este arquivo para .env.local e preencha. NUNCA commite o .env.local.
# Passo a passo de onde tirar cada chave: ver SETUP.md
# ──────────────────────────────────────────────────────────────

# ── Supabase (banco + auth + storage) ── OBRIGATÓRIO
# Onde: dashboard → Project Settings → API (https://supabase.com/dashboard)
SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJxxxxxxxx.public.placeholder        # pública (vai pro browser)
SUPABASE_SERVICE_ROLE_KEY=eyJxxxxxxxx.secret.placeholder # SECRETA — só servidor, nunca no client

# ── Anthropic (LLM) ── OBRIGATÓRIO se usa IA
# Onde: https://console.anthropic.com/settings/keys
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxx

# ── Stripe (cobrança) ── OBRIGATÓRIO se cobra
# Onde: https://dashboard.stripe.com/apikeys  (webhook em /webhooks)
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxx
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxx  # pública
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxx

# ── (opcional) outros serviços do STACK.md ──
# DATABASE_URL=postgresql://user:pass@host/db
# OPENAI_API_KEY=sk-xxxxxxxx
# TRIGGER_SECRET_KEY=tr_dev_xxxxxxxx
```

---

## Regras

- **Só placeholder.** `sk_test_xxxx`, `https://xxxx...`, nunca um valor real. O arquivo é público no repo.
- **Marque público vs secreto.** Vars com prefixo `NEXT_PUBLIC_`/`VITE_`/`PUBLIC_` vão pro browser — não são segredo, mas o valor real ainda fica só no `.env.local`.
- **Comentário com link.** Cada bloco diz onde pegar. O detalhe passo-a-passo fica no `SETUP.md`.
- **Só o que o `STACK.md` escolheu.** Não liste serviço que o projeto não usa.
