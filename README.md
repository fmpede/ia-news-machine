# Sintia · IA News Machine

Medio de novedades tecnológicas **generado con IA** que publica cada día a las 07:00 (Buenos Aires) en redes sociales en español e inglés, con cuentas separadas por idioma. Todo corre en GitHub Actions con proveedores de IA en tier gratuito; una rutina cloud de Claude Code revisa cada semana y propone mejoras vía PR. El esquema se reconfigura por vertical (tecnología → chimentos → cursos) con un YAML, sin tocar código.

## Cómo funciona

```
06:15 ART  daily.yml → ingest → cluster → rank → select → write → qa → media → publish → site
19:00 ART  metrics.yml → engagement de los posts del día
lunes 09:00 ART  rutina "editor en jefe" (Claude Code cloud) → PR con ≤ 3 cambios
```

| Etapa | Qué hace | Modelo |
|---|---|---|
| ingest | RSS, Hacker News, GitHub, arXiv, Google News → `stories` (dedup por URL canónica) | — |
| cluster | agrupa títulos parecidos (Jaccard) | — |
| rank | rúbrica relevancia/viralidad/novedad/riesgo | Gemini Flash → Groq → Haiku |
| select | 6 historias, 1 hero; baja el cuerpo de la nota | — |
| write | por historia × idioma: post, hilo, carrusel, tarjeta, guion de video, artículo, claims | hero: Claude Sonnet 5 · resto: Gemini/Groq |
| qa | reglas determinísticas + veredicto legal/factual; **bloquea, no arregla de fondo** | Claude Haiku 4.5 → Sonnet |
| media | ilustración (Gemini Image → Cloudflare Flux → Pollinations → degradé), tarjetas y carrusel (Pillow), video 1080×1920 (edge-tts + ffmpeg), metadata IPTC "IA" | — |
| publish | Telegram, Bluesky, Mastodon (día 1); X, Threads, Instagram, LinkedIn, YouTube, TikTok (cuando haya secrets). Lo que no sale va al **publish pack** | — |
| site | sitio estático (GitHub Pages): artículos, digest, RSS, sitemap, llms.txt, términos | — |

Estado: SQLite volcado a `state/<vertical>.sql` y commiteado por el workflow (git es la base de datos). Artefactos del día en `out/<vertical>/<fecha>/` (artifact de Actions, 7 días).

## Onboarding del operador (una vez)

Cada fila desbloquea un publisher. Hasta que exista el secret, la red queda `enabled: false` en `verticals/tech.yaml` y su contenido va al pack con caption lista para pegar.

| # | Cuenta / app | Acción | Secret (GitHub → Settings → Secrets → Actions) |
|---|---|---|---|
| 1 | Telegram bot | @BotFather `/newbot`; mandale un mensaje al bot; `curl https://api.telegram.org/bot<TOKEN>/getUpdates` → `chat.id` | `TELEGRAM_BOT_TOKEN`, `TELEGRAM_OPERATOR_CHAT_ID` |
| 2 | Canales Telegram `@sintia_es`, `@sintia_en` | crear canal público; agregar el bot como admin con "Post messages"; poner el disclosure en la descripción | (el `chat_id` ya está en el YAML) |
| 3 | Google AI Studio | crear API key (gratis, sin tarjeta) | `GEMINI_API_KEY` |
| 4 | Anthropic Console | API key + **límite de gasto mensual US$15** | `ANTHROPIC_API_KEY` |
| 5 | Groq | API key gratis | `GROQ_API_KEY` |
| 6 | Bluesky ×2 | crear `sintia-es` y `sintia-en`; bio con disclosure; Settings → App Passwords | `NM_TECH_ES_BSKY_HANDLE`, `NM_TECH_ES_BSKY_APP_PASSWORD`, `NM_TECH_EN_BSKY_HANDLE`, `NM_TECH_EN_BSKY_APP_PASSWORD` |
| 7 | Mastodon ×2 (mastodon.social) | crear cuentas, marcarlas "automatizada"; Preferencias → Desarrollo → Nueva app (`write:statuses write:media read:statuses`) | `NM_TECH_ES_MASTO_TOKEN`, `NM_TECH_EN_MASTO_TOKEN` |
| 8 | Cloudflare (gratis) | Workers AI; token con permiso "Workers AI: Read" | `CF_ACCOUNT_ID`, `CF_API_TOKEN` |
| 9 | Google Cloud TTS (opcional; requiere tarjeta, US$0 dentro del cupo) | habilitar Text-to-Speech API; API key | `GOOGLE_TTS_KEY` |
| 10 | X ×2 | developer.x.com (pago por uso, tarjeta); app Read+Write; tokens OAuth 1.0a | `NM_TECH_{ES,EN}_X_API_KEY`, `_API_SECRET`, `_ACCESS_TOKEN`, `_ACCESS_SECRET` |
| 11 | Meta app (una) → Threads ×2, Instagram Creator ×2 | developers.facebook.com → app → casos de uso Threads e Instagram; agregar tus cuentas como Testers (Standard Access, sin revisión); token de larga duración | `NM_TECH_{ES,EN}_THREADS_USER_ID`, `_THREADS_TOKEN`, `NM_TECH_{ES,EN}_IG_USER_ID`, `_IG_TOKEN` |
| 12 | LinkedIn (perfil personal) | app + producto "Share on LinkedIn" (`w_member_social`) | `NM_TECH_EN_LI_TOKEN` |
| 13 | YouTube ×2 canales | proyecto GCP + YouTube Data API v3 + OAuth Desktop → refresh token; **pedir la auditoría de cumplimiento el día 1** (sin ella solo sube en privado) | `NM_TECH_{ES,EN}_YT_CLIENT_ID`, `_YT_CLIENT_SECRET`, `_YT_REFRESH_TOKEN` |
| 14 | TikTok ×2 | app developer + Content Posting API; **pedir auditoría el día 1** (política de privacidad + video demo) | `NM_TECH_{ES,EN}_TIKTOK_TOKEN` |
| 15 | Claude Code cloud | conectar el repo en claude.ai/code; env vars `TELEGRAM_BOT_TOKEN`, `TELEGRAM_OPERATOR_CHAT_ID`; crear las rutinas con los prompts de `routines/` | — |
| 16 | Dominio (opcional, ~US$12/año) | `sintia.news` → CNAME a GitHub Pages; actualizar `brand.site_url` | — |

