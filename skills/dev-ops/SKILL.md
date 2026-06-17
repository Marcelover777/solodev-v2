---
name: dev-ops
description: Git/GitHub no automático para quem nunca quer mexer em git. Scaffolda os arquivos drop-in do GitHub (.github/workflows/ci.yml com lint+typecheck+unit, dependabot.yml, PULL_REQUEST_TEMPLATE.md, ISSUE_TEMPLATE/bug_report.md), escreve um GITHUB.md que explica Actions/PR/CI/issue/branch em 1 parágrafo cada pra leigo, define a política de timing de testes no TESTING.md (lint on-save, unit on-push, e2e só em PR-pra-main/nightly), abre PR via gh pr create --fill e oferece hooks git opt-in (auto-commit no Stop, limpeza de worktree). Use quando o usuário disser "/dev-ops", "configura o GitHub", "põe CI", "cria o pipeline", "quero Actions", "abre um PR", "automatiza o git", "não quero entender git", "configura os testes no push", ou pedir branch protection.
---

# /dev-ops — Git/GitHub no automático (o usuário nunca precisa entender git)

O iniciante não quer saber o que é branch, PR ou CI. Quer que o código suba seguro, que o robô rode os testes e que ninguém quebre a `main` sem aviso. Esta skill **scaffolda os arquivos** que fazem isso, **explica em linguagem de leigo** o que cada um faz, e **oferece** (nunca impõe) a automação de commit. Ela não reimplementa git — usa o que o GitHub e o Claude Code já dão.

## Princípios não-negociáveis

1. **Opt-in para tudo que escreve no histórico.** Auto-commit e limpeza de worktree só ligam com flag explícita do usuário. Sem flag → só os arquivos `.github/*` e os docs. Nunca um push silencioso para `main`.
2. **Drop-in, não framework.** Arquivos prontos que o GitHub lê sozinho (`ci.yml`, `dependabot.yml`, templates). Nada de orquestrador, nada de infra, nada de porta/worker.
3. **Timing certo de teste.** Rápido roda sempre, lento roda raro. `format/lint on-save → unit on-push → e2e/harness só em PR-pra-main / workflow_dispatch / nightly`. e2e a cada save é proibido (Phase 0.4).
4. **Leigo entende.** O `GITHUB.md` explica Actions, PR, CI, issue e branch em 1 parágrafo cada, sem jargão solto. Se escrever "merge", explica "merge".
5. **Karpathy.** Não inventa workflow que o projeto não usa. Sem teste no projeto → o job de teste vira um passo "adicione testes" comentado, não um verde falso.

## Pré-condições

