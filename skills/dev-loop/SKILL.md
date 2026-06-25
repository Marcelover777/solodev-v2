---
name: dev-loop
description: Runner de avanço-automático gated — avança N unidades de trabalho (passos do ROADMAP e itens do .forge/BACKLOG.md) entre paradas, sempre numa branch isolada, parando em TODA frontier (GATE = falta chave, CHECKPOINT = ambiguidade/merge, RED = destrutivo). Não é autonomia solta estilo Ralph: é um batch runner que halta direito, com caps de iteração, de custo e de não-progresso, verificação mecânica autoritativa (build/test/validate) e journal por iteração. Níveis em .forge/AUTONOMY.md — suggest, step (default), supervised, headless (runner scripts/loop.ps1|loop.sh, opt-in). Use quando o usuário disser "/dev-loop", "roda sozinho", "avança vários passos", "vai fazendo o backlog", "modo autônomo", "loop", "deixa rodando", "resolve a fila", ou pedir para o Forger avançar trabalho sem ele confirmar passo a passo.
---

# /dev-loop — Avanço-automático com coleira (não é "autonomia solta")

> **O que isto é.** Um runner que pega a próxima unidade de trabalho **já planejada e já gated** (passo do `ROADMAP.md` ou item do `.forge/BACKLOG.md`), executa, **verifica de verdade**, registra, e repete — **parando em toda frontier**. Um loop que para no 1º gate, no 1º destrutivo, na 1ª ambiguidade e na 3ª falha **não é autônomo — é um batch runner que halta direito. E está certo assim.** A lei é a do Forger: **AUTONOMIA = f(VERIFICAÇÃO)**; subir o nível só aumenta o **lote entre gates**, nunca remove um gate.

## Pré-condições

- Existe `ROADMAP.md` **ou** `.forge/BACKLOG.md` com trabalho pendente (senão, nada a avançar — sugira `/dev-roadmap` ou `/dev-audit`).
- Roda numa **branch dedicada** `forger/loop/<data>` — **nunca** na branch default (`main`/`master`). O merge é decisão humana (CHECKPOINT).
- O nível de autonomia vive em `.forge/AUTONOMY.md` (default `step`). Ver [LOOP-TEMPLATE.md](LOOP-TEMPLATE.md).

## Uma iteração = um ciclo OODA, UMA unidade

```
OBSERVE  → lê a próxima unidade (precedência do /dev-next: ROADMAP → BACKLOG; ordem de arquivo,
           NÃO o modelo escolhendo). Nada pendente → COMPLETE.
ORIENT   → GATE: falta chave/config? → bloco GATE com o link, PARA.
           RED: a unidade implica destrutivo (migration, drop, push, reset)? → PARA, exige humano.
DECIDE   → despacha a skill certa do ciclo (o dispatcher do /dev-next: bug→/dev-fix, etc.).
ACT      → aplica a mudança. Anti-placeholder = GREP no diff (o do /dev-coding §2b), não promessa.
VERIFY   → roda o must_pass DA unidade + os Critérios/Aceite do .plans/steps/0X-*.md ou da linha
           do backlog (reusa o /dev-ship) + `node scripts/validate.mjs` quando aplicável.
           Mecânico-primeiro e AUTORITATIVO. Nada de server long-lived (só build/test/tsc).
JOURNAL  → append em .forge/JOURNAL.md; marca ✅ SÓ se o verify passou; commit estruturado.
ÁRBITRO  → success (fila vazia) | cap de iteração | cap de custo | no-progress (3x no mesmo item)
           | frontier (GATE/CHECKPOINT/RED) → para na hora.
```

## Frontiers — para, nada em silêncio

| Frontier | Quando | O que faz |
|----------|--------|-----------|
| **GATE** | chave/config faltando para a unidade | bloco com o **link exato**; não executa; espera você resolver |
| **CHECKPOINT** | ambiguidade de spec, **merge da branch**, arquivamento, promover `idea` a passo | para e pergunta; uma decisão por vez |
| **RED** | destrutivo/irreversível | **PARA — nunca executa.** Recovery = parar + CHECKPOINT, jamais `reset --hard` |

**O loop NUNCA executa autonomamente:** `git reset --hard`, `git clean`, `rebase`, `push`/`push --force`, deletar branch, reescrever histórico, commit na branch default, migration destrutiva, `rm -rf`. Tudo isso é **RED** → para e devolve ao humano.

## Caps (três, todos obrigatórios)

| Cap | Default | Regra |
|-----|---------|-------|
| **Iteração** | ≤ 8 | persistido em `.forge/STATE.md`; hard-stop ao atingir |
| **Custo cumulativo** | sem teto até você dar `--max-budget-usd` | soma o `total_cost_usd` de cada run em `.forge/STATE.md`, checado **antes** de cada iteração (o `total_cost_usd` é por-invocação; sem somar, 8 iterações = 8× um run grande) |
| **No-progress** | 3 | `attempts ≥ 3` no **mesmo** item é o backstop **autoritativo**. O hash da falha (nomes dos testes que falharam + exit code, com paths/timestamps/números removidos) é só sinal de apoio — o contador manda |

## Verificação INDEPENDENTE (a destilação honesta do WARDEN)

