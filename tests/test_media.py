"""Tests offline (sin red) de newsmachine/images.py, tts.py y video.py."""
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from PIL import ImageFont  # noqa: E402
from newsmachine import images, tts, video  # noqa: E402


def _cfg():
    return {
        "brand": {
            "name": "Test",
            "colors": {"bg": "#0B0F19", "fg": "#F8FAFC", "accent": "#22D3EE", "muted": "#94A3B8"},
            "fonts": {"title": "assets/fonts/Inter.ttf", "body": "assets/fonts/Inter.ttf"},
            "disclosure": {"overlay": {"es": "Generado con IA"}, "voice": {"es": "Generado con IA."}},
        }
    }


def test_chunk_captions_respects_limits():
    # palabras contiguas de 300ms: un chunk de 4 entra bien dentro de 1600ms
    words = [(f"w{i}", i * 300, i * 300 + 300) for i in range(10)]
    chunks = video.chunk_captions(words)
    assert sum(len(c) for c in chunks) == len(words)
    for c in chunks:
        assert len(c) <= 4
        assert c[-1][2] - c[0][1] <= 1600

    # palabras de 500ms: al 4to excedería 1600ms, así que debe cortar antes
    words_slow = [(f"s{i}", i * 500, i * 500 + 500) for i in range(6)]
    chunks_slow = video.chunk_captions(words_slow)
    for c in chunks_slow:
        assert len(c) <= 4
        assert c[-1][2] - c[0][1] <= 1600


def test_proportional_timings_sums_to_duration():
    text = "a bb ccc dddd eeeee"
    duration = 1000
    timings = tts.proportional_timings(text, duration)
    assert len(timings) == len(text.split())
    assert timings[0][1] == 0
    assert timings[-1][2] == duration
    for (_, start, end) in timings:
        assert 0 <= start <= end <= duration
    # no vacío y no se pisan
    starts = [t[1] for t in timings]
    assert starts == sorted(starts)


def test_wrap_never_exceeds_max_width():
    font = ImageFont.truetype(str(PROJECT_ROOT / "assets" / "fonts" / "Inter.ttf"), 40)
    text = "Esta es una oración bastante larga para probar el wrap de líneas de una tarjeta cualquiera"
    max_width = 500
    lines = images.wrap(text, font, max_width)
    assert lines
    for ln in lines:
        assert font.getlength(ln) <= max_width
    # el texto completo se preserva (ninguna palabra se pierde)
    assert " ".join(lines).split() == text.split()


def test_stamp_ai_metadata_marker_present(tmp_path):
    out = images.generate(_cfg(), "prueba de gradiente", (200, 150), tmp_path / "gradient.jpg", providers=[])
    assert out.exists()
    data = out.read_bytes()
    assert b"trainedAlgorithmicMedia" in data
