"""Config de vertical, prompts, entorno y argumentos comunes de CLI."""
import argparse, datetime as dt, json, os, string, sys, zoneinfo
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parent.parent
REQUIRED = ["name", "mode", "timezone", "languages", "brand", "sources", "selection", "formats", "networks", "editorial"]


def load_env():
    """SECRETS_JSON (GitHub Actions: toJSON(secrets)) y .env local → os.environ, sin pisar lo ya seteado."""
    for k, v in json.loads(os.environ.get("SECRETS_JSON") or "{}").items():
        os.environ.setdefault(k, v)
    env = ROOT / ".env"
    if env.exists():
        for line in env.read_text().splitlines():
            if "=" in line and not line.lstrip().startswith("#"):
                k, v = line.split("=", 1)
                if v.strip():
                    os.environ.setdefault(k.strip(), v.strip())


def load_vertical(name):
    cfg = yaml.safe_load((ROOT / "verticals" / f"{name}.yaml").read_text())
    missing = [k for k in REQUIRED if k not in cfg] if cfg["mode"] == "news" else [k for k in REQUIRED if k not in cfg and k != "sources"]
    if missing:
        raise SystemExit(f"verticals/{name}.yaml: faltan {missing}")
    if cfg["mode"] == "course":
        cfg["syllabus_data"] = yaml.safe_load((ROOT / cfg["syllabus"]).read_text())
    return cfg


def prompt_path(cfg, stage):
    p = ROOT / "prompts" / cfg["name"] / f"{stage}.md"
    return p if p.exists() else ROOT / "prompts" / f"{stage}.md"


def prompt(cfg, stage, **vars):
    tpl = string.Template(prompt_path(cfg, stage).read_text())
    missing = set(tpl.get_identifiers()) - set(vars)
    if missing:
        raise KeyError(f"prompt {stage}: faltan variables {sorted(missing)}")
    return tpl.safe_substitute(vars)


def now(cfg):
    return dt.datetime.now(zoneinfo.ZoneInfo(cfg["timezone"]))


def edition_date(cfg):
    return now(cfg).date().isoformat()


def out_dir(cfg, date):
    d = ROOT / "out" / cfg["name"] / date
    d.mkdir(parents=True, exist_ok=True)
    return d


def parse(argv=None, extra=None):
    """Argumentos comunes a todas las etapas. `extra(parser)` agrega los propios."""
    ap = argparse.ArgumentParser()
    ap.add_argument("--vertical", default="tech")
    ap.add_argument("--date", default=None)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--force", action="store_true")
    if extra:
        extra(ap)
    args = ap.parse_args(argv)
    load_env()
    cfg = load_vertical(args.vertical)
    args.date = args.date or edition_date(cfg)
    return cfg, args


def check(cfg):
    """--check: valida YAML y que cada prompt renderice con variables dummy."""
    problems = []
    for lang in cfg["languages"]:
        for key in ("audience", "tone"):
            if lang not in cfg[key]:
                problems.append(f"{key}.{lang} falta")
        for net, n in cfg["networks"].get(lang, {}).items():
            if n.get("enabled") and not (n.get("env") or n.get("chat_id")):
                problems.append(f"networks.{lang}.{net} habilitada sin env/chat_id")
    for f in ("title", "body"):
        if not (ROOT / cfg["brand"]["fonts"][f]).exists():
            problems.append(f"fuente {cfg['brand']['fonts'][f]} no existe")
    for p in sorted((ROOT / "prompts").glob("*.md")):
        tpl = string.Template(p.read_text())
        try:
            tpl.substitute({k: "x" for k in tpl.get_identifiers()})
        except (KeyError, ValueError) as e:
            problems.append(f"prompt {p.name}: {e}")
    return problems


if __name__ == "__main__":
    def _extra(ap): ap.add_argument("--check", action="store_true")
    cfg, args = parse(extra=_extra)
    probs = check(cfg)
    print("\n".join(probs) if probs else f"OK vertical={cfg['name']} date={args.date} langs={cfg['languages']}")
    sys.exit(1 if probs else 0)
