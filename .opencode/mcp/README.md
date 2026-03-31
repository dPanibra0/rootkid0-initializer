# MCP centralizado

Configura todos los servidores MCP en esta carpeta para evitar definiciones duplicadas.

- Plantilla base: `.opencode/mcp/servers.template.json`.
- Plantilla recomendada (requiere ajuste): `.opencode/mcp/servers.recommended.template.json`.
- Copia esta plantilla al formato que use tu cliente OpenCode.
- Mantener una sola fuente de verdad para endpoints, comandos y variables.

## MCPs recomendados del proyecto

- `context7`
- `engram`
- `notion`

## Recomendacion de uso

- Mantener la configuracion MCP a nivel global de usuario.
- Usar `servers.template.json` como baseline estable.
- Tomar `servers.recommended.template.json` como punto de partida para agregar `context7`, `engram` y `notion` segun tu entorno.

Sugerencia: referenciar esta carpeta desde scripts de setup del equipo.
