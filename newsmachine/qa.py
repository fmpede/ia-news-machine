"""Etapa 7: checks determinísticos + veredicto LLM (Haiku → Sonnet). Ante la duda, bloquea."""
import json, re
from . import db, llm
from .config import parse, prompt
from .write import LINK_NETWORKS, source_name

SENSITIVE = {"es": ["salud", "enferm", "cáncer", "hospital", "internad", "embaraz", "gay", "lesbian", "sexual", "trans ",
                    "delito", "denunci", "detenid", "preso", "condena", "estafa", "adic", "droga", "alcohol", "rehab", "muri", "muert", "falleci", "suicid"],
             "en": ["health", "illness", "cancer", "hospital", "pregnan", "gay", "lesbian", "sexual", "trans ",
                    "crime", "arrest", "charged", "convict", "fraud", "addict", "drug", "alcohol", "rehab", "died", "death", "suicid"]}
NAME = re.compile(r"\b[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+ [A-ZÁÉÍÓÚÑ][a-záéíóúñ]+\b")
QUOTE = re.compile(r"[\"“«]([^\"”»]{10,})[\"”»]")
SCHEMA = {"type": "object", "properties": {
    "verdict": {"type": "string", "enum": ["pass", "fix", "block"]},
    "issues": {"type": "array", "items": {"type": "object", "properties": {"format": {"type": "string"}, "type": {"type": "string"},
        "text": {"type": "string"}, "fix": {"type": "string"}}, "required": ["format", "type", "text", "fix"], "additionalProperties": False}},
    "fixed_outputs": {"type": "string", "description": "JSON (como texto) del objeto con los formatos corregidos, o \"{}\" si verdict no es fix"}},
    "required": ["verdict", "issues", "fixed_outputs"], "additionalProperties": False}


def texts_of(outputs):
    """(formato, texto) de todo lo que se publica como texto."""
    for fmt, c in outputs.items():
        if fmt == "post": yield fmt, c["text"]
        elif fmt == "thread":
            for t in c["items"]: yield fmt, t
        elif fmt == "carousel":
            for s in c["slides"]: yield fmt, f"{s['title']} {s['body']}"
        elif fmt == "card": yield fmt, f"{c['title']} {c['kicker']}"
        elif fmt == "video": yield fmt, " ".join([c["hook"], *(s["text"] for s in c["segments"]), c["cta"], c.get("caption", "")])
        elif fmt == "article": yield fmt, re.sub(r"<[^>]+>", " ", c["html"]) + " " + c["tldr"]


def norm(s):
    return re.sub(r"\s+", " ", re.sub(r"[^\w\s]", "", s.lower()))


def check_rules(cfg, lang, story, outputs):
    """Checks determinísticos. Devuelve lista de issues; vacía = limpio."""
    issues, ed, locked = [], cfg["editorial"], cfg["editorial"]["locked"]
    disc, src = cfg["brand"]["disclosure"][lang], source_name(story)
    body = norm(story["body"] or story["summary"] or "")
    if "post" in outputs:
        t = outputs["post"]["text"]
        if disc not in t: issues.append(("post", "missing_disclosure", t[-80:]))
        if src.lower() not in t.lower(): issues.append(("post", "missing_attribution", src))
        if re.search(r"https?://", t): issues.append(("post", "url_in_post", "el post no lleva URLs"))
    if "thread" in outputs and outputs["thread"]["items"] and disc not in outputs["thread"]["items"][-1]:
        issues.append(("thread", "missing_disclosure", "último mensaje"))
    for net, n in cfg["networks"].get(lang, {}).items():
        if not n.get("enabled"): continue
        lim = ed["network_limits"].get(net, 500) - (len(story["url"]) + 1 if net in LINK_NETWORKS else 0)
        for fmt in ("post", "thread"):
            if fmt in n.get("formats", []) and fmt in outputs:
                for t in ([outputs["post"]["text"]] if fmt == "post" else outputs["thread"]["items"]):
                    if len(t) > lim: issues.append((fmt, "too_long", f"{len(t)} > {lim} para {net}"))
    banned = [w.lower() for w in ed["banned_words"].get(lang, [])]
    for fmt, t in texts_of(outputs):
        for q in QUOTE.findall(t):
            if len(q.split()) > locked["max_quote_words"]: issues.append((fmt, "long_quote", q[:60]))
        for w in banned:
            if re.search(rf"\b{re.escape(w)}\b", t.lower()): issues.append((fmt, "banned_word", w))
        low = t.lower()
        for name in set(NAME.findall(t)):
            for term in SENSITIVE.get(lang, []):
                for m in re.finditer(re.escape(term), low):
                    if abs(m.start() - low.find(name.lower())) <= 90:
                        quotes = [norm(c["quote"]) for c in outputs.get("article", {}).get("claims", []) if name.split()[0].lower() in c["claim"].lower()]
                        if locked["people_sensitive"] == "hold" or not any(q and q in body for q in quotes):
                            issues.append((fmt, "people_sensitive", f"{name} / {term}"))
                        break
    if locked["people_sensitive"] == "hold" and any(NAME.findall(t) for _, t in texts_of(outputs)):
        issues.append(("*", "hold", "menciona personas: requiere aprobación manual"))
    if "article" in outputs:
        art = outputs["article"]
        allowed = {story["url"]} | set(re.findall(r"https?://\S+", story["body"] or "")) | \
            {r["url"] for r in db.CONN.execute("SELECT url FROM stories WHERE cluster_id=?", (story["cluster_id"] or story["id"],))}
        if locked.get("require_source_url") and not art.get("claims"): issues.append(("article", "no_claims", ""))
        for c in art.get("claims", []):
            if c["source_url"] not in allowed: issues.append(("article", "bad_source_url", c["source_url"]))
        if src.lower() not in re.sub(r"<[^>]+>", " ", art["html"]).lower(): issues.append(("article", "missing_attribution", src))
        if "<h1" in art["html"]: issues.append(("article", "h1_in_body", ""))
    if "illustration" in outputs and NAME.findall(outputs["illustration"]["prompt"]):
        issues.append(("illustration", "real_person", outputs["illustration"]["prompt"][:80]))
    if "video" in outputs:
        words = len(" ".join([outputs["video"]["hook"], *(s["text"] for s in outputs["video"]["segments"]), outputs["video"]["cta"]]).split())
        if words > cfg["formats"]["video"]["max_words"] * 1.15: issues.append(("video", "too_long", f"{words} palabras"))
    return issues


