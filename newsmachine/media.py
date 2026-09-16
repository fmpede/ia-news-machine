"""Etapa 6 (corre después de qa): ilustración, tarjeta, carrusel y video para outputs aprobados; URLs públicas vía GitHub Release."""
import json, os, shutil, subprocess
from urllib.parse import urlparse
from . import db, images, video
from .config import parse, out_dir, ROOT


def domain(url):
    return urlparse(url).netloc.replace("www.", "")


def release_upload(cfg, date, paths, dry_run):
    """Sube archivos a un GitHub Release (assets públicos, no pesan en el repo). Devuelve {path: url} o {}."""
    if dry_run or not paths or not shutil.which("gh"):
        return {}
    repo = os.getenv("GH_REPO") or subprocess.run(["gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"],
                                                  capture_output=True, text=True).stdout.strip()
    if not repo:
        return {}
    tag = f"media-{cfg['name']}-{date}"
    subprocess.run(["gh", "release", "create", tag, "--title", tag, "--notes", "media assets", "--repo", repo], capture_output=True)
    r = subprocess.run(["gh", "release", "upload", tag, *map(str, paths), "--clobber", "--repo", repo], capture_output=True, text=True)
    if r.returncode != 0:
        print("release upload falló:", r.stderr[:300]); return {}
    return {p: f"https://github.com/{repo}/releases/download/{tag}/{os.path.basename(p)}" for p in paths}


def main(argv=None):
    cfg, args = parse(argv)
    db.connect(cfg["name"])
    rows = db.CONN.execute("""SELECT o.*, s.url, s.source, s.title AS story_title FROM outputs o JOIN stories s ON s.id=o.story_id
        WHERE o.vertical=? AND o.date=? AND o.qa_status IN ('pass','fixed') AND o.format IN ('illustration','card','carousel','video')
        AND (o.file_path IS NULL OR ?) ORDER BY CASE o.format WHEN 'illustration' THEN 0 WHEN 'card' THEN 1 WHEN 'carousel' THEN 2 ELSE 3 END""",
                           (cfg["name"], args.date, args.force)).fetchall()
    base, sizes, made, uploads = out_dir(cfg, args.date), cfg["formats"]["image"]["sizes"], {}, []
    for r in rows:
        c, key = json.loads(r["content_json"]), (r["story_id"], r["lang"])
        d = base / f"{r['story_id']}_{r['lang']}"; d.mkdir(exist_ok=True)
        stem = f"{r['story_id']}_{r['lang']}_{r['format']}"
        illus = made.get((*key, "illustration")) or (d / "illustration.jpg" if (d / "illustration.jpg").exists() else None)
        try:
            if r["format"] == "illustration":
                path = images.generate(cfg, c["prompt"], tuple(sizes["square"]), d / f"{stem}.jpg")
            elif r["format"] == "card":
                path = images.render_card(cfg, r["lang"], c["title"], c["kicker"], domain(r["url"]), d / f"{stem}.jpg", tuple(sizes["square"]), backdrop=illus)
            elif r["format"] == "carousel":
                paths = images.render_carousel(cfg, r["lang"], c["slides"], domain(r["url"]), d / "carousel", tuple(sizes["portrait"]), backdrop=illus)
                path = d / f"{stem}.json"; path.write_text(json.dumps([str(p) for p in paths])); uploads += paths
            else:
                path = video.build(cfg, r["lang"], c, illus, domain(r["url"]), d)
                if path is None:
                    db.CONN.execute("UPDATE outputs SET qa_status='blocked', qa_json=? WHERE id=?", ('{"issues": [["video","no_tts","sin voz disponible hoy"]]}', r["id"]))
                    db.log_run(args.date, "media", "warn", f"video {stem}: sin TTS"); continue
                path = shutil.move(str(path), d / f"{stem}.mp4")
            made[(*key, r["format"])] = path
            if r["format"] != "carousel": uploads.append(path)
            db.CONN.execute("UPDATE outputs SET file_path=? WHERE id=?", (str(path), r["id"]))
        except Exception as e:
            db.log_run(args.date, "media", "failed", f"{stem}: {type(e).__name__}: {str(e)[:200]}")
    urls = release_upload(cfg, args.date, uploads, args.dry_run)
    for r in db.CONN.execute("SELECT id, format, file_path, content_json FROM outputs WHERE vertical=? AND date=? AND file_path IS NOT NULL", (cfg["name"], args.date)).fetchall():
        if r["format"] == "carousel":
            slides = [urls.get(p) for p in json.loads(open(r["file_path"]).read())]
            if all(slides):
                c = json.loads(r["content_json"]); c["public_urls"] = slides
                db.CONN.execute("UPDATE outputs SET public_url=?, content_json=? WHERE id=?", (slides[0], json.dumps(c, ensure_ascii=False), r["id"]))
        elif urls.get(r["file_path"]):
            db.CONN.execute("UPDATE outputs SET public_url=? WHERE id=?", (urls[r["file_path"]], r["id"]))
    db.log_run(args.date, "media", "ok", f"{len(made)} archivos, {len(urls)} URLs públicas")
    db.save()


if __name__ == "__main__":
    main()
