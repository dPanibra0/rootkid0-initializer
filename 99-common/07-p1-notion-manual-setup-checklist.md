# P1 Checklist - implementacion manual en Notion (MVP)

## Preparacion

- [ ] Crear pagina raiz `P1 - Management Template (multi-DB)`.
- [ ] Confirmar alcance MVP: solo setup manual, sin API ni automatizaciones.
- [ ] Confirmar responsables: owner operativo y aprobador de gate.
- [ ] Tener a mano `99-common/05-p1-notion-multi-db-plan.md` y `99-common/06-p1-notion-schema-spec.md`.

## Crear bases de datos

- [ ] Crear DB `Projects` (tabla).
- [ ] Crear DB `Phases` (tabla).
- [ ] Crear DB `Deliverables` (tabla).
- [ ] Crear DB `Backlog` (tabla).
- [ ] Crear DB `Risks` (tabla).
- [ ] Crear DB `Decisions` (tabla).
- [ ] Crear DB `Incidents` (tabla).

## Configurar propiedades por DB

- [ ] Cargar propiedades de `Projects` segun spec.
- [ ] Cargar propiedades de `Phases` segun spec.
- [ ] Cargar propiedades de `Deliverables` segun spec.
- [ ] Cargar propiedades de `Backlog` segun spec.
- [ ] Cargar propiedades de `Risks` segun spec.
- [ ] Cargar propiedades de `Decisions` segun spec.
- [ ] Cargar propiedades de `Incidents` segun spec.

## Configurar relaciones bidireccionales

- [ ] Configurar relaciones `Projects <->` todas las demas DB.
- [ ] Configurar relaciones `Phases <-> Deliverables/Backlog/Risks/Decisions/Incidents`.
- [ ] Configurar `Backlog <-> Deliverables`.
- [ ] Configurar `Backlog <-> Risks`.
- [ ] Configurar `Backlog <-> Incidents`.
- [ ] Configurar `Risks <-> Decisions`.
- [ ] Configurar `Decisions <-> Incidents`.

## Cargar catalogos y datos semilla

- [ ] En `Phases`, dejar lista de codigos canonicos `01..07` para el proyecto piloto.
- [ ] Definir valores de estados y prioridades en selects/status segun spec.
- [ ] Crear 1 proyecto piloto en `Projects` con owner y objetivo.
- [ ] Crear 7 registros de fase del proyecto piloto (uno por codigo).
- [ ] Crear al menos 1 entregable obligatorio para `01-business` y `02-proposal`.

## Crear vistas requeridas

- [ ] Crear vistas MVP de `Projects` (Dashboard, En riesgo).
- [ ] Crear vistas MVP de `Phases` (Board de gate, Timeline).
- [ ] Crear vistas MVP de `Deliverables` (Pendientes de aprobacion, Por fase).
- [ ] Crear vistas MVP de `Backlog` (Priorizado, Ejecucion, Sin criterio de cierre).
- [ ] Crear vistas MVP de `Risks` (Activos, Alto impacto).
- [ ] Crear vistas MVP de `Decisions` (Pendientes, Aprobadas).
- [ ] Crear vistas MVP de `Incidents` (Activos, Postmortem pendiente).

## Ritual operativo inicial

- [ ] Agendar ritual diario (15 min) para backlog/incidentes/bloqueos.
- [ ] Agendar ritual semanal (45 min) para riesgos/decisiones/entregables.
- [ ] Definir formato de cierre de gate por fase (`Go/No-Go` + condiciones).

## Validacion final (DoD de implementacion manual)

- [ ] Se puede navegar desde un `Project` hacia todas las DB relacionadas.
- [ ] Cada fase tiene owner, criterios de gate y estado actual.
- [ ] Los entregables obligatorios muestran claramente si bloquean gate.
- [ ] Existe backlog priorizado con criterio de cierre por item.
- [ ] Riesgos activos tienen owner y plan de mitigacion.
- [ ] Decisiones e incidentes tienen trazabilidad con evidencia o acciones.
- [ ] El equipo puede correr una revision semanal sin editar el schema.
