param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectName,

  [Parameter(Mandatory = $true)]
  [string]$ProjectDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$Message) {
  throw $Message
}

function Require-Command([string]$Name) {
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    Fail "Dependencia requerida no encontrada: $Name. Instalala y vuelve a ejecutar init-project."
  }
}

function Resolve-McpConfigFile() {
  $opencodeFile = Join-Path $HOME ".config/opencode/opencode.json"

  if (Test-Path -LiteralPath $opencodeFile) {
    return $opencodeFile
  }

  Fail "Prerequisito faltante: no existe $opencodeFile. Configura OpenCode con MCP Notion habilitado y vuelve a ejecutar init-project."
}

function Test-NotionMcpEnabled([string]$McpFile) {
  try {
    $raw = Get-Content -Path $McpFile -Raw | ConvertFrom-Json
  }
  catch {
    return $false
  }

  if ($null -ne $raw.mcp) {
    if ($null -ne $raw.mcp.notion) {
      if (($raw.mcp.notion -is [bool]) -and ($raw.mcp.notion -eq $false)) {
        return $false
      }
      if (($raw.mcp.notion -isnot [bool]) -and ($null -ne $raw.mcp.notion.enabled) -and ($raw.mcp.notion.enabled -eq $false)) {
        return $false
      }
      return $true
    }

    if ($null -ne $raw.mcp.servers -and $null -ne $raw.mcp.servers.notion) {
      if (($null -ne $raw.mcp.servers.notion.enabled) -and ($raw.mcp.servers.notion.enabled -eq $false)) {
        return $false
      }
      return $true
    }
  }

  if ($null -ne $raw.servers -and $null -ne $raw.servers.notion) {
    if (($null -ne $raw.servers.notion.enabled) -and ($raw.servers.notion.enabled -eq $false)) {
      return $false
    }
    return $true
  }

  return $false
}

function New-InstructionFile([string]$Path, [string]$RootTitle, [string]$ParentPageId) {
  $content = @"
Objetivo: crear la estructura base de Notion para un proyecto rootkid0-initializer usando UNICAMENTE herramientas MCP de Notion.

Reglas obligatorias:
- No usar API HTTP directa de Notion.
- No usar tokens o variables de entorno de Notion.
- Usar solo las herramientas MCP de Notion disponibles en esta sesion.
- Responder al final SOLO con un JSON valido, sin markdown y sin texto adicional.

Pasos a ejecutar:
1) Crear una pagina raiz con titulo exacto: "$RootTitle".
2) Si se provee parent_page_id y no esta vacio, crear la pagina raiz como hija de ese page_id.
3) Crear bajo la pagina raiz estas paginas de fase:
   - 01-business
   - 02-proposal
   - 03-design
   - 04-management
   - 05-development
   - 06-deployment
   - 07-production
   - 99-common
4) Dentro de 99-common crear estas secciones:
   - Projects
   - Phases
   - Deliverables
   - Backlog
   - Risks
   - Decisions
   - Incidents

Datos de entrada:
- root_title: "$RootTitle"
- parent_page_id: "$ParentPageId"

Formato de salida requerido (JSON exacto en estructura):
{
  "notion_parent_mode": "workspace o page",
  "notion_parent_page_id": "id o vacio",
  "project_root_page_id": "id",
  "phase_pages": {
    "01-business": "id",
    "02-proposal": "id",
    "03-design": "id",
    "04-management": "id",
    "05-development": "id",
    "06-deployment": "id",
    "07-production": "id",
    "99-common": "id"
  },
  "model_sections": {
    "Projects": "id",
    "Phases": "id",
    "Deliverables": "id",
    "Backlog": "id",
    "Risks": "id",
    "Decisions": "id",
    "Incidents": "id"
  }
}
"@

  Set-Content -Path $Path -Value $content
}

function Parse-OpenCodeEvents([string]$EventsPath) {
  $textParts = New-Object System.Collections.Generic.List[string]
  $lines = Get-Content -Path $EventsPath

  foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) {
      continue
    }

    try {
      $evt = $line | ConvertFrom-Json
    }
    catch {
      continue
    }

    if ($evt.type -eq "text" -and $null -ne $evt.part -and -not [string]::IsNullOrWhiteSpace($evt.part.text)) {
      [void]$textParts.Add([string]$evt.part.text)
    }
  }

  if ($textParts.Count -eq 0) {
    Fail "No se recibio respuesta de texto desde opencode run."
  }

  $combined = ($textParts -join "`n").Trim()
  if ($combined -match '^```(?:json)?\s*([\s\S]*?)\s*```$') {
    $combined = $Matches[1].Trim()
  }

  try {
    $result = $combined | ConvertFrom-Json
  }
  catch {
    $preview = if ($combined.Length -gt 200) { $combined.Substring(0, 200) + "..." } else { $combined }
    Fail "OpenCode no devolvio JSON valido para bootstrap Notion. Detalle parser: $($_.Exception.Message). Vista previa: $preview"
  }

  if ($result -isnot [pscustomobject] -and $result -isnot [hashtable]) {
    Fail "OpenCode devolvio JSON invalido: se esperaba un objeto JSON en el nivel raiz."
  }

  $requiredPhases = @(
    "01-business",
    "02-proposal",
    "03-design",
    "04-management",
    "05-development",
    "06-deployment",
    "07-production",
    "99-common"
  )

  $requiredSections = @(
    "Projects",
    "Phases",
    "Deliverables",
    "Backlog",
    "Risks",
    "Decisions",
    "Incidents"
  )

  if ([string]::IsNullOrWhiteSpace($result.project_root_page_id)) {
    Fail "Falta campo obligatorio en respuesta MCP: project_root_page_id"
  }

  if ($null -eq $result.phase_pages) {
    Fail "Falta campo obligatorio en respuesta MCP: phase_pages"
  }

  if ($null -eq $result.model_sections) {
    Fail "Falta campo obligatorio en respuesta MCP: model_sections"
  }

  foreach ($phase in $requiredPhases) {
    $phaseId = $result.phase_pages.$phase
    if ([string]::IsNullOrWhiteSpace($phaseId)) {
      Fail "Falta fase obligatoria en respuesta MCP: $phase"
    }
  }

  foreach ($section in $requiredSections) {
    $sectionId = $result.model_sections.$section
    if ([string]::IsNullOrWhiteSpace($sectionId)) {
      Fail "Falta seccion obligatoria en respuesta MCP: $section"
    }
  }

  return $result
}

