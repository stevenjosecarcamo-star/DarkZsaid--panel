#!/bin/bash

VERDE="\e[32m"
ROJO="\e[31m"
AMARILLO="\e[33m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"

pausa() {
    echo ""
    read -p "Presiona ENTER para continuar..."
}

estado_udp_custom() {
    clear
    echo -e "${CYAN}===== UDP CUSTOM HTTP CUSTOM =====${RESET}"
    echo ""

    if systemctl is-active --quiet udp-custom; then
        echo -e "Servicio: ${VERDE}ACTIVO${RESET}"
    else
        echo -e "Servicio: ${ROJO}OFF${RESET}"
    fi

    if ss -ulnp | grep -q ":36712"; then
        echo -e "Puerto 36712: ${VERDE}ESCUCHANDO${RESET}"
    else
        echo -e "Puerto 36712: ${ROJO}NO ESCUCHA${RESET}"
    fi

    echo ""
    echo -e "${AMARILLO}Datos para HTTP Custom:${RESET}"
    echo "Servidor/IP: $(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')"
    echo "Puerto UDP: 36712"
    echo "Modo: UDP Custom"
    pausa
}

activar_udp_custom() {
    clear
    echo -e "${CYAN}===== ACTIVANDO UDP CUSTOM =====${RESET}"

    systemctl daemon-reload
    systemctl enable udp-custom >/dev/null 2>&1
    systemctl restart udp-custom

    ufw allow 36712/udp >/dev/null 2>&1 || true
    iptables -I INPUT -p udp --dport 36712 -j ACCEPT 2>/dev/null || true

    sleep 1

    if systemctl is-active --quiet udp-custom && ss -ulnp | grep -q ":36712"; then
        echo -e "${VERDE}✅ UDP Custom activo en puerto 36712${RESET}"
    else
        echo -e "${ROJO}❌ UDP Custom no levantó${RESET}"
        systemctl status udp-custom --no-pager
    fi

    pausa
}

detener_udp_custom() {
    clear
    echo -e "${AMARILLO}Deteniendo UDP Custom...${RESET}"
    systemctl stop udp-custom
    echo -e "${VERDE}Listo.${RESET}"
    pausa
}

while true; do
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLANCO}     UDP CUSTOM HTTP CUSTOM${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "[01] Activar / reiniciar UDP Custom"
    echo -e "[02] Ver estado y datos de conexión"
    echo -e "[03] Detener UDP Custom"
    echo ""
    echo -e "[00] Volver"
    echo ""
    read -p "Opción: " op

    case "$op" in
        1|01) activar_udp_custom ;;
        2|02) estado_udp_custom ;;
        3|03) detener_udp_custom ;;
        0|00) exit 0 ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
