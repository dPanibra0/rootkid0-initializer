# Release Closure - Product 3 and 4

## Scope

Este documento cierra formalmente:

- Producto 3: Estructura local ejecutable.
- Producto 4: CLI / bootstrap initializer.

## Final Decision

- Product 3 Status: DONE
- Product 4 Status: DONE
- Closure date: 2026-03-31
- Closure mode: Opcion 1 (MCP recomendados con placeholders, sin bloqueo de release)

## Evidence - Product 3

- Estructura por fases disponible: `01-business/` a `07-production/` y `99-common/`.
- Modelo local por subproyecto aplicado: `AGENTS.md` + `skills/SKILL.md`.
- Sin `.opencode/` local en subproyectos.
- OpenCode global centralizado en `.opencode/`.
- Gates operativos definidos fase por fase (Discovery, Proposal, Design, Management, Development, Deployment, Production).

## Evidence - Product 4

- Bootstrap Bash operativo: `rootkid0-bootstrap/init-project.sh`.
- Bootstrap PowerShell operativo por implementacion: `rootkid0-bootstrap/init-project.ps1`.
- Opcion MCP recomendada (no obligatoria):
  - Bash: `--setup-mcp`
  - PowerShell: `-SetupMcp`
- Placeholders de proyecto reemplazables con `{{PROJECT_NAME}}`.

## Validation Summary

- Bash syntax check: OK (`init-project.sh`, `helpers.sh`).
- Smoke test Bash (creacion de proyecto desde baseline actual): OK.
- Validacion de `pwsh` en este entorno: no disponible (`pwsh: command not found`).

## Accepted Deferments (Post-Release)

- MCP `context7`, `engram`, `notion` quedan como recomendados con plantilla y placeholders.
- Configuracion final de comandos/args/env especificos se define por entorno de equipo.

## Immediate Next Step

- Publicar este estado en repositorio Git como cierre de Producto 3 y 4.
