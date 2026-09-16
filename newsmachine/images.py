"""Ilustraciones, tarjetas y carrusel. Cadena de proveedores donde el último eslabón (gradiente
Pillow) nunca falla. Estilo: stdlib + Pillow + requests, sin clases."""
import base64, io, os, re, urllib.parse
from pathlib import Path
import requests
from PIL import Image, ImageDraw, ImageFilter, ImageFont
from .config import ROOT
from . import db

XMP = (
    '<?xpacket begin="" id="W5M0MpCehiHzreSzNTczkc9d"?>'
    '<x:xmpmeta xmlns:x="adobe:ns:meta/">'
    '<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">'
    '<rdf:Description rdf:about="" xmlns:Iptc4xmpExt="http://iptc.org/std/Iptc4xmpExt/2008-02-29/" xmlns:dc="http://purl.org/dc/elements/1.1/">'
    "<Iptc4xmpExt:DigitalSourceType>http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia</Iptc4xmpExt:DigitalSourceType>"
    '<dc:description><rdf:Alt><rdf:li xml:lang="x-default">AI-generated image</rdf:li></rdf:Alt></dc:description>'
    "</rdf:Description></rdf:RDF></x:xmpmeta><?xpacket end=\"w\"?>"
)
_EMOJI_RE = re.compile(
    "[\U0001F000-\U0010FFFF☀-➿←-⇿⌀-⏿️‍]+"
)


def _hex(s):
    s = s.lstrip("#")
    return tuple(int(s[i : i + 2], 16) for i in (0, 2, 4))


def _clean(text):
    """Saca emoji/no-BMP: Pillow no dibuja emoji en color y renderiza tofu."""
    return _EMOJI_RE.sub("", text or "")


def _font(cfg, size, weight="Regular"):
    f = ImageFont.truetype(str(ROOT / cfg["brand"]["fonts"]["title"]), size)
    try:
        f.set_variation_by_name(weight)
    except Exception:
        pass
    return f


def wrap(text, font, max_width):
    """Envuelve `text` en líneas que no superan max_width según font.getlength."""
    lines, cur = [], ""
    for word in (text or "").split():
        trial = f"{cur} {word}".strip()
        if not cur or font.getlength(trial) <= max_width:
            cur = trial
        else:
            lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)
    return lines


def _fit_title(cfg, text, max_width, max_lines=5, start=84, min_size=32):
    size = start
    while size > min_size:
        font = _font(cfg, size, "Bold")
        lines = wrap(text, font, max_width)
        if len(lines) <= max_lines:
            return font, lines
        size -= 4
    font = _font(cfg, min_size, "Bold")
    return font, wrap(text, font, max_width)[:max_lines]


def _cover_fit(img, w, h):
    """Recorta al centro y reescala para cubrir exactamente w x h."""
    img = img.convert("RGB")
    sw, sh = img.size
    target, src = w / h, sw / sh
    if src > target:
        nw = max(1, round(sh * target))
        x = (sw - nw) // 2
        img = img.crop((x, 0, x + nw, sh))
    else:
        nh = max(1, round(sw / target))
        y = (sh - nh) // 2
        img = img.crop((0, y, sw, y + nh))
    return img.resize((w, h), Image.LANCZOS)


def _gradient(cfg, size):
    """Fallback 100% local: gradiente vertical bg -> mezcla con accent + círculo suave."""
    w, h = size
    bg, accent = _hex(cfg["brand"]["colors"]["bg"]), _hex(cfg["brand"]["colors"]["accent"])
    mix = tuple(round(bg[c] * 0.55 + accent[c] * 0.45) for c in range(3))
    img = Image.new("RGB", (w, h), bg)
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1, h - 1)
        draw.line([(0, y), (w, y)], fill=tuple(round(bg[c] * (1 - t) + mix[c] * t) for c in range(3)))
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    r = min(w, h) * 0.35
    cx, cy = w * 0.75, h * 0.25
    ImageDraw.Draw(overlay).ellipse([cx - r, cy - r, cx + r, cy + r], fill=accent + (90,))
    return Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")


def _try_gemini(prompt):
    key = os.getenv("GEMINI_API_KEY")
    if not key:
        return None
    try:
        r = requests.post(
            f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key={key}",
            json={"contents": [{"parts": [{"text": prompt}]}]}, timeout=120,
        )
        r.raise_for_status()
        parts = r.json()["candidates"][0]["content"]["parts"]
        b64 = next(p["inlineData"]["data"] for p in parts if "inlineData" in p)
        if db.CONN is not None:
            db.quota_add("gemini_image")
        return Image.open(io.BytesIO(base64.b64decode(b64)))
    except Exception as e:
        print(f"images: gemini_image falló: {e}")
        if db.CONN is not None:
            db.quota_add("gemini_image", calls=0, errors=1)
        return None


