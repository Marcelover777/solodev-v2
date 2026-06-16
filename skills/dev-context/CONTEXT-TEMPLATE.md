# CONTEXT.md Template

Salvar em `CONTEXT.md` na raiz do projeto (ou `docs/CONTEXT.md` se o projeto concentra docs lá). É a memória de vocabulário que `/dev-brainstorm`, `/dev-plan`, `/dev-coding` e `/dev-ship` citam. Curto e denso — atualizar quando a arquitetura ou o vocabulário mudam, não por feature.

---

```markdown
---
project: <kebab-case-slug>
status: living          # documento vivo — atualizar quando arquitetura/vocabulário mudam
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
---

# CONTEXT — <Project Name>

## One-liner
<1 frase. O que este projeto é, na perspectiva de quem usa — não o que ele faz tecnicamente.>

## Arquitetura (mapa módulo → responsabilidade)
<Para cada módulo/diretório-chave, 1 linha: por que ele existe e o que é dele. Só o que importa para entender onde as coisas vivem.>

| Módulo | Responsabilidade |
|--------|------------------|
| `<path/dir>` | <o que vive aqui, em 1 linha> |
| `<path/dir>` | <o que vive aqui, em 1 linha> |

## Glossário (termo → definição precisa)
<Só o vocabulário REAL do domínio com sentido específico neste projeto. Termo que significa o óbvio não entra.>

- **<Termo>:** <definição precisa neste contexto>
- **<Termo>:** <definição precisa neste contexto>

## Convenções (nomes / testes / erros / commits)
<1 linha por categoria. Se o CLAUDE.md já cobre, escreva "ver CLAUDE.md § X" em vez de repetir.>

- **Nomes:** <padrão de nomenclatura de arquivos/funções/branches>
- **Testes:** <onde ficam, como nomeiam, o que se testa>
- **Erros:** <como o projeto trata/propaga/loga erro>
- **Commits:** <Conventional Commits? formato de mensagem? ver CLAUDE.md § X se aplicável>

## Invariantes (nunca faça X)
<Regras "nunca" do negócio/arquitetura, verificáveis — não "código limpo". O que quebra o sistema ou o domínio se violado.>

- **Nunca** <regra verificável — ex.: deletar `orders` direto; sempre soft-delete via `OrderService`>
- **Nunca** <regra verificável>

## Comandos (build / test / lint / run / deploy)
<Os comandos reais do projeto. Se já estão no CLAUDE.md, cite e não duplique.>

- **Build:** `<comando>`
- **Test:** `<comando>`
- **Lint:** `<comando>`
- **Run (dev):** `<comando>`
- **Deploy:** `<comando ou ver CLAUDE.md § Deploy>`

## Boundaries externos (DBs / APIs / filas)
<Com quem o sistema fala do lado de fora. 1 linha por boundary: o quê, para quê.>

- **<DB / serviço / API / fila>** — <para que serve; como o projeto fala com ele>
- **<DB / serviço / API / fila>** — <para que serve; como o projeto fala com ele>
```
