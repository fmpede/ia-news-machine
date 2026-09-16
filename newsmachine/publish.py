"""Etapa 8: publica cada (historia, idioma) en las redes habilitadas; idempotente; lo que no sale va al publish pack."""
import json
from . import db, publishers
from .config import parse
from .write import LINK_NETWORKS


def outputs_for(cfg, date, story_id, lang):
    rows = db.CONN.execute("SELECT * FROM outputs WHERE vertical=? AND date=? AND story_id=? AND lang=?", (cfg["name"], date, story_id, lang)).fetchall()
    return {r["format"]: {"content": json.loads(r["content_json"]), "file_path": r["file_path"], "public_url": r["public_url"], "qa_status": r["qa_status"]} for r in rows}


def main(argv=None):
    def extra(ap): ap.add_argument("--network", default="")
    cfg, args = parse(argv, extra)
    db.connect(cfg["name"])
    pairs = db.CONN.execute("SELECT DISTINCT story_id, lang FROM outputs WHERE vertical=? AND date=?", (cfg["name"], args.date)).fetchall()
    counts = {}
    for p in pairs:
        story = db.CONN.execute("SELECT * FROM stories WHERE id=?", (p["story_id"],)).fetchone()
        outs = outputs_for(cfg, args.date, p["story_id"], p["lang"])
        good = {k: v for k, v in outs.items() if v["qa_status"] in ("pass", "fixed")}
        if not good:
            reason = next((v["content"] and db.CONN.execute("SELECT qa_json FROM outputs WHERE vertical=? AND date=? AND story_id=? AND lang=? LIMIT 1",
                          (cfg["name"], args.date, p["story_id"], p["lang"])).fetchone()[0] for v in outs.values()), "")
            publishers.pack(cfg, args.date, "blocked", p["lang"], story, outs, f"QA bloqueó: {str(reason)[:500]}")
            counts["blocked"] = counts.get("blocked", 0) + 1
            continue
        for net, n in cfg["networks"].get(p["lang"], {}).items():
            if args.network and net != args.network: continue
            prev = db.CONN.execute("SELECT status FROM publish_log WHERE vertical=? AND story_id=? AND lang=? AND network=?", (cfg["name"], p["story_id"], p["lang"], net)).fetchone()
            if prev and prev["status"] == "ok" and not args.force: continue
            outs_net = {k: dict(v) for k, v in good.items() if k in n.get("formats", []) or k in ("illustration", "thread")}
            if not any(k in outs_net for k in n.get("formats", [])):
                status, post_id, url, err = "skipped", None, None, "sin formato aplicable"
            elif not n.get("enabled"):
                publishers.pack(cfg, args.date, net, p["lang"], story, outs_net, "red deshabilitada (faltan secrets)")
                status, post_id, url, err = "packed", None, None, "disabled"
            else:
                if "post" in outs_net and net in LINK_NETWORKS:
                    outs_net["post"] = {**outs_net["post"], "content": {**outs_net["post"]["content"], "text": outs_net["post"]["content"]["text"] + "\n" + story["url"]}}
                if args.dry_run:
                    publishers.pack(cfg, args.date, net, p["lang"], story, outs_net, "dry-run")
                    status, post_id, url, err = "packed", None, None, "dry-run"
                else:
                    try:
                        res = publishers.PUBLISHERS[n["publisher"]](cfg, n, p["lang"], story, outs_net)
                        status, post_id, url, err = "ok", str(res.get("post_id")), res.get("url"), None
                    except publishers.NotConfigured as e:
                        publishers.pack(cfg, args.date, net, p["lang"], story, outs_net, f"no configurado: {e}")
                        status, post_id, url, err = "packed", None, None, str(e)[:300]
                    except Exception as e:
                        publishers.pack(cfg, args.date, net, p["lang"], story, outs_net, f"falló: {e}")
                        status, post_id, url, err = "failed", None, None, f"{type(e).__name__}: {str(e)[:300]}"
                        db.log_run(args.date, "publish", "failed", f"{net} {p['lang']} story {p['story_id']}: {err}")
            db.CONN.execute("""INSERT OR REPLACE INTO publish_log (vertical, date, story_id, lang, network, format, status, post_id, url, error, published_at)
                VALUES (?,?,?,?,?,?,?,?,?,?,?)""", (cfg["name"], args.date, p["story_id"], p["lang"], net, ",".join(k for k in outs_net if k in n.get("formats", [])),
                                                   status, post_id, url, err, db.utcnow()))
            counts[status] = counts.get(status, 0) + 1
    db.log_run(args.date, "publish", "ok" if counts.get("ok") or counts.get("packed") else "empty", json.dumps(counts))
    db.save()


if __name__ == "__main__":
    main()
