#!/bin/bash

CYAN="\e[36m"
BLANCO="\e[97m"
VERDE="\e[32m"
AMARILLO="\e[33m"
ROJO="\e[31m"
RESET="\e[0m"

clear

RAYA="${CYAN}◆══════════════════════════════════════════════◆${RESET}"

echo -e "${CYAN}"
echo " ____             _    ______          _     _ "
echo "|  _ \  __ _ _ __| | _|__  / ___  ___(_) __| |"
echo "| | | |/ _\` | '__| |/ / / / / __|/ _ \ |/ _\` |"
echo "| |_| | (_| | |  |   < / /_ \__ \  __/ | (_| |"
echo "|____/ \__,_|_|  |_|\_/____|___/\___|_|\__,_|"
echo -e "${RESET}"

echo -e "$RAYA"
echo -e "${BLANCO} ⚡ Gestor VPN/SSH by ${CYAN}@DarkZsaid${RESET}  ${AMARILLO}◆ v1.0${RESET}"
echo -e "$RAYA"

echo -e "$RAYA"
echo -e "${CYAN} ◈${RESET} SO:    ${BLANCO}Ubuntu 20.04.6 LTS${RESET}     ${CYAN}◈${RESET} IP: ${BLANCO}TU-IP${RESET}"
echo -e "${CYAN} ◈${RESET} CPU:   ${BLANCO}1 cores${RESET}                 ${CYAN}◈${RESET} Fecha: ${BLANCO}$(date '+%d/%m/%Y-%H:%M')${RESET}"
echo -e "${CYAN} ◈${RESET} RAM:   ${BLANCO}293Mi${RESET}                   ${CYAN}◈${RESET} Uptime: ${BLANCO}activo${RESET}"
echo -e "$RAYA"

echo -e "${CYAN} ◈${RESET} SSH:22 ${CYAN}◆${RESET} ${VERDE}ON${RESET}        ${CYAN}◈${RESET} DNS:53 ${CYAN}◆${RESET} ${VERDE}ON${RESET}"
echo -e "${CYAN} ◈${RESET} SOCKS/PYTHON:80 ${CYAN}◆${RESET} ${VERDE}ON${RESET}"
echo -e "${CYAN} ◈${RESET} SSL:443 ${CYAN}◆${RESET} ${VERDE}ON${RESET}"
echo -e "${CYAN} ◈${RESET} UDP-CUSTOM:36712 ${CYAN}◆${RESET} ${VERDE}ON${RESET}"
echo -e "${CYAN} ◈${RESET} BadVPN:7300 ${CYAN}◆${RESET} ${VERDE}ON${RESET}"
echo -e "$RAYA"

echo -e "${BLANCO}<1>${RESET} ⚡ ${BLANCO}USUARIOS${RESET}              ${BLANCO}<2>${RESET} 📡 ${BLANCO}PROTOCOLOS${RESET}"
echo -e "${BLANCO}<3>${RESET} 🛠  ${BLANCO}HERRAMIENTAS${RESET}         ${BLANCO}<5>${RESET} ✚ ${BLANCO}PUERTOS${RESET}"
echo -e "${BLANCO}<6>${RESET} ◆  ${BLANCO}BOT TELEGRAM${RESET}         ${BLANCO}<7>${RESET} ⚙ ${BLANCO}NOMBRE PANEL${RESET}"
echo -e "${CYAN} ◈ Version: ${VERDE}v1.0${RESET} ${CYAN}◈${RESET}"
echo -e "$RAYA"

echo -e "${BLANCO}<08>${RESET} 💻 ${AMARILLO}ACTUALIZAR${RESET}           ${BLANCO}<9>${RESET} 🗑 ${ROJO}DESINSTALAR${RESET}"
echo -e "${BLANCO}<99>${RESET} 🔄 ${AMARILLO}REBOOT${RESET}"
echo -e "$RAYA"
echo -e "${BLANCO}<0>${RESET} ❌ ${ROJO}SALIR${RESET}"
echo -e "$RAYA"

echo ""
read -p "Opción: " op
