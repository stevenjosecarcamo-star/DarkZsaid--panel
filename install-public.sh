#!/bin/bash

clear

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

REPO_URL="https://github.com/stevenjosecarcamo-star/DarkZsaid--panel.git"
APP_DIR="/opt/darkzsaid"

echo -e "${ROJO}════════════════════════════════════════════════════${RESET}"
echo -e "${BLANCO}${BOLD}        DARKZSAID PANEL INSTALLER                  ${RESET}"
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

if [[ -d "$APP_DIR" ]]; then
    FECHA=$(date +%Y%m%d-%H%M%S)
    echo -e "${AMARILLO}Ya existe $APP_DIR. Creando backup...${RESET}"
    tar -czf "/root/darkzsaid-before-install-$FECHA.tar.gz" "$APP_DIR" 2>/dev/null || true
    rm -rf "$APP_DIR"
fi


echo ""
echo -e "${CYAN}Limpiando protocolos/puertos activos anteriores...${RESET}"

SERVICIOS_LIMPIAR=(
  nginx
  stunnel4
  stunnel
  dropbear
  badvpn
  badvpn-udpgw
  udp-custom
  udpmod
  hysteria-server
  hysteria
  zivpn
  sipvpn-activex
  socks
  socks-ws
  ws
  ws-stunnel
  python-ws
)

for s in "${SERVICIOS_LIMPIAR[@]}"; do
    systemctl stop "$s" 2>/dev/null || true
    systemctl disable "$s" 2>/dev/null || true
done

pkill -f "badvpn" 2>/dev/null || true
pkill -f "stunnel" 2>/dev/null || true
pkill -f "nginx" 2>/dev/null || true
pkill -f "socks-python" 2>/dev/null || true
pkill -f "ssh-ws" 2>/dev/null || true
pkill -f "udp-custom" 2>/dev/null || true
pkill -f "udpmod" 2>/dev/null || true
pkill -f "hysteria" 2>/dev/null || true
pkill -f "ZipVPN" 2>/dev/null || true

ufw --force reset 2>/dev/null || true
ufw allow 22/tcp 2>/dev/null || true
ufw --force enable 2>/dev/null || true

echo -e "${VERDE}Limpieza inicial aplicada. Solo SSH 22 queda permitido por defecto.${RESET}"


echo ""
echo -e "${CYAN}Descargando DarkZsaid Panel limpio...${RESET}"

git clone "$REPO_URL" "$APP_DIR"

if [[ ! -d "$APP_DIR" ]]; then
    echo -e "${ROJO}Error: no se pudo clonar el repositorio.${RESET}"
    exit 1
fi

echo ""
echo -e "${CYAN}Ejecutando instalador principal limpio...${RESET}"

cd "$APP_DIR" || exit 1

chmod +x install.sh 2>/dev/null || true
bash install.sh

echo ""
echo -e "${CYAN}Instalando comandos globales...${RESET}"

if [[ -f "$APP_DIR/darkzsaid-update.sh" ]]; then
    chmod +x "$APP_DIR/darkzsaid-update.sh"
    ln -sf "$APP_DIR/darkzsaid-update.sh" /usr/local/bin/darkzsaid-update
fi

ln -sf "$APP_DIR/panel.sh" /usr/local/bin/darkzsaid
ln -sf "$APP_DIR/panel.sh" /usr/local/bin/menu

chmod +x /usr/local/bin/darkzsaid
chmod +x /usr/local/bin/menu

echo ""

echo ""
echo -e "${CYAN}Configurando actualizador DarkZsaid...${RESET}"

if [[ -f "$APP_DIR/darkzsaid-update.sh" ]]; then
    chmod +x "$APP_DIR/darkzsaid-update.sh"
    ln -sf "$APP_DIR/darkzsaid-update.sh" /usr/local/bin/darkzsaid-update
    chmod +x /usr/local/bin/darkzsaid-update
fi


echo -e "${VERDE}${BOLD}Instalación limpia terminada correctamente.${RESET}"
echo ""
echo -e "${AMARILLO}Estado inicial:${RESET}"
echo "Solo SSH 22 queda abierto."
echo "Sin usuarios copiados."
echo "Sin tokens copiados."
echo "Sin protocolos activados automáticamente."
echo ""
echo -e "${AMARILLO}Comandos disponibles:${RESET}"
echo "menu"
echo "darkzsaid"
echo "darkzsaid-update"
echo ""
echo -e "${CYAN}Abriendo panel...${RESET}"
sleep 2
menu
