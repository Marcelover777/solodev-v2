#!/usr/bin/env node
// solodev — Claude Code SessionStart hook (continuidade entre sessões).
//
// O que faz: se existir `.solodev/PROGRESS.md` na raiz do projeto (cwd da
// sessão), imprime o conteúdo como contexto de sessão. É a reimplementação
// file-based da ideia "capturar → injetar memória" do claude-mem (Phase 0.1 do
// PLAN): UM hook que faz `cat` de um arquivo Markdown — sem worker, sem DB, sem
// porta de rede. O journal `PROGRESS.md` é escrito por `/dev-next`; este hook
// só o LÊ.
//
// Princípios (não-negociáveis):
//   - silent-fail em QUALQUER erro de filesystem — nunca bloqueia o início da
//     sessão (no pior caso: saída vazia + exit 0);
//   - respeita CLAUDE_CONFIG_DIR (a leitura do journal é relativa ao cwd do
//     projeto; o env var é honrado para qualquer caminho de config global que
//     venha a ser usado);
//   - CommonJS puro (o package.json desta pasta fixa "type":"commonjs");
//   - sem worker, sem DB, sem porta, sem processo de background.
//
// Contrato Claude Code (stdin → stdout):
//   stdin  : JSON { session_id, transcript_path, cwd, hook_event_name,
//                   source: "startup"|"resume"|"clear"|"compact", model? }
//   stdout : texto puro vira contexto de sessão (modo mais simples do contrato).
//            Saída vazia = nenhum contexto injetado.

const fs = require('fs');
const path = require('path');

// Cap de leitura: o journal é Markdown legível de 1 pessoa, não um log de
// firehose. Se passar disso, injetamos a CAUDA (blocos mais recentes) —
// append-only põe o estado atual no fim, e estado atual > história antiga.
const MAX_INJECT_BYTES = 32 * 1024; // 32 KB

function readStdin() {
  try {
    // fd 0 = stdin. Leitura síncrona evita corrida com process.exit.
    return fs.readFileSync(0, 'utf8');
  } catch (_) {
    return '';
  }
}

function resolveProjectDir(data) {
  // Fonte canônica do diretório do projeto: o campo `cwd` do payload.
  // Fallback para process.cwd() se o payload não trouxer.
  if (data && typeof data.cwd === 'string' && data.cwd.trim()) {
    return data.cwd;
  }
  return process.cwd();
}

// Leitura defensiva do journal:
//   - recusa symlink no caminho do arquivo (vetor de clobber/exfil);
//   - limita o tamanho injetado, mantendo a CAUDA (blocos mais recentes).
function readProgress(progressPath) {
  let st;
  try {
    st = fs.lstatSync(progressPath);
  } catch (_) {
    return ''; // não existe → projeto sem journal ainda; silencioso.
  }
  if (st.isSymbolicLink() || !st.isFile()) return '';

  let content;
  try {
    content = fs.readFileSync(progressPath, 'utf8');
  } catch (_) {
    return '';
  }

  if (Buffer.byteLength(content, 'utf8') <= MAX_INJECT_BYTES) return content;

  // Trunca pela cauda: preserva o estado recente (journal append-only).
  const buf = Buffer.from(content, 'utf8');
  let tail = buf.slice(buf.length - MAX_INJECT_BYTES).toString('utf8');
  // Recomeça num limite de bloco (`\n## `) para não cortar no meio de um.
  const firstBlock = tail.indexOf('\n## ');
  if (firstBlock !== -1) tail = tail.slice(firstBlock + 1);
  return '…(journal truncado; mostrando blocos mais recentes)…\n\n' + tail;
}

function main() {
  let data = {};
  try {
    const raw = readStdin();
    if (raw.trim()) data = JSON.parse(raw);
  } catch (_) {
    data = {}; // payload ausente/inválido → segue com fallback de cwd.
  }

  const projectDir = resolveProjectDir(data);
  const progressPath = path.join(projectDir, '.solodev', 'PROGRESS.md');

  const journal = readProgress(progressPath);
  if (!journal.trim()) {
    // Sem journal → não injeta nada. Saída vazia, exit 0.
    process.exit(0);
  }

  const header =
    'CONTINUIDADE solodev — memória do projeto (.solodev/PROGRESS.md).\n' +
    'É o journal append-only do que já foi feito. Use para retomar SEM pedir ao ' +
    'usuário reexplicar. O próximo passo costuma estar no último bloco.\n' +
    '────────────────────────────────────────\n\n';

  try {
    process.stdout.write(header + journal.trim() + '\n');
  } catch (_) {
    // Silent fail — nunca bloqueia o início da sessão.
  }
  process.exit(0);
}

try {
  main();
} catch (_) {
  // Rede de segurança final: qualquer erro inesperado → saída limpa.
  process.exit(0);
}
