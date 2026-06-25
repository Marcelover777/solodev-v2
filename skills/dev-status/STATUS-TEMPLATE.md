# STATUS.md Template

Salvar em `.crucible/STATUS.md` (na raiz do projeto do usuário). Sobrescrito a cada `/dev-status`. Reflete só o que arquivo real sustenta — célula sem fonte é `❓ sem dado`, nunca um valor inventado.

---

```markdown
# STATUS — <Nome do projeto>

> Gerado por `/dev-status` em <YYYY-MM-DD HH:MM>. Fonte: ROADMAP.md, .plans/*/PLAN.md, git, must_pass.

## Progresso

**<NN>% — <feitos>/<total> passos** (do `ROADMAP.md`)

| Feature (.plans/<feature>) | Tasks done | Status |
|----------------------------|------------|--------|
| <feature-1>                | <m>/<n>    | in-progress |
| <feature-2>                | <m>/<n>    | done |

<!-- omitir a linha da feature que não tem PLAN.md — não estimar -->

## Qualidade

| Parte | Estado | Bloqueia? | Como foi medido |
|-------|--------|-----------|-----------------|
| build     | ✅ / ⚠️ / ❌ / ❓ sem dado | `❌` sim | `<comando de build>` |
| test      | ✅ / ⚠️ / ❌ / ❓ sem dado | `❌` sim | `<comando de teste unit>` |
| test:e2e  | ✅ / ⚠️ / ❌ / ❓ sem dado | `❌` sim (se existe) | `<comando e2e/integração>` |
| lint      | ✅ / ⚠️ / ❌ / ❓ sem dado | não | `<comando de lint>` |
| security  | ✅ / ⚠️ / ❌ / ❓ sem dado | `❌` sim | audit de deps + `.env*` no `.gitignore` |

## Erros (onde estão)

<!-- só as partes ⚠️/❌; cada uma com endereço, não só veredito -->

- `<arquivo>:<linha>` — `<comando que falhou>` — <1 linha do erro>
- `<arquivo>:<linha>` — `<comando que falhou>` — <1 linha do erro>

<!-- se tudo verde: -->
Nenhum erro nas partes medidas.

## Blockers

<!-- o que impede avançar AGORA; "Nenhum" se não há -->

- 🔒 **Passo 0X bloqueado** — falta `<CHAVE_ENV>`. Resolva pelo `SETUP.md` e rode de novo.
- ❌ **build falhando** — bloqueia o passo 0X até corrigir (ver Erros).
- ⛓️ **task-XX espera task-YY** (`depends_on` não satisfeito).

<!-- ou: -->
Nenhum.

## Mudanças pendentes (git)

- <N> arquivo(s) modificado(s), <M> não rastreado(s) (de `git status`)
- Último commit: `<hash>` <mensagem em 1 linha>

## Próximo passo

> <A recomendação que encaixa: `executa o passo 0X` se desbloqueado · `/dev-fix` se há `❌` · resolver o gate do `SETUP.md` se travado.>
```

---

## Notas para quem escreve o STATUS

- **Número sai de contagem, não de sensação.** `<feitos>/<total>` vem de contar `- [x]` vs `- [ ]` no `ROADMAP.md`. Arredonde o % pra baixo.
- **❓ sem dado é resposta válida.** Comando inexistente ou não rodado → `❓`, nunca `✅` presumido.
- **Erro precisa de endereço.** `arquivo:linha` + comando + 1 linha. Sem isso o painel não orienta o fix.
- **Security em prosa quando é sério.** Segredo commitado ou `.env.local` rastreado → frase clara com arquivo, risco e remediação, fora da tabela.
- **Sem token-economics.** Este painel não tem custo/token — Crucible é file-based, não há DB pra contar.
