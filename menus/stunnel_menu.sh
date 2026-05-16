#!/bin/bash

source /opt/darkzsaid/lib/install_clean.sh 2>/dev/null || true

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

pausa() {
    echo ""
    read -p "Presiona ENTER para continuar..."
}

titulo_stunnel() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET} ${BLANCO}${BOLD}        STUNNEL SSL${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

estado_stunnel() {
    if systemctl is-active --quiet darkzsaid-stunnel 2>/dev/null; then
        echo -e "${VERDE}[ON]${RESET}"
    else
        echo -e "${ROJO}[OFF]${RESET}"
    fi
}

instalar_stunnel_full() {
    source /opt/darkzsaid/lib/install_clean.sh 2>/dev/null || true

    clean_title "INSTALANDO STUNNEL SSL"

    clean_task "Instalando paquetes SSL" "apt-get update -y >/dev/null 2>&1 && apt-get install -y darkzsaid-stunnel openssl >/dev/null 2>&1"

    clean_task "Preparando certificados" "mkdir -p /etc/stunnel; openssl req -new -x509 -days 3650 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj '/C=US/ST=DarkZsaid/L=DarkZsaid/O=DarkZsaid/OU=DarkZsaid/CN=DarkZsaid' >/dev/null 2>&1; chmod 600 /etc/stunnel/stunnel.pem"

    clean_task "Creando configuración SSL" "cat > /etc/stunnel/stunnel.conf <<'EOC'
cert = /etc/stunnel/stunnel.pem
client = no
foreground = no
pid = /var/run/darkzsaid-stunnel.pid

[ssh-ssl]
accept = 443
connect = 127.0.0.1:22
EOC"

    clean_task "Habilitando Stunnel" "sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/darkzsaid-stunnel 2>/dev/null || echo 'ENABLED=1' > /etc/default/darkzsaid-stunnel"

    clean_task "Abriendo puerto 443" "ufw allow 443/tcp >/dev/null 2>&1 || true; ufw reload >/dev/null 2>&1 || true"

    clean_task "Iniciando servicio SSL" "systemctl enable darkzsaid-stunnel >/dev/null 2>&1; systemctl restart darkzsaid-stunnel"

    clean_task "Verificando Stunnel" "systemctl is-active --quiet darkzsaid-stunnel"

    clean_done
    pausa
}

detener_stunnel() {
    source /opt/darkzsaid/lib/install_clean.sh 2>/dev/null || true

    clean_title "DETENIENDO STUNNEL SSL"

    clean_task_soft "Deteniendo servicio SSL" "systemctl stop darkzsaid-stunnel 2>/dev/null || true"
    clean_task_soft "Verificando apagado" "! systemctl is-active --quiet darkzsaid-stunnel"

    clean_done
    pausa
}

reiniciar_stunnel() {
    source /opt/darkzsaid/lib/install_clean.sh 2>/dev/null || true

    clean_title "REINICIANDO STUNNEL SSL"

    clean_task "Reiniciando servicio SSL" "systemctl restart darkzsaid-stunnel"
    clean_task "Verificando Stunnel" "systemctl is-active --quiet darkzsaid-stunnel"

    clean_done
    pausa
}

estado_stunnel_full() {
    titulo_stunnel

    echo -e "${AMARILLO}Estado:${RESET} $(estado_stunnel)"
    echo ""
    echo -e "${AMARILLO}Puerto activo:${RESET}"
    ss -tulnp | grep -E ':443 ' || echo "No se detecta puerto SSL 443 activo."
    echo ""
    echo -e "${AMARILLO}Servicio:${RESET}"
    systemctl status darkzsaid-stunnel --no-pager -l 2>/dev/null | head -25 || echo "Stunnel no está instalado."

    pausa
}

remover_stunnel() {
    source /opt/darkzsaid/lib/install_clean.sh 2>/dev/null || true

    clean_title "REMOVIENDO STUNNEL SSL"

    clean_task_soft "Deteniendo servicio SSL" "systemctl stop darkzsaid-stunnel 2>/dev/null || true"
    clean_task_soft "Desactivando servicio SSL" "systemctl disable darkzsaid-stunnel 2>/dev/null || true"
    clean_task_soft "Cerrando puerto 443" "ufw delete allow 443/tcp >/dev/null 2>&1 || true; ufw reload >/dev/null 2>&1 || true"

    clean_done
    pausa
}

while true; do
    titulo_stunnel
    echo -e "${ROJO}[01]${RESET} ${CYAN}➜${RESET} ${BLANCO}ACTIVAR / INSTALAR STUNNEL SSL${RESET} $(estado_stunnel)"
    echo -e "${ROJO}[02]${RESET} ${CYAN}➜${RESET} ${BLANCO}DETENER STUNNEL SSL${RESET}"
    echo -e "${ROJO}[03]${RESET} ${CYAN}➜${RESET} ${BLANCO}REINICIAR STUNNEL SSL${RESET}"
    echo -e "${ROJO}[04]${RESET} ${CYAN}➜${RESET} ${BLANCO}VER ESTADO STUNNEL SSL${RESET}"
    echo -e "${ROJO}[05]${RESET} ${CYAN}➜${RESET} ${BLANCO}REMOVER STUNNEL SSL${RESET}"
    echo ""
    echo -e "${ROJO}[00]${RESET} ${CYAN}➜${RESET} ${BLANCO}VOLVER${RESET}"
    echo ""
    read -p "Seleccione una opción: " opc

    case "$opc" in
        1|01) instalar_stunnel_full ;;
        2|02) detener_stunnel ;;
        3|03) reiniciar_stunnel ;;
        4|04) estado_stunnel_full ;;
        5|05) remover_stunnel ;;
        0|00) exit 0 ;;
        *) echo -e "${ROJO}Opción inválida.${RESET}"; sleep 1 ;;
    esac
