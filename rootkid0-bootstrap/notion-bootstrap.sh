#!/usr/bin/env bash

set -euo pipefail

print_usage() {
  echo "Uso: ./rootkid0-bootstrap/notion-bootstrap.sh --project-name <name> --project-dir <path>"
}

fail() {
  echo "Error: $1" >&2
  exit 1
}

json_escape() {
  local value="${1:-}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/ }"
  value="${value//$'\r'/ }"
  printf '%s' "$value"
}

pick_python() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
    return 0
  fi

  if command -v python >/dev/null 2>&1; then
    echo "python"
    return 0
  fi

  return 1
}

validate_mcp_config() {
  local mcp_file="$HOME/.config/opencode/mcp-servers.json"

  if [[ ! -f "$mcp_file" ]]; then
    fail "Prerequisito faltante: MCP Notion no disponible. Debe existir $mcp_file con entrada 'notion' antes de ejecutar init-project."
  fi

  if ! grep -q '"notion"' "$mcp_file"; then
    fail "Prerequisito faltante: MCP Notion no disponible. Agrega la entrada 'notion' en $mcp_file y vuelve a ejecutar init-project."
  fi
}

require_env() {
  local var_name="$1"
  local var_value="${!var_name:-}"

  if [[ -z "$var_value" ]]; then
    fail "Variable requerida no definida: $var_name. Exporta $var_name y vuelve a ejecutar init-project."
  fi
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    fail "Dependencia requerida no encontrada: $command_name. Instalala y vuelve a ejecutar init-project."
  fi
}

resolve_notion_token() {
  local mcp_file="$HOME/.config/opencode/mcp-servers.json"
  local token="${NOTION_TOKEN:-}"
  local py_bin

  if [[ -n "$token" ]]; then
    printf '%s' "$token"
    return 0
  fi

  py_bin="$(pick_python || true)"
  if [[ -n "$py_bin" ]]; then
    token="$($py_bin - "$mcp_file" <<'PY'
import json
import os
import re
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

value = ""
servers = data.get("servers", {})
notion = servers.get("notion", {}) if isinstance(servers, dict) else {}
env = notion.get("env", {}) if isinstance(notion, dict) else {}

if isinstance(env, dict):
    raw = env.get("NOTION_TOKEN", "")
    if isinstance(raw, str):
        match = re.fullmatch(r"\$\{([^}]+)\}", raw.strip())
        if match:
            value = os.environ.get(match.group(1), "")
        else:
            value = raw

print(value)
PY
)"
  fi

  if [[ -z "$token" ]]; then
    fail "No se pudo resolver credencial de Notion. Define NOTION_TOKEN o configura servers.notion.env.NOTION_TOKEN en $mcp_file."
  fi

  printf '%s' "$token"
}

build_page_payload() {
  local parent_mode="$1"
  local parent_value="$2"
  local title="$3"

  if [[ "$parent_mode" == "page" ]]; then
    printf '{"parent":{"page_id":"%s"},"properties":{"title":{"title":[{"type":"text","text":{"content":"%s"}}]}}}' \
      "$parent_value" \
      "$(json_escape "$title")"
    return 0
  fi

  if [[ "$parent_mode" == "workspace" ]]; then
    printf '{"parent":{"workspace":true},"properties":{"title":{"title":[{"type":"text","text":{"content":"%s"}}]}}}' \
      "$(json_escape "$title")"
    return 0
  fi

  fail "Modo de parent no soportado para Notion payload: $parent_mode"
}

create_notion_page() {
  local parent_mode="$1"
  local parent_value="$2"
  local title="$3"
  local payload
  local response_file
  local status
  local py_bin
  local page_id

  payload="$(build_page_payload "$parent_mode" "$parent_value" "$title")"
  response_file="$(mktemp)"

  status="$(curl -sS -o "$response_file" -w "%{http_code}" \
    -X POST "https://api.notion.com/v1/pages" \
    -H "Authorization: Bearer $NOTION_AUTH_TOKEN" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    --data "$payload")"

  if [[ "$status" -lt 200 || "$status" -ge 300 ]]; then
    local error_body
    error_body="$(tr -d '\n' < "$response_file")"
    rm -f "$response_file"
    fail "Notion API devolvio HTTP $status al crear '$title'. Respuesta: $error_body"
  fi

  py_bin="$(pick_python || true)"
  if [[ -n "$py_bin" ]]; then
    page_id="$("$py_bin" - "$response_file" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

