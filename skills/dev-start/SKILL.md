---
name: dev-start
description: Porta de entrada do vibe coder iniciante — da ideia ao projeto estético com ROADMAP.md pronto, aprendendo um verbo só. Espelha a ideia (estilo dev-brainstorm), depois encadeia /dev-stack → /dev-design → /dev-setup → /dev-roadmap mostrando o que está montando em cada etapa, e termina dizendo "Agora é só pedir: executa o passo 01". Uma decisão por vez, sem jargão, nada em silêncio. Use quando o usuário disser "/dev-start", "quero começar um projeto", "tenho uma ideia", "nunca programei", "me ajuda a começar do zero", "como eu começo", "monta meu projeto", "sou iniciante", ou trouxer uma ideia bruta sem nenhum projeto montado ainda.
---

# /dev-start — Da ideia ao ROADMAP.md, um verbo só

Esta skill é o **modo guiado** do Crucible: o caminho feliz para quem nunca programou. O usuário fala a ideia uma vez e sai daqui com **stack escolhido**, **projeto estético scaffoldado**, **chaves mapeadas** e um **`ROADMAP.md` numerado** — tendo aprendido **um** comando: *"executa o passo 01"*.

Ela **não reimplementa** stack, design, setup ou roadmap. Ela **orquestra** as quatro skills que já fazem isso — `/dev-stack`, `/dev-design`, `/dev-setup`, `/dev-roadmap` — em sequência, **mostrando o que está montando** a cada etapa. Usuário avançado pula isso e chama as sub-skills direto.

## Para quem é (e para quem não é)

| Perfil | Caminho |
|--------|---------|
| **Nunca programou / primeiro projeto** | `/dev-start` (você está no lugar certo) |
| **Já tem o projeto montado, quer só a feature** | `/dev-brainstorm` → `/dev-plan` → `/dev-coding` |
| **Já sabe o stack, quer pular a conversa** | chame `/dev-stack`, `/dev-design`, `/dev-setup`, `/dev-roadmap` na ordem que quiser |

## Princípios não-negociáveis

1. **Uma decisão por vez.** Leigo trava com 5 perguntas juntas. Pergunte uma, com recomendação inline, e espere. Nunca despeje um questionário.
2. **Mostra o que está montando.** Antes de cada etapa, diga em 1-2 linhas o que ela vai produzir e por quê. O usuário precisa **ver o que cada parte vai ser**, não receber arquivos surgindo do nada.
3. **Sem jargão sem tradução.** Se escrever "deploy", "API key", "repo", "commit", explique em meia linha na primeira vez. Quem nunca programou está aqui.
4. **Nada em silêncio (Karpathy).** Não assuma stack, não assuma Next.js, não scaffolde sem anunciar. Cada sub-skill é acionada com o usuário sabendo o que vem.
5. **Delega, não duplica.** O conteúdo (matriz de stack, comandos de scaffold, env vars, formato do roadmap) vive nas sub-skills. Aqui só o encadeamento e a tradução para leigo.

## Processo

### 0. Espelhe a ideia (antes de qualquer pergunta)

O usuário fala solto. Antes de tudo, **espelhe o que entendeu em no máximo 3 bullets** (mesmo espelho do `/dev-brainstorm`):

```
Entendi que você quer:
- <o que o app faz, em 1 frase concreta>
- <pra quem é / quando a pessoa usa>
- <a parte que ainda está difusa e vou clarear primeiro>
É isso? Faltou algo importante?
```

Isso pega 80% dos desentendimentos no turn 1. Só siga depois do "é isso".

### 1. Diga o plano de voo (o que vai acontecer)

Em 4 linhas, mostre o caminho — para o usuário saber que são 4 paradas e que ele decide em cada uma:

```
Vou te guiar em 4 passos, um de cada vez:
1. Stack    — escolher as peças do projeto (e te explicar cada uma)
2. Design   — deixar a cara do app bonita desde o começo
3. Setup    — mapear as chaves/contas que o projeto vai precisar
4. Roadmap  — montar a lista numerada de tarefas que você vai executar
No fim, você só vai precisar dizer: "executa o passo 01".
```

Não avance todas de uma vez. Uma etapa, mostra o resultado, confirma, próxima.

### 2. Stack — aciona `/dev-stack`

Anuncie em 1 linha o que esta parada decide: *"Primeiro, as peças do projeto — onde ele vai rodar, onde guarda os dados. Eu recomendo, te explico o porquê, e você escolhe."*

Delegue ao **`/dev-stack`**. Ele infere/pergunta o arquétipo (site, web app, API, jobs, app de IA, realtime), recomenda o default **com o porquê em 1 linha**, oferece 1 alternativa, avisa os gotchas de free-tier e **linka a página oficial de pricing — nunca crava preço nem limite** (muda rápido). Saída: **`STACK.md`** na raiz.

Quando o `/dev-stack` fechar, **mostre o que ficou** em linguagem de leigo (2-3 bullets: "o app vai rodar em X, os dados ficam em Y") e confirme antes de seguir. Não assuma Next.js nem nenhuma peça fora do que o `/dev-stack` decidiu.

### 3. Design — aciona `/dev-design`

Anuncie: *"Agora a aparência — pra não nascer com cara de template genérico."*

Delegue ao **`/dev-design`**. Para o arquétipo web (default), ele recomenda e scaffolda o combo de UI e escolhe um tema, lendo o `BRIEF.md`/ideia para pegar o tom. Saída: **`DESIGN.md`** + os comandos de scaffold (que entram como passo do roadmap). Para arquétipo não-web, ele degrada com elegância (recomenda o equivalente ou pula) — respeite a decisão dele.

