---
name: dev-fix
description: Loop de diagnóstico disciplinado para bugs — sem PLAN.md, direto ao ponto. Constrói feedback loop reproduzível primeiro, ranqueia hipóteses falsificáveis, instrumenta um probe por hipótese, corrige com teste de regressão e limpa os rastros. Tem modo rápido para bug trivial. Use quando o usuário disser "/dev-fix", "tem um bug", "está quebrado", "parou de funcionar", "dá esse erro", colar um stack trace, ou quando um checkpoint:human-verify do /dev-coding for reprovado.
---

# /dev-fix — Bug morre com método, não com tentativa

Bugfix não precisa de BRIEF nem PLAN. Precisa de **disciplina de diagnóstico** — a diferença entre 10 minutos e 3 horas é quase sempre a qualidade do feedback loop, não a dificuldade do bug.

## Triagem (primeiro turn)

Classifique em 1 linha e siga o caminho:

| Classe | Heurística | Caminho |
|--------|-----------|---------|
| **Trivial** | Causa evidente no erro (typo, import, null óbvio), fix de 1-5 linhas | **Modo rápido** ↓ |
| **Real** | Causa não evidente, comportamento intermitente, "funcionava ontem" | **Loop completo** ↓ |
| **Arquitetural** | O fix exigiria redesenho, toca contrato público ou 3+ módulos | Pare. Apresente diagnóstico + opções. Sugira `/dev-brainstorm` ou `/dev-plan`. |

## Modo rápido (bug trivial)

1. Leia o arquivo inteiro em volta do erro (não só a linha)
2. Aplique o fix mínimo
3. Rode o comando que falhava → veja passar
4. Se existir suite, rode os testes do módulo tocado
5. Reporte em 2 linhas: causa → fix

**Se o "trivial" não morrer no primeiro fix, ele não era trivial.** Promova para o loop completo — não tente um segundo palpite.

## Loop completo (6 fases)

### Phase 1 — Construa o feedback loop

O teste/script que reproduz o bug em **<10s** com pass/fail determinístico. **Isso é 90% do trabalho.** Se o seu único loop é "rodar o app e clicar", invista em melhorá-lo antes de qualquer hipótese: um teste, um curl, um script de 5 linhas.

### Phase 2 — Reproduza

Rode o loop, observe a falha, confirme que é a **mesma** que o usuário descreveu (não uma vizinha). Se não reproduz: colete mais contexto (env, dados, versão) antes de teorizar.

### Phase 3 — Hipóteses ranqueadas

3-5 hipóteses, cada uma com **predição falsificável** ("se X é a causa, mexer em Y faz desaparecer"). Mostre a lista ao usuário antes de testar — ele ranqueia mais rápido com domain knowledge. Comece pela mais provável OU pela mais barata de descartar.

### Phase 4 — Instrumente

**Um probe por hipótese.** Prefira debugger > log direcionado > log everything. Logs de debug com prefixo único (`[DEBUG-a4f2]`) para cleanup via grep no fim. Cada probe responde sim/não para UMA hipótese — probe que "olha geral" é ruído.

### Phase 5 — Fix + teste de regressão

Se há seam testável, escreva o teste de regressão **ANTES** do fix. Veja falhar → aplique o fix → veja passar. O teste fica; o bug nunca mais volta sem alarme.

### Phase 6 — Cleanup

Remova logs `[DEBUG-*]`, delete probes, confirme que o repro original não reproduz mais, rode a suite do módulo. Commit: `fix(<área>): <causa em 1 linha>`.

## Regras do loop

- **Uma hipótese por vez.** Mudar 3 coisas e "ver se passa" destrói a informação de qual era a causa.
- **Falhou a hipótese? Risque e vá pra próxima.** Não "ajeite mais um pouquinho" a mesma teoria morta.
- **2 ciclos sem progresso → pare.** Apresente o que foi descartado e o que aprendeu. Pergunte ao usuário antes do 3º ciclo — domain knowledge dele vale mais que sua próxima teoria.
- **O fix muda behavior público?** Avise antes de aplicar — pode ser que o "bug" fosse contrato que alguém depende.

## Anti-padrões

- ❌ "Vou mudar isso e ver se passa" (tentativa ≠ diagnóstico)
- ❌ Corrigir o sintoma onde ele aparece em vez da causa onde ela nasce
- ❌ Mudar o teste para passar em vez de corrigir o código
- ❌ Fix sem repro confirmado ("acho que era isso")
- ❌ Deixar `console.log`/probe no código após o fix
- ❌ Refatorar "já que estou aqui" no meio do diagnóstico
- ❌ Terceiro palpite sem falar com o usuário

## Saída

Ao fechar, reporte em até 5 linhas:
- **Causa raiz:** <1 linha>
- **Fix:** <arquivos + 1 linha>
- **Regressão:** <teste adicionado / por que não>
- **Vizinhos:** <algo suspeito notado no caminho — mencionado, NÃO corrigido>
