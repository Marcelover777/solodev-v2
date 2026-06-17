# DESIGN.md — <nome do projeto>

> Fonte de verdade da camada visual. O `/dev-coding` lê isto antes de criar qualquer tela ou componente — reusa o que está aqui antes de inventar. Atualize quando trocar tema, adicionar componente ou mudar convenção. Escrito por `/dev-design`.

- **Arquétipo:** <web full-stack | site/SPA | API (sem UI) | jobs | IA c/ front | realtime c/ front> — (do `STACK.md`)
- **Framework de UI:** <Next.js + React | Vite + React | … | n/a> — (do `STACK.md`, não re-escolhido aqui)
- **Tom (do BRIEF):** <ex.: profissional, denso, dark-first> — público: <consumidor | profissional | interno>
- **Data:** <YYYY-MM-DD>

---

## 1. Stack visual (o quê + por quê)

| Peça | Escolha | Por quê (1 linha) |
|------|---------|-------------------|
| Utilitário CSS | <Tailwind v4> | <classes utilitárias, zero-config> |
| Componentes | <shadcn/ui \| daisyUI> | <copiados pro projeto, editáveis \| atalho rápido> |
| Tema | <nome do tema tweakcn> | <faz parecer desenhado, não default> |
| Dashboards (se houver) | <Tremor \| —> | <KPIs/gráficos prontos> |

> Componentes shadcn/ui vivem **dentro** do projeto (`components/ui/`) — são seus, dá pra editar. Não é dependência fechada no `node_modules`.

---

## 2. Tema e tokens

- **Tema:** <nome> — origem: <https://tweakcn.com → tema X> (galeria muda; reconfira o comando de registry na hora)
- **Modo:** <claro | escuro | os dois (toggle)>

### Tokens (preencher com os valores reais do tema aplicado)

| Token | Valor | Uso |
|-------|-------|-----|
| `--primary` | <ex.: oklch(...)> | ação principal, links |
| `--secondary` | <...> | ação secundária |
| `--background` / `--foreground` | <...> / <...> | base da página |
| `--muted` / `--muted-foreground` | <...> / <...> | texto/áreas secundárias |
| `--destructive` | <...> | ações perigosas |
| `--radius` | <ex.: 0.5rem> | arredondamento global |
| Fonte (sans) | <ex.: Inter> | corpo |
| Fonte (mono) | <ex.: JetBrains Mono \| —> | código/números |
| Escala de espaçamento | <ex.: padrão Tailwind (4px)> | ritmo do layout |

> Os valores reais ficam no CSS do projeto (ex.: `app/globals.css` em `:root` / `.dark`). Esta tabela é o índice legível — a fonte canônica é o CSS gerado pelo tema.

---

## 3. Componentes instalados

O que já foi adicionado via `npx shadcn@latest add ...` (reuse antes de criar um novo):

- [ ] `button`
- [ ] `card`
- [ ] `input`
- [ ] `dialog`
- [ ] <outro> …

Local: `<components/ui/>`. Para adicionar mais: `npx shadcn@latest add <nome>` (confira o nome na doc — https://ui.shadcn.com).

---

## 4. Convenções

- **Onde vivem os componentes:** primitivos em `<components/ui/>`; compostos do produto em `<components/>`.
- **Nomeação:** <ex.: PascalCase para componente, kebab-case para arquivo>.
- **Reuso antes de criação:** precisa de um elemento? Procure aqui na lista da seção 3 primeiro. Só crie novo se não houver equivalente.
- **Estados obrigatórios por tela:** loading, vazio (empty state), erro. (Especialmente em arquétipo realtime/IA.)
- **Acessibilidade mínima:** contraste do tema ok, foco visível, alvo de toque ≥ 44px.
- **Responsividade:** mobile-first; breakpoints padrão do Tailwind.

---

## 5. Comandos de scaffold (copy-ready)

> **Voláteis** — rode com `@latest` e confira a doc oficial se algum reclamar. Não decore flags antigas.

```bash
npx create-next-app@latest          # só se o projeto ainda não existe
npx shadcn@latest init              # inicializa shadcn/ui
npx shadcn@latest add button card input dialog
# tema tweakcn: https://tweakcn.com → escolha → copie o "npx shadcn add <url-do-registry>"
npm i @tremor/react                 # só se tem dashboard
```

---

## 6. Notas / decisões descartadas

- <ex.: descartado daisyUI porque o usuário quer editar cada componente → shadcn.>
- <ex.: dark-first porque o público é dev.>

> Arquétipo sem front (API/jobs): preencha só o cabeçalho + esta seção dizendo "sem camada visual"; pule as seções 2-5. Se um dia ganhar painel, rode `/dev-design` de novo.
