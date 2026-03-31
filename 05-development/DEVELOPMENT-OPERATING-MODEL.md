# Development Operating Model

## Objective

Estandarizar Development para ejecutar implementacion tecnica con calidad, trazabilidad y consistencia respecto al diseno aprobado.

## Inputs

- Management aprobado (Go) en `04-management/`.
- Backlog priorizado con owner y criterio de cierre.
- Riesgos y dependencias activas identificadas.

## Mandatory Deliverables

1. `01-setup.md`
2. `02-standards.md`
3. `03-testing.md`
4. `04-structure.md`

## Mandatory Content by Deliverable

- `01-setup.md`: prerequisitos, entorno local y pasos de arranque reproducibles.
- `02-standards.md`: reglas de codigo, convenciones y criterios minimos de calidad.
- `03-testing.md`: estrategia de pruebas y cobertura minima por capa.
- `04-structure.md`: estructura tecnica del proyecto y responsabilidades por modulo.

## Execution Steps

1. Preparar entorno de desarrollo y validar setup.
2. Implementar backlog por prioridad y criterio de cierre.
3. Aplicar estandares de codigo y arquitectura definidos.
4. Ejecutar pruebas continuas en caminos criticos.
5. Registrar decisiones tecnicas relevantes y su impacto.
6. Consolidar estado tecnico para preparar Deployment.

## Development Gate (Go / No-Go)

La fase solo pasa a Deployment si todas las condiciones son verdaderas:

- Los items comprometidos del backlog estan implementados y verificados.
- Existen evidencias de pruebas en caminos criticos.
- La estructura de codigo y estandares estan actualizados.
- No hay bloqueos tecnicos criticos abiertos sin plan.
- El estado tecnico permite preparar release candidate.

Si una condicion falla, el resultado es **No-Go** y se itera en Development.

## Validation Checklist

- [ ] `01-setup.md` permite reproducir el entorno sin pasos ocultos.
- [ ] `02-standards.md` refleja convenciones vigentes.
- [ ] `03-testing.md` define pruebas accionables por tipo.
- [ ] `04-structure.md` explica modulos y limites de responsabilidad.
- [ ] Hay evidencia de pruebas para cambios criticos.
- [ ] Los bloqueos activos tienen owner y siguiente accion.

## Output Format

Al cerrar Development, registrar decision en `01-setup.md` con este formato:

```md
## Development Decision

- Status: Go | No-Go
- Date: YYYY-MM-DD
- Approved by: <nombre/rol tecnico>
- Test evidence:
  - <evidencia 1>
  - <evidencia 2>
- Open blockers:
  - <bloqueo 1>
  - <bloqueo 2>
- Next step:
  - Si Go: iniciar `06-deployment/`
  - Si No-Go: iterar backlog/pruebas/estandares
```

## Quality Rules

- No cerrar tareas sin criterio de aceptacion verificado.
- Evitar deuda tecnica no registrada en backlog o change-log.
- Toda excepcion relevante de calidad debe quedar documentada.
