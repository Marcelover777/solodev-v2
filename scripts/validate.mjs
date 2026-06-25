#!/usr/bin/env node
// Forger — validador de integridade do pacote.
//
// Roda sem dependências (só built-ins do Node). Falha (exit 1) se o pacote
// estiver inconsistente. É o "must_pass" do próprio repo: a suíte que prega
// critério verificável valida a si mesma.
//
//   node scripts/validate.mjs
//
import { readFileSync, readdirSync, existsSync, statSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const errors = [];
const fail = (msg) => errors.push(msg);

const read = (p) => readFileSync(join(ROOT, p), "utf8");
const has = (p) => existsSync(join(ROOT, p));

// --- 1. Descobre as skills (skills/<name>/SKILL.md) ------------------------
// Pastas prefixadas com '_' (ex.: _shared/) ou '.' são ASSETS compartilhados,
// não skills — ficam de fora da descoberta (sem SKILL.md, sem exigência de
// aparecer nas superfícies). É como _shared/ENV-VARS.md mora aqui sem virar skill.
const skillsDir = join(ROOT, "skills");
const skills = readdirSync(skillsDir).filter(
  (n) =>
    !n.startsWith("_") &&
    !n.startsWith(".") &&
    statSync(join(skillsDir, n)).isDirectory(),
);
if (skills.length === 0) fail("skills/: nenhuma skill encontrada");

// --- 2. Cada skill: SKILL.md com frontmatter name/description --------------
const parseFrontmatter = (txt) => {
  const m = txt.match(/^---\n([\s\S]*?)\n---/);
  if (!m) return null;
  const fm = {};
  for (const line of m[1].split("\n")) {
    const kv = line.match(/^([a-zA-Z_]+):\s*(.*)$/);
    if (kv) fm[kv[1]] = kv[2].trim();
  }
  return fm;
};

for (const skill of skills) {
  const skillMd = join("skills", skill, "SKILL.md");
  if (!has(skillMd)) {
    fail(`${skillMd}: ausente`);
    continue;
  }
  const txt = read(skillMd);
  const fm = parseFrontmatter(txt);
  if (!fm) {
    fail(`${skillMd}: sem frontmatter YAML (---)`);
    continue;
  }
  if (!fm.name) fail(`${skillMd}: frontmatter sem 'name'`);
  else if (fm.name !== skill)
    fail(`${skillMd}: name '${fm.name}' != diretório '${skill}'`);
  if (!fm.description || fm.description.length < 20)
    fail(`${skillMd}: 'description' ausente ou curta demais`);

  // Templates referenciados ([..](X-TEMPLATE.md)) devem existir.
  for (const ref of txt.matchAll(/\]\(([^)]*TEMPLATE\.md)\)/g)) {
    const tpl = join("skills", skill, ref[1]);
    if (!has(tpl)) fail(`${skillMd}: referencia template inexistente '${ref[1]}'`);
  }
}

// --- 3. Manifests do plugin (JSON válido + nomes coerentes) ----------------
let pluginName = null;
try {
  const plugin = JSON.parse(read(".claude-plugin/plugin.json"));
  pluginName = plugin.name;
  if (!plugin.name) fail("plugin.json: sem 'name'");
  if (!plugin.description) fail("plugin.json: sem 'description'");
} catch (e) {
  fail(`.claude-plugin/plugin.json: JSON inválido — ${e.message}`);
}
try {
  const mkt = JSON.parse(read(".claude-plugin/marketplace.json"));
  const names = (mkt.plugins || []).map((p) => p.name);
  if (pluginName && !names.includes(pluginName))
    fail(`marketplace.json: nenhum plugin com name '${pluginName}'`);
} catch (e) {
  fail(`.claude-plugin/marketplace.json: JSON inválido — ${e.message}`);
}

// --- 4. Toda skill é referenciada nos installers e nos READMEs --------------
const surfaces = {
  "install.sh": has("install.sh") ? read("install.sh") : (fail("install.sh: ausente"), ""),
  "install.ps1": has("install.ps1") ? read("install.ps1") : (fail("install.ps1: ausente"), ""),
  "README.md": has("README.md") ? read("README.md") : (fail("README.md: ausente"), ""),
  "README.en.md": has("README.en.md") ? read("README.en.md") : (fail("README.en.md: ausente"), ""),
};
for (const skill of skills) {
  for (const [file, content] of Object.entries(surfaces)) {
    if (content && !content.includes(skill))
      fail(`${file}: não menciona a skill '${skill}'`);
  }
}

// --- 5. Arquivos-âncora existem --------------------------------------------
for (const f of ["LICENSE", "INSTALL.md", "CHANGELOG.md", "README.md", "README.en.md"]) {
  if (!has(f)) fail(`${f}: ausente`);
}

// --- Resultado --------------------------------------------------------------
if (errors.length) {
  console.error(`\n✗ Forger — ${errors.length} problema(s):\n`);
  for (const e of errors) console.error(`  - ${e}`);
  process.exit(1);
}
console.log(`✓ Forger OK — ${skills.length} skills, manifests e docs coerentes.`);
