# Discovery Operating Model

## Objective

Estandarizar la ejecucion de Discovery para asegurar que el problema este claro, el flujo actual documentado y el alcance definido antes de avanzar.

## Inputs

- Contexto inicial del negocio.
- Stakeholders disponibles para validacion.
- Hipotesis inicial del problema (si existe).

## Mandatory Deliverables

1. `01-business-understanding.md`
2. `02-problem-statement.md`
3. `03-as-is-flow.md`
4. `04-scope-definition.md`
5. `05-assumptions-risks.md`

## Execution Steps

1. Levantar contexto del negocio y actores clave.
2. Capturar sintoma, impacto y causa raiz preliminar.
3. Mapear el flujo actual end-to-end con puntos de falla.
4. Definir alcance in/out sin ambiguedades.
5. Documentar supuestos y riesgos con mitigacion inicial.
6. Validar con negocio antes de cerrar fase.

## Discovery Gate (Go / No-Go)

La fase solo pasa a Proposal si todas las condiciones son verdaderas:

- Problema principal definido en una frase clara.
- Impacto de negocio descrito (tiempo, costo o cliente).
- Flujo as-is completo con actores/sistemas/puntos de falla.
- Alcance incluye explicitamente in-scope y out-of-scope.
- Supuestos y riesgos tienen owner y accion inicial.
- Stakeholder responsable valida el contenido.

Si una condicion falla, el resultado es **No-Go** y se itera en Discovery.

## Validation Checklist

- [ ] `01-business-understanding.md` esta completo y coherente.
- [ ] `02-problem-statement.md` diferencia sintoma vs causa raiz.
- [ ] `03-as-is-flow.md` representa el flujo actual real.
- [ ] `04-scope-definition.md` evita ambiguedad de alcance.
- [ ] `05-assumptions-risks.md` registra riesgos accionables.
- [ ] Existe validacion explicita de negocio.

## Output Format

Al cerrar Discovery, generar un bloque final en `01-business/` con este formato:

```md
## Discovery Decision

- Status: Go | No-Go
- Date: YYYY-MM-DD
- Approved by: <nombre/rol>
- Blocking gaps:
  - <gap 1>
  - <gap 2>
- Next step:
  - Si Go: iniciar `02-proposal/01-proposal.md`
  - Si No-Go: iterar entregables pendientes
```

## Quality Rules

- Prohibido texto decorativo sin valor de decision.
- Cada afirmacion relevante debe tener evidencia en un entregable.
- Si hay dudas de contexto, preguntar antes de asumir.
