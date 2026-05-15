#!/bin/bash
[[ -f /opt/darkzsaid/lib/puertas_reales.sh ]] && source /opt/darkzsaid/lib/puertas_reales.sh

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
AZUL="\e[34m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

IP="216.238.113.15"

pausa() {
    echo ""
    read -p "Presiona ENTER para continuar..."
}

titulo() {
    clear
    echo -e "${ROJO}══════════════════════════ / / / ══════════════════════════${RESET}"
    echo -e "${BLANCO}${BOLD}          $1${RESET}"
    echo -e "${ROJO}══════════════════════════ / / / ══════════════════════════${RESET}"
    echo ""
}

estado_ws() {
    titulo "ESTADO SSH WEBSOCKET ESTABLISHED 200"

    echo -e "${AMARILLO}Servicio:${RESET}"
    systemctl is-active ssh-ws 2>/dev/null || echo "inactive"

    echo ""
    echo -e "${AMARILLO}Puerto 80:${RESET}"
    ss -tulnp | grep ':80' || echo "Puerto 80 no está escuchando"

    echo ""
    echo -e "${AMARILLO}Response configurado:${RESET}"
    grep 'BRAND =' /opt/darkzsaid/ssh-ws-direct.py 2>/dev/null || echo "No instalado"

    echo ""
    echo -e "${VERDE}Datos para HTTP Custom:${RESET}"
    echo "Host/IP: $IP"
    echo "Puerto: 80"
    echo "SSH Host: $IP"
    echo "SSH Puerto: 22"
    echo "Response: HTTP/1.1 200 Connection established"
    echo ""
    pausa
}

cambiar_marca() {
    titulo "CAMBIAR MARCA FINAL"

    if [[ ! -f /opt/darkzsaid/ssh-ws-direct.py ]]; then
        echo "SSH-WS Established no está instalado."
        pausa
        return
    fi

    echo "Marca actual:"
    grep 'BRAND =' /opt/darkzsaid/ssh-ws-direct.py

    echo ""
    read -p "Nueva marca [ADM SJCC]: " NUEVA_MARCA
    NUEVA_MARCA=${NUEVA_MARCA:-ADM SJCC}

    sed -i 's/^BRAND = .*/BRAND = "'"$NUEVA_MARCA"'"/' /opt/darkzsaid/ssh-ws-direct.py

    systemctl restart ssh-ws

    echo ""
    echo "Marca actualizada:"
    grep 'BRAND =' /opt/darkzsaid/ssh-ws-direct.py
    pausa
}

while true; do
    titulo "SSH WEBSOCKET ESTABLISHED 200"

    echo -e "${ROJO}[1]${RESET} ${AZUL}VER ESTADO${RESET}"
    echo -e "${ROJO}[2]${RESET} ${AZUL}VER LOGS${RESET}"
    echo -e "${ROJO}[3]${RESET} ${AZUL}CAMBIAR MARCA FINAL${RESET}"
    echo -e "${ROJO}[4]${RESET} ${AZUL}REINICIAR SERVICIO${RESET}"
    echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"
    echo ""
    read -p "Opción: " op

    case "$op" in
        1) estado_ws ;;
        2) journalctl -u ssh-ws -n 80 --no-pager -l; pausa ;;
        3) cambiar_marca ;;
        4) systemctl restart ssh-ws; pausa ;;
        0) exit 0 ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
