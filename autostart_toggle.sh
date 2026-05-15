#!/bin/bash

APP_DIR="/opt/darkzsaid"
CONF="$APP_DIR/autostart.conf"

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
CYAN="\e[36m"
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

guardar_conf() {
cat > "$CONF" <<EOC
AUTOSTART="$AUTOSTART"
VERSION_PANEL="V1.0.0"
INSTALL_DATE="$INSTALL_DATE"
EOC
}

badge() {
    source "$CONF" 2>/dev/null
    if [[ "$AUTOSTART" == "on" ]]; then
        echo -e "${VERDE}[ON]${RESET}"
    else
        echo -e "${ROJO}[OFF]${RESET}"
    fi
}

toggle_once() {
    source "$CONF" 2>/dev/null

    clear
    echo -e "${ROJO}════════════════════════════════════════════${RESET}"
    echo -e "${BLANCO}${BOLD}        AUTOINICIAR SCRIPT DARKZSAID        ${RESET}"
    echo -e "${ROJO}════════════════════════════════════════════${RESET}"
    echo ""

    if [[ "$AUTOSTART" == "on" ]]; then
        AUTOSTART="off"
        guardar_conf
        echo -e "${AMARILLO}AUTOINICIAR SCRIPT:${RESET} ${ROJO}[OFF]${RESET}"
        echo ""
        echo -e "${CYAN}Ahora al entrar a la VPS saldrá la bienvenida.${RESET}"
        echo -e "${CYAN}Luego puedes escribir menu o darkzsaid.${RESET}"
    else
        AUTOSTART="on"
        guardar_conf
        echo -e "${AMARILLO}AUTOINICIAR SCRIPT:${RESET} ${VERDE}[ON]${RESET}"
        echo ""
        echo -e "${CYAN}Ahora al entrar a la VPS abrirá el menú automáticamente.${RESET}"
    fi

    echo ""
    read -p "Presiona ENTER para continuar..."
}

case "$1" in
    badge)
        badge
        ;;
    toggle_once)
        toggle_once
        ;;
    *)
        toggle_once
        ;;
esac
