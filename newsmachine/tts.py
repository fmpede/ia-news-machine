"""Texto a voz: edge-tts (con timings de palabra) -> Google Cloud TTS -> nada.
Estilo: stdlib + requests + edge-tts, sin clases."""
import asyncio, base64, os, subprocess, sys
from pathlib import Path
import requests
from . import db


def speak(cfg, text, lang, out_mp3):
    """-> (Path, timings) | (None, None). timings = [(word, start_ms, end_ms), ...] o None
    si el proveedor que respondió no da timing por palabra (el llamador usa proportional_timings)."""
    out_mp3 = Path(out_mp3)
    out_mp3.parent.mkdir(parents=True, exist_ok=True)
    voice = cfg["formats"]["video"]["voice"][lang]

    timings = _edge_tts(text, voice, out_mp3)
    if timings is not None:
        return out_mp3, timings
    if _google_tts(text, lang, out_mp3):
        return out_mp3, None
    return None, None


def _edge_tts(text, voice, out_mp3):
    try:
        return asyncio.run(_edge_tts_async(text, voice, out_mp3))
    except Exception as e:
        print(f"tts: edge-tts falló: {e}")
        if db.CONN is not None:
            db.quota_add("edge_tts", calls=0, errors=1)
        return None


async def _edge_tts_async(text, voice, out_mp3):
    import edge_tts

    # edge-tts >=7 default a boundary="SentenceBoundary"; forzamos WordBoundary (lo que pide el spec).
    communicate = edge_tts.Communicate(text, voice, boundary="WordBoundary")
    chunks, words = [], []
    async for chunk in communicate.stream():
        if chunk["type"] == "audio":
            chunks.append(chunk["data"])
        elif chunk["type"] == "WordBoundary":
            start = chunk["offset"] / 10_000  # 100ns ticks -> ms
            end = start + chunk["duration"] / 10_000
            words.append((chunk["text"], round(start), round(end)))
    if not chunks:
        raise RuntimeError("sin audio en la respuesta")
    out_mp3.write_bytes(b"".join(chunks))
    if db.CONN is not None:
        db.quota_add("edge_tts")
    return words


def _google_tts(text, lang, out_mp3):
    key = os.getenv("GOOGLE_TTS_KEY")
    if not key:
        return False
    try:
        body = {
            "input": {"text": text},
            "voice": {"languageCode": "es-US" if lang == "es" else "en-US"},
            "audioConfig": {"audioEncoding": "MP3"},
        }
        r = requests.post(f"https://texttospeech.googleapis.com/v1/text:synthesize?key={key}", json=body, timeout=60)
        r.raise_for_status()
        out_mp3.write_bytes(base64.b64decode(r.json()["audioContent"]))
        if db.CONN is not None:
            db.quota_add("google_tts")
        return True
    except Exception as e:
        print(f"tts: google cloud tts falló: {e}")
        if db.CONN is not None:
            db.quota_add("google_tts", calls=0, errors=1)
        return False


def proportional_timings(text, duration_ms):
    """Reparte duration_ms entre las palabras de `text`, pesando por len(word)+1."""
    words = text.split()
    if not words:
        return []
    weights = [len(w) + 1 for w in words]
    total = sum(weights)
    out, t = [], 0.0
    for i, (w, wt) in enumerate(zip(words, weights)):
        end = duration_ms if i == len(words) - 1 else t + duration_ms * wt / total
        out.append((w, round(t), round(end)))
        t = end
    return out


def duration_ms(path):
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(path)],
        capture_output=True, text=True, check=True,
    )
    return round(float(out.stdout.strip()) * 1000)


if __name__ == "__main__":  # python -m newsmachine.tts --selftest
    from .config import ROOT, load_env

    load_env()
    cfg = {"formats": {"video": {"voice": {"es": "es-AR-TomasNeural"}}}}
    out = ROOT / "out" / "_selftest" / "voice.mp3"
    path, timings = speak(cfg, "Hola, esto es una prueba de Sintia.", "es", out)
    if path is None:
        print("SKIP: edge-tts no disponible (sin red)")
        sys.exit(0)
    assert path.stat().st_size > 1024, "voice.mp3 demasiado chico"
    assert timings, "sin timings de palabra"
    print("OK tts.py:", path, len(timings), "palabras,", duration_ms(path), "ms")