if (-not (Test-Path -LiteralPath $ProjectDir)) {
  Fail "No existe el directorio de proyecto: $ProjectDir"
}

Require-Command "opencode"

$mcpFile = Resolve-McpConfigFile
if (-not (Test-NotionMcpEnabled -McpFile $mcpFile)) {
  Fail "Prerequisito faltante: MCP Notion no habilitado en $mcpFile. Agrega la entrada mcp.notion (o mcp.servers.notion) y vuelve a ejecutar init-project."
}

$workspaceName = [Environment]::GetEnvironmentVariable("NOTION_WORKSPACE_NAME")
$parentPageId = [Environment]::GetEnvironmentVariable("NOTION_PARENT_PAGE_ID")

Write-Host "Iniciando bootstrap automatico de Notion via MCP..."

$rootTitle = $ProjectName
if (-not [string]::IsNullOrWhiteSpace($workspaceName)) {
  $rootTitle = "$workspaceName - $ProjectName"
}

$parentMode = "workspace"
if (-not [string]::IsNullOrWhiteSpace($parentPageId)) {
  $parentMode = "page"
  Write-Host "Modo parent Notion (opcional): page ($parentPageId)"
}
else {
  Write-Host "Modo parent Notion (opcional): workspace"
}

$instructionFile = [System.IO.Path]::GetTempFileName()
$eventsFile = [System.IO.Path]::GetTempFileName()
$opencodeErrFile = [System.IO.Path]::GetTempFileName()

try {
  New-InstructionFile -Path $instructionFile -RootTitle $rootTitle -ParentPageId $parentPageId

  $opencodePrompt = "Sigue las instrucciones del archivo adjunto y devuelve SOLO el JSON final."
  $opencodeMode = 'opencode run --format json --dir "<project-dir>" --file "<instruction-file>" -- "<prompt>"'
  $opencodeArgs = @(
    "run",
    "--format", "json",
    "--dir", $ProjectDir,
    "--file", $instructionFile,
    "--",
    $opencodePrompt
  )

  & opencode @opencodeArgs 2> $opencodeErrFile | Set-Content -Path $eventsFile
  if ($LASTEXITCODE -ne 0) {
    $stderr = ""
    if (Test-Path -LiteralPath $opencodeErrFile) {
      $stderr = (Get-Content -Path $opencodeErrFile -Raw).Trim()
    }
    if ([string]::IsNullOrWhiteSpace($stderr)) {
      $stderr = "sin detalle"
    }
    Fail "Fallo la ejecucion de OpenCode para bootstrap de Notion. Modo detectado: $opencodeMode. Error CLI: $stderr. Verifica que MCP Notion este disponible y operativo."
  }

  $mcpResult = Parse-OpenCodeEvents -EventsPath $eventsFile

  $outputPath = Join-Path $ProjectDir "99-common/notion-bootstrap.output.json"

  $result = [ordered]@{
    project_name = $ProjectName
    workspace_name = $workspaceName
    created_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    notion_parent_mode = if (-not [string]::IsNullOrWhiteSpace($mcpResult.notion_parent_mode)) { $mcpResult.notion_parent_mode } else { $parentMode }
    notion_parent_page_id = if (-not [string]::IsNullOrWhiteSpace($mcpResult.notion_parent_page_id)) { $mcpResult.notion_parent_page_id } else { $parentPageId }
    project_root_page_id = $mcpResult.project_root_page_id
    phase_pages = $mcpResult.phase_pages
    model_sections = $mcpResult.model_sections
  }

  $result | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath

  Write-Host "Bootstrap Notion completado via MCP."
  Write-Host "Salida guardada en: $outputPath"
}
finally {
  if (Test-Path -LiteralPath $instructionFile) {
    Remove-Item -LiteralPath $instructionFile -Force
  }
  if (Test-Path -LiteralPath $eventsFile) {
    Remove-Item -LiteralPath $eventsFile -Force
  }
  if (Test-Path -LiteralPath $opencodeErrFile) {
    Remove-Item -LiteralPath $opencodeErrFile -Force
  }
}
