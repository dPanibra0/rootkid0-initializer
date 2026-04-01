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

El init ejecuta bootstrap Notion automaticamente despues de crear el proyecto. Requisitos obligatorios:

- MCP Notion preinstalado/configurado por el usuario (el initializer no instala ni modifica MCP global).
- Archivo global `~/.config/opencode/opencode.json` (preferido) o `~/.config/opencode/mcp-servers.json` (legacy), con entrada `notion`.
- Credencial de Notion resuelta desde MCP Notion (o `NOTION_TOKEN` si la defines manualmente).
- Variables opcionales:
  - `NOTION_PARENT_PAGE_ID` (recomendado para crear bajo una raiz definida)
  - `NOTION_WORKSPACE_NAME` (opcional)

Resultado del bootstrap:

- Crea pagina raiz del proyecto en Notion.
- Si existe `NOTION_PARENT_PAGE_ID`, crea la pagina raiz como hija de ese parent.
- Si no existe `NOTION_PARENT_PAGE_ID`, crea la pagina raiz a nivel workspace del usuario.
- Crea paginas por fase: `01-business` a `07-production` y `99-common`.
- Crea secciones placeholder del modelo multi-DB: `Projects`, `Phases`, `Deliverables`, `Backlog`, `Risks`, `Decisions`, `Incidents`.
- Guarda IDs generados en `99-common/notion-bootstrap.output.json` dentro del proyecto creado.

MCP recomendados para configurar: `context7`, `engram`, `notion`.
