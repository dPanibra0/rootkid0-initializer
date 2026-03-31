# AGENTS

Entrypoint local para trabajo en `rootkid0-bootstrap`.

## Scope

Scripts de inicializacion de proyectos (PowerShell y Bash).

## Reglas locales

- Garantizar compatibilidad entre PS1 y SH.
- Mantener salida de uso simple y consistente.

## Orden de carga recomendado

1. Contexto global: `.opencode/context.md`
2. AGENTS local: `rootkid0-bootstrap/AGENTS.md`
3. Skill global: `.opencode/skills/global/SKILL.md`
4. Skill local: `rootkid0-bootstrap/skills/SKILL.md`
5. Rol: `AGENTS.md` (raiz)
