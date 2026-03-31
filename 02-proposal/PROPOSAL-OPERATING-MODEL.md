# Proposal Operating Model

## Objective

Estandarizar Proposal para convertir Discovery en una propuesta aprobable, con valor de negocio claro y alcance controlado.

## Inputs

- Discovery aprobado (Go) en `01-business/`.
- Problema, impacto y alcance base definidos.
- Riesgos y supuestos relevantes identificados.

## Mandatory Deliverable

1. `01-proposal.md`

## Mandatory Content in `01-proposal.md`

- Resumen del problema y su impacto.
- Flujo actual resumido y puntos criticos.
- Solucion propuesta a alto nivel.
- Beneficios esperados y metrica de exito.
- Alcance in-scope / out-of-scope.
- Riesgos principales y mitigacion inicial.

## Execution Steps

1. Resumir Discovery en lenguaje de negocio.
2. Formular propuesta de solucion sin entrar en detalle de implementacion.
3. Definir valor esperado (resultado medible).
4. Cerrar alcance y exclusiones para evitar ambiguedad.
5. Validar propuesta con stakeholders clave.
6. Registrar decision y condiciones de avance.

## Proposal Gate (Go / No-Go)

La fase solo pasa a Design si todas las condiciones son verdaderas:

- El problema y su impacto son claros para negocio y equipo.
- La solucion propuesta responde al problema correcto.
- El valor esperado esta explicitado con criterio medible.
- El alcance in/out esta definido sin ambiguedad.
- Existe aprobacion explicita de negocio para avanzar.

Si una condicion falla, el resultado es **No-Go** y se itera en Proposal.

## Validation Checklist

- [ ] `01-proposal.md` incluye problema, solucion, valor y alcance.
- [ ] Los beneficios son concretos y medibles.
- [ ] Las exclusiones estan explicitas.
- [ ] Los riesgos clave tienen mitigacion inicial.
- [ ] La aprobacion de negocio esta registrada.

## Output Format

Al cerrar Proposal, agregar bloque final en `01-proposal.md` con este formato:

```md
## Proposal Decision

- Status: Go | No-Go
- Date: YYYY-MM-DD
- Approved by: <nombre/rol>
- Conditions to proceed:
  - <condicion 1>
  - <condicion 2>
- Next step:
  - Si Go: iniciar `03-design/`
  - Si No-Go: ajustar `01-proposal.md`
```

## Quality Rules

- Evitar detalle tecnico de implementacion en esta fase.
- Toda afirmacion de valor debe poder validarse.
- Si falta contexto de negocio, preguntar antes de asumir.
