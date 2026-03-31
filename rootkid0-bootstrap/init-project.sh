#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/helpers.sh"

print_usage() {
  echo "Uso: ./rootkid0-bootstrap/init-project.sh [--setup-mcp] <project-name>"
}

SETUP_MCP=false
PROJECT_NAME=""

for arg in "$@"; do
  case "$arg" in
    --setup-mcp)
      SETUP_MCP=true
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME="$arg"
      else
        echo "Error: argumento no reconocido '$arg'" >&2
        print_usage
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$PROJECT_NAME" ]]; then
  read -r -p "Nombre del proyecto: " PROJECT_NAME
fi

validate_project_name "$PROJECT_NAME"

DESTINATION="$PWD/$PROJECT_NAME"

if [[ -e "$DESTINATION" ]]; then
  echo "Error: Ya existe la carpeta $DESTINATION" >&2
  exit 1
fi

echo "Creando proyecto: $PROJECT_NAME"
mkdir -p "$DESTINATION"

copy_baseline "$REPO_ROOT" "$DESTINATION"
replace_project_placeholders "$DESTINATION" "$PROJECT_NAME"
generate_project_readme "$DESTINATION" "$PROJECT_NAME"

if [[ "$SETUP_MCP" == "true" ]]; then
  setup_global_mcp_config "$REPO_ROOT"
fi

bash "$SCRIPT_DIR/notion-bootstrap.sh" --project-name "$PROJECT_NAME" --project-dir "$DESTINATION"

echo
echo "Proyecto creado en: $DESTINATION"
echo "Siguientes pasos:"
echo "  1) cd \"$PROJECT_NAME\""
echo "  2) Completar 01-business/ a 07-production/"
echo "  3) Ajustar 99-common/project.config.json"
echo "  4) Revisar AGENTS.md y .opencode/README.md"
echo "  5) Revisar 99-common/notion-bootstrap.output.json"
