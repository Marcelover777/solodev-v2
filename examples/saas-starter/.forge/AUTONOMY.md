---
level: step          # suggest | step | supervised | headless
max_iterations: 8    # hard-stop por run
max_budget_usd: 0    # 0 = sem teto; >0 = para antes de estourar
allow_yolo: false    # true habilita --dangerously-skip-permissions no headless (ruidoso)
---

# AUTONOMIA — saas-starter

> A coleira do `/dev-loop`. `level` decide o lote entre paradas; os gates
> (GATE/CHECKPOINT/RED) NUNCA somem, em nenhum nível. Edite à mão, dê commit —
> é versionado, reversível por diff. Subir o nível só aumenta o lote *entre* gates.
