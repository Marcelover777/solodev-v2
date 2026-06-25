#requires -version 5
<#
  Forger — runner headless do /dev-loop (Windows, PowerShell 5.1+, first-class).

  Avança N unidades de trabalho (passos do ROADMAP + itens do .forge/BACKLOG.md)
  chamando o Claude Code em modo -p num laço, SEMPRE numa branch isolada, parando
  em toda frontier (GATE/CHECKPOINT/RED) e nos caps (iteração/custo/no-progress).
  NÃO é autonomia solta — é um batch runner que halta direito.

  Uso:
    .\scripts\loop.ps1 [-MaxIterations 8] [-MaxBudgetUsd 0] [-Yolo] [-TargetDir <path>]

  -MaxBudgetUsd 0 = sem teto de custo. -Yolo = --dangerously-skip-permissions
  (o "headless total", opt-in ruidoso; mesmo assim os RED continuam parando o loop).

  Contrato file-based (.forge/):
    - loop.lock   : trava (recusa iniciar se existir).
    - loop.signal : a iteração interna escreve 2 linhas — result=<...> e item=<...>.
    - STATE.md    : este runner escreve (iteração, custo cumulado, último resultado).
    - JOURNAL.md  : a iteração interna faz append (1 entrada por volta).

  Caveats Windows respeitados: sinal = `subtype` do JSON (não $LASTEXITCODE);
  estado em UTF-8 sem BOM; sem &&/||; sem 2>&1 em exe nativo; sem --bare.
#>
param(
    [int]$MaxIterations = 8,
    [double]$MaxBudgetUsd = 0,
    [switch]$Yolo,
    [string]$TargetDir = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)   # UTF-8 SEM BOM
function Write-Utf8($path, $text) { [System.IO.File]::WriteAllText($path, $text, $enc) }

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Error "claude (Claude Code CLI) não encontrado no PATH."; exit 1
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git não encontrado no PATH."; exit 1
}

$forge = Join-Path $TargetDir '.forge'
New-Item -ItemType Directory -Force -Path $forge | Out-Null
$lock = Join-Path $forge 'loop.lock'
if (Test-Path $lock) {
    Write-Error "Há um loop em curso (ou morto sujo): $lock existe. Confira e apague à mão se for resíduo."
    exit 1
}

