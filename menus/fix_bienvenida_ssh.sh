#!/bin/bash

cat > /root/.darkzsaid_welcome.sh <<'EOF2'
#!/bin/bash

VERDE="\e[32m"
CYAN="\e[36m"
ROJO="\e[31m"
AMARILLO="\e[33m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

clear

IP_PUBLICA=$(curl -4 -s https://api.ipify.org 2>/dev/null)
IP_LOCAL=$(hostname -I 2>/dev/null | awk '{print $1}')
HOSTNAME_SERVER=$(hostname)
FECHA_ACTUAL=$(date '+%d-%m-%Y - %H:%M:%S')
UPTIME_TXT=$(uptime -p 2>/dev/null | sed 's/up //')
RAM_LIBRE=$(free -h | awk '/Mem:/ {print $7}')
DISCO_LIBRE=$(df -h / | awk 'NR==2 {print $4}')
VERSION_DARK="V1.0 ESTABLE"

if [[ -z "$IP_PUBLICA" ]]; then
    IP_PUBLICA="$IP_LOCAL"
fi

echo -e "${CYAN}"
echo "██████╗  █████╗ ██████╗ ██╗  ██╗███████╗███████╗ █████╗ ██╗██████╗ "
echo "██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝╚══███╔╝██╔════╝██╔══██╗██║██╔══██╗"
echo "██║  ██║███████║██████╔╝█████╔╝   ███╔╝ ███████╗███████║██║██║  ██║"
echo "██║  ██║██╔══██║██╔══██╗██╔═██╗  ███╔╝  ╚════██║██╔══██║██║██║  ██║"
echo "██████╔╝██║  ██║██║  ██║██║  ██╗███████╗███████║██║  ██║██║██████╔╝"
echo "╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝╚═════╝ "
echo -e "${RESET}"

echo -e "${VERDE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BLANCO}${BOLD}        DARKZSAID VPS MANAGER / PANEL SSH${RESET}"
echo -e "${VERDE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo
echo -e "${CYAN}SERVIDOR INSTALADO EL :${RESET} ${VERDE}$(date -r /opt/darkzsaid 2>/dev/null '+%d-%m-%Y' || echo 'No detectado')${RESET}"
echo -e "${CYAN}FECHA/HORA ACTUAL    :${RESET} ${VERDE}$FECHA_ACTUAL${RESET}"
echo -e "${CYAN}NOMBRE DEL SERVIDOR  :${RESET} ${VERDE}$HOSTNAME_SERVER${RESET}"
echo -e "${CYAN}IP PUBLICA           :${RESET} ${VERDE}$IP_PUBLICA${RESET}"
echo -e "${CYAN}TIEMPO EN LINEA      :${RESET} ${VERDE}$UPTIME_TXT${RESET}"
echo -e "${CYAN}VERSION INSTALADA    :${RESET} ${VERDE}$VERSION_DARK${RESET}"
echo -e "${CYAN}MEMORIA RAM LIBRE    :${RESET} ${VERDE}$RAM_LIBRE${RESET}"
echo -e "${CYAN}DISCO LIBRE          :${RESET} ${VERDE}$DISCO_LIBRE${RESET}"
echo
echo -e "${AMARILLO}      RESELLER:${RESET} ${ROJO}${BOLD}DarkZsaid${RESET}"
echo
echo -e "${VERDE}${BOLD}BIENVENIDO DE NUEVO!${RESET}"
echo -e "${AMARILLO}${BOLD}Teclee menu o darkzsaid para ver el MENU.${RESET}"
echo
EOF2

chmod +x /root/.darkzsaid_welcome.sh

chmod -x /etc/update-motd.d/* 2>/dev/null || true
rm -f /etc/motd 2>/dev/null || true
touch /etc/motd

grep -q ".darkzsaid_welcome.sh" /root/.bashrc || cat >> /root/.bashrc <<'EOF2'

# Bienvenida DarkZsaid al iniciar sesión SSH
if [[ -t 1 && -z "$DARKZSAID_WELCOME_SHOWN" ]]; then
    export DARKZSAID_WELCOME_SHOWN=1
    bash /root/.darkzsaid_welcome.sh
fi
EOF2

ln -sf /opt/darkzsaid/panel.sh /usr/local/bin/menu
ln -sf /opt/darkzsaid/panel.sh /usr/local/bin/darkzsaid
chmod +x /usr/local/bin/menu /usr/local/bin/darkzsaid 2>/dev/null || true
chmod +x /opt/darkzsaid/panel.sh 2>/dev/null || true

echo "Bienvenida SSH DarkZsaid instalada correctamente."
