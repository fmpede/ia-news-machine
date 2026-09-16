# Onboarding paso a paso (operador)

Todo se hace desde la Terminal en la carpeta del proyecto con el entorno activado:

```bash
cd "/Users/fmped/IA news machine" && . .venv/bin/activate
```

Cada clave se guarda en el Keychain de la Mac con `python -m newsmachine.config --set-secret NOMBRE` (pide el valor sin mostrarlo). Nunca se pega en archivos. Al final de cada fase, `python -m newsmachine.config --push-secrets` copia lo nuevo a GitHub Secrets (cifrado) para que el job de las 07:00 pueda usarlo.

Correos: usá alias de Gmail (`fmpede+sintia.es@gmail.com`, `fmpede+sintia.en@gmail.com`, etc.) para que todas las cuentas caigan en tu casilla y cada red tenga un mail distinto.

## Fase A — Base (30 min): Telegram + IA

1. **Bot de Telegram.** En Telegram abrí `@BotFather` → `/newbot` → nombre `Sintia` → usuario `sintia_ops_bot` (o el que esté libre). Copiá el token.
   `python -m newsmachine.config --set-secret TELEGRAM_BOT_TOKEN`
2. **Tu chat id.** Escribile "hola" al bot desde tu cuenta. Después:
   `curl -s "https://api.telegram.org/bot$(security find-generic-password -s sintia -a TELEGRAM_BOT_TOKEN -w)/getUpdates" | grep -o '"chat":{"id":[0-9-]*' | head -1`
   El número es tu chat id. `python -m newsmachine.config --set-secret TELEGRAM_OPERATOR_CHAT_ID`
3. **Canales.** En Telegram → Nuevo canal → público → enlace `sintia_es`, nombre "Sintia". Descripción: *Medio generado con inteligencia artificial y supervisado por un editor humano. Reportamos según fuentes públicas citadas en cada nota.* Foto: `assets/logo/tech.png`. Administradores → agregar `@sintia_ops_bot` con permiso "Publicar mensajes". Repetí con `sintia_en` y la descripción en inglés: *AI-generated media outlet, supervised by a human editor. We report from the public sources cited in each post.*
4. **Gemini (gratis, sin tarjeta).** https://aistudio.google.com → "Get API key" → "Create API key" (en un proyecto nuevo). `--set-secret GEMINI_API_KEY`
5. **Anthropic (pago, centavos por día).** https://console.anthropic.com → Billing → cargar crédito (el mínimo alcanza para semanas) → Limits → límite mensual de gasto: **US$15** → API Keys → Create key "sintia". `--set-secret ANTHROPIC_API_KEY`
6. **Groq (gratis).** https://console.groq.com → API Keys → Create. `--set-secret GROQ_API_KEY`
7. **Verificar.**
   `python -m newsmachine.config --list-secrets` (deben figurar con "keychain" las 5 claves de arriba)
   `python -m newsmachine.llm --selftest` (una respuesta OK por proveedor)
8. **Subir a GitHub Secrets.** `python -m newsmachine.config --push-secrets`
9. **Primer día de prueba, local y sin publicar.** `python -m newsmachine.run --vertical tech --dry-run`
   Te llega el reporte por Telegram y el contenido queda en `out/tech/<fecha>/`. Avisame y lo revisamos juntos antes de publicar en serio.

## Fase B — Redes del día 1 (1 h): Bluesky + Mastodon

10. **Bluesky ×2.** https://bsky.app → Create account con `fmpede+sintia.es@gmail.com`, usuario `sintia-es` (queda `sintia-es.bsky.social`), nombre "Sintia", bio = texto del paso 3, avatar = logo. Settings → Privacy and security → App passwords → Add → nombre `sintia-bot` → copiá la contraseña generada.
    `--set-secret NM_TECH_ES_BSKY_HANDLE` (valor: `sintia-es.bsky.social`) y `--set-secret NM_TECH_ES_BSKY_APP_PASSWORD`
    Repetí con `sintia-en` → `NM_TECH_EN_BSKY_HANDLE` y `NM_TECH_EN_BSKY_APP_PASSWORD`.
