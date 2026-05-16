#!/bin/bash

DB="/opt/darkzsaid/data/usuarios_ssh.db"
CONFIG="/etc/udpmod/config.json"
OBFS_DEFAULT="DarkZsaid"

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

DB = Path("/opt/darkzsaid/data/usuarios_ssh.db")
CONFIG = Path("/etc/udpmod/config.json")
OBFS_DEFAULT = "DarkZsaid"

usuarios_auth = []

def run(cmd):
    return subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def linux_user_exists(user):
    return run(["id", user]).returncode == 0

def safe_user(user):
    if not user:
        return False
    if user.startswith("#"):
        return False
    if user.lower() in ["usuario", "user_test", "readme", "normal"]:
        return False
    if "/" in user or " " in user:
        return False
    return True

def parse_line(line):
    line = line.strip()
    if not line or line.startswith("#"):
        return None

    if "|" in line:
        p = [x.strip() for x in line.split("|")]
    elif ":" in line:
        p = [x.strip() for x in line.split(":")]
    else:
        p = [x.strip() for x in re.split(r"\s+", line)]

    if len(p) < 2:
        return None

    usuario = p[0]
    clave = p[1]

    # Formato común:
    # user|1111|NORMAL|1|10|2026-05-26
    fecha = ""
    if len(p) >= 6 and re.match(r"^\d{4}-\d{2}-\d{2}$", p[5]):
        fecha = p[5]
    elif len(p) >= 4 and re.match(r"^\d{4}-\d{2}-\d{2}$", p[3]):
        fecha = p[3]

    return usuario, clave, fecha

if DB.exists():
    for raw in DB.read_text(errors="ignore").splitlines():
        parsed = parse_line(raw)
        if not parsed:
            continue

        usuario, clave, fecha = parsed

        if not safe_user(usuario) or not clave:
            continue

        # Crear usuario Linux si no existe
        if not linux_user_exists(usuario):
            run(["useradd", "-M", "-s", "/bin/bash", usuario])

        # Asegurar contraseña Linux
        subprocess.run(
            ["bash", "-c", f"echo '{usuario}:{clave}' | chpasswd"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

        # Asegurar expiración si existe
        if fecha:
            run(["chage", "-E", fecha, usuario])

        # Solo agregar si ya existe en Linux
        if linux_user_exists(usuario):
            usuarios_auth.append(f"{usuario}:{clave}")

usuarios_auth = list(dict.fromkeys(usuarios_auth))

cfg = json.loads(CONFIG.read_text(errors="ignore"))

cfg["listen"] = cfg.get("listen", ":36712")
cfg["cert"] = cfg.get("cert", "/etc/udpmod/server.crt")
cfg["key"] = cfg.get("key", "/etc/udpmod/server.key")
cfg["obfs"] = OBFS_DEFAULT
cfg["auth"] = {
    "mode": "passwords",
    "config": usuarios_auth
}
cfg["alpn"] = cfg.get("alpn", "")
cfg["up_mbps"] = int(cfg.get("up_mbps", 17))
cfg["down_mbps"] = int(cfg.get("down_mbps", 15))
cfg["disable_udp"] = False

CONFIG.write_text(json.dumps(cfg, indent=2, ensure_ascii=False) + "\n")

print("Usuarios sincronizados con UDPMOD:")
for u in usuarios_auth:
    print(" -", u)
PY

mkdir -p /opt/UDPMOD
ln -sf /etc/udpmod/config.json /opt/UDPMOD/config.json 2>/dev/null || true
ln -sf /etc/udpmod/server.crt /opt/UDPMOD/udpmod.server.crt 2>/dev/null || true
ln -sf /etc/udpmod/server.key /opt/UDPMOD/udpmod.server.key 2>/dev/null || true

systemctl restart udpmod 2>/dev/null || true
