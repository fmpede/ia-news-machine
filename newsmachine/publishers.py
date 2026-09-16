"""Publicadores por red. Cada uno: publish_<red>(cfg, net, lang, story, outputs) -> {"post_id", "url"}.

Secrets: os.environ[f"{net['env']}_<CAMPO>"] (ver .env.example). Telegram usa envs
globales (TELEGRAM_BOT_TOKEN, TELEGRAM_OPERATOR_CHAT_ID), sin prefijo NM_.
Falta una credencial -> NotConfigured. Cualquier otra falla, excepción normal
(la llama qa/run.py y hace el log + pack de fallback).
"""
import datetime as dt, io, json, os, re, shutil, time
from pathlib import Path

import requests

from . import config

TIMEOUT = 30
URL_RE = re.compile(r"https?://\S+")


class NotConfigured(Exception):
    pass


# ---------- helpers compartidos ----------

def _env(net, field):
    val = os.environ.get(f"{net['env']}_{field}")
    if not val:
        raise NotConfigured(f"falta {net['env']}_{field}")
    return val


def _post_text(cfg, net_name, outputs):
    text = outputs["post"]["content"]["text"]
    limit = cfg["editorial"]["network_limits"].get(net_name)
    if limit and len(text) > limit:
        raise ValueError("too long")
    return text


def _image_paths(outputs, fmt):
    """Rutas locales de imagen para un formato: file_path puede ser un .json con
    una lista de paths, un directorio, o un path único."""
    fp = (outputs.get(fmt) or {}).get("file_path")
    if not fp:
        return []
    p = Path(fp)
    if fp.endswith(".json"):
        return [s for s in json.loads(p.read_text()) if Path(s).exists()] if p.exists() else []
    if p.is_dir():
        return sorted(str(x) for x in p.iterdir() if x.is_file())
    return [fp] if p.exists() else []


def _pick_images(outputs, limit=4):
    """Primer formato con imagen disponible entre card, illustration, carousel."""
    for fmt in ("card", "illustration", "carousel"):
        imgs = _image_paths(outputs, fmt)
        if imgs:
            return imgs[:limit]
    return []


def _alt(outputs, story):
    return ((outputs.get("illustration") or {}).get("content") or {}).get("alt", "") or story["title"]


def _now_iso():
    return dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"


def facets(text):
    """Facets de link de AT Protocol: offsets en bytes UTF-8 de cada URL en el texto."""
    out = []
    for m in URL_RE.finditer(text):
        start = len(text[:m.start()].encode("utf-8"))
        end = start + len(m.group().encode("utf-8"))
        out.append({"index": {"byteStart": start, "byteEnd": end},
                     "features": [{"$type": "app.bsky.richtext.facet#link", "uri": m.group()}]})
    return out


def strip_urls(text):
    return re.sub(r"[ \t]{2,}", " ", URL_RE.sub("", text)).strip()


# ---------- telegram ----------

def _tg_ok(r):
    r.raise_for_status()
    j = r.json()
    if not j.get("ok"):
        raise RuntimeError(f"telegram error: {j}")
    return j


