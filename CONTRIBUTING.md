# Contribuir com o solodev v2

Obrigado pelo interesse. O solodev v2 é um pacote de **skills do Claude Code** — Markdown com frontmatter YAML, sem build, sem runtime. Contribuir é editar texto e rodar um validador.

## Layout

```
solodev-v2/
├── skills/<nome>/SKILL.md      # corpo da skill (o que o agente carrega)
│   └── *-TEMPLATE.md           # esqueletos citados pela skill (BRIEF/PLAN/CONTEXT)
├── .claude-plugin/             # manifests do plugin (plugin.json, marketplace.json)
├── install.sh / install.ps1    # instaladores cross-platform
├── examples/                   # exemplo end-to-end (BRIEF → PLAN → SUMMARY)
├── scripts/validate.mjs        # validador de integridade (sem dependências)
└── README.md / README.en.md    # porta de entrada (PT / EN)
```

**Fonte única de verdade:** cada comportamento vive em um único `SKILL.md`. Não duplique conteúdo entre skills — referencie.

## Adicionar uma skill

1. Crie `skills/<nome>/SKILL.md` com frontmatter `name:` (igual ao diretório) e `description:` rica em gatilhos.
2. Se a skill produz um documento, adicione um `<NOME>-TEMPLATE.md` ao lado e linke no corpo.
3. Registre a skill nas superfícies: `install.sh`, `install.ps1`, a tabela do `README.md` e do `README.en.md`, e o `INSTALL.md`.
4. Rode o validador (abaixo). Ele falha se alguma superfície esquecer a skill nova.
5. Registre a mudança no `CHANGELOG.md`.

## Validar

```bash
node scripts/validate.mjs
```

Checa: frontmatter de cada skill (`name`/`description`), templates referenciados existem, JSON dos manifests válido e coerente, e que **toda skill** aparece nos instaladores e nos READMEs. O mesmo comando roda no CI (`.github/workflows/validate.yml`) a cada push/PR.

## Estilo

- **PT-BR**, terse, opinativo — a voz das skills existentes é o padrão.
- Princípios Karpathy: nunca assumir em silêncio, cirurgia não reforma, mínimo necessário, critério verificável > prosa.
- **Nada de números/benchmarks inventados.** A suíte é metodologia.
- Markdown que renderiza no GitHub: tabelas, listas de anti-padrões com ❌, frases curtas.

## Licença

Ao contribuir, você concorda em licenciar sua contribuição sob a [MIT](LICENSE), preservando os créditos ao [solodev original](https://github.com/calneymgp/solodev).
