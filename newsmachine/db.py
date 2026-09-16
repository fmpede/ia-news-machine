"""SQLite en memoria, persistido como dump de texto en state/<vertical>.sql (git = DB)."""
import datetime as dt, os, re, sqlite3
from .config import ROOT, SECRET_NAMES

SCHEMA = """
CREATE TABLE IF NOT EXISTS stories (
  id INTEGER PRIMARY KEY, vertical TEXT NOT NULL, url TEXT NOT NULL, url_hash TEXT NOT NULL,
  title TEXT NOT NULL, summary TEXT, body TEXT, source TEXT NOT NULL, source_weight REAL DEFAULT 1,
  lang TEXT, points INTEGER, published_at TEXT, fetched_at TEXT NOT NULL,
  cluster_id INTEGER, score REAL, score_json TEXT,
  UNIQUE (vertical, url_hash));
CREATE INDEX IF NOT EXISTS ix_stories_recent  ON stories (vertical, fetched_at);
CREATE INDEX IF NOT EXISTS ix_stories_cluster ON stories (vertical, cluster_id);
CREATE TABLE IF NOT EXISTS selected (
  vertical TEXT, date TEXT, story_id INTEGER REFERENCES stories(id),
  role TEXT CHECK (role IN ('hero','story')), position INTEGER,
  PRIMARY KEY (vertical, date, story_id));
CREATE TABLE IF NOT EXISTS outputs (
  id INTEGER PRIMARY KEY, vertical TEXT, date TEXT, story_id INTEGER, lang TEXT,
  format TEXT CHECK (format IN ('post','thread','carousel','card','video','article','illustration')),
  content_json TEXT NOT NULL, file_path TEXT, public_url TEXT,
  qa_status TEXT DEFAULT 'pending' CHECK (qa_status IN ('pending','pass','fixed','blocked')),
  qa_json TEXT, model TEXT, created_at TEXT,
  UNIQUE (vertical, date, story_id, lang, format));
CREATE INDEX IF NOT EXISTS ix_outputs_day ON outputs (vertical, date, qa_status);
CREATE TABLE IF NOT EXISTS publish_log (
  id INTEGER PRIMARY KEY, vertical TEXT, date TEXT, story_id INTEGER, lang TEXT, network TEXT, format TEXT,
  status TEXT CHECK (status IN ('ok','failed','packed','skipped')),
  post_id TEXT, url TEXT, error TEXT, published_at TEXT,
  UNIQUE (vertical, story_id, lang, network));
CREATE INDEX IF NOT EXISTS ix_publish_day ON publish_log (vertical, date, status);
CREATE TABLE IF NOT EXISTS quota (provider TEXT, day TEXT, calls INTEGER DEFAULT 0, tokens INTEGER DEFAULT 0,
  errors INTEGER DEFAULT 0, PRIMARY KEY (provider, day));
CREATE TABLE IF NOT EXISTS metrics (publish_id INTEGER REFERENCES publish_log(id), snapshot_at TEXT,
  likes INTEGER, reposts INTEGER, replies INTEGER, views INTEGER, raw_json TEXT, PRIMARY KEY (publish_id, snapshot_at));
CREATE TABLE IF NOT EXISTS runs (vertical TEXT, date TEXT, stage TEXT, status TEXT, detail TEXT, at TEXT);
"""
CONN = None
VERTICAL = None


def utcnow():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds")


def path(vertical):
    return ROOT / "state" / f"{vertical}.sql"


def connect(vertical):
    global CONN, VERTICAL
    CONN = sqlite3.connect(":memory:")
    CONN.row_factory = sqlite3.Row
    p = path(vertical)
    if p.exists():
        CONN.executescript(p.read_text())
    CONN.executescript(SCHEMA)
    VERTICAL = vertical
    return CONN


def save(vertical=None):
    vertical = vertical or VERTICAL
    p = path(vertical)
    tmp = p.with_suffix(".tmp")
    tmp.write_text("\n".join(CONN.iterdump()) + "\n")
    os.replace(tmp, p)


def quota_used(provider):
    r = CONN.execute("SELECT calls FROM quota WHERE provider=? AND day=?", (provider, utcnow()[:10])).fetchone()
    return r["calls"] if r else 0


def quota_add(provider, calls=1, tokens=0, errors=0):
    CONN.execute("""INSERT INTO quota (provider, day, calls, tokens, errors) VALUES (?,?,?,?,?)
        ON CONFLICT(provider, day) DO UPDATE SET calls=calls+excluded.calls, tokens=tokens+excluded.tokens,
        errors=errors+excluded.errors""", (provider, utcnow()[:10], calls, tokens, errors))


_PATTERNS = [(re.compile(r"bot\d{6,}:[\w-]{20,}"), "bot***"),
             (re.compile(r"(?i)(access_token|api_key|apikey|token|key|password|secret)=[^&\s'\"]+"), r"\1=***"),
             (re.compile(r"(?i)bearer\s+[\w.\-]{12,}"), "Bearer ***")]


def redact(text):
    """Quita valores de secretos y tokens en URLs antes de guardar o imprimir cualquier detalle de error."""
    text = str(text)
    for name in SECRET_NAMES:
        v = os.environ.get(name, "")
        if len(v) >= 8:
            text = text.replace(v, "***")
    for rx, rep in _PATTERNS:
        text = rx.sub(rep, text)
    return text


def log_run(date, stage, status, detail=""):
    detail = redact(detail)[:500]
    CONN.execute("INSERT INTO runs VALUES (?,?,?,?,?,?)", (VERTICAL, date, stage, status, detail, utcnow()))
    print(f"[{stage}] {status} {detail}"[:300])


def prune(days=30):
    cutoff = (dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=days)).isoformat()
    CONN.execute("""DELETE FROM stories WHERE vertical=? AND fetched_at<? AND id NOT IN (SELECT story_id FROM selected)""",
                 (VERTICAL, cutoff))
    CONN.execute("DELETE FROM runs WHERE at<?", (cutoff,))


if __name__ == "__main__":  # python -m newsmachine.db --selftest : roundtrip en un vertical temporal
    import tempfile
    connect("_selftest")
    CONN.execute("INSERT INTO stories (vertical,url,url_hash,title,source,fetched_at) VALUES ('t','u','h','T','s',?)", (utcnow(),))
    quota_add("gemini"); quota_add("gemini", tokens=10)
    assert quota_used("gemini") == 2
    save("_selftest")
    connect("_selftest")
    assert CONN.execute("SELECT count(*) c FROM stories").fetchone()["c"] == 1 and quota_used("gemini") == 2
    path("_selftest").unlink()
    print("db OK")