def publish_telegram(cfg, net, lang, story, outputs):
    token = os.environ.get("TELEGRAM_BOT_TOKEN")
    if not token:
        raise NotConfigured("falta TELEGRAM_BOT_TOKEN")
    chat_id = net["chat_id"]
    base = f"https://api.telegram.org/bot{token}"
    text = _post_text(cfg, "telegram", outputs)

    video = outputs.get("video") or {}
    video_path = video.get("file_path")
    if "video" in net.get("formats", []) and video_path and Path(video_path).exists():
        caption = (video.get("content") or {}).get("caption") or text
        with open(video_path, "rb") as f:
            r = requests.post(f"{base}/sendVideo",
                               data={"chat_id": chat_id, "caption": caption[:1024], "supports_streaming": True},
                               files={"video": f}, timeout=TIMEOUT * 6)
        mid = _tg_ok(r)["result"]["message_id"]
    else:
        images = _pick_images(outputs, limit=1)
        if images and len(text) <= 1024:
            with open(images[0], "rb") as f:
                r = requests.post(f"{base}/sendPhoto", data={"chat_id": chat_id, "caption": text},
                                   files={"photo": f}, timeout=TIMEOUT)
            mid = _tg_ok(r)["result"]["message_id"]
        elif images:
            with open(images[0], "rb") as f:
                r = requests.post(f"{base}/sendPhoto", data={"chat_id": chat_id}, files={"photo": f}, timeout=TIMEOUT)
            _tg_ok(r)
            r = requests.post(f"{base}/sendMessage",
                               data={"chat_id": chat_id, "text": text, "disable_web_page_preview": False}, timeout=TIMEOUT)
            mid = _tg_ok(r)["result"]["message_id"]
        else:
            r = requests.post(f"{base}/sendMessage",
                               data={"chat_id": chat_id, "text": text, "disable_web_page_preview": False}, timeout=TIMEOUT)
            mid = _tg_ok(r)["result"]["message_id"]

    handle = str(chat_id).lstrip("@")
    return {"post_id": str(mid), "url": f"https://t.me/{handle}/{mid}"}


def telegram_send(text, files=None, chat_id=None):
    """Reporte al operador. Nunca lanza: devuelve True/False."""
    try:
        token = os.environ["TELEGRAM_BOT_TOKEN"]
        chat_id = chat_id or os.environ["TELEGRAM_OPERATOR_CHAT_ID"]
        base = f"https://api.telegram.org/bot{token}"
        if files:
            with open(files[0], "rb") as f:
                r = requests.post(f"{base}/sendDocument", data={"chat_id": chat_id, "caption": text[:1024]},
                                   files={"document": f}, timeout=TIMEOUT * 2)
        else:
            r = requests.post(f"{base}/sendMessage", data={"chat_id": chat_id, "text": text[:4096]}, timeout=TIMEOUT)
        return bool(_tg_ok(r).get("ok"))
    except Exception as e:
        print(f"telegram_send falló: {e}")
        return False


# ---------- bluesky ----------

def _downscale_jpeg(path):
    from PIL import Image
    im = Image.open(path).convert("RGB")
    w, h = im.size
    buf = io.BytesIO()
    for scale in (0.9, 0.75, 0.6, 0.5, 0.4, 0.3, 0.2):
        buf = io.BytesIO()
        im.resize((max(1, int(w * scale)), max(1, int(h * scale)))).save(buf, "JPEG", quality=85)
        if buf.tell() <= 1_000_000:
            break
    return buf.getvalue()  # ponytail: mejor esfuerzo; si ni al 20% entra bajo 1MB se manda igual


def _bsky_upload(headers, path, alt):
    data = Path(path).read_bytes()
    if len(data) > 1_000_000:
        data = _downscale_jpeg(path)
    r = requests.post("https://bsky.social/xrpc/com.atproto.repo.uploadBlob",
                       headers={**headers, "Content-Type": "image/jpeg"}, data=data, timeout=TIMEOUT)
    r.raise_for_status()
    return {"image": r.json()["blob"], "alt": alt}


def publish_bluesky(cfg, net, lang, story, outputs):
    handle = _env(net, "HANDLE")
    password = _env(net, "APP_PASSWORD")
    text = _post_text(cfg, "bluesky", outputs)

    r = requests.post("https://bsky.social/xrpc/com.atproto.server.createSession",
                       json={"identifier": handle, "password": password}, timeout=TIMEOUT)
    r.raise_for_status()
    session = r.json()
    headers = {"Authorization": f"Bearer {session['accessJwt']}"}

    embed = None
    images = _pick_images(outputs, limit=4)
    if images:
        alt = _alt(outputs, story)
        embed = {"$type": "app.bsky.embed.images", "images": [_bsky_upload(headers, p, alt) for p in images]}

    record = {"$type": "app.bsky.feed.post", "text": text, "createdAt": _now_iso(), "langs": [lang]}
    fa = facets(text)
    if fa:
        record["facets"] = fa
    if embed:
        record["embed"] = embed

    r = requests.post("https://bsky.social/xrpc/com.atproto.repo.createRecord", headers=headers,
                       json={"repo": session["did"], "collection": "app.bsky.feed.post", "record": record},
                       timeout=TIMEOUT)
    r.raise_for_status()
    data = r.json()
    rkey = data["uri"].rsplit("/", 1)[-1]
    return {"post_id": data["uri"], "url": f"https://bsky.app/profile/{handle}/post/{rkey}"}


