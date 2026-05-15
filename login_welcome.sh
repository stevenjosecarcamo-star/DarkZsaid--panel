#!/bin/bash

APP_DIR="/opt/darkzsaid"
CONF="$APP_DIR/autostart.conf"

VERDE="\e[32m"
ROJO="\e[31m"
AMARILLO="\e[33m"
CYAN="\e[36m"
CELESTE="\e[96m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

mkdir -p "$APP_DIR"

if [[ ! -f "$CONF" ]]; then
cat > "$CONF" <<EOC
AUTOSTART="off"
VERSION_PANEL="V1.0.0"
INSTALL_DATE="$(date +%d-%m-%Y)"
EOC
fi

source "$CONF" 2>/dev/null
VERSION_PANEL="V1.0.0"

mostrar_bienvenida() {
    clear

    FECHA_ACTUAL=$(date +"%d-%m-%Y - %H:%M:%S")
    NOMBRE_SERVIDOR=$(hostname)
    UPTIME_SERVIDOR=$(uptime -p 2>/dev/null | sed 's/up //')
    RAM_LIBRE=$(free -h | awk '/Mem:/ {print $7}')
    USUARIO_CONECTADO=$(whoami)
    IP_ACTUAL=$(hostname -I | awk '{print $1}')

    echo -e "${CELESTE}${BOLD}"
    echo ' ____             _     _____          _     _ '
    echo '|  _ \  __ _ _ __| | __|__  /___  __ _(_) __| |'
    echo '| | | |/ _` | '"'"'__| |/ /  / // __|/ _` | |/ _` |'
    echo '| |_| | (_| | |  |   <  / /_\__ \ (_| | | (_| |'
    echo '|____/ \__,_|_|  |_|\_\/____|___/\__,_|_|\__,_|'
    echo -e "${RESET}"

    echo ""
    echo -e "${CELESTE}SERVIDOR INSTALADO EL     :${RESET} ${BLANCO}${INSTALL_DATE}${RESET}"
    echo -e "${CELESTE}FECHA/HORA ACTUAL         :${RESET} ${BLANCO}${FECHA_ACTUAL}${RESET}"
    echo -e "${CELESTE}NOMBRE DEL SERVIDOR       :${RESET} ${BLANCO}${NOMBRE_SERVIDOR}${RESET}"
    echo -e "${CELESTE}IP DEL SERVIDOR           :${RESET} ${BLANCO}${IP_ACTUAL}${RESET}"
    echo -e "${CELESTE}TIEMPO EN LÍNEA           :${RESET} ${BLANCO}${UPTIME_SERVIDOR}${RESET}"
    echo -e "${CELESTE}VERSIÓN ACTUAL INSTALADA  :${RESET} ${BLANCO}${VERSION_PANEL}${RESET}"
    echo -e "${CELESTE}MEMORIA RAM LIBRE         :${RESET} ${BLANCO}${RAM_LIBRE}${RESET}"
    echo ""
    echo -e "        ${CELESTE}RESELLER:${RESET} ${ROJO}${USUARIO_CONECTADO}${RESET}"
    echo ""
    echo -e "${VERDE}BIENVENIDO DE NUEVO!${RESET}"
    echo -e "${AMARILLO}Teclee ${BLANCO}menu${AMARILLO} o ${BLANCO}darkzsaid${AMARILLO} para ver el MENU.${RESET}"
    echo ""
}

case "$1" in
    login)
        source "$CONF" 2>/dev/null

        if [[ "$AUTOSTART" == "on" ]]; then
            if command -v menu >/dev/null 2>&1; then
                exec menu
            elif command -v darkzsaid >/dev/null 2>&1; then
                exec darkzsaid
            fi
        else
            mostrar_bienvenida
        fi
        ;;
    *)
        mostrar_bienvenida
        ;;
esac
