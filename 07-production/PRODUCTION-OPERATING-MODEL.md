# Production Operating Model

## Objective

Estandarizar Production para operar el sistema con confiabilidad, gestionar incidentes de forma predecible y sostener una mejora continua.

## Inputs

- Deployment aprobado (Go) en `06-deployment/`.
- Monitoreo y alertas activos.
- Ownership operativo definido.

## Mandatory Deliverables

1. `01-operations-runbook.md`
2. `02-incident-management.md`
3. `03-performance-capacity.md`
4. `04-continuous-improvement.md`

## Mandatory Content by Deliverable

- `01-operations-runbook.md`: procedimientos operativos, ownership y rutina diaria.
- `02-incident-management.md`: severidades, respuesta, escalamiento y postmortem.
- `03-performance-capacity.md`: indicadores clave, umbrales y plan de capacidad.
- `04-continuous-improvement.md`: backlog de mejoras y criterio de priorizacion.

## Execution Steps

1. Establecer operacion base y responsables.
2. Monitorear continuamente salud, errores y capacidad.
3. Gestionar incidentes con flujo y tiempos de respuesta definidos.
4. Registrar causas raiz y acciones preventivas.
5. Priorizar mejoras con impacto operativo y de negocio.
6. Revisar periodicamente estabilidad y tendencias.

## Production Gate (Healthy / At Risk)

La fase se considera saludable cuando todas las condiciones son verdaderas:

- Runbook operativo actualizado y en uso.
- Flujo de incidentes activo con owner y seguimiento.
- Indicadores de performance/capacidad monitoreados regularmente.
- Mejoras de alto impacto priorizadas y en ejecucion.
- Riesgos operativos criticos bajo control o con plan activo.

Si una condicion falla, el estado es **At Risk** y se requiere plan de correccion.

## Validation Checklist

- [ ] `01-operations-runbook.md` cubre operaciones diarias y escalamiento.
- [ ] `02-incident-management.md` tiene severidades y proceso de postmortem.
- [ ] `03-performance-capacity.md` define umbrales y revisiones.
- [ ] `04-continuous-improvement.md` mantiene backlog de mejoras activo.
- [ ] Hay evidencia de seguimiento operativo periodico.

## Output Format

Al cerrar un ciclo operativo, registrar estado en `01-operations-runbook.md` con este formato:

```md
## Production Status

- Status: Healthy | At Risk
- Date: YYYY-MM-DD
- Reviewed by: <nombre/rol>
- Active incidents:
  - <incidente 1>
  - <incidente 2>
- Top risks:
  - <riesgo 1>
  - <riesgo 2>
- Next actions:
  - <accion 1>
  - <accion 2>
```

## Quality Rules

- No cerrar incidentes sin causa raiz documentada.
- No mantener alertas ruidosas sin ajuste.
- Cada mejora operacional debe tener owner y fecha objetivo.