done


reparar_ssl_darkzsaid() {
    systemctl stop stunnel4 2>/dev/null || true
    systemctl disable stunnel4 2>/dev/null || true
    systemctl reset-failed stunnel4 2>/dev/null || true

    systemctl stop darkzsaid-stunnel 2>/dev/null || true
    pkill -9 -f "stunnel" 2>/dev/null || true

    PID443=$(ss -ltnp 2>/dev/null | awk '/:443 / {print $NF}' | grep -oP 'pid=\K[0-9]+' | sort -u)
    [[ -n "$PID443" ]] && kill -9 $PID443 2>/dev/null || true

    apt-get update -y >/dev/null 2>&1
    apt-get install -y stunnel4 openssl >/dev/null 2>&1

    mkdir -p /etc/stunnel

    openssl req -new -x509 -days 3650 -nodes \
        -out /etc/stunnel/stunnel.pem \
        -keyout /etc/stunnel/stunnel.pem \
        -subj "/C=US/ST=DarkZsaid/L=DarkZsaid/O=DarkZsaid/OU=DarkZsaid/CN=DarkZsaid" >/dev/null 2>&1

    chmod 600 /etc/stunnel/stunnel.pem

    cat > /etc/stunnel/darkzsaid.conf <<'EOFSSL'
cert = /etc/stunnel/stunnel.pem
client = no
foreground = yes
pid = /run/darkzsaid-stunnel.pid

[ssh-ssl]
accept = 0.0.0.0:443
connect = 127.0.0.1:22
EOFSSL

    cat > /etc/systemd/system/darkzsaid-stunnel.service <<'EOFSERVICE'
[Unit]
Description=DarkZsaid Stunnel SSL 443
After=network.target ssh.service

[Service]
Type=simple
ExecStart=/usr/bin/stunnel4 /etc/stunnel/darkzsaid.conf
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOFSERVICE

    ufw allow 443/tcp >/dev/null 2>&1 || true
    ufw reload >/dev/null 2>&1 || true

    systemctl daemon-reload
    systemctl enable darkzsaid-stunnel >/dev/null 2>&1
    systemctl restart darkzsaid-stunnel
}
