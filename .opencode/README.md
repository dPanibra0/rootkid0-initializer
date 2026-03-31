# OpenCode setup (MVP)

Esta carpeta define una integracion simple para OpenCode con este modelo:

- 1 contexto global en la raiz.
- 1 AGENTS local por subproyecto.
- Skills globales y locales.
- MCP centralizado.
- Entrypoint de agentes en `AGENTS.md` y roles definidos por archivo.

## Estructura

- `.opencode/context.md`: contexto global del proyecto.
- `.opencode/skills/global/SKILL.md`: skill global de convenciones base.
- `<subproyecto>/AGENTS.md`: reglas y scope local del subproyecto.
- `<subproyecto>/skills/SKILL.md`: skill local con reglas del subproyecto.
- `.opencode/mcp/servers.template.json`: plantilla centralizada de MCP.
- `AGENTS.md`: indice canonico para seleccionar rol.
- `.opencode/agents/*.md`: detalle de roles reutilizables.

## Uso recomendado

1. Cargar primero `.opencode/context.md`.
2. Para trabajar en un subproyecto, cargar su `AGENTS.md` local y su `skills/SKILL.md`.
3. Mantener todos los servidores MCP en `.opencode/mcp/servers.template.json`.
4. Entrar por `AGENTS.md` y luego abrir el rol que corresponda.

MCP recomendados del proyecto: `context7`, `engram`, `notion`.

## Ejemplo rapido de consumo (05-development)

- Global: `.opencode/context.md`
- Local: `05-development/AGENTS.md`
- Skill global: `.opencode/skills/global/SKILL.md`
- Skill local: `05-development/skills/SKILL.md`
- Agente sugerido: `AGENTS.md` -> `implementer`

Con esto se combina el contexto comun con las reglas especificas del area.
