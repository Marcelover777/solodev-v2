#requires -version 5
#
# solodev v2 - instalador Windows PowerShell
# Copia as skills do solodev v2 para o .claude\skills\ de um projeto alvo.
#
# Uso:
#   .\install.ps1 [-TargetDir <caminho>]   # default: diretorio atual
#   irm https://raw.githubusercontent.com/Marcelover777/solodev-v2/main/install.ps1 | iex
#
# No modo pipe (irm|iex) nao existem arquivos locais, entao clonamos o repo
# publico num diretorio temporario e copiamos de la.
#
param(
    [string]$TargetDir = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$RepoUrl = 'https://github.com/Marcelover777/solodev-v2.git'
$Skills  = @('dev-start', 'dev-stack', 'dev-design', 'dev-setup', 'dev-roadmap', 'dev-next', 'dev-status', 'dev-ops', 'dev-context', 'dev-brainstorm', 'dev-plan', 'dev-coding', 'dev-fix', 'dev-ship', 'dev-help')

# --- Descobrir a fonte das skills ------------------------------------------
#
# Caso A (clone local): este script esta dentro do repo, ao lado de skills\.
# Caso B (pipe):        sem arquivos locais ($PSScriptRoot vazio) - clonamos um tmp.
#
$SourceDir  = $null
$CleanupTmp = $null

if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'skills'))) {
    # Rodando a partir de um clone local.
    $SourceDir = $PSScriptRoot
}
else {
    # Rodando via pipe (irm|iex) - clona o repo publico num tmp.
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error 'git nao encontrado. Instale o git ou clone o repo manualmente.'
        exit 1
    }
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("solodev-v2-" + [System.Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    $CleanupTmp = $tmp
    Write-Host "==> Baixando solodev v2 de $RepoUrl ..."
    git clone --depth 1 $RepoUrl $tmp 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git clone falhou (codigo $LASTEXITCODE). Verifique sua conexao ou clone o repo manualmente."
        exit 1
    }
    $SourceDir = $tmp
}

try {
    # --- Validar a fonte ----------------------------------------------------
    $srcSkills = Join-Path $SourceDir 'skills'
    if (-not (Test-Path $srcSkills)) {
        Write-Error "nao encontrei a pasta skills\ em $SourceDir"
        exit 1
    }

    # --- Instalar -----------------------------------------------------------
    $dest = Join-Path (Join-Path $TargetDir '.claude') 'skills'
    New-Item -ItemType Directory -Force -Path $dest | Out-Null

    Write-Host "==> Instalando solodev v2 em: $dest"
    foreach ($skill in $Skills) {
        $src = Join-Path $srcSkills $skill
        if (Test-Path $src) {
            $target = Join-Path $dest $skill
            if (Test-Path $target) { Remove-Item -Recurse -Force $target }
            Copy-Item -Recurse -Force $src $target
            Write-Host "    copiado: $skill"
        }
        else {
            Write-Warning "    pulado (nao encontrado na fonte): $skill"
        }
    }

    Write-Host ''
    Write-Host "Pronto. As skills do solodev v2 estao em $dest"
    Write-Host 'Abra este projeto no Claude Code. Comece por /dev-start (modo guiado) - ou /dev-help para o mapa dos 15 comandos.'
}
finally {
    if ($CleanupTmp -and (Test-Path $CleanupTmp)) {
        Remove-Item -Recurse -Force $CleanupTmp -ErrorAction SilentlyContinue
    }
}
