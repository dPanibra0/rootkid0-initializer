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

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    fail "Dependencia requerida no encontrada: $command_name. Instalala y vuelve a ejecutar init-project."
  fi
}

resolve_mcp_config_file() {
  local opencode_file="$HOME/.config/opencode/opencode.json"

  if [[ -f "$opencode_file" ]]; then
    printf '%s' "$opencode_file"
    return 0
  fi

  fail "Prerequisito faltante: no existe $opencode_file. Configura OpenCode con MCP Notion habilitado y vuelve a ejecutar init-project."
}

validate_mcp_config() {
  local mcp_file="$1"
  local py_bin
  local has_notion=""

  py_bin="$(pick_python || true)"
  if [[ -n "$py_bin" ]]; then
    has_notion="$($py_bin - "$mcp_file" <<'PY'
import json
import sys

def has_enabled_notion(data):
    if not isinstance(data, dict):
        return False

    mcp = data.get("mcp")
    if isinstance(mcp, dict):
        notion = mcp.get("notion")
        if notion not in (None, False):
            if not (isinstance(notion, dict) and notion.get("enabled") is False):
                return True

        servers = mcp.get("servers")
        if isinstance(servers, dict) and "notion" in servers:
            notion_server = servers.get("notion")
            if not (isinstance(notion_server, dict) and notion_server.get("enabled") is False):
                return True

    servers = data.get("servers")
    if isinstance(servers, dict) and "notion" in servers:
        notion_server = servers.get("notion")
        if not (isinstance(notion_server, dict) and notion_server.get("enabled") is False):
            return True

    return False

with open(sys.argv[1], "r", encoding="utf-8") as f:
    raw = json.load(f)

print("yes" if has_enabled_notion(raw) else "no")
PY
)"
  else
    has_notion="$(grep -q '"notion"' "$mcp_file" && echo yes || echo no)"
  fi

  if [[ "$has_notion" != "yes" ]]; then
    fail "Prerequisito faltante: MCP Notion no habilitado en $mcp_file. Agrega la entrada mcp.notion (o mcp.servers.notion) y vuelve a ejecutar init-project."
  fi
}

build_instruction_file() {
  local instruction_file="$1"
  local root_title="$2"
  local parent_page_id="$3"

  cat > "$instruction_file" <<EOF
Objetivo: crear la estructura base de Notion para un proyecto rootkid0-initializer usando UNICAMENTE herramientas MCP de Notion.

Reglas obligatorias:
- No usar API HTTP directa de Notion.
- No usar tokens o variables de entorno de Notion.
- Usar solo las herramientas MCP de Notion disponibles en esta sesion.
- Responder al final SOLO con un JSON valido, sin markdown y sin texto adicional.

Pasos a ejecutar:
1) Crear una pagina raiz con titulo exacto: "$root_title".
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
- root_title: "$root_title"
- parent_page_id: "$parent_page_id"

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
EOF
}