# ---------- mastodon ----------

def publish_mastodon(cfg, net, lang, story, outputs):
    token = _env(net, "TOKEN")
    base = net["base_url"].rstrip("/")
    headers = {"Authorization": f"Bearer {token}"}
    text = _post_text(cfg, "mastodon", outputs)
    alt = _alt(outputs, story)

    media_ids = []
    for p in _pick_images(outputs, limit=4):
        with open(p, "rb") as f:
            r = requests.post(f"{base}/api/v2/media", headers=headers, data={"description": alt},
                               files={"file": f}, timeout=TIMEOUT)
        r.raise_for_status()
        media, pending = r.json(), r.status_code == 202
        while pending and not media.get("url"):
            time.sleep(1)
            pr = requests.get(f"{base}/api/v1/media/{media['id']}", headers=headers, timeout=TIMEOUT)
            pr.raise_for_status()
            media = pr.json()
        media_ids.append(str(media["id"]))

    data = [("status", text), ("language", lang), ("visibility", "public")] + [("media_ids[]", i) for i in media_ids]
    r = requests.post(f"{base}/api/v1/statuses", headers=headers, data=data, timeout=TIMEOUT)
    r.raise_for_status()
    j = r.json()
    return {"post_id": str(j["id"]), "url": j["url"]}


# ---------- x ----------
# Media: v1.1 upload.twitter.com/1.1/media/upload.json en vez de v2 /2/media/upload.
# v2 solo documenta INIT/APPEND/FINALIZE (chunked) incluso para imágenes sueltas
# ("no envíes command=INIT/APPEND/FINALIZE a POST /2/media/upload" es la única vía
# de un paso que describen) y sus ejemplos son Bearer/OAuth2, no OAuth1.0a de
# usuario; v1.1 sigue soportando OAuth1.0a y una sola request para imágenes <5MB.

def publish_x(cfg, net, lang, story, outputs):
    from requests_oauthlib import OAuth1
    auth = OAuth1(_env(net, "API_KEY"), _env(net, "API_SECRET"), _env(net, "ACCESS_TOKEN"), _env(net, "ACCESS_SECRET"))
    text = strip_urls(_post_text(cfg, "x", outputs))

    media_ids = []
    for p in _pick_images(outputs, limit=4):
        with open(p, "rb") as f:
            r = requests.post("https://upload.twitter.com/1.1/media/upload.json", auth=auth,
                               files={"media": f}, timeout=TIMEOUT)
        r.raise_for_status()
        media_ids.append(r.json()["media_id_string"])

    body = {"text": text}
    if media_ids:
        body["media"] = {"media_ids": media_ids}
    r = requests.post("https://api.x.com/2/tweets", auth=auth, json=body, timeout=TIMEOUT)
    r.raise_for_status()
    tid = r.json()["data"]["id"]
    return {"post_id": tid, "url": f"https://x.com/i/status/{tid}"}


# ---------- threads ----------

def _threads_container(base, token, params):
    r = requests.post(base, params={**params, "access_token": token}, timeout=TIMEOUT)
    r.raise_for_status()
    return str(r.json()["id"])