def review(cfg, date, story, lang, rows):
    outputs = {r["format"]: json.loads(r["content_json"]) for r in rows}
    issues = check_rules(cfg, lang, story, outputs)
    hard = [i for i in issues if i[1] in ("people_sensitive", "hold", "bad_source_url", "no_claims", "real_person")]
    if hard:
        return "blocked", {"issues": [list(i) for i in issues], "stage": "rules"}, outputs
    try:
        out = llm.complete(prompt(cfg, "qa", brand_name=cfg["brand"]["name"], lang_name=lang, story_url=story["url"],
                                  story_body=(story["body"] or story["summary"] or "")[:6000], outputs_json=json.dumps(outputs, ensure_ascii=False),
                                  locked_rules="\n".join(f"- {k}: {v}" for k, v in cfg["editorial"]["locked"].items()),
                                  max_quote_words=cfg["editorial"]["locked"]["max_quote_words"], disclosure=cfg["brand"]["disclosure"][lang]),
                           json_schema=SCHEMA, tier="qa", max_tokens=12000)
    except Exception as e:
        return "blocked", {"issues": [list(i) for i in issues], "error": db.redact(e)[:300], "stage": "llm"}, outputs
    verdict, qa = out["verdict"], {"issues": [list(i) for i in issues] + out["issues"], "stage": "llm"}
    if verdict == "block":
        return "blocked", qa, outputs
    if verdict == "fix" or issues:
        try:
            fo = out["fixed_outputs"] if isinstance(out["fixed_outputs"], dict) else json.loads(out["fixed_outputs"] or "{}")
        except ValueError:
            return "blocked", {**qa, "error": "fixed_outputs no es JSON"}, outputs
        fixed = {**outputs, **{k: v for k, v in fo.items() if k in outputs}} if verdict == "fix" else outputs
        left = check_rules(cfg, lang, story, fixed)
        if left:
            return "blocked", {**qa, "left": [list(i) for i in left]}, outputs
        return "fixed", qa, fixed
    return "pass", qa, outputs


def main(argv=None):
    cfg, args = parse(argv)
    db.connect(cfg["name"])
    pairs = db.CONN.execute("""SELECT DISTINCT story_id, lang FROM outputs WHERE vertical=? AND date=? AND (qa_status='pending' OR ?)""",
                            (cfg["name"], args.date, args.force)).fetchall()
    counts = {}
    for p in pairs:
        story = db.CONN.execute("SELECT * FROM stories WHERE id=?", (p["story_id"],)).fetchone()
        rows = db.CONN.execute("SELECT * FROM outputs WHERE vertical=? AND date=? AND story_id=? AND lang=?", (cfg["name"], args.date, p["story_id"], p["lang"])).fetchall()
        status, qa, outputs = review(cfg, args.date, story, p["lang"], rows)
        for r in rows:
            db.CONN.execute("UPDATE outputs SET qa_status=?, qa_json=?, content_json=? WHERE id=?",
                            (status, json.dumps(qa, ensure_ascii=False)[:4000], json.dumps(outputs[r["format"]], ensure_ascii=False), r["id"]))
        counts[status] = counts.get(status, 0) + 1
        if status == "blocked":
            db.log_run(args.date, "qa", "blocked", f"story {p['story_id']} {p['lang']}: {qa.get('issues', [])[:3]} {qa.get('error', '')}")
    db.log_run(args.date, "qa", "ok", json.dumps(counts))
    db.save()


if __name__ == "__main__":
    main()
