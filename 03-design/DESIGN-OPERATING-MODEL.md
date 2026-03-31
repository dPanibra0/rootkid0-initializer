# Design Operating Model

## Objective

Estandarizar Design para transformar una propuesta aprobada en una definicion tecnica ejecutable, estimable y consistente.

## Inputs

- Proposal aprobado (Go) en `02-proposal/`.
- Alcance in/out confirmado.
- Riesgos y condiciones de avance definidos.

## Mandatory Deliverables

1. `01-architecture-overview.md`
2. `02-to-be-flow.md`
3. `03-components.md`
4. `04-data-model.md`
5. `05-api-contracts.md`
6. `06-error-handling.md`

## Mandatory Content by Deliverable

- `01-architecture-overview.md`: componentes, limites, integraciones y decisiones de alto nivel.
- `02-to-be-flow.md`: flujo futuro extremo a extremo con actores y sistemas.
- `03-components.md`: responsabilidades por componente y dependencias.
- `04-data-model.md`: entidades, ownership, relaciones y reglas clave.
- `05-api-contracts.md`: contratos de entrada/salida, codigos de error y supuestos.
- `06-error-handling.md`: estrategia de errores, reintentos, fallback y observabilidad minima.

## Execution Steps

1. Bajar la solucion propuesta a arquitectura con limites claros.
2. Definir flujo to-be con foco en consistencia de datos.
3. Asignar responsabilidades por componente.
4. Modelar datos y contratos con reglas de negocio trazables.
5. Definir estrategia de errores y comportamiento ante fallas.
6. Validar el diseno con criterios de implementabilidad.

## Design Gate (Go / No-Go)

La fase solo pasa a Management si todas las condiciones son verdaderas:

- Todos los entregables tecnicos obligatorios estan completos.
- El diseno responde al alcance aprobado en Proposal.
- Las decisiones clave y trade-offs estan documentados.
- Los contratos tecnicos son suficientes para estimar tareas.
- Existe validacion tecnica explicita para iniciar planificacion.

Si una condicion falla, el resultado es **No-Go** y se itera en Design.

## Validation Checklist

- [ ] La arquitectura define limites y dependencias claras.
- [ ] El flujo to-be refleja el comportamiento esperado.
- [ ] Componentes y responsabilidades no se superponen.
- [ ] Modelo de datos y contratos son coherentes entre si.
- [ ] Estrategia de errores cubre escenarios criticos.
- [ ] Hay acuerdo tecnico para pasar a Management.

## Output Format

Al cerrar Design, registrar decision en `01-architecture-overview.md` con este formato:

```md
## Design Decision

- Status: Go | No-Go
- Date: YYYY-MM-DD
- Approved by: <nombre/rol tecnico>
- Open risks:
  - <riesgo 1>
  - <riesgo 2>
- Next step:
  - Si Go: iniciar `04-management/`
  - Si No-Go: iterar artefactos de design
```

## Quality Rules

- No incluir backlog detallado en Design (eso pertenece a Management).
- Evitar ambiguedad en ownership de componentes y datos.
- Cada decision de alto impacto debe tener justificacion breve.
