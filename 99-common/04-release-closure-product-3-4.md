# Release Notes - v0.2.0

## Objetivo del release

Formalizar el estado de entrega de los productos del framework y publicar una version operativa estable para uso interno.

## Resumen ejecutivo

- Version objetivo: `v0.2.0`
- Fecha de cierre: `2026-04-01`
- Estado global del release: `APROBADO`
- Productos entregados y funcionales: `1`, `3`, `4`
- Producto no incluido en este release: `2` (pendiente)

## Matriz de estado por producto

1. `Producto 1` - Plantilla de Notion: `DONE`
2. `Producto 2` - Estructura documental cliente en Drive: `PENDING`
3. `Producto 3` - Workspace local ejecutable: `DONE`
4. `Producto 4` - Sistema de bootstrap/CLI: `DONE`

## Evidencia por producto

### Producto 1 - Plantilla de Notion (`DONE`)

- Plan funcional multi-DB definido: `99-common/05-p1-notion-multi-db-plan.md`.
- Especificacion de schema detallada por base: `99-common/06-p1-notion-schema-spec.md`.
- Checklist de setup manual listo para ejecucion: `99-common/07-p1-notion-manual-setup-checklist.md`.
- Alcance MVP claro: setup manual en Notion, sin API ni automatizaciones.

### Producto 3 - Workspace local ejecutable (`DONE`)

- Estructura por fases disponible: `01-business/` a `07-production/` y `99-common/`.
- Modelo local por subproyecto aplicado: `AGENTS.md` + `skills/SKILL.md`.
- Sin `.opencode/` local en subproyectos; configuracion centralizada en `.opencode/`.
- Gates operativos definidos por fase (Discovery, Proposal, Design, Management, Development, Deployment, Production).

### Producto 4 - Sistema de bootstrap/CLI (`DONE`)

- Bootstrap Bash operativo: `rootkid0-bootstrap/init-project.sh`.
- Bootstrap PowerShell operativo por implementacion: `rootkid0-bootstrap/init-project.ps1`.
- Reemplazo de placeholders de proyecto soportado con `{{PROJECT_NAME}}`.
- Setup MCP recomendado mediante plantilla: `.opencode/mcp/servers.recommended.template.json`.

### Producto 2 - Estructura documental cliente en Drive (`PENDING`)

- No forma parte del cierre operativo de `v0.2.0`.
- Queda como siguiente entrega para completar el set de 4 productos.

## Validaciones realizadas

- Bash syntax check: `OK` (`init-project.sh`, `helpers.sh`).
- Smoke test Bash de creacion de proyecto: `OK`.
- Validacion de `pwsh` en este entorno: no disponible (`pwsh: command not found`).

## Decisiones de release

- Se libera `v0.2.0` con `Producto 1`, `Producto 3` y `Producto 4` en estado funcional.
- `Producto 2` se mantiene fuera de alcance del release y pasa como pendiente de roadmap inmediato.
- Se mantiene modo MCP recomendado con placeholders para configuracion por entorno.

## Proximo paso

- Crear tag Git `v0.2.0` y publicar nota de release con esta matriz de estado.