11. **Mastodon ×2.** https://mastodon.social → Create account `sintia_es` (si la instancia pide aprobación, puede tardar unas horas; alternativa: `mastodon.online`). Editar perfil → marcar "Esta es una cuenta automatizada" → bio. Preferencias → Desarrollo → Nueva aplicación → nombre `Sintia`, permisos: solo `write:statuses`, `write:media`, `read:statuses` → Enviar → copiá "Tu token de acceso".
    `--set-secret NM_TECH_ES_MASTO_TOKEN`. Repetí con `sintia_en` → `NM_TECH_EN_MASTO_TOKEN`. Si usás otra instancia, cambiá `base_url` en `verticals/tech.yaml`.
12. `python -m newsmachine.config --push-secrets`
13. **Prueba en la nube sin publicar:** `gh workflow run daily.yml -f dry_run=true` y después `gh run watch`. Si el reporte de Telegram llega bien, la primera publicación real la dispara el cron del día siguiente (06:15) o vos con `gh workflow run daily.yml`.

## Fase C — Semana 1: imágenes, voz, X, Meta, LinkedIn

14. **Cloudflare (gratis, respaldo de imágenes).** https://dash.cloudflare.com → crear cuenta → en la página principal copiá el **Account ID** → Perfil → API Tokens → Create Token → plantilla "Workers AI" (Read) → copiá el token.
    `--set-secret CF_ACCOUNT_ID` y `--set-secret CF_API_TOKEN`
15. **Google Cloud Text-to-Speech (opcional, requiere tarjeta, US$0 dentro del cupo mensual).** https://console.cloud.google.com → proyecto nuevo "sintia" → APIs y servicios → Habilitar "Cloud Text-to-Speech API" → Credenciales → Crear credencial → Clave de API → restringirla a esa API → Facturación → vincular tarjeta. `--set-secret GOOGLE_TTS_KEY`. Sin este paso el video usa edge-tts (gratis, no oficial).
16. **X ×2 (pago por uso, ~US$3-5/mes).** Creá `@sintia_es` y `@sintia_en` en https://x.com (teléfono requerido). Con cada cuenta logueada: https://developer.x.com → registrarse como developer (pay-per-use, tarjeta) → Projects & Apps → crear proyecto y app "Sintia" → User authentication settings → Set up: App permissions **Read and write**, Type of App "Web App, Automated App or Bot", Callback `https://fmpede.github.io/ia-news-machine/`, Website igual → Keys and tokens: copiá **API Key**, **API Key Secret**, y generá **Access Token** y **Access Token Secret** (después de fijar Read and write).
    `--set-secret NM_TECH_ES_X_API_KEY`, `NM_TECH_ES_X_API_SECRET`, `NM_TECH_ES_X_ACCESS_TOKEN`, `NM_TECH_ES_X_ACCESS_SECRET` (y los `NM_TECH_EN_X_*` para la otra cuenta).
    Luego en `verticals/tech.yaml` poné `enabled: true` en `x` (es y en).
17. **Instagram + Threads + Facebook ×2 (gratis).**
    a. Creá las cuentas de Instagram `@sintianews` y `@sintianews_en` (teléfono). Configuración → Tipo de cuenta → Cambiar a cuenta profesional → **Creador**. Creá una página de Facebook "Sintia" por idioma y vinculala a cada Instagram (Configuración → Centro de cuentas).
    b. Threads: entrá a https://threads.net con cada Instagram; el usuario de Threads es el mismo de Instagram. Bio con el disclosure.
    c. https://developers.facebook.com → Mis apps → Crear app → caso de uso "Otro" → tipo "Empresa" → nombre "Sintia". Agregar productos **Instagram** y **Threads API**. App Roles → Roles → agregar las dos cuentas de Instagram como **Instagram Testers** y aceptar la invitación desde Instagram (Configuración → Sitios web y apps → Invitaciones).
    d. Tokens: en el panel de Threads API → "User Token Generator" → generar token para cada cuenta (larga duración, 60 días) y anotar el **User ID**. `--set-secret NM_TECH_ES_THREADS_USER_ID`, `NM_TECH_ES_THREADS_TOKEN` (y `_EN_`). Para Instagram: Herramientas → Graph API Explorer → app Sintia → permisos `instagram_basic`, `instagram_content_publish`, `pages_show_list` → Generar token → convertirlo a larga duración (Herramientas → Access Token Debugger → Extend) y obtener el **Instagram User ID**. `--set-secret NM_TECH_ES_IG_USER_ID`, `NM_TECH_ES_IG_TOKEN` (y `_EN_`).
    Los tokens de Meta vencen a los 60 días: cuando lleguemos a esta fase agrego el paso de renovación automática.
