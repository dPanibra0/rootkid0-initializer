# P1 Schema Spec - Notion multi-DB relacional

## Convenciones generales

- Modelo objetivo: `multi-DB` (7 bases relacionadas).
- Idioma de propiedades: espanol (snake_case sin acentos).
- Tipo `required`: obligatorio para crear registro usable.
- Tipo `optional`: se completa segun avance operativo.
- Fases canonicas: `01-business`, `02-proposal`, `03-design`, `04-management`, `05-development`, `06-deployment`, `07-production`.

## 1) DB: Projects

Proposito: entidad raiz para trazabilidad transversal del proyecto.

| Propiedad | Tipo | Req/Opt | Proposito |
|---|---|---|---|
| nombre_proyecto | Title | required | Nombre visible del proyecto. |
| codigo_proyecto | Rich text | required | Identificador corto interno (ej: RK-001). |
| estado_global | Select | required | Estado general (`On track`, `At risk`, `Blocked`, `Done`). |
| owner_proyecto | People | required | Responsable principal operativo. |
| sponsor_negocio | People | optional | Sponsor o aprobador de negocio. |
| objetivo_resumen | Rich text | required | Objetivo concreto en 1-3 lineas. |
| fecha_inicio_plan | Date | required | Inicio planificado del proyecto. |
| fecha_fin_objetivo | Date | optional | Fecha objetivo de cierre global. |
| salud | Select | required | Semaforo (`Verde`, `Amarillo`, `Rojo`). |
| gate_actual | Relation -> Phases | optional | Fase actual o fase en gate. |
| fases | Relation -> Phases | optional | Relacion inversa de fases del proyecto. |
| entregables | Relation -> Deliverables | optional | Relacion inversa de entregables. |
| backlog_items | Relation -> Backlog | optional | Relacion inversa de backlog. |
| riesgos | Relation -> Risks | optional | Relacion inversa de riesgos. |
| decisiones | Relation -> Decisions | optional | Relacion inversa de decisiones. |
| incidentes | Relation -> Incidents | optional | Relacion inversa de incidentes. |

## 2) DB: Phases

Proposito: controlar ejecucion por fase `01..07` y su gate `Go/No-Go`.

| Propiedad | Tipo | Req/Opt | Proposito |
|---|---|---|---|
| nombre_fase | Title | required | Nombre de la fase en el proyecto. |
| codigo_fase | Select | required | Valor canonico `01-business` ... `07-production`. |
| orden_fase | Number | required | Orden numerico 1..7 para timeline/reporting. |
| proyecto | Relation -> Projects | required | Proyecto al que pertenece la fase. |
| estado_fase | Status | required | Flujo: `Not started`, `In progress`, `Ready for gate`, `Done`. |
| resultado_gate | Select | required | `Pending`, `Go`, `No-Go`. |
| owner_fase | People | required | Responsable de mover la fase y ejecutar gate. |
| fecha_inicio_plan | Date | optional | Inicio planificado de la fase. |
| fecha_fin_plan | Date | optional | Fin planificado de la fase. |
| fecha_gate | Date | optional | Fecha del ultimo gate ejecutado. |
| criterios_gate | Rich text | required | Criterios minimos para aprobar fase. |
| bloqueadores | Rich text | optional | Bloqueos activos de la fase. |
| entregables_fase | Relation -> Deliverables | optional | Evidencia asociada a la fase. |
| backlog_fase | Relation -> Backlog | optional | Trabajo de ejecucion ligado a la fase. |
| riesgos_fase | Relation -> Risks | optional | Riesgos detectados en fase. |
| decisiones_fase | Relation -> Decisions | optional | Decisiones tomadas en fase. |
| incidentes_fase | Relation -> Incidents | optional | Incidentes ocurridos en fase. |

## 3) DB: Deliverables

Proposito: registrar evidencia documental/operativa para avanzar gates.

| Propiedad | Tipo | Req/Opt | Proposito |
|---|---|---|---|
| nombre_entregable | Title | required | Nombre del entregable. |
| tipo_entregable | Select | required | `Documento`, `Demo`, `Acta`, `Decision record`, `Checklist`. |
| proyecto | Relation -> Projects | required | Proyecto asociado. |
| fase | Relation -> Phases | required | Fase donde aplica como evidencia. |
| estado_entregable | Status | required | `Draft`, `In review`, `Approved`. |
| obligatorio | Checkbox | required | Si bloquea gate (`true`) o es informativo (`false`). |
| owner_entregable | People | required | Responsable del entregable. |
| criterio_aceptacion | Rich text | required | Regla concreta de aceptacion. |
| url_documento | URL | optional | Link al documento fuente o evidencia. |
| version | Number | optional | Control basico de version. |
| fecha_compromiso | Date | optional | Fecha objetivo para tenerlo listo. |
| fecha_aprobacion | Date | optional | Fecha en que se aprueba. |
| backlog_origen | Relation -> Backlog | optional | Item que produce este entregable. |

## 4) DB: Backlog

Proposito: planificar y ejecutar trabajo accionable por fase.

| Propiedad | Tipo | Req/Opt | Proposito |
|---|---|---|---|
| titulo_item | Title | required | Tarea o item de trabajo. |
| proyecto | Relation -> Projects | required | Proyecto asociado. |
| fase_objetivo | Relation -> Phases | required | Fase donde se consume/entrega. |
| tipo_item | Select | required | `Feature`, `Task`, `Bug`, `Debt`, `Ops`. |
| prioridad | Select | required | `P0`, `P1`, `P2`, `P3`. |
| estado_item | Status | required | Flujo operativo de trabajo. |
| owner_item | People | required | Responsable de ejecucion. |
| estimacion_horas | Number | optional | Estimacion simple en horas. |
| fecha_objetivo | Date | optional | Fecha objetivo de cierre. |
| fecha_cierre | Date | optional | Fecha real de cierre. |
| criterio_cierre | Rich text | required | Definicion concreta de terminado. |
| sprint_lote | Rich text | optional | Referencia de sprint o lote. |
| deliverable_destino | Relation -> Deliverables | optional | Entregable impactado por el item. |
| riesgo_relacionado | Relation -> Risks | optional | Riesgo mitigado por este item. |
| dependencia_items | Relation -> Backlog (self) | optional | Dependencias entre items. |

