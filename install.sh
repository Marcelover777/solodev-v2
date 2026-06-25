#!/usr/bin/env bash
#
# Forger — instalador POSIX
# Copia as skills do Forger para o .claude/skills/ de um projeto alvo.
#
# Uso:
#   ./install.sh [TARGET_DIR]     # instala no diretório dado (default: diretório atual)
#   curl -fsSL https://raw.githubusercontent.com/Marcelover777/crucible/main/install.sh | bash
#
# No modo pipe (curl|bash) não existem arquivos locais, então clonamos o repo
# público num diretório temporário e copiamos de lá.
#
set -euo pipefail

REPO_URL="https://github.com/Marcelover777/crucible.git"
SKILLS=(dev-start dev-stack dev-design dev-setup dev-roadmap dev-next dev-status dev-ops dev-context dev-brainstorm dev-plan dev-coding dev-fix dev-ship dev-help)

# Diretório alvo (1º argumento) — onde fica o .claude/ do projeto.
TARGET_DIR="${1:-$(pwd)}"

# --- Descobrir a fonte das skills ------------------------------------------
#
# Caso A (clone local): este script está dentro do repo, ao lado de skills/.
# Caso B (pipe):        sem arquivos locais — clonamos o repo num tmp.
#
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
fi

CLEANUP_TMP=""
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/skills" ]; then
  # Rodando a partir de um clone local.
  SOURCE_DIR="$SCRIPT_DIR"
else
  # Rodando via pipe (curl|bash) — clona o repo público num tmp.
  command -v git >/dev/null 2>&1 || {
    echo "erro: git não encontrado. Instale o git ou clone o repo manualmente." >&2
    exit 1
  }
  TMP_DIR="$(mktemp -d)"
  CLEANUP_TMP="$TMP_DIR"
  echo "==> Baixando Forger de $REPO_URL ..."
  git clone --depth 1 "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1
  SOURCE_DIR="$TMP_DIR"
fi

# Remove o tmp ao sair (se foi criado).
cleanup() {
  if [ -n "$CLEANUP_TMP" ] && [ -d "$CLEANUP_TMP" ]; then
    rm -rf "$CLEANUP_TMP"
  fi
}
trap cleanup EXIT

# --- Validar a fonte --------------------------------------------------------
if [ ! -d "$SOURCE_DIR/skills" ]; then
  echo "erro: não encontrei a pasta skills/ em $SOURCE_DIR" >&2
  exit 1
fi

# --- Instalar ---------------------------------------------------------------
DEST="$TARGET_DIR/.claude/skills"
mkdir -p "$DEST"

echo "==> Instalando Forger em: $DEST"
for skill in "${SKILLS[@]}"; do
  src="$SOURCE_DIR/skills/$skill"
  if [ -d "$src" ]; then
    rm -rf "$DEST/$skill"
    cp -R "$src" "$DEST/$skill"
    echo "    copiado: $skill"
  else
    echo "    pulado (não encontrado na fonte): $skill" >&2
  fi
done

echo ""
echo "Pronto. As skills do Forger estão em $DEST"
echo "Abra este projeto no Claude Code. Comece por /dev-start (modo guiado) — ou /dev-help para o mapa dos 15 comandos."
