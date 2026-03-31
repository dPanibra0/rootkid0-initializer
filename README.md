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

### Bash

```bash
chmod +x rootkid0-bootstrap/init-project.sh
./rootkid0-bootstrap/init-project.sh my-project

# Opcional: configurar MCP global baseline
./rootkid0-bootstrap/init-project.sh --setup-mcp my-project
```

### PowerShell

```powershell
./rootkid0-bootstrap/init-project.ps1 my-project

# Opcional: configurar MCP global baseline
./rootkid0-bootstrap/init-project.ps1 -SetupMcp my-project
```

El script crea una carpeta nueva con la estructura actual del repositorio, excluye `rootkid0-bootstrap/` y `automation/`, reemplaza `{{PROJECT_NAME}}`, mantiene `AGENTS.md` y genera un README inicial.

MCP recomendados para configurar: `context7`, `engram`, `notion`.