Push-Location $TargetDir
New-Item -ItemType File -Path $lock | Out-Null   # sem -Force (não truncar)
try {
    # --- Branch isolada: nunca na default -----------------------------------
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
    if ($branch -eq 'main' -or $branch -eq 'master') {
        $loopBranch = 'forger/loop/' + (Get-Date -Format 'yyyy-MM-dd')
        git show-ref --verify --quiet "refs/heads/$loopBranch"
        if ($?) { git checkout $loopBranch | Out-Null }
        else { git checkout -b $loopBranch | Out-Null }
        $branch = $loopBranch
    }
    Write-Host "==> /dev-loop headless na branch: $branch  (caps: iter<=$MaxIterations, budget=$MaxBudgetUsd, yolo=$Yolo)"

    $permArgs = if ($Yolo) { @('--dangerously-skip-permissions') } else { @('--permission-mode', 'acceptEdits') }
    $sigPath = Join-Path $forge 'loop.signal'

    $prompt = @'
Você é o /dev-loop do Forger em modo runner HEADLESS. Faça UMA iteração do ciclo OODA
sobre a PRÓXIMA unidade de trabalho, seguindo a precedência do /dev-next (ROADMAP.md → .forge/BACKLOG.md;
ordem de arquivo/determinística, você NÃO escolhe a prioridade).

Regras duras (a constituição do Forger):
- Frontiers param TUDO: GATE (falta chave/config) → não execute. CHECKPOINT (ambiguidade/merge) → pare.
  RED (destrutivo: reset --hard, clean, rebase, push/--force, deletar branch, reescrever histórico,
  migration destrutiva, rm -rf, commit na branch default) → NUNCA execute, pare.
- NÃO faça push. NÃO toque na branch default. Commit só na branch atual do loop.
- Verifique DE VERDADE (mecânico e autoritativo): must_pass + Critérios/Aceite da unidade
  (reuse o /dev-ship) + `node scripts/validate.mjs` quando aplicável. Nada de dev server long-lived.
- Marque ✅ a unidade SÓ se o verify passou. Anti-placeholder: grep no diff (TODO/FIXME/stub) → não é done.
- Faça APPEND de uma entrada em .forge/JOURNAL.md (ação, verify, resultado).

No FIM, escreva em .forge/loop.signal EXATAMENTE duas linhas (UTF-8 sem BOM):
result=<progress|done|gate|checkpoint|red|no-progress>
item=<id do item B-NNN ou "passo 0X" ou "-">
("done" = fila vazia; "progress" = avançou uma unidade verde; as frontiers = o nome delas;
"no-progress" = não conseguiu avançar esta unidade.) Depois SAIA. Uma unidade por iteração, nada além.
'@

    $cumCost = 0.0
    $attempts = @{}
    $stop = ''
    $iter = 0

    while ($iter -lt $MaxIterations) {
        if ($MaxBudgetUsd -gt 0 -and $cumCost -ge $MaxBudgetUsd) { $stop = "budget (\$$cumCost >= \$$MaxBudgetUsd)"; break }
        $iter++
        Write-Host "`n--- iteração $iter/$MaxIterations (cumul \$$([math]::Round($cumCost,4))) ---"

        if (Test-Path $sigPath) { Remove-Item $sigPath -Force }

        # Invoca o Claude Code headless. Captura stdout (NÃO redirecionar stderr de exe nativo).
        $out = & claude -p $prompt --output-format json @permArgs
        $raw = ($out -join "`n")

        $res = $null
        try { $res = $raw | ConvertFrom-Json } catch { }
        if ($null -eq $res) { $stop = 'json inválido do claude (abortando para não rodar às cegas)'; break }

        # Sinal de máquina = subtype (NÃO $LASTEXITCODE).
        $subtype = [string]$res.subtype
        if ($res.total_cost_usd) { $cumCost += [double]$res.total_cost_usd }

        if ($subtype -eq 'error_during_execution' -or $subtype -eq 'refusal') {
            $stop = "claude subtype=$subtype"; break
        }
        # error_max_turns: a iteração não fechou; conta como tentativa, não como verde.

        # Lê o sinal file-based escrito pela iteração interna.
        $result = 'progress'; $item = '-'
        if (Test-Path $sigPath) {
            foreach ($line in (Get-Content $sigPath)) {
                if ($line -match '^\s*result\s*=\s*(.+)$') { $result = $Matches[1].Trim() }
                elseif ($line -match '^\s*item\s*=\s*(.+)$') { $item = $Matches[1].Trim() }
            }
        }
        elseif ($subtype -eq 'error_max_turns') { $result = 'no-progress' }

        # No-progress autoritativo: 3x no mesmo item.
        if (-not $attempts.ContainsKey($item)) { $attempts[$item] = 0 }
        if ($result -ne 'progress') { } else { $attempts[$item] = 0 }
        if ($result -eq 'no-progress') { $attempts[$item]++ }

        # STATE.md é deste runner (UTF-8 sem BOM).
        $state = @"
---
branch: $branch
iteration: $iter
max_iterations: $MaxIterations
cost_usd_cumulative: $([math]::Round($cumCost,4))
max_budget_usd: $MaxBudgetUsd
last_item: $item
last_result: $result
attempts_current_item: $($attempts[$item])
---

# STATE — /dev-loop ($branch)

> Escrito pelo runner. last_result é o sinal de parada (não o exit code).
"@
        Write-Utf8 (Join-Path $forge 'STATE.md') $state

        Write-Host "    subtype=$subtype  result=$result  item=$item  custo_cumul=\$$([math]::Round($cumCost,4))"

        switch ($result) {
            'done' { $stop = 'fila vazia (done)'; break }
            'gate' { $stop = "GATE em $item (falta chave/config — resolva e rode de novo)"; break }
            'checkpoint' { $stop = "CHECKPOINT em $item (decisão humana)"; break }
            'red' { $stop = "RED em $item (destrutivo — exige humano)"; break }
            'no-progress' { if ($attempts[$item] -ge 3) { $stop = "no-progress: 3x em $item"; break } }
        }
        if ($stop) { break }
    }
    if (-not $stop) { $stop = "cap de iteração ($MaxIterations)" }

    Write-Host "`n==> /dev-loop parou: $stop"
    Write-Host "    iterações: $iter  ·  custo: \$$([math]::Round($cumCost,4))  ·  branch: $branch"
    Write-Host "    Revise o diff e o .forge/JOURNAL.md. Merge é decisão sua (CHECKPOINT): nada foi para a branch default, nada foi pushado."
}
finally {
    if (Test-Path $lock) { Remove-Item $lock -Force -ErrorAction SilentlyContinue }
    Pop-Location
}
