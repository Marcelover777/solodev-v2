---
name: dev-next
description: Executa o próximo passo do ROADMAP.md com um verbo só — resolve o primeiro passo não-marcado com dependência satisfeita (fallback "qual o próximo?") ou um passo nomeado. Roda os gates antes de tudo — se faltar chave/config exigida pelo passo, PARA e dá o link exato para resolver, nunca avança bloqueado. Liberado, delega ao ciclo v2 (dev-coding, dev-plan, dev-ship…) executar o .plans/steps/0X-*.md, marca [x] no ROADMAP.md, faz append no .crucible/PROGRESS.md, atualiza o .crucible/STATUS.md e imprime o próximo passo. Use quando o usuário disser "executa o passo 03", "/dev-next", "qual o próximo passo", "próximo", "continua o roadmap", "manda o próximo", ou pedir para avançar o ROADMAP.md.
---

# /dev-next — Executa o próximo passo (um verbo só)

Esta skill é o motor de execução do `ROADMAP.md`. O usuário aprende **um** comando — "executa o passo 0X" — e o resto acontece: gate, execução, registro, próximo passo. Ela não cria o roadmap (isso é `/dev-roadmap`) nem reescreve o motor de implementação (isso é `/dev-coding`). Ela **resolve qual passo**, **checa se está liberado**, **delega** e **registra**.

## Pré-condições

- Existe `ROADMAP.md` na raiz do projeto. Se não existir, **pare** e sugira `/dev-roadmap` (ou `/dev-start` se for projeto novo).
- Os passos vivem em `.plans/steps/0X-<slug>.md` — linkados pelo `ROADMAP.md`.

## Processo

### 1. Resolva qual passo

Leia o `ROADMAP.md` inteiro. Cada item tem a forma:

```
## 03 — <título>
- [ ] .plans/steps/03-<slug>.md
```

Duas formas de entrada:

| Entrada do usuário | Passo escolhido |
|--------------------|-----------------|
| **Nomeado** — "executa o passo 03" | o passo `03` exato (mesmo que fora de ordem — o usuário mandou) |
| **Fallback** — "/dev-next", "qual o próximo", "próximo" | o **primeiro** passo `- [ ]` cuja dependência (`depends_on`) já está `- [x]` |

Se todos os passos estão `- [x]`: anuncie que o roadmap acabou e sugira `/dev-ship` (se ainda não fechou) ou `/dev-status`. Não invente passo novo.

Se o passo nomeado não existe no `ROADMAP.md`: pare e liste os passos disponíveis. Não adivinhe.

**Como ler `depends_on` (determinístico):** a dependência mora no **frontmatter** do `.plans/steps/0X-<slug>.md`, no campo `depends_on` — uma **lista de IDs de passo** (ex.: `depends_on: ["02"]` ou `depends_on: []`). Um passo é **elegível** no fallback quando **todos** os IDs em `depends_on` estão marcados `- [x]` no `ROADMAP.md`. O seletor é: o primeiro `- [ ]`, em ordem numérica, com `depends_on` 100% satisfeito. Sem `depends_on` (`[]`) → elegível assim que for o primeiro `- [ ]`.

### 2. Carregue o passo

**Read** `.plans/steps/0X-<slug>.md` integralmente. Dele saem:
- **objetivo observável** do passo;
- **qual skill do ciclo** ele aciona (`/dev-brainstorm`, `/dev-plan`, `/dev-coding`, `/dev-ship`, `/dev-design`, `/dev-setup`);
- **pré-requisitos (gates)** — chaves/configs que precisam existir antes;
- **dependências** (`depends_on`).

Se o passo nomeado tem `depends_on` ainda `- [ ]`: avise em 1 linha qual dependência falta e pergunte se quer rodá-la antes. Não force a ordem, mas não esconda o risco.

### 3. Gates primeiro — PARE se faltar config

**Antes de qualquer execução**, confronte os pré-requisitos do passo contra o que está configurado. Fontes de verdade, nesta ordem:
1. `STACK.md` — quais peças o projeto usa (e portanto quais chaves exige).
2. `SETUP.md` — checklist de configuração + onde pegar cada chave.
3. `.env.local` — as chaves de fato presentes em disco (leia só os **nomes** das vars; nunca ecoe valores).

> **Re-cheque o gate a cada invocação.** Releia o `.env.local` toda vez — uma chave que você adicionou desde a última tentativa **destrava** o passo. Não confie em estado de sessão anterior ("já checei isso"): o disco é a fonte da verdade, e ele pode ter mudado.

Para cada chave/config que o passo exige e **não** está presente, junte o item, o nome exato da env var (use só os nomes confirmados na [lista canônica](../_shared/ENV-VARS.md) — `SUPABASE_URL`, `ANTHROPIC_API_KEY`, `STRIPE_SECRET_KEY`, … — **nunca invente nome novo**; serviço fora da lista → use o nome exato da doc oficial) e a URL exata de onde pegar.

