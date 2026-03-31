# Contexto global - {{PROJECT_NAME}}

## Objetivo

Este repositorio usa una estructura por fases para documentar y ejecutar un proyecto desde negocio hasta despliegue.

## Regla de contexto

- Este archivo es el contexto global unico.
- Cada subproyecto define su entrada local en `<subproyecto>/AGENTS.md`.
- El agente debe cargar contexto global + reglas locales + skills al trabajar en un area.

## Convenciones base

- Mantener cambios MVP y faciles de mantener.
- Preservar estructura por fases (`01-` a `06-`, `99-common`).
- Documentar decisiones cortas y accionables.
- Priorizar consistencia con bootstrap y README.

## Mapa de subproyectos

- `01-business`: descubrimiento del problema.
- `02-proposal`: propuesta de solucion.
- `03-design`: arquitectura y contratos.
- `04-management`: roadmap, backlog y sprints.
- `05-development`: setup, estandares y testing.
- `06-deployment`: entornos, CI/CD y monitoreo.
- `07-production`: operacion, incidentes y evolucion.
- `99-common`: checklist y glosario transversal.

## Integracion OpenCode

- Skills globales: `.opencode/skills/global/`.
- Skills locales: `<subproyecto>/skills/`.
- MCP centralizado: `.opencode/mcp/`.
- Agentes por rol: `.opencode/agents/`.
