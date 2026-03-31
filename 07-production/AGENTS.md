# AGENTS

Entrypoint local para trabajo en `07-production`.

## Scope

Operar el sistema en produccion con confiabilidad, respuesta a incidentes y mejora continua.

## Reglas locales

- Priorizar estabilidad y recuperacion rapida.
- Registrar incidentes, causas raiz y acciones correctivas.
- Mantener foco en observabilidad y ownership operativo.

## Production Configuration

- Estandar operativo: `07-production/PRODUCTION-OPERATING-MODEL.md`
- Entregables obligatorios:
  - `01-operations-runbook.md`
  - `02-incident-management.md`
  - `03-performance-capacity.md`
  - `04-continuous-improvement.md`
- Criterio de fase: operacion estable, incidentes controlados y mejora continua activa.

## Orden de carga recomendado

1. Contexto global: `.opencode/context.md`
2. AGENTS local: `07-production/AGENTS.md`
3. Skill global: `.opencode/skills/global/SKILL.md`
4. Skill local: `07-production/skills/SKILL.md`
5. Rol: `AGENTS.md` (raiz)