Después de cargar un secret: poné `enabled: true` en la red correspondiente de `verticals/tech.yaml`.

## Runbook

```bash
python3 -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt
cp .env.example .env                      # pegar claves (se cargan solas)
python -m newsmachine.config --check      # valida YAML y prompts
python -m newsmachine.llm --selftest      # una llamada por proveedor configurado
python -m newsmachine.run --vertical tech --dry-run        # todo el día, publica al pack
python -m newsmachine.run --vertical tech --from publish   # reintenta solo publicación (idempotente)
python -m newsmachine.run --vertical tech --from publish --network bluesky
python -m newsmachine.metrics --vertical tech --report 7   # reporte para el editor
python -m newsmachine.site --vertical tech && python -m http.server -d site 8000
pytest -q tests/
```

En GitHub: `gh workflow run daily.yml -f dry_run=true`, `gh workflow run publish-retry.yml -f date=2026-09-17 -f network=x`.

## Constitución editorial (la aplica `qa.py`; la rutina editora no puede relajarla)

1. Ninguna afirmación sin fuente pública identificada; cada claim del artículo lleva cita textual y URL de la fuente.
2. La fuente se nombra dentro del texto ("según The Verge"), no solo en el link.
3. Lo no confirmado va en potencial o atribuido.
4. Sobre personas identificables: nada de salud, sexualidad, embarazo, delitos, adicciones o muerte sin cita textual de fuente reputada. En verticales de espectáculos (`people_sensitive: hold`) todo lo que menciona personas requiere aprobación manual.
5. Sin reproducción de texto de fuentes; citas ≤ 25 palabras. Sin imágenes de las fuentes: solo ilustraciones propias (con metadata IPTC "trainedAlgorithmicMedia") o CC0.
6. Sin ingestión de contenido paywalled ni de Reddit.
7. Disclosure en todo: bio, cada post ("🤖 Generado con IA · Fuente: …"), imagen (metadata), video (overlay permanente + frase en la voz), sitio (pie + `/terminos`).
8. Contacto de correcciones visible; respuesta en ≤ 48 h.
9. Cada pieza con ángulo propio (rotación de `editorial.angles`): sin contenido plantillado.

Textos de bio:
- ES: *Medio generado con inteligencia artificial y supervisado por un editor humano. Reportamos según fuentes públicas citadas en cada nota. Correcciones: correcciones@sintia.news*
- EN: *AI-generated media outlet, supervised by a human editor. We report from the public sources cited in each post. Corrections: correcciones@sintia.news*

## Cambiar de vertical o idioma

Copiá `verticals/tech.yaml` a `verticals/<nombre>.yaml`, ajustá `languages`, `geo`, `sources`, `tone`, `audience`, `networks`, `editorial` y `brand`; opcionalmente `prompts/<nombre>/<etapa>.md` pisa el prompt general. Agregá el nombre a la matriz de `daily.yml`. Para cursos: `mode: course` + `syllabus: verticals/<nombre>.syllabus.yaml` (una historia por lección; sin ingest ni cluster).

## Costos (estimado)

Actions, Gemini, Groq, Cloudflare, Google TTS: US$0 · Claude API (QA + hero): ~US$4-6/mes · X pago por uso: ~US$3-4/mes · dominio: ~US$1/mes. Total ≈ US$8-12/mes.

## Limitaciones conocidas

- GitHub Actions cron es "best effort": el job arranca 06:15 para publicar antes de las 07:00.
- Google News entrega links de redirección: el cuerpo de esas notas cae al resumen del feed.
- edge-tts es un servicio no oficial de Microsoft; si se rompe, cargar `GOOGLE_TTS_KEY`.
- YouTube y TikTok publican en privado hasta que aprueben la auditoría: mientras tanto, el pack trae el MP4 y la caption para subirlos a mano.
- Los cupos gratuitos cambian; `newsmachine/llm.py` tiene los límites diarios y el orden de fallback.
