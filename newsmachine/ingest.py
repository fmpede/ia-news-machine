"""Trae historias de las fuentes de un vertical e inserta en stories.
python -m newsmachine.ingest --vertical tech [--date D]
"""
import datetime as dt, hashlib, html, os, re, time
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

import feedparser, requests

from . import config, db

UA = "SintiaNewsBot/0.1 (+https://github.com/fmpede/ia-news-machine)"
TIMEOUT = 20
DROP_PARAMS = {"fbclid", "ref"}
TAG_RE = re.compile(r"<[^>]+>")


def canonical(url):
    """scheme+host lower, path sin trailing slash, sin fragment, sin utm_*/fbclid/ref."""
    u = urlsplit(url)
    path = u.path.rstrip("/")
    q = [(k, v) for k, v in parse_qsl(u.query) if k not in DROP_PARAMS and not k.startswith("utm_")]
    return urlunsplit((u.scheme.lower(), u.netloc.lower(), path, urlencode(q), ""))


def url_hash(url):
    return hashlib.sha1(canonical(url).encode()).hexdigest()


def strip_html(s):
    return html.unescape(TAG_RE.sub("", s or "")).strip()


def _iso(struct):
    return dt.datetime(*struct[:6], tzinfo=dt.timezone.utc).isoformat(timespec="seconds") if struct else None


def fetch_rss(src, date):
    feed = feedparser.parse(src["url"], request_headers={"User-Agent": UA})
    out = []
    for e in feed.entries:
        pub = e.get("published_parsed") or e.get("updated_parsed")
        out.append({"url": e.get("link"), "title": e.get("title", ""),
                     "summary": strip_html(e.get("summary", "")), "published_at": _iso(pub)})
    return out


def fetch_hn(src, date):
    r = requests.get("https://hn.algolia.com/api/v1/search", params={"tags": "front_page", "hitsPerPage": 30},
                      headers={"User-Agent": UA}, timeout=TIMEOUT)
    r.raise_for_status()
    out = []
    for hit in r.json().get("hits", []):
        if hit.get("points", 0) < src.get("min_points", 0):
            continue
        url = hit.get("url") or f"https://news.ycombinator.com/item?id={hit['objectID']}"
        out.append({"url": url, "title": hit.get("title", ""), "summary": "",
                     "points": hit.get("points"), "published_at": hit.get("created_at")})
    return out


def fetch_github_trending(src, date):
    since = (dt.date.fromisoformat(date) - dt.timedelta(days=7)).isoformat()
    headers = {"User-Agent": UA, "Accept": "application/vnd.github+json"}
    token = os.getenv("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    r = requests.get("https://api.github.com/search/repositories",
                      params={"q": f"created:>{since}", "sort": "stars", "order": "desc", "per_page": 20},
                      headers=headers, timeout=TIMEOUT)
    r.raise_for_status()
    out = []
    for repo in r.json().get("items", []):
        if repo.get("stargazers_count", 0) < src.get("min_stars", 0):
            continue
        out.append({"url": repo["html_url"], "title": f"{repo['full_name']} — {repo.get('description') or ''}",
                     "points": repo.get("stargazers_count"), "published_at": repo.get("created_at")})
    return out


def fetch_arxiv(src, date):
    time.sleep(3)  # arXiv pide 1 req / 3s
    q = urlencode({"search_query": src["query"], "sortBy": "submittedDate", "sortOrder": "descending",
                    "max_results": src.get("max", 15)})
    feed = feedparser.parse(f"http://export.arxiv.org/api/query?{q}", request_headers={"User-Agent": UA})
    out = []
    for e in feed.entries:
        out.append({"url": e.get("link") or e.get("id"), "title": (e.get("title") or "").strip(),
                     "summary": (e.get("summary") or "")[:600], "published_at": _iso(e.get("published_parsed"))})
    return out


def fetch_google_news(src, date):
    q = urlencode({"q": src["query"], "hl": src["hl"], "gl": src["gl"], "ceid": f"{src['gl']}:{src['hl']}"})
    feed = feedparser.parse(f"https://news.google.com/rss/search?{q}", request_headers={"User-Agent": UA})
    out = []
    for e in feed.entries:
        raw = e.get("title", "")
        if " - " in raw:
            title, _, publisher = raw.rpartition(" - ")
        else:
            title, publisher = raw, src.get("name", "Google News")
        out.append({"url": e.get("link"), "title": title, "source": f"Google News/{publisher}",
                     "summary": strip_html(e.get("summary", "")), "published_at": _iso(e.get("published_parsed"))})
    return out


FETCHERS = {"rss": fetch_rss, "hn": fetch_hn, "github_trending": fetch_github_trending,
            "arxiv": fetch_arxiv, "google_news": fetch_google_news}


def _insert(cfg, src, item):
    """Inserta una story; devuelve 1 si insertó, 0 si ya existía (UNIQUE vertical+url_hash)."""
    row = (cfg["name"], item["url"], url_hash(item["url"]), item["title"], item.get("summary", ""),
           item.get("source", src["name"]), item.get("source_weight", src.get("weight", 1)),
           item.get("lang", src.get("lang", cfg["languages"][0])),
           item.get("points"), item.get("published_at"), db.utcnow())
    cur = db.CONN.execute(
        "INSERT OR IGNORE INTO stories (vertical, url, url_hash, title, summary, source, source_weight, "
        "lang, points, published_at, fetched_at) VALUES (?,?,?,?,?,?,?,?,?,?,?)", row)
    return cur.rowcount if cur.rowcount > 0 else 0


def _ref_url(ref):
    return ref["url"] if isinstance(ref, dict) else ref


def _ingest_course(cfg):
    """Un item por lección del syllabus que no esté ya en stories (dedup vía UNIQUE). Sin HTTP."""
    lessons = cfg["syllabus_data"]["lessons"]
    n_ins = 0
    for lesson in lessons:
        refs = lesson.get("references") or []
        if not refs:
            continue
        summary = " ".join(lesson.get("objectives", []) + lesson.get("key_points", []))
        item = {"url": _ref_url(refs[0]), "title": lesson["title"], "summary": summary,
                 "source": "syllabus", "points": 1000 - lesson["id"]}
        n_ins += _insert(cfg, {"name": "syllabus"}, item)
    return len(lessons), n_ins


def run(cfg, date):
    db.connect(cfg["name"])
    total, had_error, details = 0, False, []
    if cfg["mode"] == "course":
        n_fetched, n_ins = _ingest_course(cfg)
        print(f"[syllabus] fetched={n_fetched} inserted={n_ins}")
        details.append(f"syllabus: {n_ins}/{n_fetched}")
        total += n_ins
    else:
        for src in cfg["sources"]:
            try:
                items = FETCHERS[src["type"]](src, date)
                n_ins = sum(_insert(cfg, src, it) for it in items)
                print(f"[{src['name']}] fetched={len(items)} inserted={n_ins}")
                details.append(f"{src['name']}: {n_ins}/{len(items)}")
                total += n_ins
            except Exception as e:
                had_error = True
                print(f"[{src['name']}] FAILED: {e}")
                db.log_run(date, "ingest", "warn", f"{src['name']}: {e}")
    db.prune(cfg["selection"]["dedup_window_days"])
    status = "warn" if had_error else ("ok" if total else "empty")
    db.log_run(date, "ingest", status, "; ".join(details))
    db.save()


def main(argv=None):
    cfg, args = config.parse(argv)
    run(cfg, args.date)


if __name__ == "__main__":
    main()
