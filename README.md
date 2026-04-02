# rootkid0-initializer

Repo base para inicializar proyectos con una estructura estandar por fases.

## Estructura actual

- `rootkid0-bootstrap/` scripts para crear un nuevo proyecto.
- `AGENTS.md` indice canonico para seleccionar roles de agentes.
- `.opencode/` contexto global, MCP centralizado y agentes por rol.
- `01-business/` descubrimiento y contexto del problema.
- `02-proposal/` propuesta de solucion.
- `03-design/` decisiones de arquitectura y diseno.
- `04-management/` planeacion y seguimiento.
- `05-development/` setup, estandares y testing.
- `06-deployment/` entornos, CI/CD y monitoreo.
- `07-production/` operacion, incidentes y mejora continua.
- `99-common/` checklist, glosario y configuracion base.

## Planeacion P1 - Notion template (multi-DB)

- `99-common/05-p1-notion-multi-db-plan.md` plan de arquitectura, relaciones, vistas, ritual y DoD.
- `99-common/06-p1-notion-schema-spec.md` especificacion detallada de schema por DB y propiedades.
- `99-common/07-p1-notion-manual-setup-checklist.md` checklist ejecutable para setup manual en Notion.

Cada subproyecto trabaja con su `AGENTS.md` local y su `skills/` local.

## Modelo OpenCode aplicado

- 1 contexto global: `.opencode/context.md`
- Skills globales y locales:
  - Global: `.opencode/skills/global/SKILL.md`
  - Local: `<subproyecto>/skills/SKILL.md`
- MCP centralizado: `.opencode/mcp/servers.template.json`
- Entrypoint de roles: `AGENTS.md`.
- Agentes por rol: `.opencode/agents/`

## Modelo local por subproyecto

- `AGENTS.md` local para scope y reglas del area.
- `skills/SKILL.md` local para convenciones de ejecucion.
- Sin `.opencode/` local en subproyectos.

## Uso rapido

### NPX (recomendado)

```bash
npx rootkid0-initializer my-project
```

### Generar templates Product 2 en Google Drive

```bash
npx rootkid0-initializer drive-templates --dry-run
```

- Comando real: `npx rootkid0-initializer drive-templates --parent-folder-id <DRIVE_FOLDER_ID> --date 2026-04-01 --version v1.0`
- Para root de My Drive: `npx rootkid0-initializer drive-templates --parent-folder-id root --date 2026-04-01 --version v1.0`
- Crea carpetas `02-Proposal`, `04-Management`, `06-Deployment`, `07-Production` y sube templates desde `99-common/templates/product2-lightweight/`.
- Setup completo de credenciales y seguridad en `99-common/08-google-drive-template-generator.md`.

### Politica estricta de secretos (Google Drive)

- Nunca guardar credenciales personales en este repositorio (ni en la raiz, ni subcarpetas).
- `drive-templates` y `export-client` bloquean ejecucion si `GOOGLE_APPLICATION_CREDENTIALS` apunta a una ruta dentro del repo.
- Para uso local, guarda el JSON fuera del proyecto y usa una ruta externa (ejemplos: `C:\\secure\\gdrive\\service-account.json`, `/etc/secrets/gdrive/service-account.json`).
- Si prefieres no usar archivo, usa credenciales por env vars: `GDRIVE_SERVICE_ACCOUNT_EMAIL` + `GDRIVE_SERVICE_ACCOUNT_PRIVATE_KEY`.

### Exportar documento cliente-facing por fase (docs reales)

```bash
npx rootkid0-initializer export-client 04-management --dry-run
```

- Alias corto: `npx rootkid0-initializer publish 04-management --dry-run`
- Fuente: documentos reales de la fase seleccionada (`01-business/`, `02-proposal/`, etc.), usando archivos `NN-*.md`.
- Comando real: `npx rootkid0-initializer export-client 04-management --parent-folder-id <DRIVE_FOLDER_ID> --date 2026-04-01 --version v1.0`
- Crea/usa la carpeta de fase correspondiente en Drive (`01-Business` ... `07-Production`) y sube 1 Google Doc consolidado.
- Naming: `YYYY-MM-DD_<fase>_<slug>_vX.Y`.

### Uso directo de scripts (fallback)

#### Bash

```bash
chmod +x rootkid0-bootstrap/init-project.sh
./rootkid0-bootstrap/init-project.sh my-project
```

#### PowerShell

```powershell
./rootkid0-bootstrap/init-project.ps1 my-project
```

El script crea una carpeta nueva con la estructura actual del repositorio, excluye `rootkid0-bootstrap/` y `automation/`, reemplaza `{{PROJECT_NAME}}`, mantiene `AGENTS.md`, genera un README inicial y ejecuta bootstrap automatico de Notion.

## Setup automatico de Notion (MVP)

El init ejecuta bootstrap Notion automaticamente despues de crear el proyecto en modo MCP-only. Requisitos obligatorios:

- MCP Notion preinstalado/configurado por el usuario (el initializer no instala ni modifica MCP global).
- Archivo global `~/.config/opencode/opencode.json` con `mcp.notion` habilitado (tambien soporta `mcp.servers.notion`).
- OpenCode CLI disponible para ejecutar el flujo de agente que crea la estructura en Notion via MCP.
- Variables opcionales:
  - `NOTION_PARENT_PAGE_ID` (si existe, el root se crea debajo de ese parent)
  - `NOTION_WORKSPACE_NAME` (opcional)

No se requiere `NOTION_TOKEN` en los scripts de bootstrap.

Resultado del bootstrap:

- Crea pagina raiz del proyecto en Notion.
- Si existe `NOTION_PARENT_PAGE_ID`, crea la pagina raiz como hija de ese parent.
- Si no existe `NOTION_PARENT_PAGE_ID`, crea la pagina raiz a nivel workspace del usuario.
- Toda la interaccion con Notion se ejecuta unicamente via MCP (sin llamadas REST directas desde bootstrap).
- Crea paginas por fase: `01-business` a `07-production` y `99-common`.
- Crea secciones placeholder del modelo multi-DB: `Projects`, `Phases`, `Deliverables`, `Backlog`, `Risks`, `Decisions`, `Incidents`.
- Guarda IDs generados en `99-common/notion-bootstrap.output.json` dentro del proyecto creado.

MCP recomendados para configurar: `context7`, `engram`, `notion`.
