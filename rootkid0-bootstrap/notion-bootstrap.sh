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
  local py_bin
  local py_status

  if [[ ! -f "$mcp_file" ]]; then
    fail "No existe $mcp_file. Configura el MCP global con entrada 'notion' y vuelve a ejecutar init-project."
  fi

  py_bin="$(pick_python || true)"

  if [[ -n "$py_bin" ]]; then
    if "$py_bin" - "$mcp_file" <<'PY'; then
import json
import sys

path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(2)

servers = data.get("servers")
if isinstance(servers, dict) and "notion" in servers:
    sys.exit(0)

sys.exit(1)
PY
      py_status=0
    else
      py_status=$?
    fi

    if [[ "$py_status" -ne 0 ]]; then
      case "$py_status" in
        1)
          fail "Falta el servidor 'notion' en $mcp_file. Agrega la entrada en servers.notion y vuelve a ejecutar init-project."
          ;;
        2)
          fail "El archivo $mcp_file no tiene JSON valido. Corrigelo y vuelve a ejecutar init-project."
          ;;
        *)
          fail "No se pudo validar $mcp_file. Verifica permisos y formato del archivo."
          ;;
      esac
    fi
    return 0
  fi

  if ! grep -q '"notion"' "$mcp_file"; then
    fail "No se detecto la entrada 'notion' en $mcp_file. Agrega el servidor notion y vuelve a ejecutar init-project."
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

build_page_payload() {
  local parent_id="$1"
  local title="$2"

  printf '{"parent":{"page_id":"%s"},"properties":{"title":{"title":[{"type":"text","text":{"content":"%s"}}]}}}' \
    "$parent_id" \
    "$(json_escape "$title")"
}

create_notion_page() {
  local parent_id="$1"
  local title="$2"
  local payload
  local response_file
  local status
  local py_bin
  local page_id

  payload="$(build_page_payload "$parent_id" "$title")"
  response_file="$(mktemp)"

  status="$(curl -sS -o "$response_file" -w "%{http_code}" \
    -X POST "https://api.notion.com/v1/pages" \
    -H "Authorization: Bearer $NOTION_TOKEN" \
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
require_env "NOTION_TOKEN"
require_env "NOTION_PARENT_PAGE_ID"

NOTION_WORKSPACE_NAME="${NOTION_WORKSPACE_NAME:-}"

echo "Iniciando bootstrap automatico de Notion..."

root_title="$PROJECT_NAME"
if [[ -n "$NOTION_WORKSPACE_NAME" ]]; then
  root_title="$NOTION_WORKSPACE_NAME - $PROJECT_NAME"
fi

project_root_page_id="$(create_notion_page "$NOTION_PARENT_PAGE_ID" "$root_title")"
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
  phase_id="$(create_notion_page "$project_root_page_id" "$phase")"
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
  section_id="$(create_notion_page "$common_page_id" "$section")"
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