def _try_cloudflare(prompt):
    account, token = os.getenv("CF_ACCOUNT_ID"), os.getenv("CF_API_TOKEN")
    if not account or not token:
        return None
    try:
        url = f"https://api.cloudflare.com/client/v4/accounts/{account}/ai/run/@cf/black-forest-labs/flux-1-schnell"
        r = requests.post(url, headers={"Authorization": f"Bearer {token}"}, json={"prompt": prompt}, timeout=60)
        r.raise_for_status()
        b64 = r.json()["result"]["image"]
        if db.CONN is not None:
            db.quota_add("cloudflare")
        return Image.open(io.BytesIO(base64.b64decode(b64)))
    except Exception as e:
        print(f"images: cloudflare falló: {e}")
        if db.CONN is not None:
            db.quota_add("cloudflare", calls=0, errors=1)
        return None


def _try_pollinations(prompt, size):
    try:
        w, h = size
        url = f"https://image.pollinations.ai/prompt/{urllib.parse.quote(prompt)}?width={w}&height={h}&nologo=true"
        r = requests.get(url, timeout=60)
        r.raise_for_status()
        if not r.headers.get("content-type", "").startswith("image/"):
            raise RuntimeError(f"content-type inesperado: {r.headers.get('content-type')}")
        if db.CONN is not None:
            db.quota_add("pollinations")
        return Image.open(io.BytesIO(r.content))
    except Exception as e:
        print(f"images: pollinations falló: {e}")
        if db.CONN is not None:
            db.quota_add("pollinations", calls=0, errors=1)
        return None


def generate(cfg, prompt, size, out_path, providers=None):
    """Ilustración vía cadena Gemini -> Cloudflare -> Pollinations -> gradiente local.
    providers=[] (o env NM_IMAGES_OFFLINE=1) fuerza el fallback local, sin red."""
    if providers is None:
        providers = [] if os.getenv("NM_IMAGES_OFFLINE") else ["gemini", "cloudflare", "pollinations"]
    img = None
    if "gemini" in providers:
        img = _try_gemini(prompt)
    if img is None and "cloudflare" in providers:
        img = _try_cloudflare(prompt)
    if img is None and "pollinations" in providers:
        img = _try_pollinations(prompt, size)
    if img is None:
        img = _gradient(cfg, size)
    img = _cover_fit(img, *size)
    out_path = Path(out_path)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path, "JPEG", quality=88)
    stamp_ai_metadata(out_path)
    return out_path


def stamp_ai_metadata(path):
    """Embebe el paquete XMP de origen IA y verifica que quedó grabado."""
    path = Path(path)
    img = Image.open(path)
    img.load()
    img.save(path, xmp=XMP.encode("utf-8"))
    data = path.read_bytes()
    assert b"trainedAlgorithmicMedia" in data, f"XMP no se pudo insertar en {path}"
    return path


def _backdrop_img(cfg, size, backdrop):
    bg = _hex(cfg["brand"]["colors"]["bg"])
    if backdrop and Path(backdrop).exists():
        img = _cover_fit(Image.open(backdrop), *size).filter(ImageFilter.GaussianBlur(18))
        return Image.blend(img, Image.new("RGB", size, (0, 0, 0)), 0.55)
    return Image.new("RGB", size, bg)


def render_card(cfg, lang, title, kicker, source, out_path, size=(1080, 1080), backdrop=None, body=None):
    w, h = size
    colors = cfg["brand"]["colors"]
    fg, accent, muted = _hex(colors["fg"]), _hex(colors["accent"]), _hex(colors["muted"])
    img = _backdrop_img(cfg, size, backdrop)
    draw = ImageDraw.Draw(img)
    side = 80
    top, bottom = (250, 350) if h >= 1920 else (120, 120)
    max_w = w - 2 * side

    title, kicker, source = _clean(title), _clean(kicker).upper(), _clean(source)
    body = _clean(body) if body else None
    brand_name = _clean(cfg["brand"]["name"])
    disclosure = _clean(cfg["brand"]["disclosure"]["overlay"][lang])

    kicker_font = _font(cfg, 34, "Bold")
    draw.text((side, top), kicker, font=kicker_font, fill=accent)
    brand_font = _font(cfg, 34, "Bold")
    draw.text((w - side - brand_font.getlength(brand_name), top), brand_name, font=brand_font, fill=fg)

    title_font, lines = _fit_title(cfg, title, max_w)
    y = top + 70
    for ln in lines:
        draw.text((side, y), ln, font=title_font, fill=fg)
        y += title_font.size + 12

    if body:
        body_font = _font(cfg, 48, "Regular")
        y += 20
        for ln in wrap(body, body_font, max_w):
            draw.text((side, y), ln, font=body_font, fill=fg)
            y += body_font.size + 14

    small_font = _font(cfg, 28, "Regular")
    draw.text((side, h - bottom), source, font=small_font, fill=muted)
    draw.text((w - side - small_font.getlength(disclosure), h - bottom), disclosure, font=small_font, fill=muted)

    out_path = Path(out_path)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(out_path, "JPEG", quality=88)
    stamp_ai_metadata(out_path)
    return out_path


