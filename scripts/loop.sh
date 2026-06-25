#!/usr/bin/env bash
#
# Forger — runner headless do /dev-loop (POSIX; paridade com scripts/loop.ps1).
#
# Avança N unidades de trabalho (passos do ROADMAP + itens do .forge/BACKLOG.md)
# chamando o Claude Code em modo -p num laço, SEMPRE numa branch isolada, parando
# em toda frontier (GATE/CHECKPOINT/RED) e nos caps (iteração/custo/no-progress).
# NÃO é autonomia solta — é um batch runner que halta direito.
#
# Uso:
#   ./scripts/loop.sh [--max-iterations 8] [--max-budget-usd 0] [--yolo] [--target-dir <path>]
#
# --max-budget-usd 0 = sem teto. --yolo = --dangerously-skip-permissions (opt-in
# ruidoso; mesmo assim os RED continuam parando o loop). Sinal = `subtype` do JSON.
#
set -euo pipefail

MAX_ITER=8
MAX_BUDGET=0
YOLO=0
TARGET_DIR="$(pwd)"

while [ $# -gt 0 ]; do
  case "$1" in
    --max-iterations) MAX_ITER="$2"; shift 2;;
    --max-budget-usd) MAX_BUDGET="$2"; shift 2;;
    --yolo) YOLO=1; shift;;
    --target-dir) TARGET_DIR="$2"; shift 2;;
    *) echo "arg desconhecido: $1" >&2; exit 1;;
  esac
done

command -v claude >/dev/null 2>&1 || { echo "erro: claude (Claude Code CLI) não encontrado." >&2; exit 1; }
command -v node   >/dev/null 2>&1 || { echo "erro: node não encontrado (usado para parsear o JSON)." >&2; exit 1; }
command -v git    >/dev/null 2>&1 || { echo "erro: git não encontrado." >&2; exit 1; }

cd "$TARGET_DIR"
FORGE="$TARGET_DIR/.forge"
mkdir -p "$FORGE"
LOCK="$FORGE/loop.lock"
if [ -e "$LOCK" ]; then
  echo "erro: há um loop em curso (ou morto sujo): $LOCK existe. Confira e apague à mão se for resíduo." >&2
  exit 1
fi
: > "$LOCK"
cleanup() { rm -f "$LOCK"; }
trap cleanup EXIT

# --- Branch isolada: nunca na default ---------------------------------------
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  LOOP_BRANCH="forger/loop/$(date +%Y-%m-%d)"
  if git show-ref --verify --quiet "refs/heads/$LOOP_BRANCH"; then
    git checkout "$LOOP_BRANCH" >/dev/null
  else
    git checkout -b "$LOOP_BRANCH" >/dev/null
  fi
  BRANCH="$LOOP_BRANCH"
fi
echo "==> /dev-loop headless na branch: $BRANCH  (caps: iter<=$MAX_ITER, budget=$MAX_BUDGET, yolo=$YOLO)"

if [ "$YOLO" -eq 1 ]; then PERM=(--dangerously-skip-permissions); else PERM=(--permission-mode acceptEdits); fi
SIG="$FORGE/loop.signal"

read -r -d '' PROMPT <<'EOF' || true
Você é o /dev-loop do Forger em modo runner HEADLESS. Faça UMA iteração do ciclo OODA
sobre a PRÓXIMA unidade de trabalho, seguindo a precedência do /dev-next (ROADMAP.md → .forge/BACKLOG.md;
ordem de arquivo/determinística, você NÃO escolhe a prioridade).

Regras duras (a constituição do Forger):
- Frontiers param TUDO: GATE (falta chave/config) → não execute. CHECKPOINT (ambiguidade/merge) → pare.
  RED (destrutivo: reset --hard, clean, rebase, push/--force, deletar branch, reescrever histórico,
  migration destrutiva, rm -rf, commit na branch default) → NUNCA execute, pare.
- NÃO faça push. NÃO toque na branch default. Commit só na branch atual do loop.
- Verifique DE VERDADE (mecânico e autoritativo): must_pass + Critérios/Aceite da unidade
  (reuse o /dev-ship) + `node scripts/validate.mjs` quando aplicável. Nada de dev server long-lived.
- Marque ✅ a unidade SÓ se o verify passou. Anti-placeholder: grep no diff (TODO/FIXME/stub) → não é done.
- Faça APPEND de uma entrada em .forge/JOURNAL.md (ação, verify, resultado).

