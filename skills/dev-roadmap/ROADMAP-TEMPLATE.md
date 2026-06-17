# ROADMAP.md Template

Salvar em `ROADMAP.md` na **raiz** do projeto do usuário. É o índice numerado de passos. Escrito pelo `/dev-roadmap`, executado pelo `/dev-next` ("executa o passo 0X"), lido pelo `/dev-status` (fonte do progresso). Os checkboxes (`- [ ]` / `- [x]`) são a verdade do progresso — só o `/dev-next` marca `[x]`, e só após o passo fechar verde.

---

```markdown
---
project: <kebab-case-slug>
status: em-andamento        # em-andamento | concluido
created: YYYY-MM-DD
stack: ./STACK.md           # se aplicável
setup: ./SETUP.md           # se aplicável
---

# ROADMAP — <Nome do projeto>

> Lista numerada de passos. Você executa um por vez com um verbo só: **"executa o passo 0X"**.
> Cada passo tem um checkbox e linka o detalhe em `.plans/steps/0X-<slug>.md`. Antes de rodar, o `/dev-next`
> checa os **gates** (chaves/config). Faltou algo? Ele para e te dá o link exato — você resolve e roda de novo.

## O produto em 1 linha

<O que é, e qual a V1 completa e funcional que este roadmap entrega (não um MVP — implementações reais, sem mocks). Stack em STACK.md.>

## Passos

- [ ] **## 01 — <título do passo>** → [.plans/steps/01-<slug>.md](./.plans/steps/01-<slug>.md)
  - <1 linha do objetivo observável>. _Sem gate._
- [ ] **## 02 — <título>** → [.plans/steps/02-<slug>.md](./.plans/steps/02-<slug>.md)
  - <1 linha>. _Gate: <o que falta — ex.: chaves Supabase>._
- [ ] **## 03 — <título>** → [.plans/steps/03-<slug>.md](./.plans/steps/03-<slug>.md)
  - <1 linha>. _Gate: <…> · depende do passo 02._

## Como executar

```
executa o passo 01    → o /dev-next roda o próximo passo pendente (ou o que você nomear)
                        e, no fim, diz: "próximo: executa o passo 02"
```

- O sistema **avança um passo por vez** e marca `[x]` aqui quando ele passa.
- Faltou uma chave? O passo **fica bloqueado** com o link de onde pegar — não trava você adivinhando.
- A qualquer hora, `/dev-status` mostra o que está pronto, o que tem erro e a qualidade de cada parte.

## Próximo passo

> *"<estado atual: quais passos prontos>. O próximo é o <0X> (<título>). Rode: **executa o passo 0X**.
> <aviso de gate, se houver>."*
```

---

## Notas para quem escreve o ROADMAP

- **Numeração estável.** Não renumere passos já criados — quebra o "executa o passo 0X". Insira no fim ou use sufixo (`03b`).
- **Primeiro passo sem gate.** Comece por algo visível (scaffold + landing via `/dev-design`), sem precisar de chave.
- **1 linha por passo no índice.** O detalhe (objetivo, gate, demo, critério de pronto) vive no `steps/0X-*.md`, não aqui.
- **Gate na cara.** Todo passo que precisa de chave declara `_Gate: …_` — é o que o `/dev-next` usa para parar antes de travar.