Se faltar **qualquer** item, emita este bloco e **PARE** — não execute o passo:

```
❌ Falta configurar antes do passo 0X — <título>:

- SUPABASE_URL e SUPABASE_ANON_KEY → Supabase → Settings → API Keys
- ANTHROPIC_API_KEY → https://console.anthropic.com/settings/keys

Pega as chaves, põe no .env.local (modelo em .env.example), e rode de novo: executa o passo 0X.
```

Regras do gate:
- **Nunca avance um passo bloqueado.** Sem chave → sem execução. Sem exceção silenciosa.
- O `SETUP.md` é a fonte da URL de "onde pegar". Se o `SETUP.md` não cobre a chave, linke a página oficial do serviço — **nunca crave preço ou limite de free-tier** (muda rápido; mande conferir na página oficial).
- Se não há `STACK.md`/`SETUP.md` ainda e o passo claramente precisa de chave, pare e sugira `/dev-setup` antes — não chute o que falta.

### 4. Liberado → delegue ao ciclo

Gate verde. Anuncie em 1 linha: *"passo 0X liberado — vou acionar `/dev-<skill>` para executar."* Então delegue ao ciclo v2 conforme o passo declara:

| O passo pede… | Delegue a |
|---------------|-----------|
| implementar a partir de um plano | `/dev-coding` (executa o `PLAN.md` da feature do passo, task por task) |
| ainda não tem plano, só ideia/escopo | `/dev-plan` (depois `/dev-coding`) |
| afinar a ideia antes de planejar | `/dev-brainstorm` |
| scaffold de estética | `/dev-design` |
| chaves/integrações | `/dev-setup` |
| fechar/verificar a feature do passo | `/dev-ship` |

**Não reimplemente o motor.** O `/dev-coding` já faz guarda de escopo, protocolo de drift, commits atômicos `[task-XX]` e verificação dura. Você só decide qual passo e o aciona.

Se a execução **falhar** (must_pass vermelho, checkpoint reprovado): **não marque `[x]`**. Reporte o que quebrou, faça append do bloqueio no `PROGRESS.md` e sugira `/dev-fix`. Passo só vira `[x]` quando a execução fecha verde de verdade.

### 5. Registre (só após verde)

Em ordem, sem acumular pro fim:

1. **`ROADMAP.md`** — marque o passo `- [x]`.
2. **`.crucible/PROGRESS.md`** — append de um bloco datado (journal append-only, nunca reescreva o histórico). Use o [PROGRESS-TEMPLATE.md](PROGRESS-TEMPLATE.md) como esqueleto do bloco:

```
## YYYY-MM-DD HH:MM — passo 03: <título>
- O que mudou: <1 linha>
- Arquivos: <lista curta>
- Verificação: <must_pass/teste que fechou verde>
- Próximo: executa o passo 04
```

3. **`.crucible/STATUS.md`** — atualize o painel (delegue ao `/dev-status` se preferir o painel completo; no mínimo, reflita o novo % de passos done).

### 6. Aponte o próximo

Termine sempre dizendo, em 1 linha, qual o próximo passo `- [ ]` com dependência satisfeita:

> **próximo: executa o passo 04 — <título>**

Se o próximo já tem gate que vai bloquear (você sabe pelo `SETUP.md`), avise junto: *"o passo 04 vai precisar de `STRIPE_SECRET_KEY` — pode adiantar pegando em https://dashboard.stripe.com/apikeys."* Se acabou o roadmap, diga isso e sugira `/dev-ship`.

## Anti-padrões

- ❌ Avançar um passo com chave/config faltando ("depois ele configura")
- ❌ Cravar preço ou limite de free-tier no bloco de gate (linke a página oficial; mande conferir)
- ❌ Inventar nome de env var fora dos confirmados no `STACK.md`/`SETUP.md`
- ❌ Marcar `- [x]` antes da execução fechar verde
- ❌ Reescrever o motor do `/dev-coding` em vez de delegar
- ❌ Reescrever o `PROGRESS.md` em vez de fazer append (é journal, não estado mutável)
- ❌ Ecoar o valor de uma env var ao checar o `.env.local` (só o nome importa)
- ❌ Adivinhar um passo nomeado que não existe no `ROADMAP.md`
- ❌ Forçar a ordem quando o usuário nomeou um passo — avise a dependência, mas é decisão dele

## Quando cair pra prosa normal (auto-clarity)

- O bloco de gate (`❌ Falta configurar…`) sempre em prosa clara — é instrução de ação que não pode ser mal lida.
- Ação destrutiva no caminho do passo (migration, drop, force push): pare e confirme antes, em prosa.
- Usuário claramente perdido ou repetindo a pergunta: explique o estado do roadmap em frases inteiras antes de seguir.

## Próximo passo

Após registrar o passo:

> *"Passo 0X feito e marcado no ROADMAP.md. **próximo: executa o passo 04.** Quer ver o painel? `/dev-status`."*
