#!/bin/bash
[[ -f /opt/darkzsaid/lib/puertas_reales.sh ]] && source /opt/darkzsaid/lib/puertas_reales.sh
ROJO="\e[31m"; VERDE="\e[32m"; AMARILLO="\e[33m"; AZUL="\e[34m"
CYAN="\e[36m"; BLANCO="\e[97m"; RESET="\e[0m"; BOLD="\e[1m"
titulo() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}        ${BLANCO}${BOLD}⚡ DARKZSAID CONTROL ⚡${RESET}             ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${AMARILLO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${VERDE}        $1${RESET}"
    echo -e "${AMARILLO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}


pausa(){ echo ""; read -p "Presiona ENTER para continuar..."; }
titulo(){ clear; echo -e "${ROJO}══════════════════════════ / / / ══════════════════════════${RESET}"; echo -e "${BLANCO}${BOLD}          $1${RESET}"; echo -e "${ROJO}══════════════════════════ / / / ══════════════════════════${RESET}"; echo ""; }
instalar(){ titulo "ACTIVAR STUNNEL SSL"; apt install -y stunnel4 openssl; mkdir -p /etc/stunnel; openssl req -new -x509 -days 3650 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/C=NI/ST=DarkZsaid/L=VPS/O=DarkZsaid/OU=VPN/CN=localhost"; cat > /etc/stunnel/stunnel.conf <<EOC
cert = /etc/stunnel/stunnel.pem
client = no

[ssh-ssl]
accept = 443
connect = 127.0.0.1:22
EOC
sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4 2>/dev/null; ufw allow 443/tcp 2>/dev/null || true; systemctl enable stunnel4; systemctl restart stunnel4; echo "Stunnel activado en 443 hacia SSH 22."; pausa; }
detener(){ titulo "DETENER STUNNEL"; systemctl stop stunnel4 2>/dev/null; echo "Stunnel detenido."; pausa; }
reiniciar(){ titulo "REINICIAR STUNNEL"; systemctl restart stunnel4 2>/dev/null; echo "Stunnel reiniciado."; pausa; }
remover(){ titulo "REMOVER STUNNEL"; read -p "¿Seguro? [s/n]: " r; [[ "$r" != "s" && "$r" != "S" ]] && echo "Cancelado." && pausa && return; systemctl stop stunnel4 2>/dev/null; systemctl disable stunnel4 2>/dev/null; apt remove -y stunnel4; rm -rf /etc/stunnel; echo "Stunnel removido."; pausa; }
estado(){ titulo "ESTADO STUNNEL"; systemctl status stunnel4 --no-pager -l; echo ""; ss -tulnp | grep ':443' || echo "Puerto 443 no está escuchando."; pausa; }
while true; do titulo "STUNNEL SSL"; echo -e "${ROJO}[1]${RESET} ${AZUL}ACTIVAR / INSTALAR${RESET}"; echo -e "${ROJO}[2]${RESET} ${AZUL}DETENER${RESET}"; echo -e "${ROJO}[3]${RESET} ${AZUL}REINICIAR${RESET}"; echo -e "${ROJO}[4]${RESET} ${AZUL}REMOVER${RESET}"; echo -e "${ROJO}[5]${RESET} ${AZUL}VER ESTADO${RESET}"; echo -e "${ROJO}[6]${RESET} ${AZUL}VER LOGS${RESET}"; echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"; echo ""; read -p "⚡ Opción: " op; case "$op" in 1) instalar ;; 2) detener ;; 3) reiniciar ;; 4) remover ;; 5) estado ;; 6) journalctl -u stunnel4 -n 80 --no-pager -l; pausa ;; 0) exit 0 ;; *) echo "Opción inválida"; sleep 1 ;; esac; done