def _page_indicator(draw, cfg, n, total, size):
    w, h = size
    f = _font(cfg, 28, "Regular")
    txt = f"{n}/{total}"
    bottom = 350 if h >= 1920 else 120
    draw.text(((w - f.getlength(txt)) / 2, h - bottom + 40), txt, font=f, fill=_hex(cfg["brand"]["colors"]["muted"]))


def render_carousel(cfg, lang, slides, source, out_dir, size=(1080, 1350), backdrop=None):
    """slides[0] = portada (solo título grande); slides[1:] = título + body; se agrega al
    final una página de fuentes con la lista de `source` de cada slide (o el `source` general)."""
    w, h = size
    colors = cfg["brand"]["colors"]
    fg, muted = _hex(colors["fg"]), _hex(colors["muted"])
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    side = 80
    top, _bottom = (250, 350) if h >= 1920 else (120, 120)
    max_w = w - 2 * side
    total = len(slides) + 1
    paths = []

    for i, sl in enumerate(slides):
        img = _backdrop_img(cfg, size, backdrop if i == 0 else None)
        draw = ImageDraw.Draw(img)
        title = _clean(sl.get("title", ""))
        if i == 0:
            font, lines = _fit_title(cfg, title, max_w, start=84)
            y = max(top, (h - len(lines) * (font.size + 14)) // 2)
        else:
            font, lines = _fit_title(cfg, title, max_w, start=60)
            y = top
        for ln in lines:
            draw.text((side, y), ln, font=font, fill=fg)
            y += font.size + 14
        if i > 0 and sl.get("body"):
            body_font = _font(cfg, 48, "Regular")
            y += 20
            for ln in wrap(_clean(sl["body"]), body_font, max_w):
                draw.text((side, y), ln, font=body_font, fill=fg)
                y += body_font.size + 14
        _page_indicator(draw, cfg, i + 1, total, size)
        p = out_dir / f"slide_{i + 1:02d}.jpg"
        img.convert("RGB").save(p, "JPEG", quality=88)
        stamp_ai_metadata(p)
        paths.append(p)

    img = Image.new("RGB", size, _hex(colors["bg"]))
    draw = ImageDraw.Draw(img)
    heading = "Fuentes" if lang == "es" else "Sources"
    draw.text((side, top), heading, font=_font(cfg, 56, "Bold"), fill=fg)
    src_font = _font(cfg, 36, "Regular")
    sources = sorted({s for s in (sl.get("source") for sl in slides) if s}) or ([source] if source else [])
    y = top + 90
    for s in sources:
        draw.text((side, y), _clean(s), font=src_font, fill=muted)
        y += 50
    disc_font = _font(cfg, 28, "Regular")
    disclosure = _clean(cfg["brand"]["disclosure"]["overlay"][lang])
    draw.text((side, h - _bottom), disclosure, font=disc_font, fill=muted)
    handle = _clean(cfg["brand"]["name"])
    draw.text((w - side - disc_font.getlength(handle), h - _bottom), handle, font=disc_font, fill=fg)
    _page_indicator(draw, cfg, total, total, size)
    p = out_dir / f"slide_{total:02d}.jpg"
    img.save(p, "JPEG", quality=88)
    stamp_ai_metadata(p)
    paths.append(p)
    return paths


if __name__ == "__main__":  # python -m newsmachine.images --selftest
    import yaml

    cfg = yaml.safe_load((ROOT / "verticals" / "tech.yaml").read_text())
    out = ROOT / "out" / "_selftest"
    out.mkdir(parents=True, exist_ok=True)

    illo = generate(cfg, "flat editorial illustration", (1080, 1350), out / "illo.jpg", providers=[])
    assert illo.exists() and Image.open(illo).size == (1080, 1350)

    card = render_card(cfg, "es", "Un titular bastante largo para probar el auto-shrink del texto",
                        "Sintia", "example.com", out / "card.jpg", backdrop=illo)
    assert card.exists() and Image.open(card).size == (1080, 1080)

    slides = [
        {"title": "Top del día"},
        {"title": "Primera noticia", "body": "Cuerpo de la primera noticia de prueba.", "source": "example.com"},
        {"title": "Segunda noticia", "body": "Cuerpo de la segunda noticia de prueba.", "source": "other.com"},
    ]
    paths = render_carousel(cfg, "es", slides, "example.com", out / "carousel", backdrop=illo)
    assert len(paths) == 4 and all(p.exists() for p in paths)

    for p in [illo, card, *paths]:
        assert b"trainedAlgorithmicMedia" in p.read_bytes(), f"falta XMP en {p}"

    print("OK images.py:", illo, card, *paths)
