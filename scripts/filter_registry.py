"""Build mornye/registry.json: the official Mornye registry, filtered to the
IDs in mornye/allowlist.txt. Entries keep their official download_url and
sha256, so Mornye still verifies every file against the upstream hash."""
import json
import pathlib
import urllib.request

UPSTREAM = "https://raw.githubusercontent.com/mornyeapp/Mornye-Extension/main/registry.json"
ROOT = pathlib.Path(__file__).resolve().parent.parent
ALLOW = ROOT / "mornye" / "allowlist.txt"
OUT = ROOT / "mornye" / "registry.json"

allowed = [
    line.strip()
    for line in ALLOW.read_text(encoding="utf-8").splitlines()
    if line.strip() and not line.lstrip().startswith("#")
]
with urllib.request.urlopen(UPSTREAM, timeout=30) as r:
    upstream = json.load(r)

by_id = {e.get("id"): e for e in upstream.get("extensions", [])}
missing = [i for i in allowed if i not in by_id]
if missing:
    print(f"warning: not in upstream registry: {missing}")

registry = {
    "version": upstream.get("version", 1),
    "updated_at": upstream.get("updated_at"),
    "extensions": [by_id[i] for i in allowed if i in by_id],
}
new = json.dumps(registry, indent=2, ensure_ascii=False) + "\n"
old = OUT.read_text(encoding="utf-8") if OUT.exists() else ""
if new != old:
    OUT.write_text(new, encoding="utf-8")
    print("registry updated:", [(e["id"], e["version"]) for e in registry["extensions"]])
else:
    print("registry unchanged")
