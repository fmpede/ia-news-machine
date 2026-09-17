"""Generador de sitio estático (GitHub Pages) para la marca Sintia: jinja2 + stdlib, sin build de JS.
Lee outputs (format='article'/'illustration'/'post') vía db.connect(cfg["name"]) y escribe site/.
Nunca llama a db.save(): este módulo es de solo lectura sobre el estado.

python -m newsmachine.site --vertical tech
"""
import datetime as dt, email.utils as eut, json, re, shutil, sys, unicodedata
from pathlib import Path
from urllib.parse import quote
from xml.sax.saxutils import escape as xml_escape

import jinja2

from . import config, db

TEMPLATES = config.ROOT / "templates" / "site"
STOPWORDS = {"de", "la", "el", "los", "las", "un", "una", "the", "a", "an", "of", "and", "y"}

I18N = {
    "es": {"telegram_cta": "Seguinos en Telegram", "source": "Fuente", "source_says": "Lo que dice la fuente",
           "faq": "Preguntas frecuentes", "related": "Te puede interesar", "share": "Compartir",
           "read_more": "Leer más", "terms": "Términos y condiciones", "tldr": "Resumen rápido",
           "digest": "Resumen del día", "home": "Inicio", "featured": "Destacada"},
    "en": {"telegram_cta": "Follow on Telegram", "source": "Source", "source_says": "What the source says",
           "faq": "Frequently asked questions", "related": "You might like", "share": "Share",
           "read_more": "Read more", "terms": "Terms and conditions", "tldr": "Quick summary",
           "digest": "Daily digest", "home": "Home", "featured": "Featured"},
}

env = jinja2.Environment(loader=jinja2.FileSystemLoader(TEMPLATES), autoescape=True, trim_blocks=True, lstrip_blocks=True)


# ---------- helpers puros (sin DB) ----------

def slugify(text):
    ascii_text = unicodedata.normalize("NFKD", text or "").encode("ascii", "ignore").decode()
    words = [w for w in re.findall(r"[a-z0-9]+", ascii_text.lower()) if w not in STOPWORDS]
    slug = "-".join(words)
    if not slug or re.fullmatch(r"[0-9-]+", slug):
        slug = ("articulo-" + slug) if slug else "articulo"
    return slug


def _md_inline(s):
    return re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", s)


def md_to_html(text):  # headings #, párrafos, listas -, bold **; único consumidor: terminos.md
    out, para, in_list = [], [], False

    def flush():
        if para:
            out.append("<p>" + " ".join(para) + "</p>"); para.clear()

    def close():
        nonlocal in_list
        if in_list:
            out.append("</ul>"); in_list = False

    for raw in (text or "").splitlines():
        line = raw.strip()
        m = re.match(r"^(#{1,6})\s+(.*)", line)
        if not line:
            flush(); close()
        elif m:
            flush(); close()
            out.append(f"<h{len(m.group(1))}>{_md_inline(m.group(2))}</h{len(m.group(1))}>")
        elif line.startswith("- "):
            flush()
            if not in_list:
                out.append("<ul>"); in_list = True
            out.append(f"<li>{_md_inline(line[2:])}</li>")
        else:
            close(); para.append(_md_inline(line))
    flush(); close()
    return "\n".join(out)


def _split_lead(html_body):
    """Separa el primer <p>...</p> (cubre la intención de búsqueda) del resto del cuerpo."""
    m = re.match(r"\s*(<p>.*?</p>)", html_body or "", re.S)
    if not m:
        return "", (html_body or "").strip()
    return m.group(1), (html_body or "")[m.end():].strip()


def _share_urls(url, title):
    u, t = quote(url, safe=""), quote(title)
    return {"x": f"https://twitter.com/intent/tweet?url={u}&text={t}",
            "whatsapp": f"https://wa.me/?text={t}%20{u}",
            "telegram": f"https://t.me/share/url?url={u}&text={t}"}


