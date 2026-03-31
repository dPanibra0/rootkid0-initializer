# Management Operating Model

## Objective

Estandarizar Management para convertir el diseno aprobado en un plan de ejecucion controlado, priorizado y trazable.

## Inputs

- Design aprobado (Go) en `03-design/`.
- Alcance y restricciones confirmadas.
- Riesgos tecnicos y de negocio identificados.

## Mandatory Deliverables

1. `01-project-overview.md`
2. `02-roadmap.md`
3. `03-backlog.md`
4. `04-sprints.md`
5. `05-risks.md`
6. `06-change-log.md`

## Mandatory Content by Deliverable

- `01-project-overview.md`: objetivo, alcance vigente, estado y responsables.
- `02-roadmap.md`: hitos, dependencias y fechas objetivo.
- `03-backlog.md`: items priorizados con owner, criterio de cierre y estado.
- `04-sprints.md`: plan de iteraciones con capacidad y objetivo por sprint.
- `05-risks.md`: riesgos activos con impacto, probabilidad, owner y mitigacion.
- `06-change-log.md`: decisiones y cambios relevantes con fecha y motivo.

## Execution Steps

1. Consolidar alcance y objetivos de entrega.
2. Definir roadmap realista con dependencias.
3. Construir backlog priorizado y accionable.
4. Planificar sprints segun capacidad del equipo.
5. Formalizar registro de riesgos y mitigaciones.
6. Registrar cambios para mantener trazabilidad.

## Management Gate (Go / No-Go)

La fase solo pasa a Development si todas las condiciones son verdaderas:

- El backlog esta priorizado, estimable y con owner por item.
- El roadmap define hitos claros y dependencias criticas.
- Los riesgos principales tienen accion de mitigacion asignada.
- El plan de iteraciones es coherente con la capacidad real.
- Existe acuerdo operativo para iniciar ejecucion tecnica.

Si una condicion falla, el resultado es **No-Go** y se itera en Management.

## Validation Checklist

- [ ] `01-project-overview.md` refleja el estado real del proyecto.
- [ ] `02-roadmap.md` muestra hitos y secuencia ejecutable.
- [ ] `03-backlog.md` evita tareas ambiguas.
- [ ] `04-sprints.md` es consistente con capacidad.
- [ ] `05-risks.md` contiene riesgos accionables con owner.
- [ ] `06-change-log.md` registra decisiones relevantes.

## Output Format

Al cerrar Management, registrar decision en `01-project-overview.md` con este formato:

```md
## Management Decision

- Status: Go | No-Go
- Date: YYYY-MM-DD
- Approved by: <nombre/rol>
- Operational blockers:
  - <bloqueo 1>
  - <bloqueo 2>
- Next step:
  - Si Go: iniciar `05-development/`
  - Si No-Go: ajustar roadmap/backlog/riesgos
```

## Quality Rules

- No incluir decisiones de arquitectura nuevas en esta fase.
- Toda tarea del backlog debe tener criterio de cierre.
- El estado de riesgos debe actualizarse en cada iteracion.
