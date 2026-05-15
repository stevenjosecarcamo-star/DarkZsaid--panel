#!/bin/bash

APP_DIR="/opt/darkzsaid"
CONF="$APP_DIR/autostart.conf"

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
AZUL="\e[34m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

mkdir -p "$APP_DIR"

if [[ ! -f "$CONF" ]]; then
cat > "$CONF" <<EOC
AUTOSTART="off"
VERSION_PANEL="B1.1.1"
RESELLER_NAME="DarkZsaid"
INSTALL_DATE="$(date +%d-%m-%Y)"
EOC
fi

source "$CONF" 2>/dev/null

guardar_conf() {
cat > "$CONF" <<EOC
AUTOSTART="$AUTOSTART"
VERSION_PANEL="$VERSION_PANEL"
RESELLER_NAME="$RESELLER_NAME"
INSTALL_DATE="$INSTALL_DATE"
EOC
}

estado_plain() {
    [[ "$AUTOSTART" == "on" ]] && echo "ON" || echo "OFF"
}

status_badge() {
    if [[ "$AUTOSTART" == "on" ]]; then
        echo -e "${VERDE}[ON]${RESET}"
    else
        echo -e "${ROJO}[OFF]${RESET}"
    fi
}

mostrar_bienvenida() {
    clear

    HOSTNAME_ACTUAL=$(hostname)
    FECHA_ACTUAL=$(date +"%d-%m-%Y - %H:%M:%S")
    UPTIME_TXT=$(uptime -p 2>/dev/null | sed 's/up //')
    RAM_LIBRE=$(free -h | awk '/Mem:/ {print $7}')
    IP_ACTUAL=$(curl -s ipv4.icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}')

    echo -e "${VERDE}"
    echo "      ____             __      _____           _     __"
    echo "     / __ \____ ______/ /__   /__  /_____ ____(_)___/ /"
    echo "    / / / / __  / ___/ //_/     / // ___// __  / __  / "
    echo "   / /_/ / /_/ / /  / ,<       / /(__  )/ /_/ / /_/ /  "
    echo "  /_____/\__,_/_/  /_/|_|     /_//____/ \__,_/\__,_/   "
    echo -e "${RESET}"

    echo -e "${CYAN}SERVIDOR INSTALADO EL :${RESET} ${BLANCO}${INSTALL_DATE}${RESET}"
    echo -e "${CYAN}FECHA/HORA ACTUAL     :${RESET} ${BLANCO}${FECHA_ACTUAL}${RESET}"
    echo -e "${CYAN}NOMBRE DEL SERVIDOR   :${RESET} ${BLANCO}${HOSTNAME_ACTUAL}${RESET}"
    echo -e "${CYAN}IP DEL SERVIDOR       :${RESET} ${BLANCO}${IP_ACTUAL}${RESET}"
    echo -e "${CYAN}TIEMPO EN LINEA       :${RESET} ${BLANCO}${UPTIME_TXT}${RESET}"
    echo -e "${CYAN}VERSION INSTALADA     :${RESET} ${BLANCO}${VERSION_PANEL}${RESET}"
    echo -e "${CYAN}MEMORIA RAM LIBRE     :${RESET} ${BLANCO}${RAM_LIBRE}${RESET}"
    echo ""
    echo -e "${CYAN}RESELLER:${RESET} ${ROJO}${RESELLER_NAME}${RESET}"
    echo ""
    echo -e "${VERDE}BIENVENIDO DE NUEVO!${RESET}"
    echo -e "${AMARILLO}Teclee ${BLANCO}menu${AMARILLO} o ${BLANCO}darkzsaid${AMARILLO} para ver el MENU.${RESET}"
    echo ""
}

login_action() {
    # Solo para sesiones interactivas
    [[ $- != *i* ]] && return 0

    # Evitar bucles
    [[ "$DARKZSAID_LOGIN_SHOWN" == "1" ]] && return 0
    export DARKZSAID_LOGIN_SHOWN=1

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
}

menu_autostart() {
    while true; do
        clear
        source "$CONF" 2>/dev/null

        echo -e "${ROJO}════════════════════════════════════════════${RESET}"
        echo -e "${BLANCO}${BOLD}        AUTOINICIAR SCRIPT DARKZSAID        ${RESET}"
        echo -e "${ROJO}════════════════════════════════════════════${RESET}"
        echo ""
        echo -e "${AMARILLO}Estado actual:${RESET} $(status_badge)"
        echo -e "${AMARILLO}Versión panel:${RESET} ${VERSION_PANEL}"
        echo -e "${AMARILLO}Reseller:${RESET} ${RESELLER_NAME}"
        echo ""
        echo -e "${ROJO}[01]${RESET} ${CYAN}➜${RESET} ${BLANCO}ACTIVAR AUTOINICIO${RESET}"
        echo -e "${ROJO}[02]${RESET} ${CYAN}➜${RESET} ${BLANCO}DESACTIVAR AUTOINICIO${RESET}"
        echo -e "${ROJO}[03]${RESET} ${CYAN}➜${RESET} ${BLANCO}CAMBIAR NOMBRE RESELLER${RESET}"
        echo -e "${ROJO}[04]${RESET} ${CYAN}➜${RESET} ${BLANCO}CAMBIAR VERSION PANEL${RESET}"
        echo -e "${ROJO}[00]${RESET} ${CYAN}➜${RESET} ${BLANCO}VOLVER${RESET}"
        echo ""
        read -p "Seleccione una opción: " opc

        case "$opc" in
            1|01)
                AUTOSTART="on"
                guardar_conf
                echo ""
                echo -e "${VERDE}Autoinicio activado.${RESET}"
                sleep 1
                ;;
            2|02)
                AUTOSTART="off"
                guardar_conf
                echo ""
                echo -e "${AMARILLO}Autoinicio desactivado.${RESET}"
                sleep 1
                ;;
            3|03)
                echo ""
                read -p "Nuevo nombre reseller: " nuevo
                [[ -n "$nuevo" ]] && RESELLER_NAME="$nuevo"
                guardar_conf
                ;;
            4|04)
                echo ""
                read -p "Nueva versión del panel: " nueva
                [[ -n "$nueva" ]] && VERSION_PANEL="$nueva"
                guardar_conf
                ;;
            0|00)
                exit 0
                ;;
            *)
                echo -e "${ROJO}Opción inválida.${RESET}"
                sleep 1
                ;;
        esac
    done
}

case "$1" in
    login)
        login_action
        ;;
    toggle|menu)
        menu_autostart
        ;;
    status_plain)
        estado_plain
        ;;
    status_badge)
        status_badge
        ;;
    *)
        menu_autostart
        ;;
esac
