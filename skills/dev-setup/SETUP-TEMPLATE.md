# SETUP.md Template

Salvar como `SETUP.md` na **raiz** do projeto (versionado). É o checklist "faça isto agora" do iniciante: por serviço, o que criar, onde pegar a chave, e o que copiar pro `.env.local`. É a fonte que o gate do `/dev-next` aponta quando um passo bloqueia por falta de chave.

---

```markdown
# SETUP — <Nome do projeto>

> Configuração das chaves e integrações. Faça uma seção por vez; cada passo do `ROADMAP.md`
> só precisa das chaves marcadas pra ele. Modelo das variáveis em `.env.example`.

## 0. Antes de tudo

- [ ] Copie o modelo: `cp .env.example .env.local` (Windows: `copy .env.example .env.local`).
- [ ] Confirme que `.env.local` está no `.gitignore` (não pode ir pro git).

## 1. Supabase (banco + auth)  — _necessário a partir do passo 0X_

- [ ] Crie um projeto em https://supabase.com/dashboard
- [ ] Vá em **Project Settings → API**
- [ ] Copie para o `.env.local`:
  - `SUPABASE_URL` ← "Project URL"
  - `SUPABASE_ANON_KEY` ← "anon public"
  - `SUPABASE_SERVICE_ROLE_KEY` ← "service_role" (⚠️ secreta — só no servidor)
- [ ] Pricing/free-tier (confira, muda): https://supabase.com/pricing

## 2. <Serviço> — _necessário a partir do passo 0X_

- [ ] Crie/entre em <link do dashboard>
- [ ] Copie `<ENV_VAR>` de <onde exatamente>
- [ ] Pricing: <link oficial>

## Pronto?

- [ ] Todas as chaves **obrigatórias** preenchidas no `.env.local`.
- [ ] `npm run dev` (ou equivalente) sobe sem erro de "missing env var".

Faltou alguma? O `/dev-next` te avisa exatamente qual quando você for rodar o passo que precisa dela.
```

---

## Regras

- **Um link por chave.** O iniciante não deve adivinhar onde clicar. Link exato do dashboard/página.
- **Diga em que passo cada chave entra** (`necessário a partir do passo 0X`) — assim ele só configura o que o próximo passo exige.
- **Nunca cole valor real aqui** — este arquivo é versionado. Valores só no `.env.local`.
- **Pricing por link, nunca número.** Free-tier muda; cravar valor envelhece.
- **Aviso de segurança** quando a chave for secreta (`service_role`, `secret_key`): diga em prosa que ela só pode viver no servidor.
