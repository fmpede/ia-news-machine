"""Etapa 10: engagement de los posts publicados (Bluesky, Mastodon, Telegram) y reporte markdown para la rutina editora."""
import datetime as dt, json, os
import requests
from . import db
from .config import parse


def bluesky(rows):
    uris = [r["post_id"] for r in rows if r["post_id"] and r["post_id"].startswith("at://")]
    out = {}
    for i in range(0, len(uris), 25):
        j = requests.get("https://public.api.bsky.app/xrpc/app.bsky.feed.getPosts", params={"uris": uris[i:i + 25]}, timeout=20).json()
        for p in j.get("posts", []):
            out[p["uri"]] = {"likes": p.get("likeCount", 0), "reposts": p.get("repostCount", 0), "replies": p.get("replyCount", 0), "views": None, "raw": p.get("viewer")}
    return out


def mastodon(rows, base):
    out = {}
    for r in rows:
        j = requests.get(f"{base}/api/v1/statuses/{r['post_id']}", timeout=20).json()
        out[r["post_id"]] = {"likes": j.get("favourites_count", 0), "reposts": j.get("reblogs_count", 0), "replies": j.get("replies_count", 0), "views": None, "raw": None}
    return out


def telegram(rows, chat_id):
    tok = os.getenv("TELEGRAM_BOT_TOKEN")
    if not tok: return {}
    n = requests.get(f"https://api.telegram.org/bot{tok}/getChatMemberCount", params={"chat_id": chat_id}, timeout=20).json().get("result")
    return {r["post_id"]: {"likes": None, "reposts": None, "replies": None, "views": None, "raw": {"subscribers": n}} for r in rows}


def collect(cfg, days=7):
    since = (dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=days)).date().isoformat()
    rows = db.CONN.execute("SELECT * FROM publish_log WHERE vertical=? AND status='ok' AND date>=?", (cfg["name"], since)).fetchall()
    now, n = db.utcnow(), 0
    for lang in cfg["languages"]:
        for net, ncfg in cfg["networks"].get(lang, {}).items():
            mine = [r for r in rows if r["network"] == net and r["lang"] == lang]
            if not mine: continue
            try:
                data = {"bluesky": lambda: bluesky(mine), "mastodon": lambda: mastodon(mine, ncfg.get("base_url", "")),
                        "telegram": lambda: telegram(mine, ncfg.get("chat_id"))}.get(ncfg["publisher"], lambda: {})()
            except Exception as e:
                print(f"metrics {net} {lang}: {e}"); continue
            for r in mine:
                m = data.get(r["post_id"])
                if m:
                    db.CONN.execute("INSERT OR REPLACE INTO metrics VALUES (?,?,?,?,?,?,?)", (r["id"], now, m["likes"], m["reposts"], m["replies"], m["views"], json.dumps(m["raw"])))
                    n += 1
    return n


def report(cfg, days=7):
    q = lambda sql, *a: db.CONN.execute(sql, a).fetchall()
    since = (dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=days)).date().isoformat()
    L = [f"# Reporte {cfg['brand']['name']} · últimos {days} días (desde {since})", "", "## Publicaciones por red y estado"]
    for r in q("SELECT network, lang, status, count(*) c FROM publish_log WHERE vertical=? AND date>=? GROUP BY 1,2,3 ORDER BY 1,2", cfg["name"], since):
        L.append(f"- {r['network']} {r['lang']} {r['status']}: {r['c']}")
    L += ["", "## Engagement (último snapshot por post)"]
    top = q("""SELECT p.network, p.lang, p.url, s.title, m.likes, m.reposts, m.replies FROM metrics m JOIN publish_log p ON p.id=m.publish_id
        JOIN stories s ON s.id=p.story_id WHERE p.vertical=? AND p.date>=? AND m.snapshot_at=(SELECT max(snapshot_at) FROM metrics WHERE publish_id=m.publish_id)
        ORDER BY coalesce(m.likes,0)+coalesce(m.reposts,0)*2 DESC""", cfg["name"], since)
    for tag, rows in (("Top", top[:5]), ("Bottom", top[-5:] if len(top) > 5 else [])):
        L.append(f"### {tag}")
        L += [f"- {r['network']}/{r['lang']} ❤{r['likes']} 🔁{r['reposts']} 💬{r['replies']} · {r['title'][:70]} · {r['url']}" for r in rows]
    L += ["", "## QA: bloqueos"]
    L += [f"- {r['date']} story {r['story_id']} {r['lang']}: {(r['qa_json'] or '')[:160]}" for r in
          q("SELECT DISTINCT date, story_id, lang, qa_json FROM outputs WHERE vertical=? AND date>=? AND qa_status='blocked'", cfg["name"], since)]
    L += ["", "## Fallos y avisos por etapa"]
    L += [f"- {r['date']} {r['stage']} {r['status']}: {r['detail'][:120]}" for r in q("SELECT * FROM runs WHERE vertical=? AND date>=? AND status!='ok' ORDER BY at", cfg["name"], since)]
    L += ["", "## Cupos por proveedor (llamadas/día)"]
    L += [f"- {r['day']} {r['provider']}: {r['calls']} llamadas, {r['tokens']} tokens, {r['errors']} errores" for r in q("SELECT * FROM quota WHERE day>=? ORDER BY day, provider", since)]
    return "\n".join(L)


def main(argv=None):
    def extra(ap): ap.add_argument("--report", type=int, default=0)
    cfg, args = parse(argv, extra)
    db.connect(cfg["name"])
    if args.report:
        print(report(cfg, args.report)); return
    n = collect(cfg)
    db.log_run(args.date, "metrics", "ok", f"{n} snapshots")
    db.save()


if __name__ == "__main__":
    main()
