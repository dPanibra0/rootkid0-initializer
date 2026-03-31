param(
  [Parameter(Position = 0)]
  [string]$ProjectName,
  [switch]$SetupMcp
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
  $ProjectName = Read-Host "Nombre del proyecto"
}

if ($ProjectName -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_-]{1,49}$') {
  throw "Nombre invalido. Usa 2-50 caracteres (letras, numeros, guion y guion bajo)."
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$destination = Join-Path (Get-Location).Path $ProjectName

if (Test-Path $destination) {
  throw "Ya existe la carpeta $destination"
}

Write-Host "Creando proyecto: $ProjectName"
New-Item -Path $destination -ItemType Directory | Out-Null

$excludedItems = @("rootkid0-bootstrap", "bootstrap", "automation", ".git", "README.md", "desktop.ini")
$itemsToCopy = Get-ChildItem -Path $repoRoot -Force |
  Where-Object { $excludedItems -notcontains $_.Name }

foreach ($item in $itemsToCopy) {
  Copy-Item -Path $item.FullName -Destination $destination -Recurse -Force
}

$extensions = @(".md", ".txt", ".json", ".yml", ".yaml", ".ini", ".cfg")
Get-ChildItem -Path $destination -Recurse -File |
  Where-Object { $extensions -contains $_.Extension.ToLowerInvariant() } |
  ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw
    $updated = $content.Replace("{{PROJECT_NAME}}", $ProjectName)
    if ($updated -ne $content) {
      Set-Content -Path $_.FullName -Value $updated -NoNewline
    }
  }

$templatePath = Join-Path $repoRoot ".opencode/mcp/servers.template.json"
$recommendedPath = Join-Path $repoRoot ".opencode/mcp/servers.recommended.template.json"

if ($SetupMcp) {
  if (Test-Path $templatePath) {
    $globalMcpDir = Join-Path $HOME ".config/opencode"
    $globalMcpFile = Join-Path $globalMcpDir "mcp-servers.json"

    New-Item -Path $globalMcpDir -ItemType Directory -Force | Out-Null

    if (Test-Path $globalMcpFile) {
      $stamp = Get-Date -Format "yyyyMMddHHmmss"
      $backupPath = "$globalMcpFile.bak.$stamp"
      Copy-Item -Path $globalMcpFile -Destination $backupPath -Force
      Write-Host "Backup MCP creado: $backupPath"
    }

    Copy-Item -Path $templatePath -Destination $globalMcpFile -Force
    Write-Host "MCP global actualizado: $globalMcpFile"

    if (Test-Path $recommendedPath) {
      Write-Host "Recomendado: configurar context7, engram y notion usando:"
      Write-Host "  $recommendedPath"
    }
  }
  else {
    Write-Warning "No se encontro plantilla MCP en $templatePath. Se omite setup MCP."
  }
}

$readmePath = Join-Path $destination "README.md"
$readmeContent = @"
# $ProjectName

Proyecto inicializado desde rootkid0-initializer.

## Que incluye

- Estructura base por fases: `01-business/` a `07-production/` y `99-common/`.
- Plantillas markdown con placeholders ya resueltos para tu proyecto.
- Configuracion inicial en `99-common/project.config.json`.
- Integracion OpenCode MVP (`AGENTS.md`, `.opencode/`, AGENTS locales, skills, MCP y agentes por rol).
- MCP recomendados: `context7`, `engram`, `notion` (configuracion global opcional).

## Siguientes pasos

1. Completa los markdown de `01-business/` a `07-production/`.
2. Ajusta `99-common/project.config.json` segun tu stack y contexto.
3. Revisa `AGENTS.md` como entrypoint de roles.
4. Revisa `.opencode/README.md` para el flujo global + subproyectos.
5. Revisa `.opencode/mcp/README.md` para configurar MCP global.
6. Versiona cambios con Git y define tu backlog inicial.
"@
Set-Content -Path $readmePath -Value $readmeContent

Write-Host ""
Write-Host "Proyecto creado en: $destination"
Write-Host "Siguientes pasos:"
Write-Host "  1) Set-Location `"$ProjectName`""
Write-Host "  2) Completar 01-business/ a 07-production/"
Write-Host "  3) Ajustar 99-common/project.config.json"
Write-Host "  4) Revisar AGENTS.md y .opencode/README.md"
Write-Host "  5) MCP recomendado: context7, engram, notion"
