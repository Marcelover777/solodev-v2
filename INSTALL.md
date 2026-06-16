# Instalação — solodev v2

> Requer [Claude Code](https://docs.anthropic.com/claude-code). As skills são arquivos Markdown que o Claude Code carrega de `.claude/skills/` (por projeto) ou `~/.claude/skills/` (global).

Escolha **um** dos três métodos abaixo.

---

## A. Plugin do Claude Code (recomendado)

Instala como plugin via marketplace — atualiza junto com o repo.

```
/plugin marketplace add Marcelover777/solodev-v2
/plugin install solodev-v2@solodev-v2
```

Rode `/reload-plugins` para ativar sem reiniciar a sessão.

Ou pelo menu interativo: rode `/plugin`, escolha **Marketplace → solodev-v2** e instale.

> **Importante:** skills instaladas por plugin são **namespaced** pelo nome do plugin. Pelo método A, os comandos aparecem como `/solodev-v2:dev-context`, `/solodev-v2:dev-brainstorm`, etc. — e não como `/dev-context` puro. Os comandos puros (`/dev-context`, …) só valem para os métodos **B** e **C**, que jogam as skills direto em `.claude/skills/`.

---

## B. Script de instalação

Copia as seis skills direto para o `.claude/skills/` do projeto.

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/Marcelover777/solodev-v2/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/Marcelover777/solodev-v2/main/install.ps1 | iex
```

Por padrão instala no **diretório atual**. Para apontar outro projeto, clone o repo e rode o script passando o destino:

```bash
git clone https://github.com/Marcelover777/solodev-v2.git
cd solodev-v2
./install.sh /caminho/do/seu/projeto        # macOS / Linux
```

```powershell
.\install.ps1 -TargetDir C:\caminho\do\seu\projeto   # Windows
```

---

## C. Manual

Copie a pasta `skills/` para o local de skills do Claude Code.

**Por projeto** (só este repositório enxerga):

```bash
mkdir -p .claude/skills
cp -R skills/* .claude/skills/
```

**Global** (todos os projetos enxergam):

```bash
mkdir -p ~/.claude/skills
cp -R skills/* ~/.claude/skills/
```

No Windows, copie `skills\*` para `.claude\skills\` (projeto) ou `%USERPROFILE%\.claude\skills\` (global).

---

## Verificar

Abra o projeto no Claude Code e digite `/`. As seis skills devem aparecer. **O prefixo depende do método de instalação:**

**Via plugin (método A)** — comandos com namespace `solodev-v2:`:

- `/solodev-v2:dev-context`
- `/solodev-v2:dev-brainstorm`
- `/solodev-v2:dev-plan`
- `/solodev-v2:dev-coding`
- `/solodev-v2:dev-fix`
- `/solodev-v2:dev-ship`

**Via script ou manual (métodos B e C)** — comandos puros:

- `/dev-context`
- `/dev-brainstorm`
- `/dev-plan`
- `/dev-coding`
- `/dev-fix`
- `/dev-ship`

Se não aparecerem: pelo método A, rode `/reload-plugins` (ou reabra a sessão). Pelos métodos B/C, confira se os arquivos estão em `.claude/skills/<skill>/SKILL.md` e reabra a sessão.

---

## Atualizar

- **Plugin (método A):** `/plugin marketplace update solodev-v2` e reinstale se pedido.
- **Script (método B):** rode o `curl ... | bash` / `irm ... | iex` de novo — ele sobrescreve as skills existentes.
- **Manual (método C):** `git pull` no repo e copie `skills/*` novamente.

---

## Desinstalar

- **Plugin (método A):** `/plugin uninstall solodev-v2@solodev-v2`.
- **Script / Manual (B e C):** remova as pastas das skills:

```bash
rm -rf .claude/skills/dev-context \
       .claude/skills/dev-brainstorm \
       .claude/skills/dev-plan \
       .claude/skills/dev-coding \
       .claude/skills/dev-fix \
       .claude/skills/dev-ship
```

No Windows:

```powershell
Foreach ($s in 'dev-context','dev-brainstorm','dev-plan','dev-coding','dev-fix','dev-ship') {
    Remove-Item -Recurse -Force ".claude\skills\$s" -ErrorAction SilentlyContinue
}
```

Troque `.claude\skills` por `~/.claude/skills` (ou `%USERPROFILE%\.claude\skills`) se a instalação foi global.
