#!/bin/bash

DB="/opt/darkzsaid/data/usuarios_ssh.db"
CONFIG="/etc/udpmod/config.json"

mkdir -p /opt/darkzsaid/data
touch "$DB"

if [[ ! -f "$CONFIG" ]]; then
    exit 0
fi

python3 <<'PY'
import json
import re
import subprocess
from pathlib import Path

db_path = Path("/opt/darkzsaid/data/usuarios_ssh.db")
config_path = Path("/etc/udpmod/config.json")

usuarios = []

def linux_user_exists(user):
    try:
        subprocess.run(["id", user], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        return True
    except Exception:
        return False

if db_path.exists():
    for raw in db_path.read_text(errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue

        if "|" in line:
            p = line.split("|")
        elif ":" in line:
            p = line.split(":")
        else:
            p = re.split(r"\s+", line)

        p = [x.strip() for x in p if x.strip()]

        if len(p) >= 2:
            user = p[0]
            password = p[1]

            if not user or not password:
                continue

            if user.lower() in ["usuario", "user", "readme"]:
                continue

            # Solo sincroniza usuarios reales de Linux
            if linux_user_exists(user):
                usuarios.append(f"{user}:{password}")

usuarios = list(dict.fromkeys(usuarios))

cfg = json.loads(config_path.read_text(errors="ignore"))

cfg["listen"] = cfg.get("listen", ":36712")
cfg["cert"] = cfg.get("cert", "/etc/udpmod/server.crt")
cfg["key"] = cfg.get("key", "/etc/udpmod/server.key")
cfg["obfs"] = "DarkZsaid"
cfg["auth"] = {
    "mode": "passwords",
    "config": usuarios
}
cfg["alpn"] = cfg.get("alpn", "")
cfg["up_mbps"] = int(cfg.get("up_mbps", 17))
cfg["down_mbps"] = int(cfg.get("down_mbps", 15))
cfg["disable_udp"] = False

config_path.write_text(json.dumps(cfg, indent=2, ensure_ascii=False) + "\n")
PY

# Mantener compatibilidad con rutas viejas
mkdir -p /opt/UDPMOD
ln -sf /etc/udpmod/config.json /opt/UDPMOD/config.json 2>/dev/null || true
ln -sf /etc/udpmod/server.crt /opt/UDPMOD/udpmod.server.crt 2>/dev/null || true
ln -sf /etc/udpmod/server.key /opt/UDPMOD/udpmod.server.key 2>/dev/null || true

systemctl restart udpmod 2>/dev/null || true
