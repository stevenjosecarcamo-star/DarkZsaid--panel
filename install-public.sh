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
echo -e "${CYAN}Preparando instalación...${RESET}"

if [[ -d "$APP_DIR" ]]; then
    FECHA=$(date +%Y%m%d-%H%M%S)
    echo -e "${AMARILLO}Ya existe $APP_DIR. Creando backup...${RESET}"
    tar -czf "/root/darkzsaid-before-install-$FECHA.tar.gz" "$APP_DIR" 2>/dev/null || true
    rm -rf "$APP_DIR"
fi

echo ""
echo -e "${CYAN}Descargando DarkZsaid Panel...${RESET}"

git clone "$REPO_URL" "$APP_DIR"

if [[ ! -d "$APP_DIR" ]]; then
    echo -e "${ROJO}Error: no se pudo clonar el repositorio.${RESET}"
    exit 1
fi

echo ""
echo -e "${CYAN}Ejecutando instalador principal...${RESET}"

cd "$APP_DIR" || exit 1
chmod +x install.sh
bash install.sh

echo ""
echo -e "${CYAN}Instalando comando de actualización...${RESET}"

if [[ -f "$APP_DIR/darkzsaid-update.sh" ]]; then
    chmod +x "$APP_DIR/darkzsaid-update.sh"
    ln -sf "$APP_DIR/darkzsaid-update.sh" /usr/local/bin/darkzsaid-update
fi

ln -sf "$APP_DIR/panel.sh" /usr/local/bin/darkzsaid
ln -sf "$APP_DIR/panel.sh" /usr/local/bin/menu

chmod +x /usr/local/bin/darkzsaid
chmod +x /usr/local/bin/menu

echo ""
echo -e "${VERDE}${BOLD}Instalación terminada correctamente.${RESET}"
echo ""
echo -e "${AMARILLO}Comandos disponibles:${RESET}"
echo "menu"
echo "darkzsaid"
echo "darkzsaid-update"
echo ""
echo -e "${CYAN}Abriendo panel...${RESET}"
sleep 2
menu