## 5) DB: Risks

Proposito: controlar riesgos de negocio/tecnicos con mitigacion activa.

| Propiedad | Tipo | Req/Opt | Proposito |
|---|---|---|---|
| titulo_riesgo | Title | required | Riesgo expresado en lenguaje claro. |
| proyecto | Relation -> Projects | required | Proyecto asociado. |
| fase_detectada | Relation -> Phases | required | Fase donde se detecta. |
| categoria | Select | required | `Negocio`, `Tecnico`, `Operativo`, `Dependencia`. |
| probabilidad | Select | required | `Baja`, `Media`, `Alta`. |
| impacto | Select | required | `Bajo`, `Medio`, `Alto`. |
| estado_riesgo | Select | required | `Abierto`, `Mitigando`, `Cerrado`. |
| owner_riesgo | People | required | Responsable de seguimiento. |
| plan_mitigacion | Rich text | required | Accion concreta para reducir impacto/probabilidad. |
| trigger_alerta | Rich text | optional | Senal temprana para detectar materializacion. |
| backlog_mitigacion | Relation -> Backlog | optional | Trabajo creado para mitigarlo. |
| decision_relacionada | Relation -> Decisions | optional | Decision que trata este riesgo. |
| fecha_revision | Date | required | Proxima revision comprometida. |
| fecha_cierre | Date | optional | Cierre formal del riesgo. |

## 6) DB: Decisions

Proposito: guardar decisiones relevantes con contexto y trazabilidad.

| Propiedad | Tipo | Req/Opt | Proposito |
|---|---|---|---|
| titulo_decision | Title | required | Nombre corto de la decision. |
| proyecto | Relation -> Projects | required | Proyecto asociado. |
| fase | Relation -> Phases | required | Fase donde se toma. |
| tipo_decision | Select | required | `Scope`, `Producto`, `Arquitectura`, `Operacion`. |
| estado_decision | Select | required | `Propuesta`, `Aprobada`, `Descartada`. |
| fecha_decision | Date | required | Fecha de toma o validacion. |
| tomada_por | People | required | Quien toma o aprueba la decision. |
| contexto | Rich text | required | Situacion que obliga a decidir. |
| decision_tomada | Rich text | required | Resolucion concreta. |
| impacto | Rich text | required | Impacto esperado en alcance, tiempo o riesgo. |
| tradeoffs | Rich text | optional | Costos y renuncias aceptadas. |
| entregable_evidencia | Relation -> Deliverables | optional | Documento/acta que la respalda. |
| riesgo_relacionado | Relation -> Risks | optional | Riesgo asociado a la decision. |
| incidente_relacionado | Relation -> Incidents | optional | Incidente que gatillo la decision. |

## 7) DB: Incidents

Proposito: operar incidentes y convertirlos en aprendizaje accionable.

| Propiedad | Tipo | Req/Opt | Proposito |
|---|---|---|---|
| titulo_incidente | Title | required | Nombre del incidente. |
| proyecto | Relation -> Projects | required | Proyecto asociado. |
| fase_afectada | Relation -> Phases | required | Fase impactada al ocurrir. |
| severidad | Select | required | `SEV1`, `SEV2`, `SEV3`, `SEV4`. |
| estado_incidente | Status | required | `Abierto`, `Investigando`, `Resuelto`, `Cerrado`. |
| owner_incidente | People | required | Responsable de coordinacion. |
| fecha_inicio | Date (date-time) | required | Momento de deteccion. |
| fecha_resolucion | Date (date-time) | optional | Momento de mitigacion/resolucion. |
| impacto_negocio | Rich text | required | Efecto concreto sobre usuario/negocio. |
| causa_raiz | Rich text | optional | Hallazgo de analisis causal. |
| accion_inmediata | Rich text | required | Contencion ejecutada. |
| accion_preventiva | Rich text | optional | Accion para evitar recurrencia. |
| decision_relacionada | Relation -> Decisions | optional | Decision disparada por el incidente. |
| backlog_correctivo | Relation -> Backlog | optional | Item correctivo/preventivo asociado. |
| postmortem_url | URL | optional | Documento de postmortem final. |

## Contrato minimo de relaciones cruzadas

Implementar como minimo estas relaciones bidireccionales en Notion:

1. `Projects <-> Phases`
2. `Projects <-> Deliverables`
3. `Projects <-> Backlog`
4. `Projects <-> Risks`
5. `Projects <-> Decisions`
6. `Projects <-> Incidents`
7. `Phases <-> Deliverables`
8. `Phases <-> Backlog`
9. `Phases <-> Risks`
10. `Phases <-> Decisions`
11. `Phases <-> Incidents`
12. `Backlog <-> Deliverables`
13. `Backlog <-> Risks`
14. `Backlog <-> Incidents`
15. `Risks <-> Decisions`
16. `Decisions <-> Incidents`

## Datos semilla recomendados

- Cargar en `Phases` los 7 codigos canonicos para cada proyecto nuevo.
- Dejar al menos 1 entregable obligatorio por fase antes de iniciar ejecucion.
- Crear vistas base antes de cargar backlog masivo para evitar deuda de orden.