def _rfc822(value, fallback_date):
    for candidate in (value, fallback_date):
        if not candidate:
            continue
        try:
            d = dt.datetime.fromisoformat(candidate)
            if d.tzinfo is None:
                d = d.replace(tzinfo=dt.timezone.utc)
            return eut.format_datetime(d)
        except ValueError:
            continue
    return eut.format_datetime(dt.datetime.now(dt.timezone.utc))


def _prefix(cfg):
    p = (cfg.get("site") or {}).get("path", "").strip("/")
    return f"/{p}" if p else ""


def _href(cfg, rel):
    return _prefix(cfg) + rel


def _abs(cfg, rel):
    return cfg["brand"]["site_url"].rstrip("/") + _prefix(cfg) + rel


def _out_root(cfg, out):
    p = (cfg.get("site") or {}).get("path", "").strip("/")
    return (out / p) if p else out


def _write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _org_jsonld(cfg):
    b = cfg["brand"]
    return json.dumps({"@context": "https://schema.org", "@type": "Organization",
                        "name": b["name"], "url": b["site_url"],
                        "description": (b.get("tagline") or {}).get("es", "")}, ensure_ascii=False)


def _base_ctx(cfg, lang):
    b = cfg["brand"]
    nav = [{"code": l, "label": l.upper(), "href": _href(cfg, f"/{l}/")} for l in cfg["languages"]]
    return {
        "brand": b, "lang": lang or cfg["languages"][0], "nav": nav,
        "home_href": _href(cfg, "/"), "terms_href": _href(cfg, "/terminos/"),
        "disclosure_bio": (b.get("disclosure") or {}).get(f"bio_{lang}", "") if lang else "",
        "ga4_id": (cfg.get("site") or {}).get("ga4_id"),
        "org_jsonld": _org_jsonld(cfg),
        "robots_meta": None, "alternates": [], "canonical": None,
        "t": I18N.get(lang, I18N["es"]),
    }


# ---------- lectura de DB ----------

def _articles(cfg, lang):
    rows = db.CONN.execute("""
        SELECT o.date, o.story_id, o.lang, o.content_json, o.created_at,
               s.title AS story_title, s.url AS story_url, s.source AS story_source,
               s.published_at, s.cluster_id, sel.role
        FROM outputs o
        JOIN stories s ON s.id = o.story_id
        LEFT JOIN selected sel ON sel.vertical = o.vertical AND sel.date = o.date AND sel.story_id = o.story_id
        WHERE o.vertical = ? AND o.format = 'article' AND o.qa_status IN ('pass', 'fixed') AND o.lang = ?
        ORDER BY o.date DESC, o.created_at DESC
    """, (cfg["name"], lang)).fetchall()
    out = []
    for r in rows:
        try:
            content = json.loads(r["content_json"])
        except (json.JSONDecodeError, TypeError):
            continue
        title = content.get("title") or r["story_title"]
        out.append({
            "date": r["date"], "story_id": r["story_id"], "lang": r["lang"],
            "title": title, "slug": slugify(content.get("slug") or title),
            "meta_description": content.get("meta_description", ""), "tldr": content.get("tldr", ""),
            "html": content.get("html", ""), "faq": content.get("faq") or [],
            "claims": content.get("claims") or [], "alt_text": content.get("alt_text", ""),
            "angle": content.get("angle", ""), "source": r["story_source"], "source_url": r["story_url"],
            "published_at": r["published_at"] or r["date"], "cluster_id": r["cluster_id"],
            "role": r["role"], "created_at": r["created_at"], "image": None,
        })
    return out


def _illustration_path(cfg, story_id, lang):
    r = db.CONN.execute("""SELECT file_path FROM outputs WHERE vertical=? AND format='illustration'
        AND story_id=? AND lang=? ORDER BY created_at DESC LIMIT 1""", (cfg["name"], story_id, lang)).fetchone()
    return r["file_path"] if r and r["file_path"] else None


