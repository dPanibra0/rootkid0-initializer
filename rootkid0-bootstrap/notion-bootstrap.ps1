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

function Require-Env([string]$Name) {
  $value = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($value)) {
    Fail "Variable requerida no definida: $Name. Definila y vuelve a ejecutar init-project."
  }
}

function Resolve-NotionToken([string]$McpFile) {
  $token = [Environment]::GetEnvironmentVariable("NOTION_TOKEN")
  if (-not [string]::IsNullOrWhiteSpace($token)) {
    return $token
  }

  try {
    $raw = Get-Content -Path $McpFile -Raw | ConvertFrom-Json
    if ($null -ne $raw.servers) {
      $fromConfig = $raw.servers.notion.env.NOTION_TOKEN
    }
    elseif ($null -ne $raw.mcp -and $null -ne $raw.mcp.servers) {
      $fromConfig = $raw.mcp.servers.notion.env.NOTION_TOKEN
    }
    else {
      $fromConfig = ""
    }
  }
  catch {
    $fromConfig = ""
  }

  if ($fromConfig -is [string]) {
    if ($fromConfig -match '^\$\{(.+)\}$') {
      $refVar = $Matches[1]
      $resolved = [Environment]::GetEnvironmentVariable($refVar)
      if (-not [string]::IsNullOrWhiteSpace($resolved)) {
        return $resolved
      }
    }
    elseif (-not [string]::IsNullOrWhiteSpace($fromConfig)) {
      return $fromConfig
    }
  }

  Fail "No se pudo resolver credencial de Notion. Define NOTION_TOKEN o configura servers.notion.env.NOTION_TOKEN en $McpFile."
}

function Resolve-McpConfigFile() {
  $opencodeFile = Join-Path $HOME ".config/opencode/opencode.json"
  $legacyFile = Join-Path $HOME ".config/opencode/mcp-servers.json"

  if (Test-Path -LiteralPath $opencodeFile) {
    return $opencodeFile
  }

  if (Test-Path -LiteralPath $legacyFile) {
    return $legacyFile
  }

  Fail "Prerequisito faltante: MCP Notion no disponible. Debe existir $opencodeFile (preferido) o $legacyFile con entrada notion antes de ejecutar init-project."
}

function Has-NotionServer([string]$McpFile) {
  try {
    $raw = Get-Content -Path $McpFile -Raw | ConvertFrom-Json
    if ($null -ne $raw.servers -and $null -ne $raw.servers.notion) {
      return $true
    }
    if ($null -ne $raw.mcp -and $null -ne $raw.mcp.servers -and $null -ne $raw.mcp.servers.notion) {
      return $true
    }
    return $false
  }
  catch {
    return $false
  }
}

function Get-NotionPagePayload([string]$ParentMode, [string]$ParentValue, [string]$Title) {
  if ($ParentMode -eq "page") {
    return @{
      parent = @{ page_id = $ParentValue }
      properties = @{
        title = @{
          title = @(
            @{
              type = "text"
              text = @{ content = $Title }
            }
          )
        }
      }
    } | ConvertTo-Json -Depth 10
  }

  if ($ParentMode -eq "workspace") {
    return @{
      parent = @{ workspace = $true }
      properties = @{
        title = @{
          title = @(
            @{
              type = "text"
              text = @{ content = $Title }
            }
          )
        }
      }
    } | ConvertTo-Json -Depth 10
  }

  Fail "Modo de parent no soportado para Notion payload: $ParentMode"
}

function New-NotionPage([string]$ParentMode, [string]$ParentValue, [string]$Title) {
  $headers = @{
    Authorization    = "Bearer $script:NotionToken"
    "Notion-Version" = "2022-06-28"
    "Content-Type"   = "application/json"
  }

  $body = Get-NotionPagePayload -ParentMode $ParentMode -ParentValue $ParentValue -Title $Title

  try {
    $response = Invoke-RestMethod -Method Post -Uri "https://api.notion.com/v1/pages" -Headers $headers -Body $body
  }
  catch {
    $apiMessage = $_.ErrorDetails.Message
    if ([string]::IsNullOrWhiteSpace($apiMessage)) {
      $apiMessage = $_.Exception.Message
    }
    Fail "No se pudo crear pagina en Notion ($Title). Detalle: $apiMessage"
  }

  if ([string]::IsNullOrWhiteSpace($response.id)) {
    Fail "Notion no devolvio un id valido al crear '$Title'."
  }

  return $response.id
}

if (-not (Test-Path -LiteralPath $ProjectDir)) {
  Fail "No existe el directorio de proyecto: $ProjectDir"
}

$mcpFile = Resolve-McpConfigFile

if (-not (Has-NotionServer -McpFile $mcpFile)) {
  Fail "Prerequisito faltante: MCP Notion no disponible. Agrega entrada notion en $mcpFile y vuelve a ejecutar init-project."
}

$script:NotionToken = Resolve-NotionToken -McpFile $mcpFile

$workspaceName = [Environment]::GetEnvironmentVariable("NOTION_WORKSPACE_NAME")
$parentPageId = [Environment]::GetEnvironmentVariable("NOTION_PARENT_PAGE_ID")

Write-Host "Iniciando bootstrap automatico de Notion..."

$rootTitle = $ProjectName
if (-not [string]::IsNullOrWhiteSpace($workspaceName)) {
  $rootTitle = "$workspaceName - $ProjectName"
}

$parentMode = "workspace"
$parentValue = ""

if (-not [string]::IsNullOrWhiteSpace($parentPageId)) {
  $parentMode = "page"
  $parentValue = $parentPageId
  Write-Host "Modo parent Notion: page ($parentPageId)"
}
else {
  Write-Host "Modo parent Notion: workspace (NOTION_PARENT_PAGE_ID no definido)"
}

$projectRootPageId = New-NotionPage -ParentMode $parentMode -ParentValue $parentValue -Title $rootTitle
Write-Host "Pagina raiz creada: $projectRootPageId"

$phaseNames = @(
  "01-business",
  "02-proposal",
  "03-design",
  "04-management",
  "05-development",
  "06-deployment",
  "07-production",
  "99-common"
)

$phaseMap = [ordered]@{}
$commonPageId = ""

foreach ($phase in $phaseNames) {
  $phaseId = New-NotionPage -ParentMode "page" -ParentValue $projectRootPageId -Title $phase
  $phaseMap[$phase] = $phaseId
  Write-Host "Pagina creada ($phase): $phaseId"
  if ($phase -eq "99-common") {
    $commonPageId = $phaseId
  }
}

if ([string]::IsNullOrWhiteSpace($commonPageId)) {
  Fail "No se pudo crear la pagina 99-common en Notion."
}

$sectionNames = @(
  "Projects",
  "Phases",
  "Deliverables",
  "Backlog",
  "Risks",
  "Decisions",
  "Incidents"
)

$sectionMap = [ordered]@{}

foreach ($section in $sectionNames) {
  $sectionId = New-NotionPage -ParentMode "page" -ParentValue $commonPageId -Title $section
  $sectionMap[$section] = $sectionId
  Write-Host "Seccion modelo MVP creada ($section): $sectionId"
}

$outputPath = Join-Path $ProjectDir "99-common/notion-bootstrap.output.json"

$result = [ordered]@{
  project_name = $ProjectName
  workspace_name = $workspaceName
  created_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  notion_parent_mode = $parentMode
  notion_parent_page_id = $parentPageId
  project_root_page_id = $projectRootPageId
  phase_pages = $phaseMap
  model_sections = $sectionMap
}

$result | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath

Write-Host "Bootstrap Notion completado."
Write-Host "Salida guardada en: $outputPath"
