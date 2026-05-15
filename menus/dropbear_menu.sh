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
instalar(){ titulo "ACTIVAR DROPBEAR"; apt install -y dropbear; sed -i 's/^NO_START=.*/NO_START=0/' /etc/default/dropbear 2>/dev/null; grep -q "^DROPBEAR_PORT=" /etc/default/dropbear && sed -i 's/^DROPBEAR_PORT=.*/DROPBEAR_PORT=442/' /etc/default/dropbear || echo "DROPBEAR_PORT=442" >> /etc/default/dropbear; ufw allow 442/tcp 2>/dev/null || true; systemctl enable dropbear; systemctl restart dropbear; echo "Dropbear activado en puerto 442."; pausa; }
detener(){ titulo "DETENER DROPBEAR"; systemctl stop dropbear 2>/dev/null; echo "Dropbear detenido."; pausa; }
reiniciar(){ titulo "REINICIAR DROPBEAR"; systemctl restart dropbear 2>/dev/null; echo "Dropbear reiniciado."; pausa; }
remover(){ titulo "REMOVER DROPBEAR"; read -p "¿Seguro? [s/n]: " r; [[ "$r" != "s" && "$r" != "S" ]] && echo "Cancelado." && pausa && return; systemctl stop dropbear 2>/dev/null; systemctl disable dropbear 2>/dev/null; apt remove -y dropbear; echo "Dropbear removido."; pausa; }
estado(){ titulo "ESTADO DROPBEAR"; systemctl status dropbear --no-pager -l; echo ""; ss -tulnp | grep ':442' || echo "Puerto 442 no está escuchando."; pausa; }
while true; do titulo "DROPBEAR"; echo -e "${ROJO}[1]${RESET} ${AZUL}ACTIVAR / INSTALAR${RESET}"; echo -e "${ROJO}[2]${RESET} ${AZUL}DETENER${RESET}"; echo -e "${ROJO}[3]${RESET} ${AZUL}REINICIAR${RESET}"; echo -e "${ROJO}[4]${RESET} ${AZUL}REMOVER${RESET}"; echo -e "${ROJO}[5]${RESET} ${AZUL}VER ESTADO${RESET}"; echo -e "${ROJO}[6]${RESET} ${AZUL}VER LOGS${RESET}"; echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"; echo ""; read -p "⚡ Opción: " op; case "$op" in 1) instalar ;; 2) detener ;; 3) reiniciar ;; 4) remover ;; 5) estado ;; 6) journalctl -u dropbear -n 80 --no-pager -l; pausa ;; 0) exit 0 ;; *) echo "Opción inválida"; sleep 1 ;; esac; done
