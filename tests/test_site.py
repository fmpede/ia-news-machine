"""Test offline de newsmachine/site.py: DB temporal _site, sin red, sin tocar state/tech.sql ni site/."""
import json
import re
import xml.etree.ElementTree as ET

from newsmachine import config, db, site


def test_site_build(tmp_path):
    db.connect("_site")
    now = db.utcnow()
    date = now[:10]
    illus = tmp_path / "illo.jpg"
    illus.write_bytes(b"\xff\xd8\xff\xe0fake")

    db.CONN.execute("""INSERT INTO stories (id, vertical, url, url_hash, title, source, lang, published_at, fetched_at, cluster_id)
        VALUES (1, '_site', 'https://example.com/es', 'h1', 'Historia ES', 'Xataka', 'es', ?, ?, 100)""", (now, now))
    db.CONN.execute("""INSERT INTO stories (id, vertical, url, url_hash, title, source, lang, published_at, fetched_at, cluster_id)
        VALUES (2, '_site', 'https://example.com/en', 'h2', 'Story EN', 'The Verge', 'en', ?, ?, 101)""", (now, now))

    content_es = {
        "title": "Un Título De Prueba", "slug": "un-titulo-de-prueba",
        "meta_description": "Descripción de prueba para SEO.",
        "tldr": "Resumen corto de la nota.",
        "html": "<p>Primer párrafo de la nota de prueba.</p><h2>Detalle</h2><p>Más contenido acá.</p>",
        "faq": [{"q": "¿Pregunta uno?", "a": "Respuesta uno."}],
        "claims": [{"claim": "Algo pasó", "quote": "cita textual", "source_url": "https://example.com/es"}],
        "alt_text": "Ilustración de prueba", "angle": "explicador",
    }
    content_en = {
        "title": "A Test Title", "slug": "a-test-title",
        "meta_description": "Test meta description for SEO.",
        "tldr": "Short summary of the story.",
        "html": "<p>First paragraph of the test story.</p><h2>Detail</h2><p>More content here.</p>",
        "faq": [{"q": "Question one?", "a": "Answer one."}],
        "claims": [{"claim": "Something happened", "quote": "verbatim quote", "source_url": "https://example.com/en"}],
        "alt_text": "Test illustration", "angle": "explainer",
    }
    db.CONN.execute("""INSERT INTO outputs (vertical, date, story_id, lang, format, content_json, qa_status, created_at)
        VALUES ('_site', ?, 1, 'es', 'article', ?, 'pass', ?)""", (date, json.dumps(content_es, ensure_ascii=False), now))
    db.CONN.execute("""INSERT INTO outputs (vertical, date, story_id, lang, format, content_json, qa_status, created_at)
        VALUES ('_site', ?, 2, 'en', 'article', ?, 'fixed', ?)""", (date, json.dumps(content_en, ensure_ascii=False), now))
    db.CONN.execute("""INSERT INTO outputs (vertical, date, story_id, lang, format, content_json, file_path, qa_status, created_at)
        VALUES ('_site', ?, 1, 'es', 'illustration', '{}', ?, 'pass', ?)""", (date, str(illus), now))
    db.save("_site")

    cfg = config.load_vertical("tech")
    cfg["name"] = "_site"  # aísla del state real de "tech"; reusa brand/site config tal cual
    out = tmp_path / "site"

    try:
        counts = site.build(cfg, out=out)
        assert counts["articles"] == {"es": 1, "en": 1}

        slug_es, slug_en = site.slugify(content_es["slug"]), site.slugify(content_en["slug"])
        es_path = out / "es" / date / slug_es / "index.html"
        en_path = out / "en" / date / slug_en / "index.html"
        assert es_path.exists()
        assert en_path.exists()

        html = es_path.read_text(encoding="utf-8")
        assert len(re.findall(r"<h1[ >]", html)) == 1
        title_text = re.search(r"<title>(.*?)</title>", html).group(1)
        h1_text = re.search(r"<h1[^>]*>(.*?)</h1>", html).group(1)
        assert title_text != h1_text
        assert 'name="description" content="Descripción de prueba para SEO."' in html
        assert "FAQPage" in html

        assert (out / "media" / date / "1_es.jpg").exists()
        assert (out / "index.html").exists()

        sitemap = (out / "sitemap.xml").read_text(encoding="utf-8")
        assert slug_es in sitemap
        assert "/page/" not in sitemap
        ET.fromstring(sitemap)

        robots = (out / "robots.txt").read_text(encoding="utf-8")
        assert "Disallow: /*/page/" in robots

        llms = (out / "llms.txt").read_text(encoding="utf-8")
        assert slug_es in llms

        terminos = (out / "terminos" / "index.html").read_text(encoding="utf-8")
        assert len(re.findall(r"<h1[ >]", terminos)) == 1

        assert (out / "404.html").exists()

        feed = (out / "es" / "feed.xml").read_text(encoding="utf-8")
        ET.fromstring(feed)  # RSS 2.0 debe parsear sin error
    finally:
        p = db.path("_site")
        if p.exists():
            p.unlink()


if __name__ == "__main__":
    import tempfile
    from pathlib import Path
    with tempfile.TemporaryDirectory() as d:
        test_site_build(Path(d))
    print("test_site OK")