18. **LinkedIn (gratis, perfil personal).** https://www.linkedin.com/developers → Create app (requiere una página de LinkedIn; creá "Sintia") → Products → agregar **Share on LinkedIn** y **Sign In with LinkedIn using OpenID Connect** → Auth → OAuth 2.0 tools → generar token con scope `w_member_social` (60 días). `--set-secret NM_TECH_EN_LI_TOKEN`.
19. `python -m newsmachine.config --push-secrets` y `enabled: true` en cada red que ya tenga secrets. Instagram y LinkedIn se activan cuando termine sus publishers (fase 3).

## Fase D — Video: YouTube y TikTok (pedir las auditorías ahora, aprueban en semanas)

20. **YouTube ×2.** Con tu cuenta de Google creá dos canales de marca "Sintia" (ES) y "Sintia EN" (youtube.com → tu perfil → Cambiar de cuenta → Crear canal). Disclosure en la descripción del canal.
    En https://console.cloud.google.com (proyecto "sintia") → habilitar **YouTube Data API v3** → Pantalla de consentimiento OAuth: External, en pruebas, agregá tu Gmail como usuario de prueba → Credenciales → ID de cliente OAuth → tipo **Escritorio** → descargá el JSON. Cuando lleguemos te doy el script que abre el navegador una vez por canal y te devuelve el `REFRESH_TOKEN` (`--set-secret NM_TECH_ES_YT_CLIENT_ID`, `_CLIENT_SECRET`, `_REFRESH_TOKEN` y los `_EN_`).
    **Auditoría** (obligatoria para subir en público): https://support.google.com/youtube/contact/yt_api_form → describí el uso ("publicación automática de videos propios generados con IA en nuestros canales"), URL de política de privacidad y términos: `https://fmpede.github.io/ia-news-machine/terminos/`, y un video demo corto de la app (te lo grabo cuando el pipeline genere el primer video). Hasta la aprobación, los videos llegan al pack por Telegram para subirlos a mano en YouTube Studio.
21. **TikTok ×2.** Creá `@sintia_es` y `@sintia_en`. https://developers.tiktok.com → Register → Manage apps → Create app "Sintia" → agregar **Login Kit** y **Content Posting API** → URL de términos y privacidad (las de arriba) → Submit for review con video demo. Hasta la aprobación, solo publica en privado; el pack trae el MP4 y la caption.

## Fase E — Rutinas cloud (cuando haya 5 días de métricas)

22. https://claude.ai/code → conectar el repo `fmpede/ia-news-machine` → Environments → variables `TELEGRAM_BOT_TOKEN` y `TELEGRAM_OPERATOR_CHAT_ID`. Avisame y creo las dos rutinas con `routines/editor.json` y `routines/morning.json`.

## Fase F — Opcional

23. **Dominio** `sintia.news` (~US$12/año en Cloudflare Registrar, Porkbun o Namecheap). DNS: `CNAME www → fmpede.github.io` y registros A de GitHub Pages para el raíz; en GitHub → Settings → Pages → Custom domain. Después cambiá `brand.site_url` en el YAML y creá el mail `correcciones@sintia.news` (Cloudflare Email Routing es gratis y lo reenvía a tu Gmail).
24. **Google Search Console**: agregar la propiedad del sitio y enviar `sitemap.xml`.
25. **Handles de Bluesky con dominio**: `es.sintia.news` / `en.sintia.news` (Settings → Change handle → I have my own domain).
