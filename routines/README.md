# Rutinas cloud de Claude Code

Cuerpos listos para crear con `RemoteTrigger {action: "create", body: <json>}` (o desde https://claude.ai/code/routines):

- `editor.json` — editor en jefe, lunes 12:00 UTC (09:00 Buenos Aires), `claude-sonnet-5`, solo PR. Prompt en `editor.md`.
- `morning.json` — revisión matinal opcional, 11:00 UTC (08:00 Buenos Aires). Prompt en `morning.md`.

Requisitos: el repo conectado en claude.ai/code y las variables `TELEGRAM_BOT_TOKEN` y `TELEGRAM_OPERATOR_CHAT_ID` en el entorno cloud. Los prompts son autocontenidos: la rutina arranca sin contexto.
