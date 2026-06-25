# LOOP Templates — arquivos de estado do `/dev-loop`

O `/dev-loop` (e os runners `scripts/loop.ps1` / `scripts/loop.sh`) usam quatro arquivos em `.forge/`, todos Markdown, todos git-diffáveis, todos **UTF-8 sem BOM**. Nenhum é DB; nenhum é binário.

---

## 1. `.forge/AUTONOMY.md` — a coleira (você edita)

Define até onde o loop pode ir sozinho. Default: `step`. Subir o nível **aumenta o lote entre gates, nunca remove um gate**.

```markdown
---
level: step          # suggest | step | supervised | headless
max_iterations: 8    # hard-stop por run
max_budget_usd: 0    # 0 = sem teto; >0 = para antes de estourar
allow_yolo: false    # true habilita --dangerously-skip-permissions no headless (ruidoso)
---

# AUTONOMIA — <projeto>

> A coleira do /dev-loop. `level` decide o lote entre paradas; os gates (GATE/CHECKPOINT/RED)
> NUNCA somem, em nenhum nível. Edite à mão, dê commit — é versionado, reversível por diff.
```

## 2. `.forge/STATE.md` — estado do run (o runner escreve)

Fonte de verdade dos caps e do sinal de parada. Reescrito a cada iteração.

```markdown
---
run_id: 2026-06-25-01
branch: forger/loop/2026-06-25
iteration: 3
max_iterations: 8
cost_usd_cumulative: 0.11
max_budget_usd: 25
last_item: B-007
last_result: progress     # progress | done | gate | checkpoint | red | no-progress
attempts_current_item: 1
updated: 2026-06-25T14:02:00Z
---

# STATE — run 2026-06-25-01

> Escrito pela iteração interna; lido pelo runner para aplicar os caps e decidir parar.
> `last_result` é o sinal de parada (NÃO o exit code do shell).
```

## 3. `.forge/JOURNAL.md` — trilha por iteração (append-only)

Distinto do `PROGRESS.md` (que é o journal do projeto). O `JOURNAL.md` é o log do **run do loop**: uma entrada por iteração, com a verificação e o custo.

```markdown
# JOURNAL — /dev-loop

## 2026-06-25 14:02 — iter 3 — B-007 (login mobile)
- ação: /dev-fix corrigiu o redirect em src/auth/google.ts
- verify: must_pass 3/3, Aceite (npm test auth) verde, validate.mjs verde
- custo: $0.04 (cumul $0.11 / teto $25) · branch forger/loop/2026-06-25
- resultado: ✅ → B-007 done
```

Commit estruturado por iteração:

```
[B-007] Corrige login Google no mobile

Verificação: must_pass 3/3, validate.mjs verde, custo $0.04
Branch: forger/loop/2026-06-25 (NÃO mergeia — humano revisa)
```

## 4. `.forge/loop.lock` — trava de concorrência

Arquivo vazio criado no início do run, removido no fim (try/finally). Se já existe, o runner **recusa iniciar** (outro loop em curso ou um run morreu sujo — apague à mão depois de conferir).

---

## Regras

- **UTF-8 sem BOM** em todos (o `validate.mjs` e o GitHub dependem disso).
- **`last_result` é o sinal**, não o exit code. `gate`/`checkpoint`/`red`/`no-progress`/`done` param o runner.
- **`JOURNAL.md` ≠ `PROGRESS.md`.** O JOURNAL é o log do run do loop; o PROGRESS é a memória do projeto (escrita quando uma unidade fecha de verdade).
- **A coleira é sua.** `AUTONOMY.md` é versionado: subir/baixar autonomia é um diff revisável, não um estado escondido.
