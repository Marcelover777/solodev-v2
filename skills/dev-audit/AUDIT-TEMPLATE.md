# AUDIT.md Template (diagnóstico de projeto existente)

Salvar em `.forge/AUDIT-<YYYY-MM-DD>.md` — **um arquivo por auditoria**, nunca sobrescreve. Um pointer curto `.forge/AUDIT.md` aponta o último run. Read-only: o `/dev-audit` só lê o projeto e escreve aqui. Toda nota sai de sinal real; sem sinal → `⏭️ não-avaliado (motivo)`, nunca `✅` presumido nem `❌` fora de fase.

---

```markdown
# AUDIT — <projeto> (<YYYY-MM-DD>)

> Gerado por `/dev-audit`. Tipo: <arquétipo via /dev-stack> · Fase: <inicial|em-andamento|maduro> · Stack: ./STACK.md
> Read-only. Notas: ✅ ok · ⚠️ aviso · ❌ bloqueia · ⏭️ não-avaliado/não-devido · 🔍 leitura subjetiva (ancorada).

## Placar

| Dimensão | Nota | Resumo (verificável / âncora arquivo:linha) |
|----------|------|---------------------------------------------|
| Config / Setup  | ⚠️   | `.env.local` rastreado no git (`git ls-files .env.local`) |
| Arquitetura     | 🔍⚠️ | `src/api.ts:1-800` concentra 12 rotas (deus-módulo) |
| Segurança       | ❌   | segredo no histórico (`git log --all -- .env` → commits) |
| Saúde de deps   | ⏭️   | não-avaliado: `osv-scanner` ausente → instalar: <link> |
| Testes          | ⚠️   | suíte verde, 0 testes de borda em `src/auth` |
| DX              | ✅   | `build`/`test`/`lint` presentes; CI em `.github/workflows` |
| Performance     | ⏭️   | API sem URL — Lighthouse não aplicável |
| Criativo / UI-UX| 🔍⚠️ | `app/dashboard/page.tsx:40` — densidade alta, sem hierarquia |
| Observabilidade | ⏭️   | fase inicial — ainda não devido |

## Achados priorizados (severidade × esforço)

### [CRÍTICO] Segredo no histórico do git
- **Evidência:** `git log --all -- .env` retorna commits (NÃO ecoo o valor).
- **Por que importa:** chave viva exposta no histórico; `git rm` simples não remove (irreversível por delete).
- **Remédio:** rotacionar a chave no serviço + remover do histórico → **RED** (destrutivo, exige segundo CHECKPOINT).
- **Item:** B-001 (semeado, gated RED).

### [ALTO] `.env.local` rastreado
- **Evidência:** `git ls-files .env.local` → presente.
- **Por que importa:** o `.gitignore` não cobre; risco de commit acidental de segredo.
- **Remédio:** adicionar ao `.gitignore` + `git rm --cached .env.local`.
- **Item:** B-002.

### [MÉDIO] Deus-módulo em `src/api.ts`
- **Evidência (🔍):** `src/api.ts:1-800` — 12 rotas num arquivo só.
- **Por que importa:** dificulta teste e mudança isolada.
- **Remédio:** extrair por recurso. **Item:** B-003 (`debt`).

## Resumo p/ o backlog

<N> itens semeados em `.forge/BACKLOG.md` (após CHECKPOINT): <lista de B-NNN>. P0: <quais>.
```

---

## Notas para quem escreve o AUDIT

- **Versiona por data.** Nunca sobrescreve `AUDIT.md`; o pointer aponta o último run, e os runs antigos mostram a evolução.
- **`⏭️` é resposta legítima.** Ferramenta ausente / dimensão não-devida na fase → `⏭️ (motivo)`, nunca `✅` nem `❌`.
- **Achado subjetivo precisa de âncora.** Arquitetura/UI levam `🔍` + `arquivo:linha` (ou componente). Sem âncora, não escreve.
- **Nunca o valor do segredo.** Só `arquivo:linha` / o comando que prova — re-vazar a chave num doc commitado é o erro a evitar.
- **Por que importa, sempre.** Cada achado diz o impacto, não só "está errado".
- **Aceite = inverso verificável.** O item de backlog que sai daqui tem um critério grep/test/build (o que prova que foi resolvido).
