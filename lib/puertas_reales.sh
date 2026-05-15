#!/bin/bash

mostrar_puertas_reales() {
    echo -e "${AMARILLO}* Puertas Activas en su Servidor *${RESET}"
    echo -e "${VERDE}────────────────────────────────────────────${RESET}"

    local MOSTRO=0

    servicio_activo() {
        systemctl is-active --quiet "$1" 2>/dev/null
    }

    tcp_on() {
        ss -tlnp 2>/dev/null | grep -qE "(:$1[[:space:]]|:$1$)"
    }

    udp_on() {
        ss -ulnp 2>/dev/null | grep -qE "(:$1[[:space:]]|:$1[[:space:]])"
    }

    linea() {
        echo -e "$1"
        MOSTRO=1
    }

    if tcp_on 22; then
        linea "◦ SSH: ${VERDE}22${RESET}"
    fi

    if tcp_on 53 || udp_on 53; then
        linea "◦ System-DNS: ${VERDE}53${RESET}"
    fi

    if tcp_on 80; then
        linea "◦ SOCKS/PYTHON: ${VERDE}80${RESET}"
    fi

    if tcp_on 443; then
        linea "◦ SSL: ${VERDE}443${RESET}"
    fi

    if servicio_activo zivpn && udp_on 5667; then
        linea "◦ ZIVPN: ${VERDE}5667${RESET}"
    fi

    if servicio_activo udpmod && udp_on 36712; then
        linea "◦ UDP-HYSTERIA: ${VERDE}36712${RESET}"
    fi

    if servicio_activo udp-custom && udp_on 36712; then
        linea "◦ UDP-CUSTOM: ${VERDE}36712${RESET}"
    fi

    if servicio_activo badvpn-udpgw && { tcp_on 7300 || udp_on 7300; }; then
        linea "◦ BadVPN: ${VERDE}7300${RESET}"
    fi

    if servicio_activo nginx && tcp_on 81; then
        linea "◦ WEB-NGINX: ${VERDE}81${RESET}"
    fi

    if [[ "$MOSTRO" -eq 0 ]]; then
        echo -e "${ROJO}No hay puertas activas detectadas.${RESET}"
    fi

    echo -e "${VERDE}────────────────────────────────────────────${RESET}"
    echo ""
}
