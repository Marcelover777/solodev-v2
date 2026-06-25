# Contribuir com o Forger

Obrigado pelo interesse. O Forger é um pacote de **skills do Claude Code** — Markdown com frontmatter YAML, sem build, sem runtime. Contribuir é editar texto e rodar um validador.

## As duas camadas

O v3 tem **15 skills em duas camadas**. Entenda em qual você mexe antes de abrir PR:

- **Onboarding (zero-fricção, do leigo ao deploy):** `dev-start` (porta de entrada guiada), `dev-stack` (advisor de infra/conectores), `dev-design` (estética), `dev-setup` (chaves/`.env`), `dev-roadmap` (lista numerada de passos), `dev-next` (executa o passo 0X), `dev-status` (painel de estado), `dev-ops` (git/GitHub no automático).
- **Ciclo de engenharia (uma feature por vez, herdado do v2):** `dev-context`, `dev-brainstorm`, `dev-plan`, `dev-coding`, `dev-fix`, `dev-ship`.
- **Referência:** `dev-help`.

O verbo único do usuário final é **"executa o passo 0X"** (`/dev-next`); o iniciante começa por `/dev-start`. A camada de onboarding **encadeia escrevendo arquivos** e delega ao ciclo — não reimplementa o motor de execução. Mantenha essa composição: skill nova de onboarding orquestra, não duplica.

## Layout

```
forger/
├── skills/<nome>/SKILL.md      # corpo da skill (o que o agente carrega)
│   └── *-TEMPLATE.md           # esqueletos citados pela skill (BRIEF/PLAN/STACK/STEP…)
├── src/hooks/                  # hooks opt-in de continuidade e git (file-based)
├── .claude-plugin/             # manifests do plugin (plugin.json, marketplace.json)
├── install.sh / install.ps1    # instaladores cross-platform
├── examples/                   # exemplo end-to-end do fluxo v3
├── scripts/validate.mjs        # validador de integridade (sem dependências)
└── README.md / README.en.md    # porta de entrada (PT / EN)
```

**Fonte única de verdade:** cada comportamento vive em um único `SKILL.md`. Não duplique conteúdo entre skills — referencie.

## `.forge/` é do projeto do USUÁRIO, não deste repo

O v3 dá ao projeto do usuário **memória entre sessões**, file-based, numa pasta `.forge/` na raiz **dele**:

- `.forge/PROGRESS.md` — journal append-only (o que mudou, arquivos tocados, próximo passo);
- `.forge/STATUS.md` — painel de estado escrito pelo `/dev-status`.

Essa pasta é gerada pelas skills no repositório de quem usa o Forger. **Nunca commite uma pasta `.forge/` neste repo da ferramenta** — ela só existe nos projetos finais. Separe-a mentalmente de `.plans/` (planos de feature) e de `CONTEXT.md` (vocabulário). Sem worker, DB ou porta: tudo é leitura/append de arquivo Markdown.

## Hooks (`src/hooks/`, opt-in)

Dois hooks de Claude Code, **CommonJS**, **silent-fail** em qualquer erro de filesystem, respeitam `CLAUDE_CONFIG_DIR`, e **não** sobem worker/DB/porta:

- `forger-session-start.js` (`SessionStart`) — injeta `.forge/PROGRESS.md` como contexto ao abrir a sessão. Só lê; inofensivo.
- `forger-autocommit.js` (`Stop`) — auto-commit Conventional Commits. **Opt-in de verdade:** instalar não ativa, precisa da env var `FORGER_AUTOCOMMIT`. Nunca faz `push`, recusa `main`/`master` sem flag explícita.

Ao mexer em hook: mantenha silent-fail, respeite `CLAUDE_CONFIG_DIR`, **nunca** push silencioso, e documente qualquer env var nova em `src/hooks/README.md`.

## Adicionar uma skill

1. Crie `skills/<nome>/SKILL.md` com frontmatter `name:` (igual ao diretório) e `description:` rica em gatilhos PT-BR.
2. Se a skill produz um documento, adicione um `<NOME>-TEMPLATE.md` ao lado e linke no corpo.
3. **Registre a skill em TODAS as superfícies**, senão o validador falha:
   - `install.sh` (array `SKILLS`)
   - `install.ps1` (array `$Skills`)
   - tabela do `README.md`
   - tabela do `README.en.md`
   - listas do `INSTALL.md` (verificar **e** desinstalar)
4. Se for skill de onboarding, posicione-a na camada certa do `README`/`dev-help` (orquestra, não duplica o ciclo).
5. Rode o validador (abaixo). Ele falha se qualquer superfície esquecer a skill nova.
6. Registre a mudança no `CHANGELOG.md`.

## Validar

```bash
node scripts/validate.mjs
```

Checa: frontmatter de cada skill (`name` == diretório / `description` ≥ 20 chars), templates `*-TEMPLATE.md` referenciados existem, JSON dos manifests válido e coerente, e que **toda skill** aparece em `install.sh`, `install.ps1`, `README.md` e `README.en.md`. **Esqueceu de registrar uma skill numa superfície → o validador quebra** (e o mesmo comando roda no CI a cada push/PR via `.github/workflows/validate.yml`). O `INSTALL.md` e o `CHANGELOG.md` não são cobertos pelo grep do validador — confira-os à mão.

## Estilo

- **PT-BR**, terse, opinativo — a voz das skills existentes é o padrão ("Plan > Vibes").
- Princípios Karpathy: nunca assumir em silêncio, cirurgia não reforma, mínimo necessário, critério verificável > prosa.
- **Nada de números/benchmarks inventados.** `/dev-stack` e `/dev-setup` **linkam a pricing oficial**, nunca cravam preço ou limite de free-tier.
- Não assumir Next.js fora do fluxo do `/dev-stack`.
- Markdown que renderiza no GitHub: tabelas, listas de anti-padrões com ❌, frases curtas.

## Licença

Ao contribuir, você concorda em licenciar sua contribuição sob a [MIT](LICENSE), preservando os créditos ao [solodev original](https://github.com/calneymgp/solodev).