def _post_text(cfg, story_id, lang, date):
    r = db.CONN.execute("""SELECT content_json FROM outputs WHERE vertical=? AND format='post'
        AND story_id=? AND lang=? AND date=?""", (cfg["name"], story_id, lang, date)).fetchone()
    if not r or not r["content_json"]:
        return ""
    try:
        data = json.loads(r["content_json"])
    except (json.JSONDecodeError, TypeError):
        return str(r["content_json"])
    if isinstance(data, str):
        return data
    if isinstance(data, dict):
        return data.get("text") or data.get("body") or data.get("post") or data.get("caption") or ""
    return ""


# ---------- páginas ----------

def _article_href(cfg, art):
    return _href(cfg, f"/{art['lang']}/{art['date']}/{art['slug']}/")


def _card(cfg, art):
    return {"title": art["title"], "href": _article_href(cfg, art), "meta_description": art["meta_description"],
            "date": art["date"], "image": art["image"], "role": art["role"]}


def _link_media(cfg, out, art):
    """Copia la ilustración (si existe) a site/media/<date>/<story_id>_<lang>.jpg y devuelve su URL."""
    src = _illustration_path(cfg, art["story_id"], art["lang"])
    if not src or not Path(src).exists():
        return None
    rel = f"/media/{art['date']}/{art['story_id']}_{art['lang']}.jpg"
    dest = _out_root(cfg, out) / rel.lstrip("/")
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dest)
    return {"url": _href(cfg, rel), "alt": art["alt_text"]}


def _render_article(cfg, out, art, all_by_story):
    lang, t = art["lang"], I18N.get(art["lang"], I18N["es"])
    href, abs_url = _article_href(cfg, art), _abs(cfg, _article_href(cfg, art))
    lead, rest = _split_lead(art["html"])
    handle = ((cfg["brand"].get("handles") or {}).get(lang) or {}).get("telegram", "").lstrip("@")
    alternates = {b["lang"]: _abs(cfg, _article_href(cfg, b)) for b in all_by_story.get(art["story_id"], []) if b is not art}
    related = [b for b in art["_related"]]
    faq_jsonld = None
    if art["faq"]:
        faq_jsonld = json.dumps({"@context": "https://schema.org", "@type": "FAQPage", "mainEntity": [
            {"@type": "Question", "name": q.get("q", ""),
             "acceptedAnswer": {"@type": "Answer", "text": q.get("a", "")}} for q in art["faq"]]}, ensure_ascii=False)
    article_jsonld = json.dumps({
        "@context": "https://schema.org", "@type": "NewsArticle", "headline": art["title"],
        "datePublished": art["published_at"], "inLanguage": lang,
        **({"image": [_abs(cfg, art["image"]["url"])]} if art["image"] else {}),
        "author": {"@type": "Organization", "name": cfg["brand"]["name"]}, "isBasedOn": art["source_url"],
    }, ensure_ascii=False)
    ctx = _base_ctx(cfg, lang)
    ctx.update({
        "page_title": f"{art['title']} · {cfg['brand']['name']}", "meta_description": art["meta_description"],
        "canonical": abs_url, "alternates": [(l, u) for l, u in alternates.items()],
        "h1": art["title"], "date": art["date"], "source": art["source"], "source_url": art["source_url"],
        "image": art["image"], "lead_html": lead, "tldr": art["tldr"], "body_html": rest,
        "telegram_href": f"https://t.me/{handle}" if handle else None, "claims": art["claims"], "faq": art["faq"],
        "related": [_card(cfg, b) for b in related], "share": _share_urls(abs_url, art["title"]),
        "faq_jsonld": faq_jsonld, "article_jsonld": article_jsonld,
    })
    _write(_out_root(cfg, out) / lang / art["date"] / art["slug"] / "index.html",
           env.get_template("article.html").render(**ctx))


def _paginate(items, per_page):
    if not items:
        return [[]]
    return [items[i:i + per_page] for i in range(0, len(items), per_page)]


