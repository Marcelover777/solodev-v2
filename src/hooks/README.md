# Hooks do Forger (opt-in, file-based)

Dois hooks de Claude Code. Ambos são **CommonJS**, **silent-fail** em qualquer
erro de filesystem, respeitam `CLAUDE_CONFIG_DIR`, e **não** sobem worker, DB
nem porta de rede. Tudo é leitura/append de arquivo — igual ao resto do Forger.

| Hook | Evento | Liga sozinho? | O que faz |
|------|--------|---------------|-----------|
| `forger-session-start.js` | `SessionStart` | inofensivo — só lê | Injeta `.forge/PROGRESS.md` (se existir) como contexto, pra retomar a sessão sem reexplicar nada. |
| `forger-autocommit.js` | `Stop` | **NÃO** — precisa de env var | Ao fim do turno, faz `git add -A` + commit (Conventional Commits) se houver mudança. **Nunca push.** |

> O **session-start** é seguro de ligar pra qualquer um: ele só lê um arquivo e
> imprime. O **autocommit** mexe no seu git — leia o aviso de segurança abaixo
> antes de ativar.

---

## 1. `forger-session-start.js` — continuidade entre sessões

Quando uma sessão nova começa, o hook procura `.forge/PROGRESS.md` na raiz do
seu projeto. Achou → imprime o conteúdo como contexto, e o Claude já sabe onde
você parou (o `/dev-next` escreve esse journal a cada passo). Não achou → fica
quieto, sem erro.

### Ativar

1. Copie o arquivo para a pasta de hooks do Claude Code (use `$CLAUDE_CONFIG_DIR`
   se você customizou; o padrão é `~/.claude`):

   ```bash
   mkdir -p "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks"
   cp src/hooks/forger-session-start.js "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/"
   ```

2. Registre o hook no `settings.json` (mesma pasta). Adicione dentro de `"hooks"`:

   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "node \"$CLAUDE_CONFIG_DIR/hooks/forger-session-start.js\""
             }
           ]
         }
       ]
     }
   }
   ```

   No Windows, troque o comando por:
   `node "%CLAUDE_CONFIG_DIR%\\hooks\\forger-session-start.js"` (ou o caminho
   absoluto da sua pasta `.claude\\hooks`).

3. Abra uma sessão nova num projeto que tenha `.forge/PROGRESS.md`. O resumo do
   journal aparece como contexto inicial.

---

## 2. `forger-autocommit.js` — auto-commit (OPT-IN, perigoso se mal usado)

Mexe no seu repositório git. Por isso, **instalar não ativa** — ele só roda
quando você liga uma variável de ambiente de propósito.

### O que ele garante (salvaguardas duras)

- **Nunca faz `push`.** O commit é local. Errou? `git reset --soft HEAD~1`
  desfaz e devolve as mudanças ao working tree.
- **Não commita na `main`/`master`** sem você liberar explicitamente
  (`FORGER_AUTOCOMMIT_ALLOW_MAIN=1`).
- **Não usa `--no-verify` por padrão:** seus git hooks (pre-commit, lint, etc.)
  continuam rodando e podem barrar o commit — do jeito certo.
- **Não entra em loop** (respeita `stop_hook_active`) e **nunca bloqueia** o fim
  da sessão: qualquer erro → ele desiste em silêncio.
- Só commita se houver mudança; a mensagem segue Conventional Commits e leva o
  marcador `[auto]` pra você achar/squashar depois.

### ⚠️ Antes de ligar, entenda o risco

Auto-commit confunde histórico se você trabalha em commits cuidadosamente
separados. O alvo dele é o fluxo vibe-coder: WIP frequente numa branch de
feature, que você depois fecha com `/dev-ship` (ou um `git rebase -i` pra
squashar os `[auto]`). Se você cura cada commit à mão, **não use este hook.**

### Ativar

1. Copie o arquivo:

   ```bash
   cp src/hooks/forger-autocommit.js "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/"
   ```

2. Registre o hook `Stop` no `settings.json`:

   ```json
   {
     "hooks": {
       "Stop": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "node \"$CLAUDE_CONFIG_DIR/hooks/forger-autocommit.js\""
             }
           ]
         }
       ]
     }
   }
   ```

3. **Ligue o opt-in** exportando a env var na shell de onde você roda o Claude
   Code (só a presença do hook no settings não basta):

   ```bash
   export FORGER_AUTOCOMMIT=1
   ```

   No Windows (PowerShell): `$env:FORGER_AUTOCOMMIT = '1'`.

### Env vars

| Variável | Efeito | Padrão |
|----------|--------|--------|
| `FORGER_AUTOCOMMIT` | **Liga** o hook. Sem ela, no-op. | desligado |
| `FORGER_AUTOCOMMIT_ALLOW_MAIN` | Permite commitar na `main`/`master`. | desligado (recusa) |
| `FORGER_AUTOCOMMIT_NO_VERIFY` | Passa `--no-verify` (pula git hooks). **Desencorajado.** | desligado |

Valores aceitos como "ligado": `1`, `true`, `yes`, `on` (case-insensitive).

> **Compat (rename Crucible → Forger).** Os nomes legados `CRUCIBLE_AUTOCOMMIT`,
> `CRUCIBLE_AUTOCOMMIT_ALLOW_MAIN` e `CRUCIBLE_AUTOCOMMIT_NO_VERIFY` continuam
> funcionando — o hook aceita as duas famílias. Do mesmo jeito, o session-start
> lê `.forge/PROGRESS.md` e, se não achar, cai no legado `.crucible/PROGRESS.md`.
> Prefira os nomes novos; os antigos podem sair numa versão futura.

### Desligar

- Temporário: `unset FORGER_AUTOCOMMIT` (PowerShell:
  `Remove-Item Env:FORGER_AUTOCOMMIT`).
- Permanente: remova o bloco `Stop` do `settings.json` e apague
  `forger-autocommit.js` da pasta `hooks/`.

---

## Por que file-based (e não um worker como o claude-mem)

O Forger guarda memória e estado em **Markdown** (`.forge/PROGRESS.md`,
`.forge/STATUS.md`) — versíável, legível, renderiza no GitHub, e não tem
"worker unreachable". Estes hooks seguem a mesma regra: **um** `SessionStart` que
lê um arquivo, **um** `Stop` opt-in que faz um commit. Sem captura de toda tool
call, sem banco, sem porta. Se um hook falhar, ele some em silêncio — nunca
derruba sua sessão.
