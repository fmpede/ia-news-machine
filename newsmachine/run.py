"""Orquestador: corre las etapas en orden, tolera fallos después de select, y reporta al operador por Telegram."""
import importlib, json, sys, traceback
from . import db
from .config import parse, load_vertical

STAGES = ["ingest", "cluster", "rank", "select", "write", "qa", "media", "publish", "site", "metrics"]


def report(cfg, date):
    """5 líneas: publicado por red, packs/bloqueos, fallos, cupos, sitio."""
    q = lambda sql, *a: db.CONN.execute(sql, a).fetchall()
    pub = q("SELECT network, status, count(*) c FROM publish_log WHERE vertical=? AND date=? GROUP BY network, status", cfg["name"], date)
    ok = ", ".join(f"{r['network']}:{r['c']}" for r in pub if r["status"] == "ok") or "nada"
    packed = sum(r["c"] for r in pub if r["status"] in ("packed", "failed"))
    blocked = q("SELECT count(DISTINCT story_id||lang) c FROM outputs WHERE vertical=? AND date=? AND qa_status='blocked'", cfg["name"], date)[0]["c"]
    fails = q("SELECT stage, detail FROM runs WHERE vertical=? AND date=? AND status IN ('failed','warn') ORDER BY at DESC LIMIT 3", cfg["name"], date)
    quota = ", ".join(f"{r['provider']}:{r['calls']}" for r in q("SELECT provider, calls FROM quota WHERE day=?", db.utcnow()[:10]))
    lines = [f"📰 {cfg['brand']['name']} {date}", f"✅ Publicado: {ok}", f"📦 Packs/fallos: {packed} · 🚫 Bloqueados por QA: {blocked}",
             "⚠️ " + (" | ".join(f"{r['stage']}: {r['detail'][:80]}" for r in fails) if fails else "sin fallos"),
             f"🔢 Cupos: {quota or '-'} · 🌐 {cfg['brand']['site_url']}"]
    return "\n".join(lines)


def main(argv=None):
    def extra(ap):
        ap.add_argument("--from", dest="start", default="ingest"); ap.add_argument("--to", dest="end", default="site")
        ap.add_argument("--network", default="")
    cfg, args = parse(argv, extra)
    todo = STAGES[STAGES.index(args.start):STAGES.index(args.end) + 1]
    if cfg["mode"] == "course":
        todo = [s for s in todo if s != "cluster"]
    common = ["--vertical", cfg["name"], "--date", args.date] + (["--dry-run"] if args.dry_run else []) + (["--force"] if args.force else [])
    for stage in todo:
        argv_stage = common + (["--network", args.network] if stage == "publish" and args.network else [])
        try:
            importlib.import_module(f"newsmachine.{stage}").main(argv_stage)
        except SystemExit as e:
            if e.code not in (0, None): raise
        except Exception as e:
            db.connect(cfg["name"]); db.log_run(args.date, stage, "failed", f"{type(e).__name__}: {e}"); db.save()
            traceback.print_exc()
            if STAGES.index(stage) <= STAGES.index("select"):
                from .publishers import telegram_send
                telegram_send(f"❌ {cfg['brand']['name']} {args.date}: falló {stage}: {e}"); sys.exit(1)
    db.connect(cfg["name"])
    msg = report(cfg, args.date)
    print(msg)
    if "publish" in todo:
        from .publishers import telegram_send
        telegram_send(msg)
        n = db.CONN.execute("SELECT count(*) c FROM publish_log WHERE vertical=? AND date=? AND status IN ('ok','packed')", (cfg["name"], args.date)).fetchone()["c"]
        sys.exit(0 if n else 2)


if __name__ == "__main__":
    main()
