#!/bin/bash

clear

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

echo -e "${ROJO}════════════════════════════════════════════════════${RESET}"
echo -e "${BLANCO}${BOLD}        INSTALADOR DARKZSAID PANEL                 ${RESET}"
echo -e "${ROJO}════════════════════════════════════════════════════${RESET}"
echo ""

if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${ROJO}Debes ejecutar como root.${RESET}"
    exit 1
fi

APP_DIR="/opt/darkzsaid"

echo -e "${CYAN}Instalando dependencias base...${RESET}"
apt update
apt install -y git curl wget nano ufw python3 python3-pip python3-venv openssl lsof net-tools unzip iptables-persistent netfilter-persistent sshpass

echo ""
echo -e "${CYAN}Preparando carpetas...${RESET}"

mkdir -p "$APP_DIR"
mkdir -p "$APP_DIR/data"
mkdir -p "$APP_DIR/users"
mkdir -p "$APP_DIR/logs"
mkdir -p /etc/adm-lite/userDIR

echo ""
echo -e "${CYAN}Configurando archivo config.env...${RESET}"

IP_ACTUAL=$(curl -s ipv4.icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}')

if [[ ! -f "$APP_DIR/config.env" ]]; then
cat > "$APP_DIR/config.env" <<EOC
APP_DOMAIN="$IP_ACTUAL"
APP_PORT="36712"
APP_OBFS="DarkZsaid"
APP_RANGE="10000:65000"
EOC
fi

chmod 600 "$APP_DIR/config.env"

echo ""
echo -e "${CYAN}Aplicando permisos...${RESET}"

chmod +x "$APP_DIR/panel.sh" 2>/dev/null || true
chmod -R +x "$APP_DIR/menus" 2>/dev/null || true
chmod +x "$APP_DIR"/*.sh 2>/dev/null || true
chmod +x "$APP_DIR"/*.py 2>/dev/null || true

ln -sf "$APP_DIR/panel.sh" /usr/local/bin/darkzsaid
chmod +x /usr/local/bin/darkzsaid

echo ""
echo -e "${CYAN}Abriendo puertos recomendados...${RESET}"

ufw allow 22/tcp 2>/dev/null || true
ufw allow 80/tcp 2>/dev/null || true
ufw allow 443/tcp 2>/dev/null || true
ufw allow 442/tcp 2>/dev/null || true
ufw allow 7300/tcp 2>/dev/null || true
ufw allow 7300/udp 2>/dev/null || true
ufw allow 36712/udp 2>/dev/null || true
ufw allow 10000:65000/udp 2>/dev/null || true
ufw --force enable 2>/dev/null || true

echo ""
echo -e "${VERDE}${BOLD}Instalación terminada correctamente.${RESET}"
echo ""
echo -e "${AMARILLO}Abre el panel con:${RESET}"
echo "darkzsaid"
echo ""
