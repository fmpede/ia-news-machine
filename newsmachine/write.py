"""Etapa 5: por (historia, idioma) genera todos los formatos en una llamada JSON."""
import datetime as dt, json
from . import db, llm
from .config import parse, prompt

S = {"type": "string"}
def obj(props): return {"type": "object", "properties": props, "required": list(props), "additionalProperties": False}
def arr(items): return {"type": "array", "items": items}
SCHEMA = obj({
    "post": obj({"text": S}),
    "thread": obj({"items": arr(S)}),
    "carousel": obj({"slides": arr(obj({"title": S, "body": S}))}),
    "card": obj({"title": S, "kicker": S}),
    "video": obj({"hook": S, "segments": arr(obj({"text": S, "card_title": S, "card_body": S})), "cta": S, "caption": S}),
    "article": obj({"title": S, "slug": S, "meta_description": S, "tldr": S, "html": S, "faq": arr(obj({"q": S, "a": S}))}),
    "alt_text": S, "illustration_prompt": S,
    "claims": arr(obj({"claim": S, "quote": S, "source_url": S})),
})
LANG_NAMES = {"es": "español rioplatense", "en": "English"}
LINK_NETWORKS = {"bluesky", "mastodon", "telegram", "threads", "linkedin"}  # reciben la URL de la fuente al final del post


def post_limit(cfg, lang):
    """Límite del post = el más chico entre las redes habilitadas que reciben 'post' (menos margen para la URL)."""
    lims = []
    for net, n in cfg["networks"].get(lang, {}).items():
        if n.get("enabled") and "post" in n.get("formats", []):
            lim = cfg["editorial"]["network_limits"].get(net, 500)
            lims.append(lim - 60 if net in LINK_NETWORKS else lim)
    return min(lims) if lims else 280


def source_name(story):
    return story["source"].split("/")[-1]


def save_outputs(cfg, date, story, lang, out, role, model):
    rows = {"post": out["post"], "thread": out["thread"], "card": out["card"],
            "article": {**out["article"], "claims": out["claims"], "alt_text": out["alt_text"], "angle": out.get("_angle", "")},
            "illustration": {"prompt": out["illustration_prompt"], "alt": out["alt_text"]}}
    if role == "hero":
        rows["carousel"] = out["carousel"]
        if cfg["formats"]["video"]["enabled"]:
            rows["video"] = out["video"]
    for fmt, content in rows.items():
        db.CONN.execute("""INSERT OR REPLACE INTO outputs (vertical, date, story_id, lang, format, content_json, model, created_at)
            VALUES (?,?,?,?,?,?,?,?)""", (cfg["name"], date, story["id"], lang, fmt, json.dumps(content, ensure_ascii=False), model, db.utcnow()))


def main(argv=None):
    cfg, args = parse(argv)
    db.connect(cfg["name"])
    sel = db.CONN.execute("""SELECT s.*, sel.role, sel.position FROM selected sel JOIN stories s ON s.id=sel.story_id
        WHERE sel.vertical=? AND sel.date=? ORDER BY sel.position""", (cfg["name"], args.date)).fetchall()
    rules = "\n".join(f"- {r}" for r in cfg["editorial"]["rules"])
    angles = cfg["editorial"].get("angles") or ["explicador"]
    done = failed = 0
    for story in sel:
        related = db.CONN.execute("SELECT title, url, source FROM stories WHERE cluster_id=? AND id!=? LIMIT 5", (story["id"], story["id"])).fetchall()
        for li, lang in enumerate(cfg["languages"]):
            if not args.force and db.CONN.execute("SELECT 1 FROM outputs WHERE vertical=? AND date=? AND story_id=? AND lang=? AND format='article'",
                                                    (cfg["name"], args.date, story["id"], lang)).fetchone():
                continue
            angle = angles[(story["position"] + li) % len(angles)]
            hero = story["role"] == "hero"
            art = cfg["formats"]["article"]
            p = prompt(cfg, "lesson" if cfg["mode"] == "course" else "write", brand_name=cfg["brand"]["name"], lang_name=LANG_NAMES.get(lang, lang), audience=cfg["audience"][lang],
                       tone=cfg["tone"][lang], angle=angle, editorial_rules=rules, max_quote_words=cfg["editorial"]["locked"]["max_quote_words"],
                       banned_words=", ".join(cfg["editorial"]["banned_words"].get(lang, [])), story_url=story["url"],
                       source_name=source_name(story), post_limit=post_limit(cfg, lang), disclosure=cfg["brand"]["disclosure"][lang],
                       hashtags=" ".join(cfg["editorial"]["hashtags"].get(lang, [])), thread_max=cfg["formats"]["post"]["thread_max"],
                       carousel_slides=cfg["formats"]["image"]["carousel_slides"], video_max_words=cfg["formats"]["video"]["max_words"],
                       article_min_words=art["min_words"] * (2 if hero else 1), article_max_words=art["max_words"] * (2 if hero else 1),
                       illustration_style=cfg["brand"]["illustration_style"], story_title=story["title"],
                       story_published=story["published_at"] or "", story_body=(story["body"] or story["summary"] or "")[:6000],
                       related_json=json.dumps([dict(r) for r in related], ensure_ascii=False) if related else "(ninguna)")
            try:
                out = llm.complete(p, json_schema=SCHEMA, tier="quality" if hero else "cheap", max_tokens=12000)
                out["_angle"] = angle
                save_outputs(cfg, args.date, story, lang, out, story["role"], "quality" if hero else "cheap")
                done += 1
            except Exception as e:
                failed += 1
                db.log_run(args.date, "write", "failed", f"story {story['id']} {lang}: {e}")
    db.log_run(args.date, "write", "ok" if done else "empty", f"{done} piezas, {failed} fallidas")
    db.save()


if __name__ == "__main__":
    main()
