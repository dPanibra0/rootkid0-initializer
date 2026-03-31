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

function Get-NotionPagePayload([string]$ParentPageId, [string]$Title) {
  return @{
    parent = @{ page_id = $ParentPageId }
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

function New-NotionPage([string]$ParentPageId, [string]$Title) {
  $headers = @{
    Authorization    = "Bearer $env:NOTION_TOKEN"
    "Notion-Version" = "2022-06-28"
    "Content-Type"   = "application/json"
  }

  $body = Get-NotionPagePayload -ParentPageId $ParentPageId -Title $Title

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

$mcpFile = Join-Path $HOME ".config/opencode/mcp-servers.json"

if (-not (Test-Path -LiteralPath $mcpFile)) {
  Fail "No existe $mcpFile. Configura MCP global con servidor notion y vuelve a ejecutar init-project."
}

try {
  $mcpConfig = Get-Content -Path $mcpFile -Raw | ConvertFrom-Json
}
catch {
  Fail "El archivo $mcpFile no tiene JSON valido. Corrigelo y vuelve a ejecutar init-project."
}

if ($null -eq $mcpConfig.servers -or $null -eq $mcpConfig.servers.notion) {
  Fail "Falta entrada servers.notion en $mcpFile. Agregala y vuelve a ejecutar init-project."
}

Require-Env "NOTION_TOKEN"
Require-Env "NOTION_PARENT_PAGE_ID"

$workspaceName = [Environment]::GetEnvironmentVariable("NOTION_WORKSPACE_NAME")

Write-Host "Iniciando bootstrap automatico de Notion..."

$rootTitle = $ProjectName
if (-not [string]::IsNullOrWhiteSpace($workspaceName)) {
  $rootTitle = "$workspaceName - $ProjectName"
}

$projectRootPageId = New-NotionPage -ParentPageId $env:NOTION_PARENT_PAGE_ID -Title $rootTitle
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
  $phaseId = New-NotionPage -ParentPageId $projectRootPageId -Title $phase
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
  $sectionId = New-NotionPage -ParentPageId $commonPageId -Title $section
  $sectionMap[$section] = $sectionId
  Write-Host "Seccion modelo MVP creada ($section): $sectionId"
}

$outputPath = Join-Path $ProjectDir "99-common/notion-bootstrap.output.json"

$result = [ordered]@{
  project_name = $ProjectName
  workspace_name = $workspaceName
  created_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  notion_parent_page_id = $env:NOTION_PARENT_PAGE_ID
  project_root_page_id = $projectRootPageId
  phase_pages = $phaseMap
  model_sections = $sectionMap
}

$result | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath

Write-Host "Bootstrap Notion completado."
Write-Host "Salida guardada en: $outputPath"