print(data.get("id", ""))
PY
)"
  else
    page_id="$(grep -o '"id":"[^"]*"' "$response_file" | head -n 1 | cut -d '"' -f 4)"
  fi

  rm -f "$response_file"

  if [[ -z "$page_id" ]]; then
    fail "No se pudo extraer el id de la pagina creada para '$title'."
  fi

  printf '%s' "$page_id"
}

PROJECT_NAME=""
PROJECT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-name)
      PROJECT_NAME="${2:-}"
      shift 2
      ;;
    --project-dir)
      PROJECT_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      fail "Argumento no reconocido: $1"
      ;;
  esac
done

if [[ -z "$PROJECT_NAME" || -z "$PROJECT_DIR" ]]; then
  print_usage
  fail "Debes indicar --project-name y --project-dir."
fi

if [[ ! -d "$PROJECT_DIR" ]]; then
  fail "No existe el directorio de proyecto: $PROJECT_DIR"
fi

validate_mcp_config
require_command "curl"
NOTION_AUTH_TOKEN="$(resolve_notion_token)"

NOTION_WORKSPACE_NAME="${NOTION_WORKSPACE_NAME:-}"
NOTION_PARENT_PAGE_ID="${NOTION_PARENT_PAGE_ID:-}"

echo "Iniciando bootstrap automatico de Notion..."

root_title="$PROJECT_NAME"
if [[ -n "$NOTION_WORKSPACE_NAME" ]]; then
  root_title="$NOTION_WORKSPACE_NAME - $PROJECT_NAME"
fi

parent_mode="workspace"
parent_value=""

if [[ -n "$NOTION_PARENT_PAGE_ID" ]]; then
  parent_mode="page"
  parent_value="$NOTION_PARENT_PAGE_ID"
  echo "Modo parent Notion: page ($NOTION_PARENT_PAGE_ID)"
else
  echo "Modo parent Notion: workspace (NOTION_PARENT_PAGE_ID no definido)"
fi

project_root_page_id="$(create_notion_page "$parent_mode" "$parent_value" "$root_title")"
echo "Pagina raiz creada: $project_root_page_id"

phase_names=(
  "01-business"
  "02-proposal"
  "03-design"
  "04-management"
  "05-development"
  "06-deployment"
  "07-production"
  "99-common"
)

phase_ids=()
common_page_id=""

for phase in "${phase_names[@]}"; do
  phase_id="$(create_notion_page "page" "$project_root_page_id" "$phase")"
  phase_ids+=("$phase_id")
  echo "Pagina creada ($phase): $phase_id"
  if [[ "$phase" == "99-common" ]]; then
    common_page_id="$phase_id"
  fi
done

if [[ -z "$common_page_id" ]]; then
  fail "No se pudo crear la pagina 99-common en Notion."
fi

section_names=(
  "Projects"
  "Phases"
  "Deliverables"
  "Backlog"
  "Risks"
  "Decisions"
  "Incidents"
)

section_ids=()
for section in "${section_names[@]}"; do
  section_id="$(create_notion_page "page" "$common_page_id" "$section")"
  section_ids+=("$section_id")
  echo "Seccion modelo MVP creada ($section): $section_id"
done

output_file="$PROJECT_DIR/99-common/notion-bootstrap.output.json"
timestamp_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "{"
  echo "  \"project_name\": \"$(json_escape "$PROJECT_NAME")\","
  echo "  \"workspace_name\": \"$(json_escape "$NOTION_WORKSPACE_NAME")\","
  echo "  \"created_at_utc\": \"$timestamp_utc\","
  echo "  \"notion_parent_mode\": \"$parent_mode\","
  echo "  \"notion_parent_page_id\": \"$(json_escape "$NOTION_PARENT_PAGE_ID")\","
  echo "  \"project_root_page_id\": \"$project_root_page_id\","
  echo "  \"phase_pages\": {"

  for i in "${!phase_names[@]}"; do
    key="${phase_names[$i]}"
    value="${phase_ids[$i]}"
    suffix=","
    if [[ "$i" -eq $((${#phase_names[@]} - 1)) ]]; then
      suffix=""
    fi
    echo "    \"$(json_escape "$key")\": \"$value\"$suffix"
  done

  echo "  },"
  echo "  \"model_sections\": {"

  for i in "${!section_names[@]}"; do
    key="${section_names[$i]}"
    value="${section_ids[$i]}"
    suffix=","
    if [[ "$i" -eq $((${#section_names[@]} - 1)) ]]; then
      suffix=""
    fi
    echo "    \"$(json_escape "$key")\": \"$value\"$suffix"
  done

  echo "  }"
  echo "}"
} > "$output_file"

echo "Bootstrap Notion completado."
echo "Salida guardada en: $output_file"