def _render_list(cfg, out, lang, arts, per_page):
    pages = _paginate(arts, per_page)
    for i, page_items in enumerate(pages, start=1):
        ctx = _base_ctx(cfg, lang)
        rel = f"/{lang}/" if i == 1 else f"/{lang}/page/{i}/"
        ctx.update({
            "page_title": f"{cfg['brand']['name']} {lang.upper()}", "meta_description": (cfg["brand"].get("tagline") or {}).get(lang, ""),
            "h1": f"{cfg['brand']['name']} {lang.upper()}" + (f" — {i}" if i > 1 else ""),
            "canonical": _abs(cfg, rel), "robots_meta": "noindex,follow" if i > 1 else None,
            "articles": [_card(cfg, a) for a in page_items], "page_num": i, "total_pages": len(pages),
            "prev_href": _href(cfg, f"/{lang}/") if i == 2 else (_href(cfg, f"/{lang}/page/{i - 1}/") if i > 2 else None),
            "next_href": _href(cfg, f"/{lang}/page/{i + 1}/") if i < len(pages) else None,
        })
        _write(_out_root(cfg, out) / rel.strip("/") / "index.html", env.get_template("list.html").render(**ctx))
    return len(pages)


def _render_landing(cfg, out, articles_by_lang):
    ctx = _base_ctx(cfg, None)
    ctx.update({"page_title": cfg["brand"]["name"], "meta_description": (cfg["brand"].get("tagline") or {}).get("es", ""),
                "h1": cfg["brand"]["name"], "canonical": _abs(cfg, "/"), "lang": cfg["languages"][0],
                "columns": [{"lang": l, "label": l.upper(), "t": I18N.get(l, I18N["es"]),
                             "articles": [_card(cfg, a) for a in articles_by_lang.get(l, [])[:10]],
                             "more_href": _href(cfg, f"/{l}/")} for l in cfg["languages"]]})
    _write(_out_root(cfg, out) / "index.html", env.get_template("landing.html").render(**ctx))


def _render_digests(cfg, out, lang, arts):
    by_date = {}
    for a in arts:
        by_date.setdefault(a["date"], []).append(a)
    for date, day_arts in by_date.items():
        items = [dict(_card(cfg, a), post=_post_text(cfg, a["story_id"], a["lang"], date)) for a in day_arts]
        ctx = _base_ctx(cfg, lang)
        ctx.update({"page_title": f"{I18N.get(lang, I18N['es'])['digest']} {date} · {cfg['brand']['name']}",
                    "meta_description": (cfg["brand"].get("tagline") or {}).get(lang, ""),
                    "h1": f"{I18N.get(lang, I18N['es'])['digest']} — {date}",
                    "canonical": _abs(cfg, f"/{lang}/{date}/"), "date": date, "articles": items})
        _write(_out_root(cfg, out) / lang / date / "index.html", env.get_template("digest.html").render(**ctx))
        md = [f"# {I18N.get(lang, I18N['es'])['digest']} — {date}", ""]
        for it in items:
            md += [f"## {it['title']}", "", it["post"] or it["meta_description"], "",
                   f"[{I18N.get(lang, I18N['es'])['read_more']}]({_abs(cfg, it['href'])})", ""]
        _write(_out_root(cfg, out) / lang / date / "digest.md", "\n".join(md))


def _render_page(cfg, out, rel, lang, page_title, meta_description, content_html):
    ctx = _base_ctx(cfg, lang)
    ctx.update({"page_title": page_title, "meta_description": meta_description,
                "canonical": _abs(cfg, rel), "content_html": content_html})
    dest = _out_root(cfg, out) / rel.strip("/") / "index.html" if rel != "/404.html" else _out_root(cfg, out) / "404.html"
    _write(dest, env.get_template("page.html").render(**ctx))


def _sitemap(cfg, urls):
    body = "".join(f"<url><loc>{xml_escape(u)}</loc></url>" for u in urls)
    return f'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">{body}</urlset>'


def _robots(cfg):
    return f"User-agent: *\nDisallow: /*/page/\n\nSitemap: {_abs(cfg, '/sitemap.xml')}\n"


