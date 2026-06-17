#!/usr/bin/env node
// Crucible — Claude Code Stop hook (auto-commit OPT-IN).
//
// O que faz: ao FIM de um turno, se houver mudanças no working tree, faz
//   git add -A  &&  git commit -m "<Conventional Commits>"
// no repositório do projeto (cwd da sessão). Não existe a menos que você ligue
// de propósito — ver README.md desta pasta.
//
// Salvaguardas (DURAS — commit silencioso é perigoso, então tudo é conservador):
//   - OPT-IN: só roda se CRUCIBLE_AUTOCOMMIT estiver em {1,true,yes,on}. Sem isso,
//     no-op imediato. Instalar o hook NÃO o ativa; a env var ativa.
//   - NUNCA push. Em hipótese nenhuma. Commit é local, reversível (`git reset`).
//   - NUNCA na branch default (main/master) sem confirmação explícita via
//     CRUCIBLE_AUTOCOMMIT_ALLOW_MAIN=1. Solo dev raramente quer auto-commit
//     direto na main.
//   - NUNCA --no-verify por padrão: os git hooks do projeto (pre-commit, etc.)
//     RODAM. Só pula com CRUCIBLE_AUTOCOMMIT_NO_VERIFY=1, e isso é desencorajado.
//   - Evita loop: respeita stop_hook_active do payload — se um Stop já está em
//     processamento, sai na hora.
//   - silent-fail / non-blocking: qualquer erro de git/FS → exit 0 sem bloquear
//     o Stop. Nunca emite decision:"block" (não prende o usuário numa sessão).
//   - respeita CLAUDE_CONFIG_DIR (convencional; aqui só lemos o cwd do payload).
//   - CommonJS puro. Sem worker, sem DB, sem porta.
//
// Contrato Claude Code (stdin):
//   { session_id, transcript_path, cwd, permission_mode, hook_event_name: "Stop",
//     stop_hook_active: boolean }
// Saída: nada (exit 0). Nunca bloqueia.

const fs = require('fs');
const { execFileSync } = require('child_process');

const TRUTHY = new Set(['1', 'true', 'yes', 'on']);
function envOn(name) {
  const v = process.env[name];
  return !!v && TRUTHY.has(String(v).trim().toLowerCase());
}

function readStdin() {
  try {
    return fs.readFileSync(0, 'utf8');
  } catch (_) {
    return '';
  }
}

// git silencioso: roda no cwd do projeto, captura stdout, engole erro.
// Retorna a string de saída ('' em falha). Nunca lança.
function git(cwd, args) {
  try {
    return execFileSync('git', args, {
      cwd,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
      timeout: 15000,
    });
  } catch (_) {
    return '';
  }
}

// git que precisa do código de saída (commit pode falhar por pre-commit hook).
// Retorna true se exit 0. Nunca lança.
function gitOk(cwd, args) {
  try {
    execFileSync('git', args, {
      cwd,
      encoding: 'utf8',
      stdio: ['ignore', 'ignore', 'ignore'],
      timeout: 60000,
    });
    return true;
  } catch (_) {
    return false;
  }
}

function isGitRepo(cwd) {
  return git(cwd, ['rev-parse', '--is-inside-work-tree']).trim() === 'true';
}

function currentBranch(cwd) {
  return git(cwd, ['rev-parse', '--abbrev-ref', 'HEAD']).trim();
}

function hasChanges(cwd) {
  // --porcelain lista staged + unstaged + untracked. Não-vazio = há o que commitar.
  return git(cwd, ['status', '--porcelain']).trim().length > 0;
}

// Deriva um tipo de Conventional Commits a partir dos paths mexidos. Heurística
// barata e honesta: na dúvida, "chore". Não inventa escopo nem descrição rica —
// um commit-WIP curto que o usuário refina depois com /dev-ship ou squash.
function inferType(cwd) {
  const out = git(cwd, ['status', '--porcelain']).trim();
  const paths = out
    .split('\n')
    .map(line => line.slice(3).trim()) // tira o XY + espaço do --porcelain
    .filter(Boolean);

  const isAll = (re) => paths.length > 0 && paths.every(p => re.test(p));
  const isAny = (re) => paths.some(p => re.test(p));

  if (isAll(/(^|\/)(test|tests|__tests__|spec)(\/|$)|\.(test|spec)\.[a-z]+$/i)) return 'test';
  if (isAll(/\.(md|mdx|txt)$|(^|\/)docs(\/|$)/i)) return 'docs';
  if (isAll(/(package(-lock)?\.json|pnpm-lock\.yaml|yarn\.lock|\.gitignore|\.env\.example|tsconfig.*\.json|\.github\/)/i)) return 'chore';
  if (isAny(/(^|\/)(src|lib|app|components|pages|routes|api)(\/|$)/i)) return 'feat';
  return 'chore';
}

function commitMessage(cwd) {
  const type = inferType(cwd);
  const count = git(cwd, ['status', '--porcelain']).trim().split('\n').filter(Boolean).length;
  const noun = count === 1 ? '1 arquivo' : `${count} arquivos`;
  // Conventional Commits, subject ≤ 50 chars, marcado [auto] p/ achar/squashar.
  return `${type}: auto-commit — ${noun} [auto]`;
}

function main() {
  // 1. Opt-in. Sem a env var, o hook não faz nada (instalar ≠ ativar).
  if (!envOn('CRUCIBLE_AUTOCOMMIT')) process.exit(0);

  // 2. Parse do payload + guarda anti-loop.
  let data = {};
  try {
    const raw = readStdin();
    if (raw.trim()) data = JSON.parse(raw);
  } catch (_) {
    data = {};
  }
  if (data && data.stop_hook_active === true) process.exit(0);

  const cwd =
    data && typeof data.cwd === 'string' && data.cwd.trim()
      ? data.cwd
      : process.cwd();

  // 3. Tem que ser um repo git de verdade.
  if (!isGitRepo(cwd)) process.exit(0);

  // 4. Recusa branch default sem override explícito.
  const branch = currentBranch(cwd);
  const isDefaultBranch = branch === 'main' || branch === 'master';
  if (isDefaultBranch && !envOn('CRUCIBLE_AUTOCOMMIT_ALLOW_MAIN')) process.exit(0);

  // Branch detached (rebase/merge/bisect em curso) → não mexe.
  if (!branch || branch === 'HEAD') process.exit(0);

  // 5. Só commita se há mudanças.
  if (!hasChanges(cwd)) process.exit(0);

  // 6. Stage tudo. Falhou? Sai limpo (não bloqueia).
  if (!gitOk(cwd, ['add', '-A'])) process.exit(0);

  // 7. Commit. --no-verify só com opt-in adicional explícito (desencorajado).
  const args = ['commit', '-m', commitMessage(cwd)];
  if (envOn('CRUCIBLE_AUTOCOMMIT_NO_VERIFY')) args.push('--no-verify');
  gitOk(cwd, args); // sucesso ou falha (ex.: pre-commit barrou) → segue.

  // NUNCA push. Fim. Exit 0 sempre.
  process.exit(0);
}

try {
  main();
} catch (_) {
  // Rede de segurança final — non-blocking sempre.
  process.exit(0);
}