No FIM, escreva em .forge/loop.signal EXATAMENTE duas linhas (UTF-8 sem BOM):
result=<progress|done|gate|checkpoint|red|no-progress>
item=<id do item B-NNN ou "passo 0X" ou "-">
("done" = fila vazia; "progress" = avançou uma unidade verde; as frontiers = o nome delas;
"no-progress" = não conseguiu avançar esta unidade.) Depois SAIA. Uma unidade por iteração, nada além.
EOF

CUM=0
declare -A ATTEMPTS
STOP=""
ITER=0

while [ "$ITER" -lt "$MAX_ITER" ]; do
  if [ "$MAX_BUDGET" != "0" ] && awk "BEGIN{exit !($CUM >= $MAX_BUDGET)}"; then
    STOP="budget (\$$CUM >= \$$MAX_BUDGET)"; break
  fi
  ITER=$((ITER + 1))
  echo ""; echo "--- iteração $ITER/$MAX_ITER (cumul \$$CUM) ---"
  rm -f "$SIG"

  OUT="$(claude -p "$PROMPT" --output-format json "${PERM[@]}")"

  SUBTYPE="$(printf '%s' "$OUT" | node -pe 'try{JSON.parse(require("fs").readFileSync(0,"utf8")).subtype||""}catch(e){"__BADJSON__"}')"
  if [ "$SUBTYPE" = "__BADJSON__" ]; then STOP="json inválido do claude (abortando para não rodar às cegas)"; break; fi
  COST="$(printf '%s' "$OUT" | node -pe 'try{(JSON.parse(require("fs").readFileSync(0,"utf8")).total_cost_usd)||0}catch(e){0}')"
  CUM="$(awk "BEGIN{printf \"%.4f\", $CUM + $COST}")"

  if [ "$SUBTYPE" = "error_during_execution" ] || [ "$SUBTYPE" = "refusal" ]; then
    STOP="claude subtype=$SUBTYPE"; break
  fi

  RESULT="progress"; ITEM="-"
  if [ -f "$SIG" ]; then
    while IFS= read -r line; do
      case "$line" in
        result=*) RESULT="$(printf '%s' "${line#result=}" | tr -d '[:space:]')";;
        item=*)   ITEM="$(printf '%s' "${line#item=}" | sed 's/^ *//;s/ *$//')";;
      esac
    done < "$SIG"
  elif [ "$SUBTYPE" = "error_max_turns" ]; then
    RESULT="no-progress"
  fi

  [ -n "${ATTEMPTS[$ITEM]:-}" ] || ATTEMPTS[$ITEM]=0
  if [ "$RESULT" = "no-progress" ]; then ATTEMPTS[$ITEM]=$((ATTEMPTS[$ITEM] + 1)); else ATTEMPTS[$ITEM]=0; fi

  cat > "$FORGE/STATE.md" <<EOF
---
branch: $BRANCH
iteration: $ITER
max_iterations: $MAX_ITER
cost_usd_cumulative: $CUM
max_budget_usd: $MAX_BUDGET
last_item: $ITEM
last_result: $RESULT
attempts_current_item: ${ATTEMPTS[$ITEM]}
---

# STATE — /dev-loop ($BRANCH)

> Escrito pelo runner. last_result é o sinal de parada (não o exit code).
EOF

  echo "    subtype=$SUBTYPE  result=$RESULT  item=$ITEM  custo_cumul=\$$CUM"

  case "$RESULT" in
    done)        STOP="fila vazia (done)";;
    gate)        STOP="GATE em $ITEM (falta chave/config — resolva e rode de novo)";;
    checkpoint)  STOP="CHECKPOINT em $ITEM (decisão humana)";;
    red)         STOP="RED em $ITEM (destrutivo — exige humano)";;
    no-progress) [ "${ATTEMPTS[$ITEM]}" -ge 3 ] && STOP="no-progress: 3x em $ITEM";;
  esac
  [ -n "$STOP" ] && break
done
[ -n "$STOP" ] || STOP="cap de iteração ($MAX_ITER)"

echo ""
echo "==> /dev-loop parou: $STOP"
echo "    iterações: $ITER  ·  custo: \$$CUM  ·  branch: $BRANCH"
echo "    Revise o diff e o .forge/JOURNAL.md. Merge é decisão sua (CHECKPOINT): nada foi para a branch default, nada foi pushado."