def _feed(cfg, lang, arts):
    b = cfg["brand"]
    items = "".join(
        f"<item><title>{xml_escape(a['title'])}</title><link>{xml_escape(_abs(cfg, _article_href(cfg, a)))}</link>"
        f"<guid>{xml_escape(_abs(cfg, _article_href(cfg, a)))}</guid>"
        f"<pubDate>{_rfc822(a['published_at'], a['date'])}</pubDate>"
        f"<description>{xml_escape(a['meta_description'])}</description></item>"
        for a in arts[:30])
    return (f'<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel>'
            f"<title>{xml_escape(b['name'])}</title><link>{xml_escape(_abs(cfg, f'/{lang}/'))}</link>"
            f"<description>{xml_escape((b.get('tagline') or {}).get(lang, ''))}</description>{items}</channel></rss>")


def _llms_txt(cfg, all_arts):
    b = cfg["brand"]
    latest = sorted(all_arts, key=lambda a: (a["date"], a["created_at"]), reverse=True)[:30]
    lines = [b["name"], (b.get("tagline") or {}).get("es", ""), "", (b.get("disclosure") or {}).get("bio_es", ""), "",
             "Artículos recientes / Recent articles:"]
    lines += [f"- {_abs(cfg, _article_href(cfg, a))}: {a['meta_description']}" for a in latest]
    lines += ["", f"Términos: {_abs(cfg, '/terminos/')}"]
    return "\n".join(lines) + "\n"


# ---------- build ----------

def build(cfg, out=None):
    db.connect(cfg["name"])
    out = Path(out) if out else config.ROOT / "site"
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True, exist_ok=True)

    articles_by_lang = {lang: _articles(cfg, lang) for lang in cfg["languages"]}
    all_arts = [a for lang in cfg["languages"] for a in articles_by_lang[lang]]
    all_by_story = {}
    for a in all_arts:
        all_by_story.setdefault(a["story_id"], []).append(a)
    for a in all_arts:
        a["image"] = _link_media(cfg, out, a)
    for a in all_arts:
        related = [b for b in all_arts if b is not a and b["cluster_id"] is not None and b["cluster_id"] == a["cluster_id"]]
        if len(related) < 4:
            related += [b for b in all_arts if b is not a and b["date"] == a["date"] and b not in related]
        a["_related"] = related[:4]

    for a in all_arts:
        _render_article(cfg, out, a, all_by_story)

    pages = {}
    for lang in cfg["languages"]:
        pages[lang] = _render_list(cfg, out, lang, articles_by_lang[lang], (cfg.get("site") or {}).get("per_page", 30))
        _render_digests(cfg, out, lang, articles_by_lang[lang])
        _write(_out_root(cfg, out) / lang / "feed.xml", _feed(cfg, lang, articles_by_lang[lang]))

    _render_landing(cfg, out, articles_by_lang)

    terminos_md = (TEMPLATES / "terminos.md").read_text(encoding="utf-8")
    _render_page(cfg, out, "/terminos/", "es", f"{I18N['es']['terms']} · {cfg['brand']['name']}",
                 "Términos y condiciones de uso de Sintia.", md_to_html(terminos_md))
    _render_page(cfg, out, "/404.html", "es", f"404 · {cfg['brand']['name']}", "Página no encontrada.",
                 "<h1>404</h1><p>Página no encontrada / Page not found.</p>"
                 f'<p><a href="{_href(cfg, "/")}">{I18N["es"]["home"]} / {I18N["en"]["home"]}</a></p>')

    sitemap_urls = [_abs(cfg, "/")] + [_abs(cfg, f"/{l}/") for l in cfg["languages"]] + \
        [_abs(cfg, _article_href(cfg, a)) for a in all_arts]
    _write(out / "sitemap.xml", _sitemap(cfg, sitemap_urls))
    _write(out / "robots.txt", _robots(cfg))
    _write(out / "llms.txt", _llms_txt(cfg, all_arts))

    return {"articles": {lang: len(articles_by_lang[lang]) for lang in cfg["languages"]},
            "pages": sum(pages.values())}


def main(argv=None):
    from .config import parse
    cfg, args = parse(argv)
    print(f"vertical={cfg['name']} {build(cfg)}")


if __name__ == "__main__":
    cfg, args = config.parse()
    counts = build(cfg)
    print(f"vertical={cfg['name']} {counts}")
    sys.exit(0)
