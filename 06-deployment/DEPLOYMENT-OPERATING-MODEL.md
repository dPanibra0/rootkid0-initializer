# Deployment Operating Model

## Objective

Estandarizar Deployment para liberar cambios de forma segura, repetible y observable, minimizando riesgo operativo.

## Inputs

- Development aprobado (Go) en `05-development/`.
- Release candidate disponible.
- Configuracion y ambientes listos para despliegue.

## Mandatory Deliverables

1. `01-environments.md`
2. `02-ci-cd.md`
3. `03-config.md`
4. `04-monitoring.md`

## Mandatory Content by Deliverable

- `01-environments.md`: definicion de ambientes, diferencias controladas y responsables.
- `02-ci-cd.md`: pipeline de build/test/deploy y condiciones de promotion.
- `03-config.md`: variables, secretos, control de cambios y estrategia de rollback.
- `04-monitoring.md`: logs, metricas, alertas y ownership operativo.

## Execution Steps

1. Validar paridad entre ambientes y prerequisitos de release.
2. Ejecutar pipeline CI/CD con checks obligatorios.
3. Aplicar cambios de configuracion con versionado.
4. Ejecutar despliegue controlado y verificar salud inicial.
5. Activar monitoreo y alertas para observabilidad temprana.
6. Registrar resultado de release y acciones post-deploy.

## Deployment Gate (Go / No-Go)

La fase solo se considera aprobada si todas las condiciones son verdaderas:

- El pipeline de despliegue completa sin errores criticos.
- Existe plan de rollback probado o documentado y aplicable.
- Monitoreo y alertas estan activos con ownership definido.
- La configuracion de runtime esta validada por ambiente.
- Hay validacion operativa inicial post-deploy.

Si una condicion falla, el resultado es **No-Go** y se itera en Deployment.

## Validation Checklist

- [ ] `01-environments.md` refleja entornos reales y responsables.
- [ ] `02-ci-cd.md` documenta flujo y gates del pipeline.
- [ ] `03-config.md` define control de cambios y rollback.
- [ ] `04-monitoring.md` incluye alertas y canales de respuesta.
- [ ] El release candidate fue desplegado y verificado.
- [ ] Los incidentes iniciales (si existen) tienen plan de accion.

## Output Format

Al cerrar Deployment, registrar decision en `01-environments.md` con este formato:

```md
## Deployment Decision

- Status: Go | No-Go
- Date: YYYY-MM-DD
- Approved by: <nombre/rol ops>
- Release version: <version>
- Monitoring status: Activo | Parcial | Inactivo
- Rollback status: Listo | No listo
- Open incidents:
  - <incidente 1>
  - <incidente 2>
- Next step:
  - Si Go: operar y mantener en Production
  - Si No-Go: corregir pipeline/config/observabilidad
```

## Quality Rules

- No desplegar cambios sin criterio de rollback.
- No cerrar fase sin observabilidad minima activa.
- Cada incidente de despliegue debe quedar registrado con owner.
