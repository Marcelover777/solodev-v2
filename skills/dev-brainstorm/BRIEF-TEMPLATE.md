# BRIEF Template

Salvar em `.plans/<feature-slug>/BRIEF.md`. Atualizar ao vivo durante o grilling.

---

```markdown
---
feature: <kebab-case-slug>
size: S | M | L
status: brainstorming | ready-for-plan
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
---

# BRIEF — <Feature Title>

## Problema
<3-5 linhas. Qual dor real, na perspectiva de quem sente. Sem solução aqui.>

## Solução (high-level)
<1-2 frases. O que queremos que exista depois disso, ainda do ponto de vista do usuário.>

## Goals (comportamentos observáveis)
- <Algo que vai estar verdadeiro depois — observável de fora>
- <Outro algo verificável>

## Non-Goals (out of scope agora)
- <O que explicitamente NÃO está incluso nesta iteração>
- <Risco comum de scope creep que estamos cortando>

## Constraints
- **Stack:** <restrições técnicas relevantes>
- **Performance:** <SLAs, latência, throughput se importam>
- **Compliance:** <LGPD, segurança, auditoria se aplica>
- **Prazo:** <se houver>

## Produto (se tem UI / usuário final)
- **Estado vazio:** <o que aparece antes de existir dado>
- **Estado de erro:** <o que o usuário vê quando falha>
- **Loading:** <se a operação demora, o que segura a percepção>
- **Permissões:** <quem NÃO pode ver/fazer isso>

## Glossário (termos do domínio)
- **<Termo>:** <definição precisa neste contexto>

> Se o projeto tem CONTEXT.md ou glossário canônico, citar aqui em vez de redefinir.

## Decisões tomadas no grilling
- **<Decisão 1>** — <1 linha do porquê>
- **<Decisão 2>** — <1 linha do porquê>

## Open Questions (precisam de resposta antes do plano)
- **Q1:** <pergunta> — *proposed:* <resposta sugerida>
- **Q2:** <pergunta> — *needs:* <user / discovery / código>

## Edge cases descobertos
- <cenário> → <comportamento decidido>

## Risk Radar (top-3 "isso vai te morder")
1. **<risco>** — mitigação: <1 linha>
2. **<risco>** — mitigação: <1 linha>
3. **<risco>** — mitigação: <1 linha>
```
