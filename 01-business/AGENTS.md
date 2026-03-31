# AGENTS

Entrypoint local para trabajo en `01-business`.

## Scope

Define problema, flujo actual, alcance y supuestos de negocio.

## Reglas locales

- Priorizar claridad para stakeholders no tecnicos.
- Mantener trazabilidad entre problema y alcance.
- No avanzar a Proposal sin cumplir el gate de Discovery.

## Discovery Configuration

- Estandar operativo: `01-business/DISCOVERY-OPERATING-MODEL.md`
- Entregables obligatorios:
  - `01-business-understanding.md`
  - `02-problem-statement.md`
  - `03-as-is-flow.md`
  - `04-scope-definition.md`
  - `05-assumptions-risks.md`
- Criterio de paso: todos los entregables completos y gate aprobado.

## Orden de carga recomendado

1. Contexto global: `.opencode/context.md`
2. AGENTS local: `01-business/AGENTS.md`
3. Skill global: `.opencode/skills/global/SKILL.md`
4. Skill local: `01-business/skills/SKILL.md`
5. Rol: `AGENTS.md` (raiz)
