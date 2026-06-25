# TESTING.md — quando cada teste roda (e por quê)

Regra de ouro: **teste rápido roda sempre, teste lento roda raro.** Se tudo
rodasse a cada "salvar", você esperaria minutos a cada tecla. Então o Forger
escalona: o que é instantâneo roda o tempo todo, o que demora roda só nos
momentos que importam.

Esta política é a **mesma** que está no `.github/workflows/ci.yml`. Se você mudar
um, mude o outro — eles não podem divergir. O `/dev-coding` e o `/dev-next`
lêem este arquivo pra decidir o que rodar quando (e pra **não** rodar e2e a cada
passo do roadmap).

## A tabela

| Teste | O que é | Quando roda | Onde |
|-------|---------|-------------|------|
| **format** | arrumar espaçamento/aspas | ao salvar o arquivo | seu editor (on-save) |
| **lint** | pegar erro de estilo/código suspeito | ao salvar + a cada push | editor + CI |
| **typecheck** | conferir os tipos (TypeScript) | a cada push e PR | CI |
| **unit** | testar funções isoladas (rápido) | a cada push e PR | CI |
| **e2e / harness** | testar o app inteiro como um usuário (lento) | só em PR-pra-`main`, no botão "Run workflow", ou de madrugada (nightly) | CI |

## Por que e2e não roda a cada push

Teste end-to-end sobe o app de verdade, abre um navegador, clica em coisas.
Isso leva minutos e gasta os minutos gratuitos do CI. Rodar isso a cada commit
trava seu fluxo sem ganho — um bug de integração não muda 50 vezes por hora.
Então e2e roda quando o trabalho vai virar oficial (**PR pra `main`**), quando
você pede de propósito (**workflow_dispatch**, o botão "Run workflow" na aba
Actions), ou **uma vez por noite** (nightly), pra pegar regressão sem te atrasar.

## Onde ligar o on-save

Format e lint ao salvar são do seu **editor**, não do GitHub:

- **VS Code / Cursor:** `"editor.formatOnSave": true` + a extensão do seu
  formatter (Prettier, Biome, Ruff…).
- **Claude Code:** um hook `PostToolUse` pode rodar o formatter no arquivo que
  acabou de ser editado (opt-in — o `/dev-ops` configura se você pedir).

> Confira na hora os comandos/flags do seu formatter — eles variam por versão.
