---
name: dev-design
description: Estética instantânea — o projeto já sai bonito e singular, não cara de bootstrap default. Para o arquétipo web (o padrão do v3) recomenda e scaffolda Tailwind v4 + shadcn/ui + um tema tweakcn (daisyUI como atalho mais rápido; Tremor para dashboards), lendo o BRIEF.md (Goals + Produto) para escolher o tom. Escreve DESIGN.md (tokens, componentes instalados, convenções de nome) e emite os comandos de scaffold (npx create-next-app, npx shadcn init/add, tema via registry) como um passo do roadmap. Para arquétipos não-web degrada com elegância. Avisa para conferir a versão das libs na hora (mudam rápido). Use quando o usuário disser "/dev-design", "deixa bonito", "cuida do design", "estética", "UI", "tema", "instala o shadcn", "escolhe as cores", "não quero cara de template", ou pedir para scaffoldar a aparência do projeto.
---

# /dev-design — Bonito de saída, não cara de template

O diferencial do v3 é o projeto já nascer com aparência **desenhada**, não com o cinza-genérico de bootstrap. Esta skill recomenda e **scaffolda** a camada visual e escreve `DESIGN.md` (a fonte de verdade de tokens, componentes e convenções). Ela não inventa um framework do nada: o stack vem do `/dev-stack`. Ela veste o que o stack escolheu.

## Pré-condições

- Idealmente já existe `STACK.md` (do `/dev-stack`) dizendo o arquétipo e o framework. Se existir, **leia primeiro** e siga o que ele decidiu — não re-escolha o framework aqui.
- Se **não** existe `STACK.md` e o arquétipo não está claro, **pare** e sugira `/dev-stack` antes. Não assuma Next.js em silêncio — é o anti-padrão nº 1 da fase.
- `BRIEF.md` (de `/dev-brainstorm`, em `.plans/<feature>/BRIEF.md` ou na raiz) alimenta o **tom**. Sem BRIEF, faça 2-3 perguntas curtas de tom antes de escolher tema.

## Processo

### 1. Leia o stack e o tom

Na ordem, pulando o que faltar:

| Sinal | De onde | Para quê |
|-------|---------|----------|
| Arquétipo + framework | `STACK.md` | decide se é caminho web ou degradação |
| Tom / público / vibe | `BRIEF.md` (Goals + seção Produto) | escolhe o tema (sério/lúdico, denso/arejado, claro/escuro) |
| O que já existe | `package.json`, `app/` ou `src/`, `tailwind.config.*` | não reinstalar o que já está; detectar Tailwind v3 vs v4 |

Se o `BRIEF.md` não dá tom, pergunte em **uma** mensagem: público (consumidor/profissional/interno), sensação (séria/divertida/minimalista) e claro vs escuro. Uma decisão por vez para o leigo — não despeje 8 opções.

### 2. Decida o caminho pelo arquétipo

| Arquétipo (do `/dev-stack`) | Caminho de design |
|-----------------------------|-------------------|
| **Web app full-stack / SPA / site** (default do v3) | **caminho web** ↓ — Tailwind v4 + shadcn/ui + tema tweakcn |
| API / backend puro | degrade ↓ — sem UI; só convenções de doc/README; pule o scaffold |
| Jobs / cron / workflows | degrade ↓ — se tem um painelzinho, trate como web mínimo; senão pule |
| App de IA (chat/RAG) com front | caminho web ↓ + nota de componentes de chat (stream, markdown) |
| App realtime com front | caminho web ↓ + nota de estados de presença/loading |

### 3. Caminho web — recomende o combo (com o porquê)

Recomendação inline, padrão do v3: **diga o que e por que em 1 linha**, ofereça o atalho, e deixe o usuário trocar.

| Peça | Recomendação | Por quê (1 linha) | Atalho / alternativa |
|------|--------------|-------------------|----------------------|
| **Utilitário CSS** | **Tailwind v4** | classes utilitárias = mexer no visual sem sair do componente; v4 é zero-config | — |
| **Biblioteca de componentes** | **shadcn/ui** | componentes que você **copia pro seu código** (são seus, dá pra editar), não um pacote fechado | **daisyUI** como atalho mais rápido se o usuário quer velocidade > controle |
| **Tema (cores/raio/fonte)** | **um tema tweakcn** | é o que faz "parecer desenhado" em vez de preto-e-branco default | tema custom depois |
| **Dashboards / gráficos** | **Tremor** (só se tem dashboard) | componentes de KPI/gráfico prontos sobre Tailwind | recharts cru |

> **shadcn/ui não é uma dependência fechada.** Os componentes são **copiados para dentro do seu projeto** (`components/ui/`). Isso é a feature, não um bug: o usuário (e você) pode editar qualquer um. Explique isso ao leigo em 1 linha — senão ele acha que "sumiu" do `node_modules`.

### 4. Escolha o tema pelo tom

