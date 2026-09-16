"""Nada versionado puede contener credenciales, y los errores guardados se redactan."""
import os, re, subprocess
from newsmachine import config, db

PATTERNS = re.compile(r"sk-ant-[A-Za-z0-9_-]{10,}|AIza[0-9A-Za-z_-]{20,}|gsk_[0-9A-Za-z]{20,}|gh[pousr]_[0-9A-Za-z]{20,}|"
                      r"bot[0-9]{6,}:[A-Za-z0-9_-]{20,}|xox[bp]-[0-9A-Za-z-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----")


def tracked_files():
    out = subprocess.run(["git", "ls-files", "-z"], cwd=config.ROOT, capture_output=True, text=True).stdout
    return [f for f in out.split("\0") if f]


def test_tracked_files_have_no_secrets():
    hits = []
    for f in tracked_files():
        p = config.ROOT / f
        if p.suffix in (".ttf", ".png", ".jpg", ".mp3", ".mp4"):
            continue
        text = p.read_text(errors="ignore")
        if PATTERNS.search(text):
            hits.append(f)
    assert not hits, f"posibles secretos en: {hits}"


def test_env_is_ignored_and_example_is_blank():
    assert subprocess.run(["git", "check-ignore", "-q", ".env"], cwd=config.ROOT).returncode == 0
    for line in (config.ROOT / ".env.example").read_text().splitlines():
        if "=" in line and not line.startswith("#"):
            assert line.split("=", 1)[1].strip() == "", line


def test_redact(monkeypatch):
    tg = "123456789:" + "AAE" + "x" * 32          # armados en runtime para que ni el hook ni el escaneo los tomen por reales
    gk = "AIza" + "Sy" + "F" * 31
    monkeypatch.setenv("TELEGRAM_BOT_TOKEN", tg)
    monkeypatch.setenv("GEMINI_API_KEY", gk)
    msg = f"404 for url https://api.telegram.org/bot{tg}/sendMessage and https://x.test/v1?key={gk}&access_token=EAAB123456 Bearer abcdefghijklmnop"
    r = db.redact(msg)
    assert tg not in r and gk not in r and "EAAB123456" not in r and "abcdefghijklmnop" not in r
    assert "bot***" in r and "key=***" in r and "access_token=***" in r