extract_bootstrap_result() {
  local events_file="$1"
  local py_bin
  py_bin="$(pick_python || true)"

  if [[ -z "$py_bin" ]]; then
    fail "No se encontro python/python3 para validar salida JSON de OpenCode."
  fi

  "$py_bin" - "$events_file" <<'PY'
import json
import re
import sys

events_file = sys.argv[1]
parts = []

with open(events_file, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            evt = json.loads(line)
        except json.JSONDecodeError:
            continue

        if evt.get("type") == "text":
            part = evt.get("part", {})
            text = part.get("text")
            if isinstance(text, str) and text.strip():
                parts.append(text)

combined = "\n".join(parts).strip()
if not combined:
    raise SystemExit("No se recibio respuesta de texto desde opencode run.")

fence_match = re.fullmatch(r"```(?:json)?\s*(.*?)\s*```", combined, flags=re.DOTALL)
if fence_match:
    combined = fence_match.group(1).strip()

data = json.loads(combined)

required_phases = [
    "01-business",
    "02-proposal",
    "03-design",
    "04-management",
    "05-development",
    "06-deployment",
    "07-production",
    "99-common",
]
required_sections = [
    "Projects",
    "Phases",
    "Deliverables",
    "Backlog",
    "Risks",
    "Decisions",
    "Incidents",
]

for top in ["project_root_page_id", "phase_pages", "model_sections"]:
    if top not in data:
        raise SystemExit(f"Falta campo obligatorio en respuesta MCP: {top}")

for key in required_phases:
    if key not in data["phase_pages"]:
        raise SystemExit(f"Falta fase obligatoria en respuesta MCP: {key}")

for key in required_sections:
    if key not in data["model_sections"]:
        raise SystemExit(f"Falta seccion obligatoria en respuesta MCP: {key}")

print(json.dumps(data, ensure_ascii=False))
PY
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

require_command "opencode"
mcp_config_file="$(resolve_mcp_config_file)"
validate_mcp_config "$mcp_config_file"

NOTION_WORKSPACE_NAME="${NOTION_WORKSPACE_NAME:-}"
NOTION_PARENT_PAGE_ID="${NOTION_PARENT_PAGE_ID:-}"

echo "Iniciando bootstrap automatico de Notion via MCP..."

root_title="$PROJECT_NAME"
if [[ -n "$NOTION_WORKSPACE_NAME" ]]; then
  root_title="$NOTION_WORKSPACE_NAME - $PROJECT_NAME"
fi

parent_mode="workspace"
if [[ -n "$NOTION_PARENT_PAGE_ID" ]]; then
  parent_mode="page"
  echo "Modo parent Notion (opcional): page ($NOTION_PARENT_PAGE_ID)"
else
  echo "Modo parent Notion (opcional): workspace"
fi

instruction_file="$(mktemp)"
events_file="$(mktemp)"
trap 'rm -f "$instruction_file" "$events_file"' EXIT

build_instruction_file "$instruction_file" "$root_title" "$NOTION_PARENT_PAGE_ID"

if ! opencode run --format json --dir "$PROJECT_DIR" --file "$instruction_file" \
  "Sigue las instrucciones del archivo adjunto y devuelve SOLO el JSON final." > "$events_file"; then
  fail "Fallo la ejecucion de OpenCode para bootstrap de Notion. Verifica que MCP Notion este disponible y operativo."
fi

mcp_result_json="$(extract_bootstrap_result "$events_file")"

output_file="$PROJECT_DIR/99-common/notion-bootstrap.output.json"
timestamp_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

py_bin="$(pick_python || true)"
if [[ -z "$py_bin" ]]; then
  fail "No se encontro python/python3 para consolidar salida JSON del bootstrap Notion."
fi

"$py_bin" - "$mcp_result_json" "$PROJECT_NAME" "$NOTION_WORKSPACE_NAME" "$timestamp_utc" "$parent_mode" "$NOTION_PARENT_PAGE_ID" "$output_file" <<'PY'
import json
import sys

mcp_result = json.loads(sys.argv[1])
project_name = sys.argv[2]
workspace_name = sys.argv[3]
timestamp_utc = sys.argv[4]
parent_mode = sys.argv[5]
parent_page_id = sys.argv[6]
output_file = sys.argv[7]

result = {
    "project_name": project_name,
    "workspace_name": workspace_name,
    "created_at_utc": timestamp_utc,
    "notion_parent_mode": mcp_result.get("notion_parent_mode", parent_mode),
    "notion_parent_page_id": mcp_result.get("notion_parent_page_id", parent_page_id),
    "project_root_page_id": mcp_result["project_root_page_id"],
    "phase_pages": mcp_result["phase_pages"],
    "model_sections": mcp_result["model_sections"],
}

with open(output_file, "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY

echo "Bootstrap Notion completado via MCP."
echo "Salida guardada en: $output_file"