Mapeie o tom do `BRIEF.md` para um tema tweakcn concreto (a galeria fica em **https://tweakcn.com** — abra e escolha; a lista de temas muda, então não crave nome de tema que pode não existir mais):

| Tom do BRIEF | Direção de tema |
|--------------|-----------------|
| Profissional / SaaS sério | neutro frio, raio pequeno, contraste alto |
| Consumidor / divertido | cor de marca saturada, raio maior, sombras suaves |
| Minimalista / conteúdo | quase-mono, muita respiração, 1 cor de destaque |
| Dark-first (dev tool, IA) | base escura, accent vivo, foco em legibilidade de código |

O tema vira um comando de registry (passo 6). Registre a escolha e o porquê no `DESIGN.md`.

### 5. Degrade com elegância (não-web)

Se o arquétipo não tem front (API/jobs sem painel): **não scaffolde UI**. Escreva um `DESIGN.md` curto que diga só: "sem camada visual neste arquétipo", as convenções de saída que importam (formato de log, README, mensagens de CLI), e quando isso muda ("se um dia ganhar um painel, rode `/dev-design` de novo"). Honesto > teatro de design.

### 6. Emita os comandos de scaffold (copy-ready) como um passo

Monte o bloco de comandos para o framework real do `STACK.md`. Para Next.js + shadcn (o caso default), nesta ordem:

```bash
# 1. projeto Next.js (Tailwind já incluso) — só se ainda não existe
npx create-next-app@latest

# 2. inicializa shadcn/ui no projeto
npx shadcn@latest init

# 3. instala os componentes que o projeto vai usar (escolha pelo BRIEF)
npx shadcn@latest add button card input dialog

# 4. aplica um tema tweakcn (pegue o comando de registry no site do tema)
#    https://tweakcn.com → escolha o tema → copie o comando "npx shadcn add <url-do-registry>"

# 5. (só se tem dashboard) Tremor
npm i @tremor/react
```

> **Confira a versão na hora.** `create-next-app`, `shadcn` e o nome dos componentes/flags mudam de versão pra versão. Não decore flags antigas: rode com `@latest` e, se um comando reclamar, abra a doc oficial do shadcn (https://ui.shadcn.com) e do Next.js antes de insistir. Esses comandos são **voláteis** por natureza.

Dois jeitos de entregar:
- **Dentro do roadmap (preferido):** escreva esses comandos num passo `.plans/steps/0X-design-scaffold.md` e deixe o `/dev-next` executar com "executa o passo 0X". Assim o scaffold entra no fluxo numerado, não solto.
- **Inline (projeto sem roadmap ainda):** mostre o bloco e ofereça rodar agora, comando por comando, confirmando cada um.

### 7. Escreva o DESIGN.md

Use [DESIGN-TEMPLATE.md](DESIGN-TEMPLATE.md) como esqueleto. Salve `DESIGN.md` **na raiz** do projeto. Ele registra: arquétipo, stack visual escolhido + porquê, o tema (nome/origem) e os tokens (cores, raio, fonte, espaçamento), a lista de componentes instalados, e as **convenções** (onde vivem os componentes, como nomear, o que reusar antes de criar). É a fonte que o `/dev-coding` consulta para não inventar um botão novo quando já existe um.

## Anti-padrões

- ❌ **Assumir Next.js** (ou qualquer framework) sem passar pelo `/dev-stack` — re-escolher framework aqui é fora de escopo.
- ❌ **Cravar versão de lib** que muda rápido (`shadcn`, `create-next-app`, Tailwind) — use `@latest` e mande conferir na doc oficial na hora.
- ❌ **Tema default genérico** — preto-e-branco de bootstrap é exatamente o que esta skill existe para evitar; aplicar um tema tweakcn é o diferencial.
- ❌ **Despejar 8 decisões de UI no leigo** de uma vez — uma pergunta de tom por vez.
- ❌ **Scaffoldar UI num arquétipo sem front** (API/jobs) — degrade, não invente painel.
- ❌ **Criar componente do zero** quando o `DESIGN.md` já lista um equivalente — reuso antes de criação.
- ❌ **DESIGN.md de prosa vazia** — sem tokens concretos e sem a lista de componentes, ele não serve ao `/dev-coding`.
- ❌ **Cravar preço/limite** de qualquer ferramenta de design — linke a página oficial.

## Quando cair pra prosa normal (auto-clarity)

- A explicação de que **shadcn copia componentes pro seu código** (não é dependência some-do-node_modules): em frase clara, senão o leigo se perde.
- Antes de rodar `create-next-app` numa pasta que **já tem arquivos**: avise que pode sobrescrever e confirme — é ação que mexe no disco.
- Usuário confuso sobre o que é tema/token/componente: explique em frases inteiras antes de seguir.

## Próximo passo

Após escrever o `DESIGN.md` e montar o scaffold:

> *"DESIGN.md salvo na raiz — tokens, tema e componentes registrados. O scaffold virou o passo 0X do ROADMAP.md: **executa o passo 0X** para instalar Tailwind + shadcn + tema. Lembra de conferir a versão dos comandos na hora (mudam rápido). Quer o painel do projeto? `/dev-status`."*
