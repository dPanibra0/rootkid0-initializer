#!/usr/bin/env bash

set -euo pipefail

validate_project_name() {
  local project_name="${1:-}"

  if [[ -z "$project_name" ]]; then
    echo "Error: Debes indicar un nombre de proyecto." >&2
    return 1
  fi

  if [[ ! "$project_name" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]{1,49}$ ]]; then
    echo "Error: Nombre invalido. Usa 2-50 caracteres (letras, numeros, guion y guion bajo)." >&2
    return 1
  fi
}

copy_baseline() {
  local repo_root="$1"
  local destination="$2"

  mkdir -p "$destination"

  local item
  for item in "$repo_root"/* "$repo_root"/.[!.]* "$repo_root"/..?*; do
    [[ -e "$item" ]] || continue

    local name
    name="$(basename "$item")"

    case "$name" in
      rootkid0-bootstrap|rootkid-bootstrap|bootstrap|automation|.git|README.md|desktop.ini)
        continue
        ;;
    esac

    cp -R "$item" "$destination/"
  done
}

replace_project_placeholders() {
  local destination="$1"
  local project_name="$2"

  while IFS= read -r -d '' file; do
    sed -i.bak "s/{{PROJECT_NAME}}/$project_name/g" "$file"
    rm -f "$file.bak"
  done < <(find "$destination" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.ini" -o -name "*.cfg" \) -print0)
}

generate_project_readme() {
  local destination="$1"
  local project_name="$2"

  cat > "$destination/README.md" <<EOF
# $project_name

Proyecto inicializado desde rootkid0-initializer.

## Que incluye

- Estructura base por fases: \`01-business/\` a \`07-production/\` y \`99-common/\`.
- Plantillas markdown con placeholders ya resueltos para tu proyecto.
- Configuracion inicial en \`99-common/project.config.json\`.
- Integracion OpenCode MVP (\`AGENTS.md\`, \`.opencode/\`, AGENTS locales, skills, MCP y agentes por rol).
- Setup automatico de Notion (MVP): MCP-only via OpenCode/agent, sin token en scripts.
- Salida de IDs Notion en \`99-common/notion-bootstrap.output.json\`.

## Siguientes pasos

1. Completa los markdown de \`01-business/\` a \`07-production/\`.
2. Ajusta \`99-common/project.config.json\` segun tu stack y contexto.
3. Revisa \`AGENTS.md\` como entrypoint de roles.
4. Revisa \`.opencode/README.md\` para el flujo global + subproyectos.
5. Confirma prerequisito MCP Notion (mcp.notion habilitado en opencode.json) en \`.opencode/mcp/README.md\`.
6. Verifica \`99-common/notion-bootstrap.output.json\`.
7. Versiona cambios con Git y define tu backlog inicial.
EOF
}
