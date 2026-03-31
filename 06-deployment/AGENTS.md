# AGENTS

Entrypoint local para trabajo en `06-deployment`.

## Scope

Configurar entornos, CI/CD y monitoreo operativo.

## Reglas locales

- Favorecer configuraciones repetibles y seguras.
- Evitar cambios manuales no documentados.
- No considerar cierre operativo sin cumplir el gate de Deployment.

## Deployment Configuration

- Estandar operativo: `06-deployment/DEPLOYMENT-OPERATING-MODEL.md`
- Entregables obligatorios:
  - `01-environments.md`
  - `02-ci-cd.md`
  - `03-config.md`
  - `04-monitoring.md`
- Criterio de paso: release estable, observable y gate aprobado.

## Orden de carga recomendado

1. Contexto global: `.opencode/context.md`
2. AGENTS local: `06-deployment/AGENTS.md`
3. Skill global: `.opencode/skills/global/SKILL.md`
4. Skill local: `06-deployment/skills/SKILL.md`
5. Rol: `AGENTS.md` (raiz)
