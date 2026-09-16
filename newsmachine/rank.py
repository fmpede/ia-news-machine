"""Etapa 3: puntúa representantes de cluster con una rúbrica (LLM barato) o heurística de respaldo."""
import datetime as dt, json, math
from . import db, llm
from .config import parse, prompt

S = {"type": "integer"}
SCHEMA = {"type": "object", "properties": {"scores": {"type": "array", "items": {"type": "object", "properties": {
    "id": S, "relevance": S, "virality": S, "novelty": S, "risk": S, "reason": {"type": "string"}},
    "required": ["id", "relevance", "virality", "novelty", "risk", "reason"], "additionalProperties": False}}},
    "required": ["scores"], "additionalProperties": False}


def score_of(s):
    return round(0.4 * s["relevance"] + 0.3 * s["virality"] + 0.2 * s["novelty"] - 0.1 * s["risk"], 1)


def heuristic(r):
    age_h = 0
    if r["published_at"]:
        try:
            age_h = (dt.datetime.now(dt.timezone.utc) - dt.datetime.fromisoformat(r["published_at"].replace("Z", "+00:00"))).total_seconds() / 3600
        except ValueError:
            pass
    return round(40 * (r["source_weight"] or 1) + 20 * math.log10((r["points"] or 0) + 1) + max(0, 20 - age_h / 2), 1)


def candidates(cfg, date):
    cutoff = (dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=cfg["selection"]["max_age_hours"])).isoformat()
    return db.CONN.execute("""SELECT * FROM stories WHERE vertical=? AND score IS NULL AND fetched_at>=?
        AND (cluster_id IS NULL OR cluster_id=id) ORDER BY id""", (cfg["name"], cutoff)).fetchall()


def main(argv=None):
    cfg, args = parse(argv)
    db.connect(cfg["name"])
    rows = candidates(cfg, args.date)
    if cfg["mode"] == "course":  # orden del syllabus, sin LLM
        for r in rows:
            db.CONN.execute("UPDATE stories SET score=?, score_json='{\"course\":true}' WHERE id=?", (r["points"], r["id"]))
        rows = []
    n_llm = n_fallback = 0
    for i in range(0, len(rows), 25):
        batch = rows[i:i + 25]
        stories_json = json.dumps([{"id": r["id"], "title": r["title"], "summary": (r["summary"] or "")[:400],
                                    "source": r["source"], "points": r["points"], "lang": r["lang"]} for r in batch], ensure_ascii=False)
        try:
            out = llm.complete(prompt(cfg, "rank", brand_name=cfg["brand"]["name"], vertical=cfg["name"],
                                      audience=cfg["audience"][cfg["languages"][0]], tone=cfg["tone"][cfg["languages"][0]],
                                      geo=cfg["geo"]["region"], today=args.date,
                                      editorial_rules="\n".join(f"- {r}" for r in cfg["editorial"]["rules"]),
                                      stories_json=stories_json), json_schema=SCHEMA, tier="cheap")
            scores = {s["id"]: s for s in out["scores"]}
        except Exception as e:
            db.log_run(args.date, "rank", "warn", f"LLM falló, heurística: {e}")
            scores = {}
        for r in batch:
            s = scores.get(r["id"])
            if s:
                db.CONN.execute("UPDATE stories SET score=?, score_json=? WHERE id=?", (score_of(s), json.dumps(s, ensure_ascii=False), r["id"]))
                n_llm += 1
            else:
                db.CONN.execute("UPDATE stories SET score=?, score_json=? WHERE id=?", (heuristic(r), '{"fallback": true, "risk": 20}', r["id"]))
                n_fallback += 1
    db.log_run(args.date, "rank", "ok", f"{n_llm} por LLM, {n_fallback} por heurística")
    db.save()


if __name__ == "__main__":
    main()