> ⚠️ Comandos de scaffold (criar projeto, instalar UI) mudam de versão rápido. O `/dev-design` é a fonte deles — **não crave versão de lib aqui**; se for rodar um comando, confira a versão atual na hora.

Mostre o resultado ("a base visual é X, com tema Y") e confirme.

### 4. Setup — aciona `/dev-setup`

Anuncie, traduzindo o jargão: *"Agora as chaves — são como senhas que ligam seu app aos serviços (banco de dados, pagamento, IA). Vou listar quais você vai precisar e o link exato de onde pegar cada uma. Você não precisa pegar nada agora — só saber o que vem."*

Delegue ao **`/dev-setup`**. Ele lê o `STACK.md`, gera o **`.env.example`** ricamente anotado (por chave: o que é, onde pegar, obrigatória ou opcional) e o **`SETUP.md`** (checklist com os links). Garante que `.gitignore` cobre `.env*` e avisa o caveat: `.gitignore` impede *enviar* o segredo pro GitHub, mas não impede ferramentas de IA *lerem* o arquivo no seu computador.

Mostre quantas chaves o projeto vai pedir e quais são obrigatórias logo no início — sem copiar URL crua aqui (a fonte é o `SETUP.md`). **Não invente nome de env var**; só os que o `/dev-setup` escreveu.

### 5. Roadmap — aciona `/dev-roadmap`

Anuncie: *"Última parada: a lista de tarefas. Cada item é um passo numerado que você executa com um comando só."*

Delegue ao **`/dev-roadmap`**. Ele transforma a ideia + `STACK.md`/`DESIGN.md`/`SETUP.md` num **`ROADMAP.md`** na raiz — lista numerada `## 01 — <título>` com checkbox `- [ ]` e link para `.plans/steps/0X-<slug>.md`. Granularidade de epics/feats, **não 30 micro-tarefas**.

Mostre os primeiros 3-4 passos no chat para o usuário ver o caminho à frente, e avise se algum passo logo no começo tem **gate** (precisa de chave) — assim ele já adianta pegando.

### 6. Registre a partida e entregue o verbo único

O projeto agora tem memória. Faça **append** de um bloco no journal `.crucible/PROGRESS.md` (crie a pasta `.crucible/` se faltar; é journal append-only, nunca reescreva):

```
## YYYY-MM-DD — projeto iniciado via /dev-start
- Ideia: <1 linha>
- Stack: <peças escolhidas> (STACK.md)
- Design: <base visual> (DESIGN.md)
- Setup: <N chaves mapeadas> (SETUP.md / .env.example)
- Roadmap: <N passos> (ROADMAP.md)
- Próximo: executa o passo 01
```

Então **feche com o verbo único** — esta é a frase de saída obrigatória da skill:

> **Tudo montado. Agora é só pedir: executa o passo 01.**
>
> Se travar em algo, peça `/dev-status` — ele te mostra o que está pronto, o que tem erro, e o que falta. Sem pressa: um passo por vez.

## O que cada artefato vira (mostre ao leigo se ele perguntar)

| Arquivo | O que é, em 1 linha |
|---------|---------------------|
| `STACK.md` | as peças do projeto e o porquê de cada uma |
| `DESIGN.md` | a aparência: cores, componentes, convenções |
| `.env.example` / `SETUP.md` | as chaves que o app precisa e onde pegar cada uma |
| `ROADMAP.md` | a lista numerada de passos — seu mapa |
| `.crucible/PROGRESS.md` | o diário do projeto (preenche sozinho conforme você avança) |

## Anti-padrões

- ❌ **Mais de uma decisão por vez** ao leigo (questionário trava quem está começando — uma pergunta, recomendação, espera).
- ❌ **`/dev-start` que faz tudo em silêncio** (requisito do v3: mostrar o que está montando em cada etapa — nada surge do nada).
- ❌ **Jargão sem tradução** ("deploy", "commit", "API key", "repo" — explique meia linha na primeira vez).
- ❌ **Assumir Next.js** ou qualquer stack antes do `/dev-stack` decidir.
- ❌ **Cravar preço/limite de free-tier** — o `/dev-stack` e o `/dev-setup` linkam a página oficial; aqui não se inventa número.
- ❌ **Inventar nome de env var / comando de CLI / versão de lib** — a fonte é a sub-skill; comando volátil (criar projeto, instalar UI) confere na hora.
- ❌ **Reimplementar stack/design/setup/roadmap** aqui em vez de delegar às quatro skills.
- ❌ **Reescrever o `PROGRESS.md`** em vez de fazer append (é journal, não estado mutável).
- ❌ **Pular o espelho da ideia** e sair montando — 10 turns na direção errada.

## Quando cair pra prosa normal (auto-clarity)

- **Sempre** com leigo: o tom inteiro desta skill é prosa clara, não fragmento telegráfico. Ser terse aqui é inimigo da compreensão.
- Ação que cria/sobrescreve arquivo ou roda comando de scaffold: avise em frase inteira o que vai acontecer antes de fazer.
- Usuário confuso ou repetindo a pergunta: pare, explique o estado em frases completas, e só então siga.

## Próximo passo

Ao terminar a orquestração:

> *"Projeto montado: `STACK.md`, `DESIGN.md`, `SETUP.md` e `ROADMAP.md` prontos na raiz. **Agora é só pedir: executa o passo 01.** A qualquer hora, `/dev-status` mostra como está o projeto."*
