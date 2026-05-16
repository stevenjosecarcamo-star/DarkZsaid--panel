#!/bin/bash

APP_DIR="/opt/darkzsaid"

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

clear
echo -e "${ROJO}════════════════════════════════════════════${RESET}"
echo -e "${BLANCO}${BOLD}        ACTUALIZADOR DARKZSAID             ${RESET}"
echo -e "${ROJO}════════════════════════════════════════════${RESET}"
echo ""

cd "$APP_DIR" || exit 1

echo -e "${CYAN}Actualizando desde GitHub...${RESET}"
git pull

echo ""
echo -e "${CYAN}Aplicando permisos...${RESET}"
chmod -R +x "$APP_DIR"
chmod +x "$APP_DIR"/*.sh 2>/dev/null || true
chmod +x "$APP_DIR"/menus/*.sh 2>/dev/null || true

echo ""
echo -e "${CYAN}Reparando comandos principales...${RESET}"
ln -sf "$APP_DIR/panel.sh" /usr/local/bin/menu
ln -sf "$APP_DIR/panel.sh" /usr/local/bin/darkzsaid
ln -sf "$APP_DIR/darkzsaid-update.sh" /usr/local/bin/darkzsaid-update
chmod +x /usr/local/bin/menu /usr/local/bin/darkzsaid /usr/local/bin/darkzsaid-update 2>/dev/null || true

echo ""
echo -e "${CYAN}Limpiando servicios viejos del puerto 80...${RESET}"

# Servicios nuevos/viejos del WS puerto 80
for s in darkzsaid-ws80 ssh-ws socks-python-ws@80.service socks-ws socks-python socks-python-ws python-ws nginx; do
    systemctl stop "$s" 2>/dev/null || true
    systemctl disable "$s" 2>/dev/null || true
    systemctl reset-failed "$s" 2>/dev/null || true
done

# Procesos viejos/nuevos del puerto 80
pkill -9 -f "python2 /opt/darkzsaid/ssh-ws-direct.py" 2>/dev/null || true
pkill -9 -f "python3 /opt/darkzsaid/ssh-ws-direct.py" 2>/dev/null || true
pkill -9 -f "ssh-ws-direct.py" 2>/dev/null || true
pkill -9 -f "socks-python-ws.py --listen-port 80" 2>/dev/null || true
pkill -9 -f "/opt/darkzsaid/socks-python-ws.py" 2>/dev/null || true
pkill -9 -f "socks-python2-ws.py" 2>/dev/null || true
pkill -9 -f "socks-python" 2>/dev/null || true
pkill -9 -f "python.*80" 2>/dev/null || true

PIDS=$(ss -ltnp 2>/dev/null | awk '/:80 / {print $NF}' | grep -oP 'pid=\K[0-9]+' | sort -u)
if [[ -n "$PIDS" ]]; then
    kill -9 $PIDS 2>/dev/null || true
fi

echo ""
echo -e "${CYAN}Sincronizando UDP Hysteria...${RESET}"

if [[ -x "$APP_DIR/menus/sync_udpmod_users.sh" ]]; then
    bash "$APP_DIR/menus/sync_udpmod_users.sh" 2>/dev/null || true
fi

if [[ -f /etc/udpmod/config.json ]]; then
python3 <<'PY'
import json
from pathlib import Path

config = Path("/etc/udpmod/config.json")
cfg = json.loads(config.read_text(errors="ignore"))

cfg["obfs"] = "DarkZsaid"
cfg["listen"] = cfg.get("listen", ":36712")
cfg["cert"] = cfg.get("cert", "/etc/udpmod/server.crt")
cfg["key"] = cfg.get("key", "/etc/udpmod/server.key")
cfg["alpn"] = cfg.get("alpn", "")
cfg["up_mbps"] = int(cfg.get("up_mbps", 17))
cfg["down_mbps"] = int(cfg.get("down_mbps", 15))
cfg["disable_udp"] = False

config.write_text(json.dumps(cfg, indent=2, ensure_ascii=False) + "\n")
PY

    mkdir -p /opt/UDPMOD
    ln -sf /etc/udpmod/config.json /opt/UDPMOD/config.json 2>/dev/null || true
    ln -sf /etc/udpmod/server.crt /opt/UDPMOD/udpmod.server.crt 2>/dev/null || true
    ln -sf /etc/udpmod/server.key /opt/UDPMOD/udpmod.server.key 2>/dev/null || true

    systemctl restart udpmod 2>/dev/null || true
fi

echo ""
echo -e "${CYAN}Verificando estado final...${RESET}"

echo ""
echo -e "${AMARILLO}Puerto 80:${RESET}"
ss -tulnp | grep -E ':80 ' || echo -e "${VERDE}PUERTO 80 LIBRE${RESET}"

echo ""
echo -e "${AMARILLO}UDP Hysteria:${RESET}"
if [[ -f /etc/udpmod/config.json ]]; then
    grep '"obfs"' /etc/udpmod/config.json 2>/dev/null || true
    grep -A20 '"auth"' /etc/udpmod/config.json 2>/dev/null || true
    systemctl is-active udpmod 2>/dev/null || true
    ss -ulnp | grep 36712 || true
else
    echo "UDPMOD todavía no está instalado."
fi

echo ""
echo -e "${VERDE}${BOLD}Actualización terminada.${RESET}"
echo "Ejecuta: menu"
echo ""
