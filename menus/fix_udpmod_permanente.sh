#!/bin/bash

CONFIG="/etc/udpmod/config.json"
DATA_DIR="/opt/darkzsaid/data"
SSH_DB="$DATA_DIR/usuarios_ssh.db"
TOKEN_DB="$DATA_DIR/tokens_zivpn.db"
PORT="36712"
OBFS="DarkZsaid"

mkdir -p "$DATA_DIR" /etc/udpmod
touch "$SSH_DB" "$TOKEN_DB"

python3 <<'PY'
import json
from pathlib import Path

CONFIG = Path("/etc/udpmod/config.json")
SSH_DB = Path("/opt/darkzsaid/data/usuarios_ssh.db")
TOKEN_DB = Path("/opt/darkzsaid/data/tokens_zivpn.db")

PORT = "36712"
OBFS = "DarkZsaid"

def read_users(path):
    users = []
    if not path.exists():
        return users

    for raw in path.read_text(errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue

        parts = [p.strip() for p in line.split("|")]
        if len(parts) < 2:
            continue

        user = parts[0]
        password = parts[1]

        if not user or not password:
            continue
        if "/" in user or " " in user:
            continue

        pair = f"{user}:{password}"
        if pair not in users:
            users.append(pair)

    return users

auth_users = []
for item in read_users(SSH_DB) + read_users(TOKEN_DB):
    if item not in auth_users:
        auth_users.append(item)

if CONFIG.exists():
    try:
        cfg = json.loads(CONFIG.read_text(errors="ignore"))
    except Exception:
        cfg = {}
else:
    cfg = {}

cfg["listen"] = f":{PORT}"
cfg["obfs"] = OBFS
cfg["auth"] = {
    "mode": "passwords",
    "config": auth_users
}

# Mantener rutas de certificados si existen, si no poner las estándar
cfg.setdefault("cert", "/etc/udpmod/server.crt")
cfg.setdefault("key", "/etc/udpmod/server.key")
cfg.setdefault("alpn", "")
cfg.setdefault("up_mbps", 17)
cfg.setdefault("down_mbps", 15)
cfg.setdefault("disable_udp", False)

CONFIG.write_text(json.dumps(cfg, indent=2, ensure_ascii=False) + "\n")
print(f"UDPMOD corregido: obfs={OBFS}, usuarios={len(auth_users)}")
PY

ufw allow 36712/udp >/dev/null 2>&1 || true
ufw reload >/dev/null 2>&1 || true

systemctl daemon-reload >/dev/null 2>&1 || true
systemctl restart udpmod 2>/dev/null || true
