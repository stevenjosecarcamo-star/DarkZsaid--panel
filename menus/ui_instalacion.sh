#!/bin/bash

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
AZUL="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"

clear
barra() {
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${RESET}"
}

barra_abajo() {
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${RESET}"
}

titulo_instalacion() {
    clear
    barra
    printf "${BLANCO}║        ⚡ %-31s ║${RESET}\n" "$1"
    barra_abajo
    echo ""
}

paso() {
    echo -e "${CYAN}➜${RESET} ${BLANCO}$1${RESET}"
    sleep 0.3
}

ok() {
    echo -e "${VERDE}✓${RESET} $1"
    sleep 0.3
}

warn() {
    echo -e "${AMARILLO}⚠${RESET} $1"
    sleep 0.3
}

fail() {
    echo -e "${ROJO}✘${RESET} $1"
    sleep 0.3
}

pausa_bonita() {
    echo ""
    read -p "Presiona ENTER para continuar..."
}
