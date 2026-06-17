<!--
.github/PULL_REQUEST_TEMPLATE.md
O GitHub preenche o corpo do PR com este texto automaticamente.
Não precisa apagar os comentários — eles não aparecem no PR renderizado.
Se você usa `/dev-ship`, ele já preenche título e descrição com `gh pr create --fill`.
-->

## O que muda

<!-- 1-3 frases. O que este PR faz e por quê. -->

## Como testar

<!-- Os passos pra alguém (ou você mesmo amanhã) confirmar que funciona. -->

1.
2.

## Checklist

- [ ] O CI passou (lint + typecheck + unit verdes)
- [ ] Testei o caminho feliz na mão
- [ ] Não tem segredo/chave commitado (`.env*` fora do git)
- [ ] Atualizei doc/README se mudei comportamento visível

## Passo do roadmap

<!-- Se este PR fecha um passo do ROADMAP.md, qual? Ex.: passo 03 — auth -->
