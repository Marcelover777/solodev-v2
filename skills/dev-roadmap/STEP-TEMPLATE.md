# STEP Template (.plans/steps/0X-<slug>.md)

Um arquivo por passo do `ROADMAP.md`. Escrito pelo `/dev-roadmap`, lido pelo `/dev-next` (que confere o gate e delega ao ciclo). O usuário não precisa abrir para rodar — basta "executa o passo 0X". Existe para o sistema (e para auditoria) saber exatamente o que o passo faz, o que precisa antes, e como saber que ficou pronto.

---

```markdown
---
step: 0X
slug: <slug>
title: <título do passo>
status: pending          # pending | done
roadmap: ../../ROADMAP.md
cycle_skill: /dev-coding  # qual skill do ciclo este passo aciona
depends_on: []           # [] ou ["02"]
---

# Passo 0X — <título>

> Detalhe de um passo do `ROADMAP.md`. Para rodar, basta **"executa o passo 0X"**.

## Objetivo observável

<O que o usuário VÊ ou consegue FAZER depois que este passo passa. Concreto e demoável — não "melhorar o código".>

## Skill do ciclo que isto aciona

`<skill>` — <1 linha do que ela faz aqui>.

## Pré-requisitos (gates)

<Liste os nomes EXATOS das env vars/contas que precisam existir antes (do STACK.md), ou escreva **Nenhum**.
Ex.: `SUPABASE_URL`, `SUPABASE_ANON_KEY` — o /dev-next confronta isto com SETUP.md/.env.local e PARA se faltar.>

## Dependências

<Passos anteriores que precisam estar `[x]`, ou **Nenhuma** (`depends_on: []`).>

## O que o passo faz

1. <subtask concreta>
2. <subtask concreta>
3. <subtask concreta>

## Critério de pronto (verificável)

- [ ] <comando/grep/test que prova que funcionou>
- [ ] <`npm run build` passa / endpoint responde / grep encontra símbolo>

## Demo (até 60s)

1. <comando> — <o que observar>
2. <ação> — <o que deve aparecer>

## Quando terminar

O `/dev-next` marca `[x]` no passo 0X do `ROADMAP.md`, faz append no `.solodev/PROGRESS.md`, atualiza o `.solodev/STATUS.md`, e aponta o próximo passo.
```

---

## Notas

- **Gate com nomes reais.** Só env vars confirmadas no `STACK.md`. Nunca invente nome — o `/dev-next` checa exatamente esses.
- **Critério verificável.** Cada item de "pronto" deve dar pra checar por grep/test/build, não por opinião.
- **`cycle_skill`** diz ao `/dev-next` a quem delegar. Scaffold → `/dev-design`; feature nova → `/dev-plan` + `/dev-coding`; fechar → `/dev-ship`.
