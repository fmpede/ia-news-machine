"""Integración sin red: rank → select → write → qa → publish(dry-run) con un LLM simulado, en el vertical temporal _test."""
import json, shutil
import pytest
import yaml
from newsmachine import config, db, llm, rank, select, write, qa, publish, run

DATE, STORY_URL = "2026-01-01", "https://example.com/news/gpt-6"
FAKE_WRITE = {
    "post": {"text": "OpenAI presentó GPT-6 y, según Test Source, duplica la velocidad de respuesta. Lo que cambia para vos: menos espera.\n🤖 Generado con IA · Fuente: Test Source #tecnología #IA"},
    "thread": {"items": ["GPT-6 llegó, según Test Source.", "Fin del hilo. 🤖 Generado con IA · Fuente: Test Source"]},
    "carousel": {"slides": [{"title": "GPT-6", "body": "Más rápido, según Test Source."}, {"title": "Qué cambia", "body": "Menos espera."}]},
    "card": {"title": "GPT-6 duplica la velocidad", "kicker": "Modelos"},
    "video": {"hook": "GPT-6 ya está acá.", "segments": [{"text": "Según Test Source duplica la velocidad.", "card_title": "Más rápido", "card_body": "el doble"}], "cta": "Mirá la fuente.", "caption": "GPT-6 🤖 Generado con IA · Fuente: Test Source"},
    "article": {"title": "GPT-6: qué cambia", "slug": "gpt-seis-que-cambia", "meta_description": "GPT-6 según Test Source.", "tldr": "Más rápido.",
                "html": "<p>Según Test Source, GPT-6 duplica la velocidad.</p><h2>Por qué importa</h2><p>Menos espera.</p>", "faq": [{"q": "¿Cuándo sale?", "a": "No se informó."}]},
    "alt_text": "Ilustración abstracta de un circuito", "illustration_prompt": "abstract glowing circuit board, flat editorial illustration",
    "claims": [{"claim": "GPT-6 duplica la velocidad", "quote": "GPT-6 duplica la velocidad de respuesta", "source_url": STORY_URL}],
}


def fake_complete(prompt, system="", json_schema=None, tier="cheap", max_tokens=0):
    req = json_schema.get("required", [])
    if "scores" in req:
        ids = [s["id"] for s in json.loads(prompt.split("Historias:")[-1].strip())]
        return {"scores": [{"id": i, "relevance": 90, "virality": 80, "novelty": 70, "risk": 5, "reason": "test"} for i in ids]}
    if "post" in req:
        out = json.dumps(FAKE_WRITE, ensure_ascii=False)
        if "Escribís en English" in prompt:
            out = out.replace("🤖 Generado con IA · Fuente:", "🤖 AI-generated · Source:")
        return json.loads(out)
    return {"verdict": "pass", "issues": [], "fixed_outputs": {}}


@pytest.fixture
def vertical(monkeypatch, tmp_path):
    cfg = yaml.safe_load((config.ROOT / "verticals" / "tech.yaml").read_text())
    cfg["name"] = "_test"
    (config.ROOT / "verticals" / "_test.yaml").write_text(yaml.safe_dump(cfg, allow_unicode=True))
    monkeypatch.setattr(llm, "complete", fake_complete)
    monkeypatch.setattr(select, "fetch_body", lambda url, summary="", limit=0: "cuerpo: GPT-6 duplica la velocidad de respuesta, dijo OpenAI.")
    monkeypatch.delenv("TELEGRAM_BOT_TOKEN", raising=False)
    db.connect("_test")
    db.CONN.execute("INSERT INTO stories (vertical,url,url_hash,title,summary,source,source_weight,lang,points,published_at,fetched_at) VALUES (?,?,?,?,?,?,?,?,?,?,?)",
                    ("_test", STORY_URL, "h1", "OpenAI launches GPT-6", "GPT-6 duplica la velocidad", "Test Source", 1.0, "en", 500, db.utcnow(), db.utcnow()))
    db.save("_test")
    yield cfg
    (config.ROOT / "verticals" / "_test.yaml").unlink(missing_ok=True)
    db.path("_test").unlink(missing_ok=True)
    shutil.rmtree(config.ROOT / "out" / "_test", ignore_errors=True)


def test_pipeline_end_to_end(vertical):
    a = ["--vertical", "_test", "--date", DATE]
    rank.main(a)
    assert db.CONN.execute("SELECT score FROM stories").fetchone()["score"] == rank.score_of({"relevance": 90, "virality": 80, "novelty": 70, "risk": 5})
    select.main(a)
    assert db.CONN.execute("SELECT role FROM selected").fetchone()["role"] == "hero"
    write.main(a)
    fmts = {r["format"] for r in db.CONN.execute("SELECT format FROM outputs WHERE lang='es'")}
    assert {"post", "thread", "carousel", "card", "video", "article", "illustration"} <= fmts
    qa.main(a)
    assert {r["qa_status"] for r in db.CONN.execute("SELECT qa_status FROM outputs")} == {"pass"}
    publish.main(a + ["--dry-run"])
    rows = db.CONN.execute("SELECT network, status FROM publish_log WHERE lang='es'").fetchall()
    assert rows and all(r["status"] in ("packed", "skipped") for r in rows)
    packs = list((config.ROOT / "out" / "_test" / DATE / "pack").glob("*/*/caption.txt"))
    assert packs and "example.com" in packs[0].read_text()          # las redes con link reciben la URL
    assert len(run.report(vertical, DATE).splitlines()) == 5
    total = db.CONN.execute("SELECT count(*) c FROM publish_log").fetchone()["c"]
    publish.main(a + ["--dry-run"])                                  # idempotente: no duplica filas
    assert db.CONN.execute("SELECT count(*) c FROM publish_log").fetchone()["c"] == total


def test_check_rules_blocks(vertical):
    story = db.CONN.execute("SELECT * FROM stories").fetchone()
    good = {"post": FAKE_WRITE["post"], "article": {**FAKE_WRITE["article"], "claims": FAKE_WRITE["claims"]}}
    bad = json.loads(json.dumps(good))
    bad["post"]["text"] = "Juan Pérez fue detenido por estafa, dicen en redes. Mirá https://x.com"
    bad["article"]["claims"][0]["source_url"] = "https://otro.com"
    types = {i[1] for i in qa.check_rules(vertical, "es", story, bad)}
    assert {"missing_disclosure", "missing_attribution", "url_in_post", "people_sensitive", "bad_source_url"} <= types
    assert qa.check_rules(vertical, "es", story, good) == []
