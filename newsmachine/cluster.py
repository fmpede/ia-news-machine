"""Agrupa stories casi-duplicadas en clusters (cluster_id = id de la más vieja del grupo).
python -m newsmachine.cluster --vertical tech [--date D]
"""
import datetime as dt, re

from . import config, db
from .ingest import canonical

STOPWORDS = {"the", "and", "for", "with", "de", "la", "el", "los", "las", "un", "una", "con"}
PUNCT_RE = re.compile(r"[^\w\s]", re.UNICODE)


def tokens(title):
    words = PUNCT_RE.sub(" ", (title or "").lower()).split()
    return {w for w in words if len(w) > 3 and w not in STOPWORDS}


def jaccard(a, b):
    ta, tb = tokens(a), tokens(b)
    if not ta and not tb:
        return 0.0
    return len(ta & tb) / len(ta | tb)


def assign_clusters(rows, threshold):
    """rows = [(id, title, url), ...]. Pura, sin DB. Union-find sobre pares que matchean.
    ponytail: O(n^2) sobre todos los pares; aceptable para unos miles de rows/día,
    si crece mucho hay que hacer blocking por token compartido antes de comparar.
    """
    ids = [r[0] for r in rows]
    parent = {i: i for i in ids}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[rx] = ry

    canon = {r[0]: (canonical(r[2]) if r[2] else None) for r in rows}
    for i in range(len(rows)):
        id1, title1, _ = rows[i]
        for j in range(i + 1, len(rows)):
            id2, title2, _ = rows[j]
            same_url = canon[id1] is not None and canon[id1] == canon[id2]
            if same_url or jaccard(title1, title2) >= threshold:
                union(id1, id2)

    groups = {}
    for i in ids:
        groups.setdefault(find(i), []).append(i)
    result = {}
    for members in groups.values():
        rep = min(members)
        for m in members:
            result[m] = rep
    return result


def run(cfg, date):
    db.connect(cfg["name"])
    cutoff = (dt.datetime.now(dt.timezone.utc) -
              dt.timedelta(days=cfg["selection"]["dedup_window_days"])).isoformat()
    rows = db.CONN.execute(
        "SELECT id, title, url FROM stories WHERE vertical=? AND (fetched_at>=? OR cluster_id IS NULL)",
        (cfg["name"], cutoff)).fetchall()
    data = [(r["id"], r["title"], r["url"]) for r in rows]
    clusters = assign_clusters(data, cfg["selection"]["dedup_similarity"])
    for story_id, cluster_id in clusters.items():
        db.CONN.execute("UPDATE stories SET cluster_id=? WHERE id=?", (cluster_id, story_id))
    n_clusters = len(set(clusters.values()))
    db.log_run(date, "cluster", "ok", f"{len(data)} stories, {n_clusters} clusters")
    db.save()


def main(argv=None):
    cfg, args = config.parse(argv)
    run(cfg, args.date)


if __name__ == "__main__":
    main()
