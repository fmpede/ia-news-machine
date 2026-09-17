"""Video 9:16: voz (tts) + tarjetas (images.render_card) + subtítulos .ass + ffmpeg.
Estilo: stdlib + Pillow (via images) + ffmpeg por subprocess, sin clases."""
import subprocess
from pathlib import Path
from .config import ROOT
from . import images, tts
from . import db

ASS_HEADER = """[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Inter,64,&H00FFFFFF,&H000000FF,&H00000000,&H80000000,-1,0,0,0,100,100,0,0,1,4,0,2,60,60,420,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text"""


def chunk_captions(words):
    """Agrupa palabras con timing en chunks de <=4 palabras y <=1600ms de duración."""
    chunks, cur = [], []
    for w in words:
        start = cur[0][1] if cur else w[1]
        if cur and (len(cur) >= 4 or w[2] - start > 1600):
            chunks.append(cur)
            cur = []
        cur.append(w)
    if cur:
        chunks.append(cur)
    return chunks


def _ass_time(ms):
    cs = round(ms / 10)
    h, rem = divmod(cs, 360000)
    m, rem = divmod(rem, 6000)
    s, cs = divmod(rem, 100)
    return f"{h}:{m:02d}:{s:02d}.{cs:02d}"


def _write_ass(chunks, path):
    lines = [ASS_HEADER]
    for chunk in chunks:
        start, end = chunk[0][1], chunk[-1][2]
        text = " ".join(w[0] for w in chunk)
        lines.append(f"Dialogue: 0,{_ass_time(start)},{_ass_time(end)},Default,,0,0,0,,{text}")
    Path(path).write_text("\n".join(lines) + "\n", encoding="utf-8")


def _esc_text(t):  # texto dentro de un valor de filtro entre comillas simples
    return t.replace("\\", "\\\\").replace(":", "\\:").replace("'", "’").replace("%", "\\%")


def _esc_path(p):  # ruta como valor de filtro (ffmpeg usa ':' como separador de opciones)
    return p.replace("\\", "/").replace(":", "\\:").replace("'", "\\'")


def _available_filters():
    """Nombres de filtros compilados en este ffmpeg (ej. sin libass -> sin 'subtitles')."""
    try:
        out = subprocess.run(["ffmpeg", "-hide_banner", "-filters"], capture_output=True, text=True, timeout=10).stdout
    except Exception:
        return set()
    return {name for name in ("subtitles", "drawtext") if name in out}


