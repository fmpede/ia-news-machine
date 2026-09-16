"""Tests offline (sin red) de newsmachine/publishers.py."""
import os
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from newsmachine import publishers  # noqa: E402


def test_facets_byte_offsets_con_acento():
    text = "Más info: https://example.com/x fin"
    url = "https://example.com/x"
    fs = publishers.facets(text)
    assert len(fs) == 1
    prefix = text[: text.index(url)]
    start = len(prefix.encode("utf-8"))
    end = start + len(url.encode("utf-8"))
    assert fs[0]["index"] == {"byteStart": start, "byteEnd": end}
    assert fs[0]["features"][0]["uri"] == url
    assert fs[0]["features"][0]["$type"] == "app.bsky.richtext.facet#link"


def test_strip_urls():
    text = "Mirá esto https://example.com/nota  y contame"
    out = publishers.strip_urls(text)
    assert "http" not in out
    assert "  " not in out
    assert out == "Mirá esto y contame"


def test_pack_escribe_caption_y_copia_imagen(tmp_path, monkeypatch):
    monkeypatch.setattr(publishers.config, "ROOT", tmp_path)
    img = tmp_path / "src" / "card.jpg"
    img.parent.mkdir()
    img.write_bytes(b"fake-jpeg")

    cfg = {"name": "tech"}
    story = {"id": 42, "url": "https://example.com/story", "title": "T", "source": "S"}
    outputs = {
        "post": {"content": {"text": "hola mundo"}, "file_path": None, "public_url": None},
        "card": {"content": {}, "file_path": str(img), "public_url": None},
    }

    folder = Path(publishers.pack(cfg, "2026-09-16", "telegram", "es", story, outputs, "sin credenciales"))
    caption = (folder / "caption.txt").read_text()
    assert "hola mundo" in caption
    assert "https://example.com/story" in caption
    assert "sin credenciales" in caption
    assert (folder / "card.jpg").read_bytes() == b"fake-jpeg"


def test_telegram_sin_token_lanza_notconfigured(monkeypatch):
    monkeypatch.delenv("TELEGRAM_BOT_TOKEN", raising=False)
    cfg = {"editorial": {"network_limits": {"telegram": 4096}}}
    net = {"chat_id": "@sintia_es", "formats": ["post"]}
    story = {"id": 1, "url": "https://example.com", "title": "T", "source": "S"}
    outputs = {"post": {"content": {"text": "hola"}, "file_path": None, "public_url": None}}
    with pytest.raises(publishers.NotConfigured):
        publishers.publish_telegram(cfg, net, "es", story, outputs)


def test_bluesky_sin_credenciales_lanza_notconfigured(monkeypatch):
    for k in ("NM_TECH_ES_BSKY_HANDLE", "NM_TECH_ES_BSKY_APP_PASSWORD"):
        monkeypatch.delenv(k, raising=False)
    cfg = {"editorial": {"network_limits": {"bluesky": 300}}}
    net = {"env": "NM_TECH_ES_BSKY", "formats": ["post"]}
    story = {"id": 1, "url": "https://example.com", "title": "T", "source": "S"}
    outputs = {"post": {"content": {"text": "hola"}, "file_path": None, "public_url": None}}
    with pytest.raises(publishers.NotConfigured):
        publishers.publish_bluesky(cfg, net, "es", story, outputs)
