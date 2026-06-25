# PROGRESS.md Template (journal append-only)

Salvar em `.forge/PROGRESS.md` na raiz do projeto do usuário. É o **journal**: a memória entre sessões, escrita pelo `/dev-next` (e pelo `/dev-loop`) a cada passo/item que fecha verde. **Append-only** — nunca reescreva blocos antigos; o histórico é a verdade que uma sessão nova herda sem você reexplicar nada.

Lido por `/dev-status jornada` (resumo narrativo) e por qualquer skill que precise saber "o que já andou".

---

```markdown
# PROGRESS — <Nome do projeto>

> Journal append-only. Cada bloco = um passo/item que fechou verde. Mais recente embaixo.
> Escrito por `/dev-next` e `/dev-loop`. Nunca reescrever — só adicionar.

## YYYY-MM-DD HH:MM — passo 03: Login (auth)
- **O que mudou:** schema users + rota /auth + tela de login funcionando
- **Arquivos:** src/auth/*.ts, src/app/login/page.tsx, supabase/migrations/0002_users.sql
- **Verificação:** must_pass 3/3 verde, npm test auth passou
- **Próximo:** executa o passo 04

## YYYY-MM-DD HH:MM — B-007: corrige login Google no mobile
- **O que mudou:** redirect URI mobile corrigido
- **Arquivos:** src/auth/google.ts
- **Verificação:** npm test auth verde
- **Origem:** .forge/BACKLOG.md (item não-planejado)
- **Próximo:** /dev-next
```

---

## Campos fixos (todo bloco)

| Campo | Conteúdo |
|-------|----------|
| **cabeçalho** | `## YYYY-MM-DD HH:MM — <passo 0X \| B-NNN>: <título>` |
| **O que mudou** | 1 linha — o resultado observável, não a lista de tool calls |
| **Arquivos** | lista curta dos arquivos tocados |
| **Verificação** | o `must_pass`/teste que provou que fechou (sem isso não é "done") |
| **Próximo** | o próximo passo/comando |

## Regras

- **Append-only.** Adicione embaixo. Nunca edite nem apague bloco anterior — é journal, não estado mutável.
- **Só após verde.** Um bloco entra quando a verificação passou de verdade. Falha vira bloqueio anotado, não um "done".
- **Datado e ordenado.** Mais recente no fim. O `/dev-status jornada` costura os blocos numa história.
- **Rotação (quando crescer):** acima de ~12 blocos, mova os mais antigos para `.forge/PROGRESS.archive.md` (append, por mês) — **ação explícita** (groom do `/dev-loop` ou a pedido), nunca efeito colateral silencioso de uma leitura.
- **Sem token-economics.** Não há DB; isto é narrativa de progresso, não contabilidade de custo.