def build(cfg, lang, video, illustration, source, out_dir):
    out_dir = Path(out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    hook, segments, cta = video.get("hook", ""), video.get("segments", []), video.get("cta", "")
    disclosure_voice = cfg["brand"]["disclosure"]["voice"][lang]
    parts = [hook, *[s.get("text", "") for s in segments], cta, disclosure_voice]
    script = " ".join(p.strip() for p in parts if p and p.strip())

    voice_path, word_timings = tts.speak(cfg, script, lang, out_dir / "voice.mp3")
    if voice_path is None:
        print("video: tts falló (sin proveedor disponible), no se genera video")
        return None

    dur_ms = tts.duration_ms(voice_path)
    words = word_timings if word_timings else tts.proportional_timings(script, dur_ms)

    _write_ass(chunk_captions(words), out_dir / "captions.ass")

    # límites de palabra por tarjeta: la tarjeta 0 lleva el hook + el primer segmento,
    # cada tarjeta i (i>=1) el segmento i; el último segmento se extiende hasta el final
    # de la voz (cubre también la cta y el disclosure hablado).
    hook_n = len(hook.split())
    seg_ns = [len(s.get("text", "").split()) for s in segments]
    starts_idx = [0]
    idx = hook_n + (seg_ns[0] if seg_ns else 0)
    for n in seg_ns[1:]:
        starts_idx.append(idx)
        idx += n

    def word_start(i):
        if i <= 0:
            return 0
        return words[i][1] if i < len(words) else dur_ms

    cards_dir = out_dir / "cards"
    cards_dir.mkdir(exist_ok=True)
    card_files = []
    n_cards = max(1, len(segments))
    for i in range(n_cards):
        start = word_start(starts_idx[i])
        end = word_start(starts_idx[i + 1]) if i + 1 < len(starts_idx) else dur_ms
        seg = segments[i] if i < len(segments) else {}
        p = cards_dir / f"card_{i:02d}.jpg"
        images.render_card(cfg, lang, seg.get("card_title", ""), source, source, p,
                            size=(1080, 1920), backdrop=illustration, body=seg.get("card_body"))
        card_files.append((p, max(0.2, (end - start) / 1000)))

    heading = "Fuentes" if lang == "es" else "Sources"
    disclosure_overlay = cfg["brand"]["disclosure"]["overlay"][lang]
    sources_path = cards_dir / f"card_{n_cards:02d}.jpg"
    images.render_card(cfg, lang, heading, source, source, sources_path,
                        size=(1080, 1920), backdrop=None, body=disclosure_overlay)
    card_files.append((sources_path, 3.0))

    cards_txt = out_dir / "cards.txt"
    lines = []
    for p, d in card_files:
        lines.append(f"file '{p.resolve()}'")
        lines.append(f"duration {d:.3f}")
    lines.append(f"file '{card_files[-1][0].resolve()}'")  # el concat demuxer ignora la última duration
    cards_txt.write_text("\n".join(lines) + "\n", encoding="utf-8")

    out_mp4 = out_dir / "video.mp4"
    font_path = str((ROOT / "assets" / "fonts" / "Inter.ttf").resolve())
    fontsdir = str((ROOT / "assets" / "fonts").resolve())
    captions_path = out_dir / "captions.ass"

    # ponytail: algunos builds de ffmpeg (p.ej. el bottle de Homebrew) no traen libass/libfreetype
    # -> sin filtros subtitles/drawtext. Si faltan, el video sale sin captions/overlay quemados en
    # vez de fallar entero; con un ffmpeg completo (CI con apt, que sí trae libass) corre el chain entero.
    avail = _available_filters()
    stages = ["scale=1080:1920:force_original_aspect_ratio=decrease", "pad=1080:1920:(ow-iw)/2:(oh-ih)/2",
              "fps=30", "format=yuv420p"]
    if "subtitles" in avail:
        stages.append(f"subtitles={_esc_path(str(captions_path.resolve()))}:fontsdir={_esc_path(fontsdir)}")
    else:
        print("video: filtro 'subtitles' no disponible en este ffmpeg (falta libass), sin captions quemados")
    if "drawtext" in avail:
        stages.append(
            f"drawtext=fontfile={_esc_path(font_path)}:text='{_esc_text(disclosure_overlay)}':"
            "fontsize=28:fontcolor=white@0.85:box=1:boxcolor=black@0.35:boxborderw=12:x=(w-text_w)/2:y=h-150"
        )
    else:
        print("video: filtro 'drawtext' no disponible en este ffmpeg (falta libfreetype), sin overlay de texto")
    filter_complex = "[0:v]" + ",".join(stages) + "[v]"

    cmd = ["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", str(cards_txt), "-i", str(voice_path)]
    maps = ["-map", "[v]", "-map", "1:a"]
    music = (cfg.get("formats", {}).get("video", {}) or {}).get("music")
    if music:
        vol = cfg["formats"]["video"].get("music_volume", 0.12)
        cmd += ["-stream_loop", "-1", "-i", str((ROOT / music).resolve())]
        filter_complex += (
            f";[1:a]volume=1.0[va];[2:a]volume={vol}[ma];"
            "[va][ma]amix=inputs=2:duration=first:dropout_transition=2[aout]"
        )
        maps = ["-map", "[v]", "-map", "[aout]"]

    cmd += [
        "-filter_complex", filter_complex, *maps,
        "-c:v", "libx264", "-preset", "medium", "-crf", "23", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "128k", "-movflags", "+faststart",
        "-metadata", "comment=AI-generated", "-t", "60", "-shortest", str(out_mp4),
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0 or not out_mp4.exists():
        print(f"video: ffmpeg falló (código {proc.returncode}):", db.redact(proc.stderr[-800:]))
        return None

    final_ms = tts.duration_ms(out_mp4)
    if final_ms > 60_000:
        print(f"video: atención, duración {final_ms}ms supera los 60s")
    return out_mp4


if __name__ == "__main__":  # python -m newsmachine.video --selftest
    import sys
    from .config import load_env

    load_env()
    cfg = {
        "brand": {
            "name": "Sintia",
            "colors": {"bg": "#0B0F19", "fg": "#F8FAFC", "accent": "#22D3EE", "muted": "#94A3B8"},
            "fonts": {"title": "assets/fonts/Inter.ttf", "body": "assets/fonts/Inter.ttf"},
            "disclosure": {
                "voice": {"es": "Este resumen fue generado con inteligencia artificial."},
                "overlay": {"es": "Generado con IA · fuentes en la descripción"},
            },
        },
        "formats": {"video": {"voice": {"es": "es-AR-TomasNeural"}, "music": None}},
    }
    out_dir = ROOT / "out" / "_selftest"
    illo = images.generate(cfg, "flat editorial illustration", (1080, 1920), out_dir / "illo_video.jpg", providers=[])
    video = {
        "hook": "Esto es una prueba de Sintia.",
        "segments": [
            {"text": "Primer segmento de prueba con un poco más de texto para que dure.",
             "card_title": "Segmento uno", "card_body": "Detalle del primer segmento."},
            {"text": "Segundo segmento de prueba para cerrar la nota de hoy.",
             "card_title": "Segmento dos", "card_body": "Detalle del segundo segmento."},
        ],
        "cta": "¿Vos qué opinás?",
    }
    mp4 = build(cfg, "es", video, illo, "example.com", out_dir)
    if mp4 is None:
        print("SKIP: tts o ffmpeg no disponible en este entorno")
        sys.exit(0)
    assert mp4.stat().st_size > 50_000, "video.mp4 demasiado chico"
    probe = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height",
         "-of", "csv=p=0", str(mp4)], capture_output=True, text=True, check=True,
    )
    w, h = probe.stdout.strip().split(",")
    assert (int(w), int(h)) == (1080, 1920), f"tamaño inesperado {w}x{h}"
    print("OK video.py:", mp4, tts.duration_ms(mp4), "ms")
