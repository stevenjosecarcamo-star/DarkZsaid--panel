#!/bin/bash

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

APP_DIR="/opt/darkzsaid"
BACKUP_DIR="/root/darkzsaid-backup-before-uninstall-$(date +%Y%m%d-%H%M%S)"

clear
echo -e "${ROJO}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${ROJO}║${RESET} ${BLANCO}${BOLD}        DESINSTALAR DARKZSAID PANEL        ${RESET}${ROJO}║${RESET}"
echo -e "${ROJO}╚════════════════════════════════════════════════════╝${RESET}"
echo
echo -e "${AMARILLO}Esta opción eliminará DarkZsaid de esta VPS.${RESET}"
echo
echo "Se eliminará:"
echo "- Panel /opt/darkzsaid"
echo "- Comandos menu y darkzsaid"
echo "- Servicios DarkZsaid"
echo "- Stunnel DarkZsaid"
echo "- UDPMod/Hysteria DarkZsaid"
echo "- Dropbear configurado por el panel"
echo "- Banner/Bienvenida SSH DarkZsaid"
echo "- Reglas NAT UDP usadas por DarkZsaid"
echo
echo -e "${ROJO}${BOLD}NO se eliminará el acceso SSH principal de la VPS.${RESET}"
echo -e "${ROJO}${BOLD}NO se borrará la VPS completa.${RESET}"
echo

read -r -p "Para confirmar escribe exactamente BORRAR-DARKZSAID: " CONFIRMAR

if [[ "$CONFIRMAR" != "BORRAR-DARKZSAID" ]]; then
    echo
    echo -e "${AMARILLO}Desinstalación cancelada.${RESET}"
    exit 0
fi

echo
echo -e "${CYAN}Creando backup antes de eliminar...${RESET}"

mkdir -p "$BACKUP_DIR"

cp -a "$APP_DIR" "$BACKUP_DIR/darkzsaid" 2>/dev/null || true
cp -a /etc/udpmod "$BACKUP_DIR/udpmod" 2>/dev/null || true
cp -a /etc/darkzsaid "$BACKUP_DIR/etc-darkzsaid" 2>/dev/null || true
cp -a /etc/adm-lite "$BACKUP_DIR/adm-lite" 2>/dev/null || true
cp -a /root/.darkzsaid_welcome.sh "$BACKUP_DIR/darkzsaid_welcome.sh" 2>/dev/null || true
cp -a /root/.bashrc "$BACKUP_DIR/bashrc" 2>/dev/null || true
cp -a /root/.profile "$BACKUP_DIR/profile" 2>/dev/null || true

echo -e "${VERDE}Backup creado en:${RESET} $BACKUP_DIR"

echo
echo -e "${CYAN}Deteniendo servicios DarkZsaid...${RESET}"

SERVICES=(
  darkzsaid-stunnel
  darkzsaid-ws80
  udpmod
  hysteria
  zivpn
  dropbear
  badvpn
  badvpn-udpgw
  socks-ws
  ws-stunnel
)

for s in "${SERVICES[@]}"; do
    systemctl stop "$s" 2>/dev/null || true
    systemctl disable "$s" 2>/dev/null || true
    systemctl reset-failed "$s" 2>/dev/null || true
done

pkill -f udpmod 2>/dev/null || true
pkill -f hysteria 2>/dev/null || true
pkill -f zivpn 2>/dev/null || true
pkill -f stunnel 2>/dev/null || true
pkill -f dropbear 2>/dev/null || true
pkill -f badvpn 2>/dev/null || true
pkill -f ssh-ws 2>/dev/null || true
pkill -f socks 2>/dev/null || true

echo
echo -e "${CYAN}Eliminando servicios systemd...${RESET}"

rm -f /etc/systemd/system/darkzsaid-stunnel.service
rm -f /etc/systemd/system/darkzsaid-ws80.service
rm -f /etc/systemd/system/udpmod.service
rm -f /etc/systemd/system/hysteria.service
rm -f /etc/systemd/system/zivpn.service
rm -f /etc/systemd/system/badvpn.service
rm -f /etc/systemd/system/badvpn-udpgw.service

systemctl daemon-reload

echo
echo -e "${CYAN}Eliminando reglas NAT UDP DarkZsaid...${RESET}"

iptables -t nat -D PREROUTING -p udp --dport 20000:39999 -j REDIRECT --to-ports 36712 2>/dev/null || true
iptables -t nat -D PREROUTING -p udp --dport 36700:36800 -j REDIRECT --to-ports 36712 2>/dev/null || true

netfilter-persistent save >/dev/null 2>&1 || true

echo
echo -e "${CYAN}Eliminando archivos DarkZsaid...${RESET}"

rm -rf /opt/darkzsaid
rm -rf /etc/udpmod
rm -rf /etc/darkzsaid
rm -rf /etc/adm-lite

rm -f /usr/local/bin/menu
rm -f /usr/local/bin/darkzsaid
rm -f /usr/local/bin/darkzsaid-update
rm -f /usr/local/bin/autoiniciador-on
rm -f /usr/local/bin/autoiniciador-off

rm -f /root/.darkzsaid_welcome.sh
rm -f /root/.darkzsaid_login.sh
rm -f /tmp/darkzsaid_login_debug.log

echo
echo -e "${CYAN}Limpiando bienvenida DarkZsaid de SSH...${RESET}"

cat > /root/.bashrc <<'EOF2'
# ~/.bashrc limpio para root

case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w# '
EOF2

cat > /root/.profile <<'EOF2'
# ~/.profile limpio para root

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOF2

echo
echo -e "${VERDE}${BOLD}DarkZsaid fue desinstalado correctamente.${RESET}"
echo
echo -e "${AMARILLO}Backup disponible en:${RESET}"
echo "$BACKUP_DIR"
echo
echo -e "${CYAN}Puedes reiniciar la VPS si quieres limpiar procesos restantes:${RESET}"
echo "reboot"
echo