def _threads_image_urls(outputs):
    for fmt in ("card", "illustration", "carousel"):
        o = outputs.get(fmt) or {}
        slides = (o.get("content") or {}).get("slides") if fmt == "carousel" else None
        if slides and all(isinstance(s, dict) and s.get("public_url") for s in slides):
            return [s["public_url"] for s in slides]
        if o.get("public_url"):
            return [o["public_url"]]
    return []


def publish_threads(cfg, net, lang, story, outputs):
    user_id = _env(net, "USER_ID")
    token = _env(net, "TOKEN")
    text = _post_text(cfg, "threads", outputs)
    base = f"https://graph.threads.net/v1.0/{user_id}/threads"

    has_image = any(_image_paths(outputs, fmt) for fmt in ("card", "illustration", "carousel"))
    urls = _threads_image_urls(outputs)
    if has_image and not urls:
        raise ValueError("no public_url")

    if not urls:
        creation_id = _threads_container(base, token, {"media_type": "TEXT", "text": text})
    elif len(urls) == 1:
        creation_id = _threads_container(base, token, {"media_type": "IMAGE", "image_url": urls[0], "text": text})
    else:
        children = [_threads_container(base, token, {"media_type": "IMAGE", "image_url": u, "is_carousel_item": "true"})
                    for u in urls]
        creation_id = _threads_container(base, token, {"media_type": "CAROUSEL", "children": ",".join(children), "text": text})

    time.sleep(2)  # ponytail: espera fija a que Meta procese el contenedor; upgrade a poll de status si falla seguido
    r = requests.post(f"https://graph.threads.net/v1.0/{user_id}/threads_publish",
                       params={"creation_id": creation_id, "access_token": token}, timeout=TIMEOUT)
    r.raise_for_status()
    post_id = str(r.json()["id"])

    url = post_id
    try:
        g = requests.get(f"https://graph.threads.net/v1.0/{post_id}",
                          params={"fields": "permalink", "access_token": token}, timeout=TIMEOUT)
        if g.ok and g.json().get("permalink"):
            url = g.json()["permalink"]
    except requests.RequestException:
        pass
    return {"post_id": post_id, "url": url}


# ---------- pendientes fase 3 (falta app review) ----------

def publish_instagram(cfg, net, lang, story, outputs):
    raise NotConfigured("pending app approval")  # TODO fase 3


def publish_youtube(cfg, net, lang, story, outputs):
    raise NotConfigured("pending app approval")  # TODO fase 3


def publish_tiktok(cfg, net, lang, story, outputs):
    raise NotConfigured("pending app approval")  # TODO fase 3


def publish_linkedin(cfg, net, lang, story, outputs):
    raise NotConfigured("pending app approval")  # TODO fase 3


# ---------- pack (fallback manual) ----------

def pack(cfg, date, net_name, lang, story, outputs, reason):
    """Empaqueta lo que no se pudo publicar para subida manual. Devuelve la carpeta."""
    d = config.ROOT / "out" / cfg["name"] / date / "pack" / f"{net_name}_{lang}" / str(story["id"])
    d.mkdir(parents=True, exist_ok=True)

    lines = []
    post = ((outputs.get("post") or {}).get("content") or {}).get("text")
    if post:
        lines.append(post)
    thread_items = ((outputs.get("thread") or {}).get("content") or {}).get("items")
    if thread_items:
        lines.extend(thread_items)
    lines.append(story["url"])
    lines.append(f"razón: {reason}")
    (d / "caption.txt").write_text("\n\n".join(lines), encoding="utf-8")

    for fmt in ("card", "illustration", "carousel", "video"):
        for src in _image_paths(outputs, fmt):
            shutil.copy(src, d / Path(src).name)

    return str(d)


PUBLISHERS = {
    "telegram": publish_telegram,
    "bluesky": publish_bluesky,
    "mastodon": publish_mastodon,
    "x": publish_x,
    "threads": publish_threads,
    "instagram": publish_instagram,
    "youtube": publish_youtube,
    "tiktok": publish_tiktok,
    "linkedin": publish_linkedin,
    "pack": pack,
}