> **Honestidade sobre verificação (não-negociável).** A verificação é **mecânica-primeiro e mecânica-autoritativa**: lint/test/build/`validate.mjs`/regex dos Critérios. Um passe de "review/beleza" por LLM é **só advisory, mesma linhagem, NUNCA destrava o `✅`, desligado por padrão.** Um verificador *de outra linhagem* exige infra → **fora de escopo** deste plugin zero-infra: não se finge que self-review é verificação independente. O verificador independente real aqui é `validate.mjs` + a suíte de testes. **Correção visual/UI é CHECKPOINT humano** (Karpathy sobre GUI) — nunca um passo de verify do loop.

## Níveis de autonomia (a coleira é um arquivo: `.forge/AUTONOMY.md`)

| Nível | Comportamento | Default |
|-------|---------------|---------|
| **`suggest`** | só propõe a próxima ação e o porquê; você roda à mão | — |
| **`step`** | avança UMA unidade, para, mostra o verify, espera "próximo" | ✅ **default** |
| **`supervised`** | avança até a próxima frontier (lote entre gates); você confirma cada frontier | opt-in |
| **`headless`** | runner desacoplado (`scripts/loop.ps1` / `scripts/loop.sh`), caps duros, branch isolada, **merge manual** | **opt-in explícito** |

> Subir o nível **aumenta o lote entre gates, nunca remove gates.** O nível mora em Markdown versionado — você grepa, dá diff e reverte a própria coleira. Mudar de `step` para `headless` é uma decisão consciente, escrita no `.forge/AUTONOMY.md` (ou passada como flag ao runner).

## Modo headless (o runner real)

O nível `headless` roda fora da sessão interativa, via `scripts/loop.ps1` (Windows, **first-class**) ou `scripts/loop.sh` (POSIX). O runner chama o Claude Code em modo `-p` (print) num laço, lê o resultado, e aplica os caps. Contrato file-based:

- **Estado** em `.forge/STATE.md` (iteração, custo cumulado, último resultado, item atual, branch). Schema no [LOOP-TEMPLATE.md](LOOP-TEMPLATE.md).
- **Sinal de parada** vem de `.forge/STATE.md` (`last_result: progress|done|gate|checkpoint|red|no-progress`), escrito pela iteração interna — não de heurística do shell.
- **Lock:** `.forge/loop.lock` no início, liberado no fim; recusa iniciar se já houver um lock.

### Caveats Windows (Win10, PowerShell 5.1) — o runner PS é correto, não waved-away pro WSL

- **Sinal de máquina = `subtype` do JSON, NÃO `$LASTEXITCODE`.** O runner parseia `claude -p --output-format json` e ramifica no `subtype` (`success | error_max_turns | error_during_execution | error_max_budget` | refusal). Exit 0 de um *result* não é "deu certo".
- **Encoding:** todo arquivo de estado em **UTF-8 sem BOM** (`[IO.File]::WriteAllText` com `UTF8Encoding($false)`). O default UTF-16 do PS 5.1 quebra o `content.includes()` do `validate.mjs` e não renderiza no GitHub.
- **Sem `&&`/`||`** no PS 5.1 — encadeie `;` + `if ($?)`. **Sem `2>&1`** em exe nativo (vira `NativeCommandError` e seta `$?` falso em exit 0).
- **Não roda `--bare`.** Bare pula a descoberta de plugin/skill/`CLAUDE.md` — mata a re-injeção da "constituição" (o `LOOP.md` é re-catado fisicamente a cada invocação, porque compaction dropa o prompt de abertura).
- **Server long-lived:** o verify nunca sobe `dev server`; só checks que terminam sozinhos (build/test/tsc).
- **Sem dependência de WSL.** O Forger mira Windows-nativo; o runner PS tem que estar **correto**.

### Permissões (headless)

Default seguro: `--permission-mode acceptEdits` + allow-list de tools + a deny-list de git-destrutivo/rede que a constituição impõe (os RED). **`--dangerously-skip-permissions` é o opt-in explícito do "headless total"**: só quando você passa a flag `-Yolo`/`--yolo`, com aviso ruidoso, **sempre** branch-isolado e caps duros — nunca o default. Mesmo no yolo, os RED continuam parando o loop (a constituição é re-injetada a cada iteração).

## Wiring do validador

`/dev-loop` é skill (entra nas 4 superfícies). Os runners `scripts/loop.{ps1,sh}` são auxiliares (não-skill). **O próprio `node scripts/validate.mjs` como must_pass por iteração é a filosofia em ação: a suíte que prega critério verificável verifica a si mesma a cada volta.**

## Anti-padrões

- ❌ Vender isto como "autonomia" (é avanço-automático com coleira)
- ❌ `git reset --hard`/`clean`/`rebase`/`push --force` como recovery (é RED — para)
- ❌ Commit/merge na branch default · ❌ rodar `--bare` · ❌ ramificar em `$LASTEXITCODE` em vez de `subtype`
- ❌ Estado em UTF-16 · ❌ self-review de LLM destravando o `✅` · ❌ server long-lived no verify
- ❌ Marcar `✅` por "build verde" genérico em vez dos Critérios/Aceite da unidade
- ❌ O modelo escolhendo a prioridade (a ordem é a do `/dev-next`: arquivo, determinística)
- ❌ Subir o nível removendo um gate (só cresce o lote *entre* gates) · ❌ exigir WSL

## Próximo passo

> *"Loop em nível `<n>`. Avancei <k> unidade(s) na branch `forger/loop/<data>`; parei em `<frontier/cap>`. Veja `.forge/JOURNAL.md`. Para mergear, revise o diff e confirme (CHECKPOINT). Subir a autonomia: edite `.forge/AUTONOMY.md` ou rode `scripts/loop.ps1 -MaxIterations N`."*
