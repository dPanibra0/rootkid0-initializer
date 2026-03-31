# P1 Plan - Notion management template (multi-DB)

## Objetivo

Definir un template de gestion en Notion, basado en multiples bases relacionadas, para operar el framework por fases `01..07` con trazabilidad de gates, entregables y trabajo operativo.

Este artefacto cubre solo planeacion y diseno funcional del template. No incluye aprovisionamiento por API en esta iteracion.

## Scope

- Disenar arquitectura multi-DB para gestion de proyectos.
- Definir modelo de relaciones entre `Projects`, `Phases`, `Deliverables`, `Backlog`, `Risks`, `Decisions` e `Incidents`.
- Establecer vistas minimas para operar el ciclo semanal y los gates.
- Definir ritual operativo para mantener el sistema vivo y util.
- Alinear nombres y flujo con el modelo por fases del repositorio y filosofia de gate `Go/No-Go`.

## Out of Scope

- Integracion con Notion API, scripts o IaC.
- Automatizaciones avanzadas (recordatorios, webhooks, sync con Jira, etc.).
- Dashboards ejecutivos de BI fuera de Notion.
- Ajustes de proceso fuera del framework actual `01..07`.

## Arquitectura multi-DB (opcion 1)

Se adopta un modelo de 7 bases separadas y relacionadas, en lugar de una base unica, para mantener responsabilidades claras y consultas operativas simples:

1. `Projects` (nivel programa/proyecto)
2. `Phases` (control del flujo `01..07` y gate)
3. `Deliverables` (evidencia y cierre por fase)
4. `Backlog` (ejecucion de trabajo)
5. `Risks` (riesgo vivo con mitigacion)
6. `Decisions` (trazabilidad de decisiones)
7. `Incidents` (incidentes y aprendizaje operativo)

Decision de arquitectura MVP:

- Relacionar todo contra `Projects` para trazabilidad transversal.
- Usar `Phases` como columna vertebral del ciclo `01..07`.
- Conectar `Deliverables` y `Backlog` para reflejar plan vs evidencia.
- Conectar `Risks`, `Decisions` e `Incidents` para cerrar el loop de gobierno.

## Modelo de relaciones

Relaciones principales (cardinalidad esperada):

- `Projects` 1 -> N `Phases`
- `Projects` 1 -> N `Deliverables`
- `Projects` 1 -> N `Backlog`
- `Projects` 1 -> N `Risks`
- `Projects` 1 -> N `Decisions`
- `Projects` 1 -> N `Incidents`
- `Phases` 1 -> N `Deliverables`
- `Phases` 1 -> N `Backlog`
- `Phases` 1 -> N `Risks`
- `Phases` 1 -> N `Decisions`
- `Phases` 1 -> N `Incidents`
- `Backlog` N -> 1 `Deliverables` (item que produce o actualiza evidencia)
- `Backlog` N -> 1 `Risks` (item de mitigacion)
- `Decisions` N -> 1 `Risks` (decision que responde a un riesgo)
- `Incidents` N -> 1 `Decisions` (decision tomada por incidente)
- `Incidents` N -> 1 `Backlog` (accion correctiva/preventiva)

## Vistas requeridas (MVP)

### Projects

- `Proyectos - Dashboard`: tabla con estado global, salud y gate actual.
- `Proyectos - En riesgo`: filtro por salud `Amarillo/Rojo`.

### Phases

- `Fases - Board de gate`: columnas por estado (`Not started`, `In progress`, `Ready for gate`, `Go`, `No-Go`).
- `Fases - Timeline`: fechas plan vs fecha de gate.

### Deliverables

- `Entregables - Pendientes de aprobacion`: estado != `Approved` y `obligatorio = true`.
- `Entregables - Por fase`: agrupado por `codigo_fase`.

### Backlog

- `Backlog - Priorizado`: tabla por prioridad `P0..P3`.
- `Backlog - Ejecucion`: board por estado.
- `Backlog - Sin criterio de cierre`: control de calidad.

### Risks

- `Riesgos - Activos`: estado abierto o mitigando.
- `Riesgos - Alto impacto`: impacto `Alto` y probabilidad `Media/Alta`.

### Decisions

- `Decisiones - Pendientes`: estado `Propuesta`.
- `Decisiones - Aprobadas`: historial de decisiones vigentes.

### Incidents

- `Incidentes - Activos`: estado != `Cerrado`.
- `Incidentes - Postmortem pendiente`: sin `postmortem_url` con severidad `SEV1/SEV2`.

## Ritual de operacion

Cadencia minima recomendada:

- Diario (15 min): actualizar `Backlog`, `Incidents` y bloqueadores de `Phases`.
- Semanal (45 min): revisar `Risks`, decisiones pendientes y estado de entregables obligatorios.
- Cierre de fase (60 min): validar evidencia en `Deliverables`, registrar `Decision` del gate (`Go/No-Go`) y actualizar siguiente fase.

Secuencia de operacion por fase:

1. Abrir fase en `Phases` con owner y criterios de gate.
2. Planificar trabajo en `Backlog` ligado a la fase.
3. Ejecutar y adjuntar evidencia en `Deliverables`.
4. Revisar riesgos/incidentes y registrar decisiones.
5. Ejecutar gate `Go/No-Go` y registrar resultado.

## Definition of Done (P1 planning)

P1 se considera completo cuando:

- Existe este plan y esta aprobado por el responsable operativo.
- Existe especificacion de schema detallada por DB y propiedad.
- Existe checklist manual de implementacion ejecutable en Notion.
- Se mantienen nombres y flujo alineados con `01..07` y gates del framework.
- La documentacion queda visible desde README raiz.
