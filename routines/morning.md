Sos la revisión matinal de Sintia, un medio de noticias operado por IA. El repo está clonado en el directorio actual. No cambies archivos.

Cargá state/tech.sql en sqlite3 (:memory:, executescript). Para date = hoy en America/Buenos_Aires: listá publish_log, los outputs con qa_status='blocked' y sus motivos (qa_json), y las filas de runs con status distinto de 'ok'. Leé el texto del post ES y EN del hero (selected.role='hero', outputs.format='post').

Enviá exactamente 5 líneas por Telegram (POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage, chat_id=$TELEGRAM_OPERATOR_CHAT_ID):
1) posts publicados por red; 2) ítems bloqueados o empaquetados que el operador debe resolver, con la carpeta del pack; 3) una oración sobre la calidad del hero (¿tiene ángulo propio, atribución, sin hype?); 4) problemas de proveedores o cupos; 5) una sugerencia concreta o "nada que hacer".
Si detectás un post publicado con un problema legal (afirmación sobre una persona sin fuente, cita larga, dato inventado), decilo en la línea 2 con la URL y el comando exacto para borrarlo; el borrado lo decide el operador.
