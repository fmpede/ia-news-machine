"""Config de vertical, prompts, entorno y argumentos comunes de CLI."""
import argparse, datetime as dt, getpass, json, os, string, subprocess, sys, zoneinfo
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parent.parent
REQUIRED = ["name", "mode", "timezone", "languages", "brand", "sources", "selection", "formats", "networks", "editorial"]
KEYCHAIN_SERVICE = "sintia"
SECRET_NAMES = [l.split("=", 1)[0].strip() for l in (ROOT / ".env.example").read_text().splitlines()
                if "=" in l and not l.startswith("#")] if (ROOT / ".env.example").exists() else []


def keychain_get(name):
    r = subprocess.run(["security", "find-generic-password", "-s", KEYCHAIN_SERVICE, "-a", name, "-w"], capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else None


def keychain_set(name, value):
    subprocess.run(["security", "add-generic-password", "-U", "-s", KEYCHAIN_SERVICE, "-a", name, "-w", value], check=True, capture_output=True)


_LOADED = False


def load_env():
    """Orden: variables ya seteadas (GitHub Actions las pasa explícitas) → .env local (gitignored) → Keychain de macOS.
    Nunca se leen secretos de archivos versionados."""
    global _LOADED
    if _LOADED:
        return
    _LOADED = True
    env = ROOT / ".env"
    if env.exists():
        for line in env.read_text().splitlines():
            if "=" in line and not line.lstrip().startswith("#"):
                k, v = line.split("=", 1)
                if v.strip():
                    os.environ.setdefault(k.strip(), v.strip())
    if sys.platform == "darwin" and os.environ.get("CI") != "true":
        for name in SECRET_NAMES:
            if not os.environ.get(name):
                v = keychain_get(name)
                if v:
                    os.environ[name] = v


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


def secrets_cli(args):
    """--set-secret NAME (pide el valor sin eco y lo guarda en el Keychain) · --list-secrets · --push-secrets (Keychain → GitHub Secrets)."""
    if args.set_secret:
        if args.set_secret not in SECRET_NAMES:
            raise SystemExit(f"{args.set_secret} no está en .env.example; agregalo ahí primero")
        keychain_set(args.set_secret, getpass.getpass(f"valor de {args.set_secret}: ").strip())
        print(f"guardado en Keychain (servicio '{KEYCHAIN_SERVICE}'): {args.set_secret}")
    if args.list_secrets:
        for n in SECRET_NAMES:
            print(("keychain " if keychain_get(n) else "         ") + ("env " if os.environ.get(n) else "    ") + n)
    if args.push_secrets:
        repo = subprocess.run(["gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"], capture_output=True, text=True).stdout.strip()
        for n in SECRET_NAMES:
            v = keychain_get(n)
            if v:
                subprocess.run(["gh", "secret", "set", n, "--repo", repo], input=v, text=True, check=True)
                print("GitHub Secret actualizado:", n)


if __name__ == "__main__":
    def _extra(ap):
        ap.add_argument("--check", action="store_true")
        ap.add_argument("--set-secret", metavar="NAME"); ap.add_argument("--list-secrets", action="store_true"); ap.add_argument("--push-secrets", action="store_true")
    cfg, args = parse(extra=_extra)
    if args.set_secret or args.list_secrets or args.push_secrets:
        secrets_cli(args); sys.exit(0)
    probs = check(cfg)
    print("\n".join(probs) if probs else f"OK vertical={cfg['name']} date={args.date} langs={cfg['languages']}")
    sys.exit(1 if probs else 0)
