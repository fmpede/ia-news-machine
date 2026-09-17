"""Etapa 4: elige las N historias del día (1 hero) y baja el cuerpo de cada una."""
import datetime as dt, json, re
from html.parser import HTMLParser
from urllib.parse import urlparse
import requests
from . import db
from .config import parse

UA = {"User-Agent": "SintiaNewsBot/0.1 (+https://github.com/fmpede/ia-news-machine)"}


class _Text(HTMLParser):
    def __init__(self):
        super().__init__(); self.parts, self.skip, self.in_p = [], 0, False
    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style", "nav", "footer", "header", "aside"): self.skip += 1
        if tag in ("p", "li", "h2", "h3"): self.in_p = True
    def handle_endtag(self, tag):
        if tag in ("script", "style", "nav", "footer", "header", "aside"): self.skip = max(0, self.skip - 1)
        if tag in ("p", "li", "h2", "h3"): self.in_p = False; self.parts.append("\n")
    def handle_data(self, data):
        if not self.skip and self.in_p: self.parts.append(data)


def fetch_body(url, summary="", limit=4000):
    """Texto de los <p> del artículo; si falla o es un redirect de Google News, el resumen del feed."""
    try:
        r = requests.get(url, headers=UA, timeout=20, allow_redirects=True)
        if "news.google." in urlparse(r.url).netloc or r.status_code >= 400:
            return summary
        p = _Text(); p.feed(r.text)
        text = re.sub(r"[ \t]+", " ", "".join(p.parts)); text = re.sub(r"\n{2,}", "\n", text).strip()
        return text[:limit] if len(text) > len(summary) else summary
    except Exception:
        return summary


def resolve_google_news(url):
    """Los links de Google News son redirecciones de 500+ caracteres: los resolvemos a la URL real del medio."""
    if "news.google." not in urlparse(url).netloc:
        return url
    try:
        from googlenewsdecoder import gnewsdecoder
        r = gnewsdecoder(url, interval=1)
        return r["decoded_url"] if r.get("status") and r.get("decoded_url") else url
    except Exception:
        return url


MIN_BODY = 400  # sin texto fuente suficiente no hay pieza verificable: se salta la historia


def risk(r):
    try:
        return json.loads(r["score_json"] or "{}").get("risk", 0)
    except ValueError:
        return 0


def main(argv=None):
    cfg, args = parse(argv)
    db.connect(cfg["name"])
    sel = cfg["selection"]
    if db.CONN.execute("SELECT 1 FROM selected WHERE vertical=? AND date=?", (cfg["name"], args.date)).fetchone() and not args.force:
        db.log_run(args.date, "select", "ok", "ya seleccionado (usar --force para rehacer)"); return
    db.CONN.execute("DELETE FROM selected WHERE vertical=? AND date=?", (cfg["name"], args.date))
    if args.force:  # rehacer el día: los outputs de la selección anterior ya no valen
        db.CONN.execute("DELETE FROM outputs WHERE vertical=? AND date=?", (cfg["name"], args.date))
    cutoff = (dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=sel["max_age_hours"])).isoformat()
    n = sel.get("stories_per_day") or sel.get("lessons_per_day", 1)
    rows = db.CONN.execute("""SELECT * FROM stories WHERE vertical=? AND score>=? AND (cluster_id IS NULL OR cluster_id=id)
        AND (fetched_at>=? OR ?='course') AND id NOT IN (SELECT story_id FROM selected WHERE vertical=?)
        ORDER BY score DESC""", (cfg["name"], sel["min_score"] if cfg["mode"] == "news" else 0, cutoff, cfg["mode"], cfg["name"])).fetchall()
    per_source, chosen, bodies = {}, [], {}
    for r in rows:
        if per_source.get(r["source"], 0) >= sel.get("max_per_source", 99): continue
        body = r["body"]
        if not body:
            if cfg["mode"] == "course":
                body = r["summary"]
            else:
                url = resolve_google_news(r["url"])
                if url != r["url"]:
                    db.CONN.execute("UPDATE stories SET url=? WHERE id=?", (url, r["id"]))
                body = fetch_body(url, r["summary"] or "")
            db.CONN.execute("UPDATE stories SET body=? WHERE id=?", (body, r["id"]))
        if cfg["mode"] == "news" and len(body or "") < MIN_BODY:
            db.log_run(args.date, "select", "warn", f"salteada (texto fuente insuficiente): {r['title'][:60]}")
            continue
        per_source[r["source"]] = per_source.get(r["source"], 0) + 1
        chosen.append(db.CONN.execute("SELECT * FROM stories WHERE id=?", (r["id"],)).fetchone())
        if len(chosen) >= n: break
    if not chosen:
        db.log_run(args.date, "select", "empty", "sin historias elegibles"); db.save(); return
    hero = next((r for r in chosen if risk(r) <= sel.get("max_risk_for_hero", 100)), chosen[0])
    if cfg["mode"] == "news" and sel.get("min_cluster_sources_for_hero", 1) > 1:
        ok = [r for r in chosen if db.CONN.execute("SELECT count(DISTINCT source) c FROM stories WHERE cluster_id=?", (r["id"],)).fetchone()["c"] >= sel["min_cluster_sources_for_hero"]]
        hero = next((r for r in ok if risk(r) <= sel.get("max_risk_for_hero", 100)), None)
    for i, r in enumerate(chosen):
        role = "hero" if hero is not None and r["id"] == hero["id"] else "story"
        db.CONN.execute("INSERT INTO selected VALUES (?,?,?,?,?)", (cfg["name"], args.date, r["id"], role, i))
    db.log_run(args.date, "select", "ok", f"{len(chosen)} historias, hero={hero['title'][:60] if hero else None}")
    db.save()


if __name__ == "__main__":
    main()
