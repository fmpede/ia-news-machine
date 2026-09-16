"""Tests offline de ingest.py y cluster.py: sin red, sin tocar state/tech.sql."""
import pytest

from newsmachine import db, ingest
from newsmachine.cluster import assign_clusters, jaccard, tokens


def test_canonical_strips_utm_and_fragment_and_trailing_slash():
    a = ingest.canonical("https://Example.com/foo/?utm_source=x&utm_campaign=y#frag")
    b = ingest.canonical("https://example.com/foo")
    assert a == b


def test_canonical_keeps_other_query_params():
    assert "id=5" in ingest.canonical("https://example.com/foo?id=5&utm_source=x")


def test_url_hash_same_for_equivalent_urls():
    h1 = ingest.url_hash("https://example.com/foo/?utm_source=x&fbclid=abc")
    h2 = ingest.url_hash("https://example.com/foo")
    assert h1 == h2


def test_jaccard_and_tokens_drop_stopwords():
    assert "the" not in tokens("the openai gpt-6 model")
    assert jaccard("OpenAI launches GPT-6 model", "OpenAI launches the GPT-6 model today") > 0.5


def test_assign_clusters_groups_similar_titles_and_keeps_unrelated_separate():
    rows = [
        (1, "OpenAI launches GPT-6 model", "https://a.com/1"),
        (2, "OpenAI launches the GPT-6 model today", "https://b.com/2"),
        (3, "Completely unrelated story about cats", "https://c.com/3"),
    ]
    clusters = assign_clusters(rows, 0.6)
    assert clusters[1] == clusters[2]
    assert clusters[3] != clusters[1]


def test_assign_clusters_same_url_clusters_regardless_of_title():
    rows = [
        (1, "Some headline", "https://example.com/story?utm_source=tw"),
        (2, "A totally different headline text here", "https://example.com/story"),
    ]
    clusters = assign_clusters(rows, 0.99)
    assert clusters[1] == clusters[2]


@pytest.fixture
def tmp_vertical():
    db.connect("_test")
    yield "_test"
    p = db.path("_test")
    if p.exists():
        p.unlink()


def test_ingest_insert_dedupes_on_reinsert(tmp_vertical):
    cfg = {"name": tmp_vertical, "languages": ["en"]}
    src = {"name": "fake", "weight": 1}
    items = [
        {"url": "https://x.com/a", "title": "A", "summary": ""},
        {"url": "https://x.com/b", "title": "B", "summary": ""},
    ]
    n1 = sum(ingest._insert(cfg, src, it) for it in items)
    assert n1 == 2
    n2 = sum(ingest._insert(cfg, src, it) for it in items)
    assert n2 == 0
