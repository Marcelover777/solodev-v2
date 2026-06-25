# 📋 BACKLOG — saas-starter

> Fila de trabalho NÃO-planejado: bugs, dívida, infra, chores, ideias, achados de auditoria.
> NÃO é o ROADMAP (feature planejada vive lá). Próximo item: `/dev-next`. Concluir: marca ✅ e registra no PROGRESS.

| ID    | Item                              | Tipo  | Origem       | Prio | Status    | Deps  | Gate        | Aceite (verificável)                          |
|-------|-----------------------------------|-------|--------------|------|-----------|-------|-------------|-----------------------------------------------|
| B-001 | `.env.local` rastreado no git     | infra | audit:sec-01 | P0   | ⛔ gate    | —     | GATE_ROTATE | `git ls-files .env.local` → vazio; chave nova |
| B-002 | Extrair `formatDate` duplicado    | debt  | passo-02     | P2   | ⬜ ready   | —     | —           | `grep -rn "function formatDate" src` → 1      |
| B-003 | Rate-limit no `/api/waitlist`     | idea  | manual       | P1   | 🧊 icebox  | B-004 | —           | (promover a passo do ROADMAP se aceito)       |
| B-004 | Provisionar Upstash Redis         | infra | manual       | P1   | ⛔ gate    | —     | GATE_REDIS  | `UPSTASH_REDIS_REST_URL` no `.env.local`      |

<!-- Concluídos (✅) migram para .forge/BACKLOG.archive.md — ação explícita, nunca side-effect de leitura. -->