- Repositório git existe (`git rev-parse --git-dir` não falha). Se não houver, pare e sugira `git init` antes — não inicialize repo em silêncio.
- Para PR e branch protection: `gh` (GitHub CLI) instalado e autenticado (`gh auth status`). Se faltar, dê o link oficial (https://cli.github.com) e siga só com o scaffold local.
- Lê `STACK.md` (se existir) para descobrir o gerenciador de pacotes e os comandos reais de lint/typecheck/test. Sem `STACK.md`, infira do `package.json`/lockfile presente — não chute o ecossistema.

## Processo

### 1. Descubra os comandos reais do projeto

Nunca crave `npm run lint` sem confirmar. Leia `package.json` (`scripts`) ou o equivalente do ecossistema:

| Sinal | De onde | Vira |
|-------|---------|------|
| gerenciador | lockfile (`package-lock.json`/`pnpm-lock.yaml`/`yarn.lock`/`bun.lockb`) | `npm`/`pnpm`/`yarn`/`bun` no `ci.yml` |
| lint | `scripts.lint` | passo de lint (ou omitir com comentário se não existe) |
| typecheck | `scripts.typecheck` ou `tsc --noEmit` | passo de typecheck |
| unit | `scripts.test` | passo de unit on-push |
| e2e | `scripts.test:e2e`/`playwright`/`cypress` | job separado, gatilho PR-pra-main/nightly |

Se um comando não existe, **não invente** — deixe o passo comentado no `ci.yml` com `# adicione um script "lint" no package.json para ativar`. Verde falso é pior que job ausente.

### 2. Scaffolde os arquivos `.github/*`

Escreva (sem sobrescrever sem avisar — se já existe, faça diff e pergunte):

- `.github/workflows/ci.yml` — de [ci.yml](templates/ci.yml). Lint + typecheck + unit em `push` e `pull_request`. e2e/harness em job separado só com `pull_request` para `main`, `workflow_dispatch` e `schedule` (nightly). Comente os passos cujos comandos o projeto ainda não tem.
- `.github/dependabot.yml` — de [dependabot.yml](templates/dependabot.yml). Updates semanais de deps + actions.
- `.github/PULL_REQUEST_TEMPLATE.md` — de [PULL_REQUEST_TEMPLATE.md](templates/PULL_REQUEST_TEMPLATE.md).
- `.github/ISSUE_TEMPLATE/bug_report.md` — de [bug_report.md](templates/bug_report.md).

Ajuste o `ci.yml` ao gerenciador detectado no passo 1 (o template vem com `npm`; troque `setup` e `install` se for pnpm/yarn/bun). Para comandos voláteis (versão de action, setup do gerenciador), avise o usuário para conferir a versão atual na hora — não fixe uma major que pode ter mudado.

### 3. Escreva o `GITHUB.md` (para leigo)

De [GITHUB.md](templates/GITHUB.md). Cada conceito em 1 parágrafo de gente, não de docs: **repositório**, **branch**, **commit**, **PR (pull request)**, **CI (o robô que testa)**, **Actions**, **issue**. Termina com "o que você realmente precisa fazer" (resposta: quase nada — `/dev-ship` abre o PR).

### 4. Escreva o `TESTING.md` (política de timing)

De [TESTING.md](templates/TESTING.md). A tabela de quando cada teste roda. É a fonte que `/dev-coding` e `/dev-next` consultam para **não** rodar e2e a cada passo. Reflita exatamente o que o `ci.yml` faz — os dois não podem divergir.

### 5. Hooks git opt-in (só com flag explícita)

Não instale nada aqui sem o usuário pedir em palavras. Ofereça assim:

> *"Quer que eu ligue o auto-commit? Toda vez que eu terminar um turno, faço um commit com mensagem Conventional Commits — você nunca digita `git commit`. Fica só local, nunca dou push pra `main` sozinho. Ligo? (s/n)"*

Só com "sim":

- **Auto-commit (`Stop`-hook).** Vive em `src/hooks/` (CommonJS, silent-fail, respeita `CLAUDE_CONFIG_DIR`, sem worker/porta/DB). No fim do turno: `git add -A` + commit com mensagem Conventional Commits (espelha o `[task-XX]` do `/dev-coding`). **Nunca** `git push`. **Nunca** na `main` sem confirmar. Hook no `Stop`, não no `PostToolUse` (que faria 1 commit por arquivo = ruído — Phase 0.4).
- **Limpeza de worktree.** Após merge, `git worktree prune` para remover worktrees órfãos do `claude -w`. Idempotente, silent-fail.

Registre no `.claude/settings.json` do projeto com disciplina defensiva (valide o schema antes de escrever; tolere comentários JSONC no arquivo existente). **Confirme o schema do hook (`Stop`, casing, `$CLAUDE_FILE_PATHS`) na doc oficial do Claude Code antes de gravar** — não assuma o casing.

### 6. PR e branch protection (via gh)

- **PR:** o fluxo de PR é do `/dev-ship`, que chama `gh pr create --fill` (preenche título/corpo do último commit, usa o `PULL_REQUEST_TEMPLATE.md`). Aqui só garanta que o template existe e que `gh` está pronto.
- **Branch protection:** **one-liner opcional**, nunca obrigatório (confunde solo dev sem remote/colaborador). Ofereça o comando e o que ele faz, deixe o usuário decidir:

> *"Opcional: proteger a `main` pra ninguém (nem você por acidente) dar push direto sem o CI passar. É um comando só. Quer? Se for projeto solo no início, pode pular — liga quando entrar gente."*
>
> `gh api repos/{owner}/{repo}/branches/main/protection -X PUT ...` (monte com os checks do `ci.yml`; confirme o shape atual na doc do `gh` — a API de protection muda de campos).

## Quando cair pra prosa normal (auto-clarity)

Git mexe em histórico — vários pontos aqui são destrutivos ou irreversíveis. Saia do terse e escreva em frases inteiras quando:

- For ligar **auto-commit** ou **auto-push**: explique exatamente o que vai acontecer no histórico antes de ligar, e confirme.
- For aplicar **branch protection**: diga em prosa o que trava e como destravar depois.
- Qualquer comando que reescreve histórico (`push --force`, `reset --hard`, `rebase`): pare, explique o risco, confirme. Nunca rode com `--no-verify` por padrão.
- O usuário claramente não sabe o que é PR/branch: explique antes de agir, não despeje comando.

## Anti-padrões

- ❌ Auto-push para `main` sem opt-in explícito (Phase 0.5)
- ❌ e2e/harness a cada save ou a cada push (lento — só PR-pra-main / `workflow_dispatch` / nightly)
- ❌ Branch protection obrigatória (trava o solo dev sem colaborador)
- ❌ Auto-commit via `PostToolUse` (1 commit por arquivo = firehose; use `Stop`)
- ❌ Assumir o schema/casing do hook sem checar a doc oficial do Claude Code
- ❌ Commit com `--no-verify` por padrão (pula os hooks de qualidade do próprio usuário)
- ❌ Cravar `npm run lint` sem confirmar que o script existe (verde falso)
- ❌ Hook com worker/porta/DB ou que estoura erro de FS (tem que silent-fail)
- ❌ Sobrescrever um `.github/*` já existente sem mostrar o diff e perguntar
- ❌ `ci.yml` e `TESTING.md` divergentes (a política tem que ser a mesma nos dois)

## Onde ficam os arquivos

- `.github/workflows/ci.yml`, `.github/dependabot.yml`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/bug_report.md` — no repo do usuário (drop-in).
- `GITHUB.md`, `TESTING.md` — raiz do repo do usuário.
- Hooks opt-in — `src/hooks/` (só se o usuário ligar), registrados no `.claude/settings.json` do projeto.

## Próximo passo

Após scaffoldar:

> *"Pronto: `.github/` montado, `GITHUB.md` e `TESTING.md` escritos. O robô (CI) já vai rodar lint+typecheck+unit no próximo push. Pra abrir o primeiro PR, é só `/dev-ship`. Quer que eu ligue o auto-commit pra você nunca digitar `git commit`? Pra ver o estado: `/dev-status`."*
