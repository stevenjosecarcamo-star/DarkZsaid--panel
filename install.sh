#!/bin/bash

clear

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

APP_DIR="/opt/darkzsaid"

echo -e "${ROJO}════════════════════════════════════════════════════${RESET}"
echo -e "${BLANCO}${BOLD}        INSTALADOR DARKZSAID PANEL                 ${RESET}"
echo -e "${ROJO}════════════════════════════════════════════════════${RESET}"
echo ""

if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${ROJO}Debes ejecutar como root.${RESET}"
    exit 1
fi

echo -e "${CYAN}Instalando dependencias base...${RESET}"
apt update
apt install -y git curl wget nano ufw python3 python3-pip python3-venv openssl lsof net-tools unzip iptables-persistent netfilter-persistent sshpass rsync

echo ""
echo -e "${CYAN}Preparando instalación limpia...${RESET}"

mkdir -p "$APP_DIR"
mkdir -p "$APP_DIR/data"
mkdir -p "$APP_DIR/users"
mkdir -p "$APP_DIR/logs"
mkdir -p /etc/adm-lite/userDIR

# Limpiar usuarios/tokens viejos de la instalación nueva
rm -f "$APP_DIR/data/"*.db 2>/dev/null || true
rm -f "$APP_DIR/data/token.key" 2>/dev/null || true
rm -f "$APP_DIR/data/token_password.conf" 2>/dev/null || true
rm -f "$APP_DIR/users/"*.db 2>/dev/null || true
rm -f "$APP_DIR/users/token_password.conf" 2>/dev/null || true
rm -f /etc/adm-lite/userDIR/* 2>/dev/null || true

echo ""
echo -e "${CYAN}Configurando archivo config.env limpio...${RESET}"

IP_ACTUAL=$(curl -s ipv4.icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}')

cat > "$APP_DIR/config.env" <<EOC
APP_DOMAIN="$IP_ACTUAL"
APP_PORT="36712"
APP_OBFS="DarkZsaid"
APP_RANGE="10000:65000"
EOC

chmod 600 "$APP_DIR/config.env"

echo ""
echo -e "${CYAN}Aplicando permisos...${RESET}"

chmod +x "$APP_DIR/panel.sh" 2>/dev/null || true
chmod +x "$APP_DIR/install.sh" 2>/dev/null || true
chmod +x "$APP_DIR/install-public.sh" 2>/dev/null || true
chmod +x "$APP_DIR/darkzsaid-update.sh" 2>/dev/null || true
chmod -R +x "$APP_DIR/menus" 2>/dev/null || true
chmod +x "$APP_DIR"/*.sh 2>/dev/null || true
chmod +x "$APP_DIR"/*.py 2>/dev/null || true

ln -sf "$APP_DIR/panel.sh" /usr/local/bin/darkzsaid
ln -sf "$APP_DIR/panel.sh" /usr/local/bin/menu

chmod +x /usr/local/bin/darkzsaid
chmod +x /usr/local/bin/menu

echo ""
echo -e "${CYAN}Configurando firewall limpio...${RESET}"

# Dejar solo SSH 22 abierto por defecto.
ufw allow 22/tcp 2>/dev/null || true
ufw --force enable 2>/dev/null || true

echo ""
echo -e "${VERDE}${BOLD}Instalación limpia terminada correctamente.${RESET}"
echo ""
echo -e "${AMARILLO}Estado inicial:${RESET}"
echo "Solo SSH 22 queda abierto."
echo "No se crean usuarios."
echo "No se activan protocolos automáticamente."
echo ""
echo -e "${AMARILLO}Abre el panel con:${RESET}"
echo "menu"
echo ""
