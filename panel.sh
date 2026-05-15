#!/bin/bash

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
AZUL="\e[34m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

APP_DIR="/opt/darkzsaid"
CONFIG_FILE="$APP_DIR/config.env"

source "$CONFIG_FILE"

LINEA="${ROJO}══════════════════════════ / / / ══════════════════════════${RESET}"

pausa() {
    echo ""
    read -p "Presiona ENTER para continuar..."
}

titulo() {
    clear
    echo -e "$LINEA"
    echo -e "${BLANCO}${BOLD}                 $1${RESET}"
    echo -e "$LINEA"
    echo ""
}

get_ip() {
    echo "$APP_DOMAIN"
}

estado_servicio() {
    systemctl is-active --quiet "$1" 2>/dev/null && echo -e "${VERDE}[ON]${RESET}" || echo -e "${ROJO}[OFF]${RESET}"
}

info_vps() {
    OS=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    IP=$(get_ip)
    RAM=$(free -m | awk '/Mem:/ {print $3 "/" $2 " MB"}')
    SWAP=$(free -m | awk '/Swap:/ {print $3 "/" $2 " MB"}')
    DISCO=$(df -h / | awk 'NR==2 {print $4 " libre"}')

    echo -e "${ROJO}»${RESET} OS: ${VERDE}$OS${RESET} | IP: ${AMARILLO}$IP${RESET}"
    echo -e "${ROJO}⇒${RESET} RAM: ${AMARILLO}$RAM${RESET} | Swap: ${AMARILLO}$SWAP${RESET} | Disco: ${AMARILLO}$DISCO${RESET}"
    echo ""
}


mostrar_puertas_activas_panel() {
    echo -e "${AMARILLO}* Puertas Activas en su Servidor *${RESET}"
    echo -e "${VERDE}────────────────────────────────────────────${RESET}"

    ACTIVOS=0

    LINEA1=""
    LINEA2=""
    LINEA3=""
    LINEA4=""
    LINEA5=""

    if ss -tulnp 2>/dev/null | grep -qE '(:22[[:space:]]|:22$)'; then
        LINEA1="${LINEA1}◦ SSH: ${VERDE}22${RESET}"
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:53[[:space:]]|:53$)'; then
        if [[ -n "$LINEA1" ]]; then
            LINEA1="${LINEA1}              ◦ System-DNS: ${VERDE}53${RESET}"
        else
            LINEA1="◦ System-DNS: ${VERDE}53${RESET}"
        fi
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:80[[:space:]]|:80$)'; then
        LINEA2="${LINEA2}◦ SOCKS/PYTHON: ${VERDE}80${RESET}"
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:81[[:space:]]|:81$)'; then
        if [[ -n "$LINEA2" ]]; then
            LINEA2="${LINEA2}          ◦ WEB-NGINX: ${VERDE}81${RESET}"
        else
            LINEA2="◦ WEB-NGINX: ${VERDE}81${RESET}"
        fi
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:443[[:space:]]|:443$)'; then
        LINEA3="${LINEA3}◦ SSL: ${VERDE}443${RESET}"
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:442[[:space:]]|:442$)'; then
        if [[ -n "$LINEA3" ]]; then
            LINEA3="${LINEA3}              ◦ DROPBEAR: ${VERDE}442${RESET}"
        else
            LINEA3="◦ DROPBEAR: ${VERDE}442${RESET}"
        fi
        ACTIVOS=1
    fi

    # ZIVPN_REAL_PORT_MARK
    if systemctl is-active --quiet zivpn 2>/dev/null && ss -ulnp 2>/dev/null | grep -qE '(:5667[[:space:]]|:5667$)'; then
        LINEA4="${LINEA4}◦ ZIVPN: ${VERDE}5667${RESET}"
    fi

    if systemctl is-active --quiet udpmod 2>/dev/null && ss -ulnp 2>/dev/null | grep -qE '(:36712[[:space:]]|:36712$)'; then
        LINEA4="${LINEA4}◦ UDP-HYSTERIA: ${VERDE}36712${RESET}"
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:7300[[:space:]]|:7300$)'; then
        if [[ -n "$LINEA4" ]]; then
            LINEA4="${LINEA4}     ◦ BadVPN: ${VERDE}7300${RESET}"
        else
            LINEA4="◦ BadVPN: ${VERDE}7300${RESET}"
        fi
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:7200[[:space:]]|:7200$)'; then
        LINEA5="◦ BadVPN: ${VERDE}7200${RESET}"
        ACTIVOS=1
    fi

    [[ -n "$LINEA1" ]] && echo -e "$LINEA1"
    [[ -n "$LINEA2" ]] && echo -e "$LINEA2"
    [[ -n "$LINEA3" ]] && echo -e "$LINEA3"
    [[ -n "$LINEA4" ]] && echo -e "$LINEA4"
    [[ -n "$LINEA5" ]] && echo -e "$LINEA5"

    if [[ "$ACTIVOS" -eq 0 ]]; then
        echo -e "${ROJO}No hay puertos activos detectados.${RESET}"
    fi

    echo -e "${VERDE}────────────────────────────────────────────${RESET}"
    echo ""
}



cyber_line() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

cyber_box_title() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}        ${BLANCO}${BOLD}⚡ DARKZSAID CONTROL PANEL ⚡${RESET}       ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

cyber_section() {
    echo -e "${AMARILLO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${VERDE}        $1${RESET}"
    echo -e "${AMARILLO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

mostrar_puertas_activas_panel() {
    echo -e "${AMARILLO}* Puertas Activas en su Servidor *${RESET}"
    echo -e "${VERDE}────────────────────────────────────────────${RESET}"

    ACTIVOS=0

    LINEA1=""
    LINEA2=""
    LINEA3=""
    LINEA4=""
    LINEA5=""

    if ss -tulnp 2>/dev/null | grep -qE '(:22[[:space:]]|:22$)'; then
        LINEA1="${LINEA1}◦ SSH: ${VERDE}22${RESET}"
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:53[[:space:]]|:53$)'; then
        if [[ -n "$LINEA1" ]]; then
            LINEA1="${LINEA1}              ◦ System-DNS: ${VERDE}53${RESET}"
        else
            LINEA1="◦ System-DNS: ${VERDE}53${RESET}"
        fi
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:80[[:space:]]|:80$)'; then
        LINEA2="${LINEA2}◦ SOCKS/PYTHON: ${VERDE}80${RESET}"
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:81[[:space:]]|:81$)'; then
        if [[ -n "$LINEA2" ]]; then
            LINEA2="${LINEA2}          ◦ WEB-NGINX: ${VERDE}81${RESET}"
        else
            LINEA2="◦ WEB-NGINX: ${VERDE}81${RESET}"
        fi
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:443[[:space:]]|:443$)'; then
        LINEA3="${LINEA3}◦ SSL: ${VERDE}443${RESET}"
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:442[[:space:]]|:442$)'; then
        if [[ -n "$LINEA3" ]]; then
            LINEA3="${LINEA3}              ◦ DROPBEAR: ${VERDE}442${RESET}"
        else
            LINEA3="◦ DROPBEAR: ${VERDE}442${RESET}"
        fi
        ACTIVOS=1
    fi

    # ZIVPN_REAL_PORT_MARK
    if systemctl is-active --quiet zivpn 2>/dev/null && ss -ulnp 2>/dev/null | grep -qE '(:5667[[:space:]]|:5667$)'; then
        LINEA4="${LINEA4}◦ ZIVPN: ${VERDE}5667${RESET}"
    fi

    if systemctl is-active --quiet udpmod 2>/dev/null && ss -ulnp 2>/dev/null | grep -qE '(:36712[[:space:]]|:36712$)'; then
        LINEA4="${LINEA4}◦ UDP-HYSTERIA: ${VERDE}36712${RESET}"
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:7300[[:space:]]|:7300$)'; then
        if [[ -n "$LINEA4" ]]; then
            LINEA4="${LINEA4}     ◦ BadVPN: ${VERDE}7300${RESET}"
        else
            LINEA4="◦ BadVPN: ${VERDE}7300${RESET}"
        fi
        ACTIVOS=1
    fi

    if ss -tulnp 2>/dev/null | grep -qE '(:7200[[:space:]]|:7200$)'; then
        LINEA5="◦ BadVPN: ${VERDE}7200${RESET}"
        ACTIVOS=1
    fi

    [[ -n "$LINEA1" ]] && echo -e "$LINEA1"
    [[ -n "$LINEA2" ]] && echo -e "$LINEA2"
    [[ -n "$LINEA3" ]] && echo -e "$LINEA3"
    [[ -n "$LINEA4" ]] && echo -e "$LINEA4"
    [[ -n "$LINEA5" ]] && echo -e "$LINEA5"

    if [[ "$ACTIVOS" -eq 0 ]]; then
        echo -e "${ROJO}No hay puertos activos detectados.${RESET}"
    fi

    echo -e "${VERDE}────────────────────────────────────────────${RESET}"
    echo ""
}

menu_principal() {
    while true; do
        cyber_box_title

        echo -e "${AMARILLO}» OS:${RESET} ${VERDE}$(lsb_release -ds 2>/dev/null || echo Ubuntu)${RESET} ${AMARILLO}| IP:${RESET} ${VERDE}$(get_ip)${RESET}"
        echo -e "${AMARILLO}» RAM:${RESET} ${VERDE}$(free -m | awk '/Mem:/ {print $3"/"$2" MB"}')${RESET} ${AMARILLO}| Swap:${RESET} ${VERDE}$(free -m | awk '/Swap:/ {print $3"/"$2" MB"}')${RESET} ${AMARILLO}| Disco:${RESET} ${VERDE}$(df -h / | awk 'NR==2 {print $4" libre"}')${RESET}"
        echo ""

        mostrar_puertas_activas_panel

        cyber_section "MENU PRINCIPAL"

        echo -e "${ROJO}[1]${RESET} ${CYAN}➜${RESET} ${BLANCO}CONTROL USUARIOS (SSH/SSL/UDP)${RESET}        ${VERDE}●${RESET}"
        echo -e "${ROJO}[2]${RESET} ${CYAN}➜${RESET} ${BLANCO}INSTALADORES & PROTOCOLOS${RESET}       ${CYAN}▣${RESET}"
        echo -e "${ROJO}[3]${RESET} ${CYAN}➜${RESET} ${BLANCO}HERRAMIENTAS${RESET}                    ${AMARILLO}◉${RESET}"
        echo -e "${ROJO}[4]${RESET} ${CYAN}➜${RESET} ${BLANCO}BANNER SSH${RESET}                     ${CYAN}▤${RESET}"
        echo -e "${ROJO}[5]${RESET} ${CYAN}➜${RESET} ${BLANCO}ADMINISTRAR PUERTOS${RESET}            ${VERDE}✚${RESET}"
        echo -e "${ROJO}[6]${RESET} ${CYAN}➜${RESET} ${BLANCO}BOT TELEGRAM OPCIONAL${RESET}          ${ROJO}◆${RESET}"
        echo ""
        echo -e "${ROJO}[99]${RESET} ${CYAN}➜${RESET} ${AMARILLO}REBOOT VPS${RESET}                  ${ROJO}⟳${RESET}"
        echo -e "${ROJO}[0]${RESET}  ${CYAN}➜${RESET} ${ROJO}SALIR${RESET}                       ${AMARILLO}↩${RESET}"
        echo ""
        echo -e "${CYAN}╭──────────────────────────────────────────────────╮${RESET}"
        echo -e "${CYAN}│${RESET} ${AMARILLO}DARKZSAID:${RESET} ${VERDE}READY${RESET}   ${AMARILLO}MODO:${RESET} ${CYAN}CYBER TECH${RESET}              ${CYAN}│${RESET}"
        echo -e "${CYAN}╰──────────────────────────────────────────────────╯${RESET}"
        echo ""

        read -p "⚡ Seleccione una opción: " op

        case "$op" in
            1) bash /opt/darkzsaid/menus/users_menu.sh ;;
            2) menu_instaladores ;;
            3) menu_herramientas ;;
            4) menu_banner ;;
            5) menu_puertos ;;
            6) menu_bot ;;
            99) reboot ;;
            0) clear; exit ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}



crear_usuario_ssh() {
    titulo "CREAR USUARIO SSH / UDP"

    read -p "Usuario: " user

    if [[ -z "$user" ]]; then
        echo "Usuario vacío."
        pausa
        return
    fi

    if id "$user" &>/dev/null; then
        echo "Ese usuario ya existe."
        pausa
        return
    fi

    read -p "Contraseña: " pass

    if [[ -z "$pass" ]]; then
        echo "Contraseña vacía."
        pausa
        return
    fi

    read -p "Días de duración: " dias

    if ! [[ "$dias" =~ ^[0-9]+$ ]]; then
        echo "Días inválidos."
        pausa
        return
    fi

    fecha=$(date -d "+$dias days" +%Y-%m-%d 2>/dev/null)

    useradd -M "$user" -s /bin/false -e "$fecha"
    echo "$user:$pass" | chpasswd

    echo ""
    echo -e "${VERDE}Usuario creado correctamente.${RESET}"
    echo ""
    echo "Usuario: $user"
    echo "Contraseña: $pass"
    echo "Expira: $fecha"
    echo "IP VPS: $(get_ip)"
    echo ""
    echo "Este usuario sirve para SSH, Dropbear, Stunnel, Socks Python WS y UDP-Hysteria APPmod's."
    pausa
}

menu_usuarios() {
    while true; do
        titulo "ADMINISTRACION DE USUARIOS"

        echo -e "${ROJO}[1]${RESET} ${AZUL}CREAR USUARIO${RESET}"
        echo -e "${ROJO}[8]${RESET} ${AZUL}CREADOR DE CUENTAS TIPO${RESET}"
        echo -e "${ROJO}[2]${RESET} ${AZUL}ELIMINAR USUARIO${RESET}"
        echo -e "${ROJO}[3]${RESET} ${AZUL}CAMBIAR PASSWORD${RESET}"
        echo -e "${ROJO}[4]${RESET} ${AZUL}BLOQUEAR USUARIO${RESET}"
        echo -e "${ROJO}[5]${RESET} ${AZUL}DESBLOQUEAR USUARIO${RESET}"
        echo -e "${ROJO}[6]${RESET} ${AZUL}LISTAR USUARIOS${RESET}"
        echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"
        echo ""
        read -p "Opción: " op

        case "$op" in
            1) crear_usuario_ssh ;;
            2)
                read -p "Usuario a eliminar: " user
                deluser --remove-home "$user" 2>/dev/null
                echo "Usuario eliminado si existía."
                pausa
                ;;
            3)
                read -p "Usuario: " user
                read -p "Nueva contraseña: " pass
                echo "$user:$pass" | chpasswd
                echo "Contraseña cambiada."
                pausa
                ;;
            4)
                read -p "Usuario a bloquear: " user
                usermod -L "$user"
                echo "Usuario bloqueado."
                pausa
                ;;
            5)
                read -p "Usuario a desbloquear: " user
                usermod -U "$user"
                echo "Usuario desbloqueado."
                pausa
                ;;
            6)
                awk -F: '$3 >= 1000 && $1 != "nobody" {print "Usuario:", $1, "| Expira:", $8}' /etc/passwd
                pausa
                ;;
            0) return ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

menu_instaladores() {
    while true; do
        titulo "INSTALADORES & PROTOCOLOS"

        echo -e "${ROJO}[01]${RESET} ${AZUL}ABRIR PUERTOS RECOMENDADOS${RESET}"
        echo -e "${ROJO}[02]${RESET} ${AZUL}UDP-HYSTERIA APPMOD'S / UDPMOD${RESET}   $(estado_servicio udpmod)"
        echo -e "${ROJO}[03]${RESET} ${AZUL}UDP-CUSTOM${RESET}                       $(estado_servicio udp-custom)"
        echo -e "${ROJO}[04]${RESET} ${AZUL}ZIVPN${RESET}                            $(estado_servicio zivpn)"
        echo -e "${ROJO}[05]${RESET} ${AZUL}SOCKS PYTHON DIRECTO WS${RESET}"
        echo -e "${ROJO}[06]${RESET} ${AZUL}DROPBEAR${RESET}                         $(estado_servicio dropbear)"
        echo -e "${ROJO}[07]${RESET} ${AZUL}STUNNEL SSL${RESET}                       $(estado_servicio stunnel4)"
        echo -e "${ROJO}[08]${RESET} ${AZUL}BADVPN UDPGW${RESET}                      $(estado_servicio badvpn-udpgw)"
        echo -e "${ROJO}[09]${RESET} ${AZUL}PANEL WEB 3X-UI${RESET}                   $(estado_servicio x-ui)"
        echo -e "${ROJO}[00]${RESET} ${BLANCO}VOLVER${RESET}"
        echo ""
        read -p "Opción: " op

        case "$op" in
            1|01) abrir_puertos_recomendados ;;
            2|02) menu_appmods ;;
            3|03) menu_udp_custom_seguro ;;
            4|04) menu_zivpn_seguro ;;
            5|05) menu_socks_python_ws ;;
            6|06) instalar_dropbear ;;
            7|07) instalar_stunnel ;;
            8|08) instalar_badvpn ;;
            9|09) instalar_3xui ;;
            0|00) return ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

abrir_puertos_recomendados() {
    titulo "ABRIR PUERTOS RECOMENDADOS"

    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 442/tcp
    ufw allow 7300/tcp
    ufw allow 7300/udp
    ufw allow 36712/udp
    ufw allow 5667/udp
    ufw allow 10000:65000/udp
    ufw --force enable

    echo "Puertos abiertos:"
    echo "22/tcp SSH"
    echo "80/tcp HTTP / WS"
    echo "443/tcp SSL"
    echo "442/tcp Dropbear"
    echo "7300/tcp BadVPN"
    echo "7300/udp BadVPN"
    echo "36712/udp UDP-Hysteria APPmod's"
    echo "5667/udp ZiVPN"
    echo "10000:65000/udp rango UDP"
    echo ""
    ufw status numbered
    pausa
}


estado_limpio_udpm() {
    titulo "DARKZSAID UDP HYSTERIA"

    IP=$(get_ip)
    CONFIG="/opt/UDPMOD/config.json"

    if [[ -f "$CONFIG" ]]; then
        OBFS_ACTUAL=$(grep '"obfs"' "$CONFIG" | head -1 | cut -d'"' -f4)
        ALPN_ACTUAL=$(grep '"alpn"' "$CONFIG" | head -1 | cut -d'"' -f4)
    else
        OBFS_ACTUAL="No instalado"
        ALPN_ACTUAL="h3"
    fi

    [[ -z "$ALPN_ACTUAL" ]] && ALPN_ACTUAL="h3"

    if systemctl is-active --quiet udpmod 2>/dev/null; then
        ESTADO="${VERDE}[ON]${RESET}"
    else
        ESTADO="${ROJO}[OFF]${RESET}"
    fi

    echo -e "${AMARILLO}        DATOS UDP-HYSTERIA${RESET}"
    echo -e "$LINEA"
    echo ""
    echo -e "${CYAN}Servicio:${RESET} Hysteria"
    echo -e "${CYAN}Estado:${RESET} $ESTADO"
    echo ""
    echo -e "${CYAN}Servidor UDP/IP:${RESET} $IP"
    echo -e "${CYAN}Puerto:${RESET} 36712 UDP"
    echo -e "${CYAN}UDP:${RESET} Original"
    echo -e "${CYAN}Hysteria Obfuscation:${RESET} $OBFS_ACTUAL"
    echo -e "${CYAN}Rango:${RESET} 10000-65000"
    echo -e "${CYAN}ALPN:${RESET} $ALPN_ACTUAL"
    echo ""
    echo -e "${AMARILLO}Datos para la app:${RESET}"
    echo "Servidor UDP/IP: $IP"
    echo "Puerto: 36712"
    echo "Hysteria Obfuscation: $OBFS_ACTUAL"
    echo "Rango: 10000-65000"
    echo ""
    pausa
}


menu_udp_custom_seguro() {
    titulo "UDP-CUSTOM"

    if [[ -f /opt/darkzsaid/menus/udp_custom_menu.sh ]]; then
        bash /opt/darkzsaid/menus/udp_custom_menu.sh
        return
    fi

    echo -e "${AMARILLO}UDP-CUSTOM no tiene menú nuevo conectado.${RESET}"
    echo "No se encontró: /opt/darkzsaid/menus/udp_custom_menu.sh"
    echo ""
    echo "Servicio: udp-custom"
    echo -n "Estado: "
    systemctl is-active udp-custom 2>/dev/null || echo "OFF"
    echo ""
    echo "Puerto UDP-CUSTOM:"
    ss -ulnp | grep -Ei 'udp-custom|36712|5667' || echo "No se detectó puerto UDP-CUSTOM."
    pausa
}


menu_zivpn_seguro() {
    titulo "ZIVPN"

    if [[ -f /opt/darkzsaid/menus/zivpn_menu.sh ]]; then
        bash /opt/darkzsaid/menus/zivpn_menu.sh
        return
    fi

    echo -e "${AMARILLO}ZIVPN ya queda como está configurado actualmente.${RESET}"
    echo "No se encontró menú externo: /opt/darkzsaid/menus/zivpn_menu.sh"
    echo ""
    echo "Servicio: zivpn"
    echo -n "Estado: "
    systemctl is-active zivpn 2>/dev/null || echo "OFF"
    echo ""
    echo "Puerto ZIVPN:"
    ss -ulnp | grep -Ei 'zivpn|ZipVPN|5667' || echo "5667 no está escuchando."
    echo ""
    echo "Config actual:"
    ls -lh /etc/zivpn/config.json /etc/zivpn/zivpn/config.json 2>/dev/null || true
    pausa
}

menu_appmods() {
    while true; do
        titulo "UDP-HYSTERIA APPMOD'S / UDPMOD"

        echo -e "${ROJO}[1]${RESET} ${AZUL}INSTALAR / REINSTALAR UDPMOD ORIGINAL${RESET}"
        echo -e "${ROJO}[2]${RESET} ${AZUL}VER DATOS DE CONEXION${RESET}"
        echo -e "${ROJO}[3]${RESET} ${AZUL}REINICIAR SERVICIO${RESET}"
        echo -e "${ROJO}[4]${RESET} ${AZUL}VER ESTADO LIMPIO${RESET}"
        echo -e "${ROJO}[5]${RESET} ${AZUL}VER CONFIG.JSON${RESET}"
        echo -e "${ROJO}[6]${RESET} ${AZUL}CAMBIAR OBFS${RESET}"
        echo -e "${ROJO}[7]${RESET} ${AZUL}VER LOGS UDPMOD${RESET}"
        echo -e "${ROJO}[8]${RESET} ${AZUL}VER REDIRECCION UDP${RESET}"
        echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"
        echo ""
        read -p "Opción: " op

        case "$op" in
            1) instalar_appmods ;;
            2) datos_appmods ;;
            3)
                systemctl restart udpmod
                echo "Servicio reiniciado."
                pausa
                ;;
            4) estado_limpio_udpm ;;
            5)
                cat /opt/UDPMOD/config.json 2>/dev/null || echo "No existe config."
                pausa
                ;;
            6) cambiar_obfs_appmods ;;
            7)
                journalctl -u udpmod -n 80 --no-pager -l
                pausa
                ;;
            8)
                iptables -t nat -S PREROUTING | grep 36712 || echo "No hay redirección."
                pausa
                ;;
            0) return ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

instalar_appmods() {
    titulo "INSTALAR PROTOCOLO UDP"

    source "$CONFIG_FILE"

    mkdir -p /etc/udpmod

    ARCH=$(uname -m)

    if [[ "$ARCH" == "x86_64" ]]; then
        BIN_URL="https://github.com/apernet/hysteria/releases/download/v1.3.5/hysteria-linux-amd64"
    elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        BIN_URL="https://github.com/apernet/hysteria/releases/download/v1.3.5/hysteria-linux-arm64"
    else
        echo "Arquitectura no soportada: $ARCH"
        pausa
        return
    fi

    wget -O /usr/local/bin/udpmod "$BIN_URL"
    chmod +x /usr/local/bin/udpmod

    openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout /etc/udpmod/server.key \
        -out /etc/udpmod/server.crt \
        -subj "/CN=$APP_DOMAIN" \
        -days 3650 >/dev/null 2>&1

    cat > /etc/udpmod/config.json << EOC
{
  "listen": ":$APP_PORT",
  "cert": "/etc/udpmod/server.crt",
  "key": "/etc/udpmod/server.key",
  "obfs": "APPModsPLUS",
  "auth": {
    "mode": "passwords",
    "config": ["USUARIO:CLAVE"]
  },
  "alpn": "$APP_ALPN",
  "up_mbps": 17,
  "down_mbps": 15,
  "disable_udp": false
}
EOC

    cat > /etc/systemd/system/udpmod.service << EOC
[Unit]
Description=UDP-Hysteria APPmod's
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/udpmod server -c /etc/udpmod/config.json
Restart=always
RestartSec=3
User=root
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOC

    ufw allow "$APP_PORT"/udp
    ufw allow "$APP_RANGE"/udp

    systemctl daemon-reload
    systemctl enable udpmod
    systemctl restart udpmod

    echo ""
    echo "UDP-Hysteria APPmod's instalado."
    datos_appmods
}

datos_appmods() {
    titulo "DATOS UDP-HYSTERIA APPMOD'S / UDPMOD"

    IP=$(get_ip)

    if [[ -f /opt/UDPMOD/config.json ]]; then
        OBFS_ACTUAL=$(grep '"obfs"' /opt/UDPMOD/config.json | head -1 | cut -d'"' -f4)
    else
        OBFS_ACTUAL="No instalado"
    fi

    echo -e "${VERDE}Servidor UDP/IP:${RESET} $IP"
    echo -e "${VERDE}Puerto:${RESET} 36712"
    echo -e "${VERDE}Hysteria Obfuscation:${RESET} $OBFS_ACTUAL"
    echo -e "${VERDE}Rango:${RESET} 10000-65000"
    echo ""
    echo -e "${AMARILLO}Autenticación:${RESET}"
    echo "Usa el usuario SSH creado en:"
    echo "[1] USUARIOS SSH / UDP-HYSTERIA"
    echo ""
    echo -e "${CYAN}Ejemplo:${RESET}"
    echo "Servidor UDP/IP: $IP"
    echo "Hysteria Autenticacion: usuario:contraseña"
    echo "Hysteria Obfuscation: $OBFS_ACTUAL"
    echo ""
    echo "Estado UDPMOD:"
    systemctl is-active udpmod 2>/dev/null || echo "no activo"
    echo ""
    echo "Puerto:"
    ss -ulnp | grep 36712 || echo "36712 no está escuchando"
    pausa
}

menu_socks_python_ws() {
    while true; do
        titulo "SOCKS PYTHON DIRECTO WS"

        echo -e "${ROJO}[1]${RESET} ${AZUL}INSTALAR BASE PYTHON WS${RESET}"
        echo -e "${ROJO}[2]${RESET} ${AZUL}AGREGAR PUERTO WS PERSONALIZADO${RESET}"
        echo -e "${ROJO}[3]${RESET} ${AZUL}DETENER PUERTO WS${RESET}"
        echo -e "${ROJO}[4]${RESET} ${AZUL}REINICIAR PUERTO WS${RESET}"
        echo -e "${ROJO}[5]${RESET} ${AZUL}VER ESTADO DE PUERTOS WS${RESET}"
        echo -e "${ROJO}[6]${RESET} ${AZUL}VER CONFIGURACIONES WS${RESET}"
        echo -e "${ROJO}[7]${RESET} ${AZUL}VER PUERTOS ACTIVOS${RESET}"
        echo -e "${ROJO}[8]${RESET} ${AZUL}DESINSTALAR SOCKS PYTHON WS${RESET}"
        echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"
        echo ""
        read -p "Seleccione una opción: " op

        case "$op" in
            1) instalar_base_socks_python_ws ;;
            2) agregar_puerto_ws ;;
            3) detener_puerto_ws ;;
            4) reiniciar_puerto_ws ;;
            5) estado_puertos_ws ;;
            6) ver_config_ws ;;
            7) ss -tulnp; pausa ;;
            8) desinstalar_socks_python_ws ;;
            0) return ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

instalar_base_socks_python_ws() {
    titulo "INSTALAR BASE SOCKS PYTHON WS"

    apt install -y python3 ufw lsof net-tools

    mkdir -p /opt/darkzsaid
    mkdir -p /etc/darkzsaid/ws

    crear_script_python_ws
    crear_servicio_template_ws

    systemctl daemon-reload

    echo -e "${VERDE}Base Python WS instalada correctamente.${RESET}"
    echo "Ahora puedes agregar puertos personalizados."
    pausa
}

crear_script_python_ws() {
    cat > /opt/darkzsaid/socks-python-ws.py <<'PYEOF'
#!/usr/bin/env python3

import argparse
import socket
import threading
import select

def build_response(code: str, header: str, banner: str) -> bytes:
    reasons = {
        "101": "Switching Protocols",
        "200": "Connection Established",
        "403": "Forbidden",
        "500": "Internal Server Error",
    }

    reason = reasons.get(code, "Connection Established")

    if header and header != "DEFAULT_HOST":
        return header.replace("\\r", "\r").replace("\\n", "\n").encode()

    if code == "101":
        return (
            "HTTP/1.1 101 Switching Protocols\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            f"Server: {banner}\r\n"
            "\r\n"
        ).encode()

    return (
        f"HTTP/1.1 {code} {reason}\r\n"
        f"Server: {banner}\r\n"
        "Connection: established\r\n"
        "Content-Length: 0\r\n"
        "\r\n"
    ).encode()

def pipe(client, remote):
    sockets = [client, remote]

    try:
        while True:
            readable, _, error = select.select(sockets, [], sockets, 90)

            if error:
                break

            if not readable:
                break

            for sock in readable:
                data = sock.recv(8192)

                if not data:
                    return

                if sock is client:
                    remote.sendall(data)
                else:
                    client.sendall(data)

    except Exception:
        pass

    finally:
        try:
            client.close()
        except Exception:
            pass

        try:
            remote.close()
        except Exception:
            pass

def handle_client(client, local_port, response_code, custom_header, banner):
    try:
        try:
            first = client.recv(8192)
        except Exception:
            first = b""

        client.sendall(build_response(response_code, custom_header, banner))

        remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        remote.connect(("127.0.0.1", local_port))

        if first:
            upper = first[:200].upper()

            if not (
                upper.startswith(b"GET ")
                or upper.startswith(b"POST ")
                or upper.startswith(b"CONNECT ")
                or upper.startswith(b"OPTIONS ")
                or b"HTTP/" in upper
            ):
                remote.sendall(first)

        pipe(client, remote)

    except Exception:
        try:
            client.close()
        except Exception:
            pass

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--listen-port", type=int, required=True)
    parser.add_argument("--local-port", type=int, required=True)
    parser.add_argument("--response", default="200")
    parser.add_argument("--header", default="DEFAULT_HOST")
    parser.add_argument("--banner", default="DarkZsaid WS")

    args = parser.parse_args()

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", args.listen_port))
    server.listen(300)

    print(f"[DarkZsaid WS] 0.0.0.0:{args.listen_port} -> 127.0.0.1:{args.local_port}")
    print(f"[DarkZsaid WS] RESPONSE={args.response} BANNER={args.banner}")

    while True:
        client, addr = server.accept()
        threading.Thread(
            target=handle_client,
            args=(client, args.local_port, args.response, args.header, args.banner),
            daemon=True
        ).start()

if __name__ == "__main__":
    main()
PYEOF

    chmod +x /opt/darkzsaid/socks-python-ws.py
}

crear_servicio_template_ws() {
    cat > /etc/systemd/system/socks-python-ws@.service <<'EOF'
[Unit]
Description=Socks Python Direct WS Port %i - DarkZsaid
After=network.target

[Service]
Type=simple
EnvironmentFile=/etc/darkzsaid/ws/%i.conf
ExecStart=/usr/bin/python3 /opt/darkzsaid/socks-python-ws.py --listen-port ${PY_PORT} --local-port ${LOCAL_PORT} --response ${RESPONSE_CODE} --header ${CUSTOM_HEADER} --banner ${MINI_BANNER}
Restart=always
RestartSec=3
User=root
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
}

validar_puerto_libre_ws() {
    local port="$1"

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${ROJO}Puerto inválido: $port${RESET}"
        return 1
    fi

    if ss -tulnp | grep -q ":$port "; then
        echo -e "${ROJO}Puerto $port ocupado.${RESET}"
        ss -tulnp | grep ":$port "
        return 1
    fi

    echo -e "${VERDE}Puerto python: $port VALIDO${RESET}"
    return 0
}

validar_puerto_local_ws() {
    local port="$1"

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${ROJO}Puerto local inválido.${RESET}"
        return 1
    fi

    if ss -tulnp | grep -q ":$port "; then
        echo -e "${VERDE}Puerto local: $port VALIDO${RESET}"
        return 0
    fi

    echo -e "${AMARILLO}No veo servicio activo en puerto local $port.${RESET}"
    echo "Puedes continuar si SSH/Dropbear/OpenVPN se activará después."
    read -p "¿Continuar? [s/n]: " r

    [[ "$r" == "s" || "$r" == "S" ]]
}

crear_config_puerto_ws() {
    local py_port="$1"
    local local_port="$2"
    local response="$3"
    local header="$4"
    local banner="$5"

    mkdir -p /etc/darkzsaid/ws

    cat > "/etc/darkzsaid/ws/${py_port}.conf" <<EOF
PY_PORT="$py_port"
LOCAL_PORT="$local_port"
RESPONSE_CODE="$response"
CUSTOM_HEADER="$header"
MINI_BANNER="$banner"
EOF
}

agregar_puerto_ws() {
    titulo "AGREGAR PUERTO WS"

    instalar_base_socks_python_ws_silencioso

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLANCO}Puerto python:${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Puerto python [80]: " PY_PORT
    PY_PORT=${PY_PORT:-80}

    validar_puerto_libre_ws "$PY_PORT" || {
        pausa
        return
    }

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLANCO}Puerto Local SSH/DROPBEAR/OPENVPN${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Puerto local [22]: " LOCAL_PORT
    LOCAL_PORT=${LOCAL_PORT:-22}

    validar_puerto_local_ws "$LOCAL_PORT" || {
        pausa
        return
    }

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLANCO}RESPONDE DE CABECERA 101, 200, 403, 500, etc.${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo "Response personalizado."
    echo "Enter por defecto: 200"
    echo "Para OVER WEBSOCKET escribe: 101"
    read -p "RESPONSE [200]: " RESPONSE_CODE
    RESPONSE_CODE=${RESPONSE_CODE:-200}

    if ! [[ "$RESPONSE_CODE" =~ ^[0-9]{3}$ ]]; then
        echo -e "${ROJO}Response inválida.${RESET}"
        pausa
        return
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLANCO}ENCABEZADO PERSONALIZADO${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo "Ejemplo:"
    echo '\r\nContent-length: 0\r\n\r\nHTTP/1.1 200 Connection Established\r\n\r\n'
    echo ""
    echo "Si desconoces esta opción, solo presiona ENTER."
    read -p "CABECERA [DEFAULT_HOST]: " CUSTOM_HEADER
    CUSTOM_HEADER=${CUSTOM_HEADER:-DEFAULT_HOST}

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLANCO}Introduzca su Mini-Banner${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Mini-Banner [DarkZsaid WS]: " MINI_BANNER
    MINI_BANNER=${MINI_BANNER:-DarkZsaid WS}

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLANCO}TIPO DE PROXY WEBSOCKET${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${ROJO}[1]${RESET} > Proxy (WS/Direct) (SYSTEMD)"
    echo -e "${ROJO}[2]${RESET} > Proxy (WS/Direct) RESPONSE 101"
    echo -e "${ROJO}[3]${RESET} > Proxy (WS/Direct) RESPONSE 200"
    echo ""
    read -p "Seleccione tipo [1]: " TIPO
    TIPO=${TIPO:-1}

    case "$TIPO" in
        2) RESPONSE_CODE="101" ;;
        3) RESPONSE_CODE="200" ;;
    esac

    crear_config_puerto_ws "$PY_PORT" "$LOCAL_PORT" "$RESPONSE_CODE" "$CUSTOM_HEADER" "$MINI_BANNER"

    ufw allow "$PY_PORT"/tcp 2>/dev/null

    systemctl daemon-reload
    systemctl enable "socks-python-ws@$PY_PORT"
    systemctl restart "socks-python-ws@$PY_PORT"

    echo ""
    echo -e "${VERDE}SOCKS Python WS activado correctamente.${RESET}"
    echo ""
    echo "Puerto Python WS: $PY_PORT"
    echo "Puerto local destino: $LOCAL_PORT"
    echo "Response: $RESPONSE_CODE"
    echo "Cabecera: $CUSTOM_HEADER"
    echo "Mini-Banner: $MINI_BANNER"
    echo ""
    pausa
}

detener_puerto_ws() {
    titulo "DETENER PUERTO WS"

    read -p "Puerto WS a detener: " PORT

    systemctl stop "socks-python-ws@$PORT" 2>/dev/null
    systemctl disable "socks-python-ws@$PORT" 2>/dev/null

    echo "Puerto $PORT detenido."
    pausa
}

reiniciar_puerto_ws() {
    titulo "REINICIAR PUERTO WS"

    read -p "Puerto WS a reiniciar: " PORT

    systemctl restart "socks-python-ws@$PORT" 2>/dev/null

    echo "Puerto $PORT reiniciado."
    pausa
}

estado_puertos_ws() {
    titulo "ESTADO PUERTOS WS"

    echo "Servicios WS:"
    echo ""

    systemctl list-units --type=service --all | grep "socks-python-ws@" || echo "No hay servicios WS creados."

    echo ""
    echo "Puertos escuchando:"
    echo ""

    ss -tulnp | grep "python3" || echo "No hay puertos Python WS activos."

    pausa
}

ver_config_ws() {
    titulo "CONFIGURACIONES WS"

    ls -lh /etc/darkzsaid/ws 2>/dev/null || {
        echo "No hay configuraciones."
        pausa
        return
    }

    echo ""
    read -p "Ver configuración de qué puerto, ejemplo 80, o ENTER para volver: " PORT

    if [[ -n "$PORT" ]]; then
        cat "/etc/darkzsaid/ws/${PORT}.conf" 2>/dev/null || echo "No existe config para ese puerto."
    fi

    pausa
}

desinstalar_socks_python_ws() {
    titulo "DESINSTALAR SOCKS PYTHON WS"

    for conf in /etc/darkzsaid/ws/*.conf; do
        [[ -f "$conf" ]] || continue

        port=$(basename "$conf" .conf)

        systemctl stop "socks-python-ws@$port" 2>/dev/null
        systemctl disable "socks-python-ws@$port" 2>/dev/null
    done

    rm -f /etc/systemd/system/socks-python-ws@.service
    rm -f /opt/darkzsaid/socks-python-ws.py
    rm -rf /etc/darkzsaid/ws

    systemctl daemon-reload

    echo "SOCKS Python WS desinstalado."
    pausa
}

instalar_base_socks_python_ws_silencioso() {
    apt install -y python3 ufw lsof net-tools >/dev/null 2>&1
    mkdir -p /opt/darkzsaid
    mkdir -p /etc/darkzsaid/ws
    crear_script_python_ws
    crear_servicio_template_ws
    systemctl daemon-reload
}

instalar_dropbear() {
    titulo "INSTALAR DROPBEAR"

    apt install -y dropbear

    sed -i 's/^NO_START=.*/NO_START=0/' /etc/default/dropbear 2>/dev/null
    sed -i 's/^DROPBEAR_PORT=.*/DROPBEAR_PORT=442/' /etc/default/dropbear 2>/dev/null

    if ! grep -q "^DROPBEAR_PORT=" /etc/default/dropbear; then
        echo "DROPBEAR_PORT=442" >> /etc/default/dropbear
    fi

    ufw allow 442/tcp
    systemctl enable dropbear
    systemctl restart dropbear

    echo "Dropbear instalado en puerto 442."
    pausa
}

instalar_stunnel() {
    titulo "INSTALAR STUNNEL SSL"

    apt install -y stunnel4 openssl
    mkdir -p /etc/stunnel

    openssl req -new -x509 -days 3650 -nodes \
        -out /etc/stunnel/stunnel.pem \
        -keyout /etc/stunnel/stunnel.pem \
        -subj "/C=NI/ST=DarkZsaid/L=VPS/O=DarkZsaid/OU=VPN/CN=localhost"

    cat > /etc/stunnel/stunnel.conf <<EOC
cert = /etc/stunnel/stunnel.pem
client = no

[ssh-ssl]
accept = 443
connect = 127.0.0.1:22
EOC

    sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4 2>/dev/null

    ufw allow 443/tcp
    systemctl enable stunnel4
    systemctl restart stunnel4

    echo "Stunnel instalado en puerto 443 hacia SSH 22."
    pausa
}

instalar_badvpn() {
    titulo "INSTALAR BADVPN UDPGW"

    apt install -y cmake gcc make git

    cd /opt || return
    rm -rf badvpn
    git clone https://github.com/ambrop72/badvpn.git

    cd /opt/badvpn || return
    mkdir -p build
    cd build || return

    cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
    make install

    cat > /etc/systemd/system/badvpn-udpgw.service <<EOC
[Unit]
Description=BadVPN UDPGW
After=network.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOC

    systemctl daemon-reload
    systemctl enable badvpn-udpgw
    systemctl restart badvpn-udpgw

    ufw allow 7300/tcp
    ufw allow 7300/udp

    echo "BADVPN UDPGW instalado en 127.0.0.1:7300"
    pausa
}

instalar_3xui() {
    titulo "PANEL WEB 3X-UI"

    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    pausa
}

menu_puertos() {
    while true; do
        titulo "ADMINISTRADOR DE PUERTOS"

        echo -e "${ROJO}[1]${RESET} ${AZUL}VER PUERTOS ACTIVOS${RESET}"
        echo -e "${ROJO}[2]${RESET} ${AZUL}BUSCAR PUERTO O SERVICIO${RESET}"
        echo -e "${ROJO}[3]${RESET} ${AZUL}ABRIR PUERTO TCP${RESET}"
        echo -e "${ROJO}[4]${RESET} ${AZUL}ABRIR PUERTO UDP${RESET}"
        echo -e "${ROJO}[5]${RESET} ${AZUL}ABRIR RANGO UDP${RESET}"
        echo -e "${ROJO}[6]${RESET} ${AZUL}VER REGLAS UFW${RESET}"
        echo -e "${ROJO}[7]${RESET} ${AZUL}ABRIR PUERTOS RECOMENDADOS${RESET}"
        echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"
        echo ""
        read -p "Opción: " op

        case "$op" in
            1) ss -tulnp; pausa ;;
            2)
                read -p "Buscar: " term
                ss -tulnp | grep -i "$term"
                pausa
                ;;
            3)
                read -p "Puerto TCP: " port
                ufw allow "$port"/tcp
                pausa
                ;;
            4)
                read -p "Puerto UDP: " port
                ufw allow "$port"/udp
                pausa
                ;;
            5)
                read -p "Rango UDP, ejemplo 10000:65000: " rango
                ufw allow "$rango"/udp
                pausa
                ;;
            6) ufw status numbered; pausa ;;
            7) abrir_puertos_recomendados ;;
            0) return ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

menu_bot() {
    while true; do
        titulo "BOT TELEGRAM OPCIONAL"

        echo -e "${ROJO}[1]${RESET} ${AZUL}ACTIVAR / CONFIGURAR BOT TELEGRAM${RESET}"
        echo -e "${ROJO}[2]${RESET} ${AZUL}INICIAR BOT${RESET}              $(estado_servicio darkzsaid-bot)"
        echo -e "${ROJO}[3]${RESET} ${AZUL}DETENER BOT${RESET}"
        echo -e "${ROJO}[4]${RESET} ${AZUL}REINICIAR BOT${RESET}"
        echo -e "${ROJO}[5]${RESET} ${AZUL}ESTADO BOT${RESET}"
        echo -e "${ROJO}[6]${RESET} ${AZUL}VER LOGS BOT${RESET}"
        echo -e "${ROJO}[7]${RESET} ${AZUL}CAMBIAR TOKEN / ID ADMIN${RESET}"
        echo -e "${ROJO}[8]${RESET} ${AZUL}DESACTIVAR BOT${RESET}"
        echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"
        echo ""
        read -p "Opción: " op

        case "$op" in
            1) activar_bot_telegram ;;
            2) systemctl start darkzsaid-bot 2>/dev/null; pausa ;;
            3) systemctl stop darkzsaid-bot 2>/dev/null; pausa ;;
            4) systemctl restart darkzsaid-bot 2>/dev/null; pausa ;;
            5) systemctl status darkzsaid-bot --no-pager 2>/dev/null; pausa ;;
            6) journalctl -u darkzsaid-bot -n 80 --no-pager 2>/dev/null; pausa ;;
            7) configurar_bot_telegram ;;
            8) desactivar_bot_telegram ;;
            0) return ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

activar_bot_telegram() {
    titulo "ACTIVAR BOT TELEGRAM"

    mkdir -p /opt/darkzsaid
    mkdir -p /opt/darkzsaid/logs

    crear_archivo_bot
    configurar_bot_telegram
    crear_servicio_bot_telegram

    echo "Instalando entorno Python del bot..."
    apt install -y python3 python3-venv python3-pip

    python3 -m venv /opt/darkzsaid/venv
    /opt/darkzsaid/venv/bin/pip install --upgrade pip
    /opt/darkzsaid/venv/bin/pip install python-telegram-bot

    systemctl daemon-reload
    systemctl enable darkzsaid-bot
    systemctl restart darkzsaid-bot

    echo ""
    echo -e "${VERDE}Bot Telegram activado correctamente.${RESET}"
    echo "Puedes probar en Telegram con /start"
    pausa
}

configurar_bot_telegram() {
    titulo "CONFIGURAR BOT TELEGRAM"

    read -p "Token del bot de Telegram: " BOT_TOKEN
    read -p "Tu ID de Telegram administrador: " ADMIN_ID

    if [[ -z "$BOT_TOKEN" || -z "$ADMIN_ID" ]]; then
        echo "Token o ID vacío. Cancelado."
        pausa
        return
    fi

    cat > /opt/darkzsaid/bot.env <<EOF
BOT_TOKEN="$BOT_TOKEN"
ADMIN_ID="$ADMIN_ID"
EOF

    chmod 600 /opt/darkzsaid/bot.env

    echo "Datos del bot guardados."
    pausa
}

crear_archivo_bot() {
    cat > /opt/darkzsaid/bot.py <<'PYBOT'
#!/usr/bin/env python3

import subprocess
from datetime import datetime, timedelta
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes

BOT_ENV = "/opt/darkzsaid/bot.env"
CONFIG_FILE = "/opt/darkzsaid/config.env"

def load_env(path):
    data = {}
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            data[k] = v.strip().strip('"')
    return data

BOTCFG = load_env(BOT_ENV)
CFG = load_env(CONFIG_FILE)

BOT_TOKEN = BOTCFG.get("BOT_TOKEN")
ADMIN_ID = int(BOTCFG.get("ADMIN_ID", "0"))

def run_cmd(cmd):
    try:
        result = subprocess.run(cmd, shell=True, text=True, capture_output=True, timeout=25)
        out = result.stdout.strip() or result.stderr.strip()
        return out[:3500] if out else "Sin salida."
    except Exception as e:
        return f"Error: {e}"

def is_admin(update: Update):
    return update.effective_user and update.effective_user.id == ADMIN_ID

async def deny(update: Update):
    await update.message.reply_text("Acceso denegado.")

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return

    msg = """
🤖 DARKZSAID BOT VPS

Comandos:

/status
/puertos
/ufw
/datos
/crear usuario password dias
/pass usuario password
/bloquear usuario
/desbloquear usuario
/eliminar usuario
/reiniciar_appmods
/reiniciar_bot
/logs_bot
"""
    await update.message.reply_text(msg)

async def status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return
    out = run_cmd("systemctl is-active ssh; systemctl is-active ufw; systemctl is-active udpmod; systemctl is-active darkzsaid-bot")
    await update.message.reply_text(f"📡 Estado:\n{out}")

async def puertos(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return
    out = run_cmd("ss -tulnp")
    await update.message.reply_text(f"📌 Puertos activos:\n{out}")

async def ufw(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return
    out = run_cmd("ufw status numbered")
    await update.message.reply_text(f"🧱 UFW:\n{out}")

async def datos(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return

    cfg = load_env(CONFIG_FILE)

    msg = f"""
📲 DATOS PROTOCOLO UDP

IP VPS: {cfg.get("APP_DOMAIN")}
DOMINIO/SNI: {cfg.get("APP_DOMAIN")}
PUERTO UDP: {cfg.get("APP_PORT")}
OBFS: {cfg.get("APP_OBFS")}
ALPN: {cfg.get("APP_ALPN")}
RANGO UDP: {cfg.get("APP_RANGE")}

Usuario y contraseña:
Usa el usuario SSH creado en la VPS.
"""
    await update.message.reply_text(msg)

async def crear(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return

    if len(context.args) != 3:
        await update.message.reply_text("Uso: /crear usuario password dias")
        return

    user, password, dias = context.args

    if not user.replace("_", "").replace("-", "").isalnum():
        await update.message.reply_text("Usuario inválido.")
        return

    try:
        dias_int = int(dias)
    except:
        await update.message.reply_text("Días inválidos.")
        return

    fecha = (datetime.now() + timedelta(days=dias_int)).strftime("%Y-%m-%d")

    run_cmd(f"useradd -M {user} -s /bin/false -e {fecha}")
    run_cmd(f"echo '{user}:{password}' | chpasswd")

    await update.message.reply_text(f"✅ Usuario creado\nUsuario: {user}\nContraseña: {password}\nExpira: {fecha}")

async def cambiar_pass(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return

    if len(context.args) != 2:
        await update.message.reply_text("Uso: /pass usuario password")
        return

    user, password = context.args
    run_cmd(f"echo '{user}:{password}' | chpasswd")
    await update.message.reply_text(f"✅ Password cambiada para {user}")

async def bloquear(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return
    if len(context.args) != 1:
        await update.message.reply_text("Uso: /bloquear usuario")
        return
    user = context.args[0]
    run_cmd(f"usermod -L {user}")
    await update.message.reply_text(f"🔒 Usuario bloqueado: {user}")

async def desbloquear(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return
    if len(context.args) != 1:
        await update.message.reply_text("Uso: /desbloquear usuario")
        return
    user = context.args[0]
    run_cmd(f"usermod -U {user}")
    await update.message.reply_text(f"🔓 Usuario desbloqueado: {user}")

async def eliminar(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return
    if len(context.args) != 1:
        await update.message.reply_text("Uso: /eliminar usuario")
        return
    user = context.args[0]
    run_cmd(f"deluser --remove-home {user}")
    await update.message.reply_text(f"🗑 Usuario eliminado: {user}")

async def reiniciar_appmods(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return
    out = run_cmd("systemctl restart udpmod")
    await update.message.reply_text(f"🔄 UDP-Hysteria reiniciado.\n{out}")

async def reiniciar_bot(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return
    await update.message.reply_text("🔄 Reiniciando bot...")
    subprocess.Popen(["systemctl", "restart", "darkzsaid-bot"])

async def logs_bot(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_admin(update):
        await deny(update)
        return
    out = run_cmd("journalctl -u darkzsaid-bot -n 40 --no-pager")
    await update.message.reply_text(f"📜 Logs:\n{out}")

def main():
    app = ApplicationBuilder().token(BOT_TOKEN).build()

    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("status", status))
    app.add_handler(CommandHandler("puertos", puertos))
    app.add_handler(CommandHandler("ufw", ufw))
    app.add_handler(CommandHandler("datos", datos))
    app.add_handler(CommandHandler("crear", crear))
    app.add_handler(CommandHandler("pass", cambiar_pass))
    app.add_handler(CommandHandler("bloquear", bloquear))
    app.add_handler(CommandHandler("desbloquear", desbloquear))
    app.add_handler(CommandHandler("eliminar", eliminar))
    app.add_handler(CommandHandler("reiniciar_appmods", reiniciar_appmods))
    app.add_handler(CommandHandler("reiniciar_bot", reiniciar_bot))
    app.add_handler(CommandHandler("logs_bot", logs_bot))

    app.run_polling()

if __name__ == "__main__":
    main()
PYBOT

    chmod +x /opt/darkzsaid/bot.py
}

crear_servicio_bot_telegram() {
    cat > /etc/systemd/system/darkzsaid-bot.service <<EOF
[Unit]
Description=DarkZsaid Telegram Bot
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/darkzsaid
ExecStart=/opt/darkzsaid/venv/bin/python /opt/darkzsaid/bot.py
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF
}

desactivar_bot_telegram() {
    titulo "DESACTIVAR BOT TELEGRAM"

    systemctl stop darkzsaid-bot 2>/dev/null
    systemctl disable darkzsaid-bot 2>/dev/null

    echo "Bot detenido y desactivado del arranque."
    pausa
}

menu_herramientas() {
    while true; do
        titulo "HERRAMIENTAS"

        echo -e "${ROJO}[1]${RESET} LIMPIAR CACHE"
        echo -e "${ROJO}[2]${RESET} ACTUALIZAR SISTEMA"
        echo -e "${ROJO}[3]${RESET} VER RAM"
        echo -e "${ROJO}[4]${RESET} CAMBIAR PASSWORD ROOT"
        echo -e "${ROJO}[5]${RESET} VER PROCESOS ACTIVOS"
        echo -e "${ROJO}[0]${RESET} VOLVER"
        echo ""
        read -p "Opción: " op

        case "$op" in
            1) apt clean; apt autoremove -y; pausa ;;
            2) apt update && apt upgrade -y; pausa ;;
            3) free -h; pausa ;;
            4) passwd root; pausa ;;
            5) ps aux --sort=-%mem | head -20; pausa ;;
            0) return ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

menu_banner() {
    titulo "BANNER SSH"

    cat > /etc/issue.net <<'EOC'
════════════════════════════════════════════════════
              DARKZSAID VPS
        Acceso autorizado solamente
════════════════════════════════════════════════════
EOC

    sed -i '/^Banner/d' /etc/ssh/sshd_config
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
    systemctl restart ssh || systemctl restart sshd

    echo "Banner creado."
    pausa
}

menu_principal


menu_ws_established() {
    while true; do
        titulo "SSH WEBSOCKET ESTABLISHED 200"

        echo -e "${ROJO}[1]${RESET} ${AZUL}INSTALAR / REINSTALAR SSH-WS ESTABLISHED${RESET}"
        echo -e "${ROJO}[2]${RESET} ${AZUL}VER ESTADO${RESET}"
        echo -e "${ROJO}[3]${RESET} ${AZUL}VER LOGS${RESET}"
        echo -e "${ROJO}[4]${RESET} ${AZUL}CAMBIAR MARCA FINAL${RESET}"
        echo -e "${ROJO}[5]${RESET} ${AZUL}REINICIAR SERVICIO${RESET}"
        echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"
        echo ""
        read -p "Opción: " op

        case "$op" in
            1) instalar_ws_established ;;
            2) estado_ws_established ;;
            3) journalctl -u ssh-ws -n 80 --no-pager -l; pausa ;;
            4) cambiar_marca_ws_established ;;
            5) systemctl restart ssh-ws; pausa ;;
            0) return ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

instalar_python2_si_falta() {
    if command -v python2 >/dev/null 2>&1; then
        return
    fi

    echo "Python2 no encontrado. Instalando Python 2.7.18..."
    apt update
    apt install -y build-essential wget curl make gcc zlib1g-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev

    cd /usr/src || return
    rm -rf Python-2.7.18 Python-2.7.18.tgz

    wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
    tar xzf Python-2.7.18.tgz
    cd Python-2.7.18 || return

    ./configure --prefix=/usr/local/python2.7
    make -j$(nproc)
    make install

    ln -sf /usr/local/python2.7/bin/python2.7 /usr/bin/python2
}

instalar_ws_established() {
    titulo "INSTALAR SSH-WS ESTABLISHED 200"

    instalar_python2_si_falta

    apt install -y ufw lsof net-tools openssl

    echo "Deteniendo servicios que pueden ocupar el puerto 80..."

    systemctl stop gost-http80 2>/dev/null
    systemctl disable gost-http80 2>/dev/null

    systemctl stop squid 2>/dev/null
    systemctl disable squid 2>/dev/null

    systemctl stop nginx 2>/dev/null
    systemctl disable nginx 2>/dev/null
    systemctl mask nginx 2>/dev/null

    systemctl stop socks-python-ws@80 2>/dev/null
    systemctl disable socks-python-ws@80 2>/dev/null
    systemctl mask socks-python-ws@80 2>/dev/null

    systemctl stop socks-python2-ws 2>/dev/null
    systemctl disable socks-python2-ws 2>/dev/null

    systemctl stop socks-python2-ws-nginx 2>/dev/null
    systemctl disable socks-python2-ws-nginx 2>/dev/null

    systemctl stop ssh-ws 2>/dev/null
    systemctl disable ssh-ws 2>/dev/null
    systemctl unmask ssh-ws 2>/dev/null

    fuser -k 80/tcp 2>/dev/null
    sleep 2

    mkdir -p /opt/darkzsaid

    read -p "Marca final del response [ADM SJCC]: " MARCA_WS
    MARCA_WS=${MARCA_WS:-ADM SJCC}

    cat > /opt/darkzsaid/ssh-ws-direct.py <<EOF
#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import socket
import threading
import select

LISTEN_HOST = "0.0.0.0"
LISTEN_PORT = 80

SSH_HOST = "127.0.0.1"
SSH_PORT = 22

BRAND = "$MARCA_WS"

def response_200():
    return (
        "HTTP/1.1 200 Connection established " + BRAND + "\\r\\n"
        "\\r\\n"
    )

def is_http_payload(data):
    if not data:
        return False

    d = data[:500].upper()

    if d.startswith("GET "):
        return True
    if d.startswith("POST "):
        return True
    if d.startswith("CONNECT "):
        return True
    if d.startswith("OPTIONS "):
        return True
    if d.startswith("HTTP/"):
        return True
    if "HOST:" in d:
        return True
    if "UPGRADE:" in d:
        return True
    if "HTTP/" in d:
        return True

    return False

def tunnel(client, remote):
    sockets = [client, remote]

    try:
        while True:
            readable, _, errors = select.select(sockets, [], sockets, 180)

            if errors:
                break

            if not readable:
                break

            for s in readable:
                data = s.recv(8192)

                if not data:
                    return

                if s is client:
                    remote.sendall(data)
                else:
                    client.sendall(data)
    except:
        pass

    try:
        client.close()
    except:
        pass

    try:
        remote.close()
    except:
        pass

def handle_client(client, addr):
    try:
        client.settimeout(15)

        try:
            first = client.recv(8192)
        except:
            first = ""

        client.sendall(response_200())

        remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        remote.settimeout(15)
        remote.connect((SSH_HOST, SSH_PORT))

        client.settimeout(None)
        remote.settimeout(None)

        if first and not is_http_payload(first):
            remote.sendall(first)

        tunnel(client, remote)

    except:
        try:
            client.close()
        except:
            pass

def main():
    print("[DarkZsaid] SSH WebSocket Established")
    print("[DarkZsaid] 0.0.0.0:80 -> 127.0.0.1:22")
    print("[DarkZsaid] Response: HTTP/1.1 200 Connection established " + BRAND)

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LISTEN_HOST, LISTEN_PORT))
    server.listen(500)

    while True:
        client, addr = server.accept()
        t = threading.Thread(target=handle_client, args=(client, addr))
        t.daemon = True
        t.start()

if __name__ == "__main__":
    main()
EOF

    chmod +x /opt/darkzsaid/ssh-ws-direct.py

    cat > /etc/systemd/system/ssh-ws.service <<'EOF'
[Unit]
Description=SSH WebSocket Python Direct Proxy Puerto 80 - DarkZsaid
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python2 /opt/darkzsaid/ssh-ws-direct.py
Restart=always
RestartSec=3
User=root
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

    ufw allow 80/tcp 2>/dev/null || true
    ufw allow 22/tcp 2>/dev/null || true

    systemctl daemon-reload
    systemctl enable ssh-ws
    systemctl restart ssh-ws

    echo ""
    echo -e "${VERDE}SSH WebSocket Established instalado correctamente.${RESET}"
    echo ""
    estado_ws_established
}

estado_ws_established() {
    titulo "ESTADO SSH-WS ESTABLISHED"

    echo "Servicio:"
    systemctl is-active ssh-ws 2>/dev/null || echo "inactive"

    echo ""
    echo "Puerto 80:"
    ss -tulnp | grep ':80' || echo "Puerto 80 no está escuchando"

    echo ""
    echo "Response configurado:"
    grep 'BRAND =' /opt/darkzsaid/ssh-ws-direct.py 2>/dev/null || echo "No instalado"

    echo ""
    echo "Datos para HTTP Custom:"
    echo "Host/IP: $(get_ip)"
    echo "Puerto: 80"
    echo "SSH Host: $(get_ip)"
    echo "SSH Puerto: 22"
    echo "Response: 200 Connection established"
    echo ""
    pausa
}

cambiar_marca_ws_established() {
    titulo "CAMBIAR MARCA SSH-WS"

    if [[ ! -f /opt/darkzsaid/ssh-ws-direct.py ]]; then
        echo "SSH-WS Established no está instalado."
        pausa
        return
    fi

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

menu_ws_established() {
    while true; do
        titulo "SSH WEBSOCKET ESTABLISHED 200"

        echo -e "${ROJO}[1]${RESET} ${AZUL}INSTALAR / REINSTALAR SSH-WS ESTABLISHED${RESET}"
        echo -e "${ROJO}[2]${RESET} ${AZUL}VER ESTADO${RESET}"
        echo -e "${ROJO}[3]${RESET} ${AZUL}VER LOGS${RESET}"
        echo -e "${ROJO}[4]${RESET} ${AZUL}CAMBIAR MARCA FINAL${RESET}"
        echo -e "${ROJO}[5]${RESET} ${AZUL}REINICIAR SERVICIO${RESET}"
        echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"
        echo ""
        read -p "Opción: " op

        case "$op" in
            1) instalar_ws_established ;;
            2) estado_ws_established ;;
            3) journalctl -u ssh-ws -n 80 --no-pager -l; pausa ;;
            4) cambiar_marca_ws_established ;;
            5) systemctl restart ssh-ws; pausa ;;
            0) return ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

instalar_ws_established() {
    titulo "INSTALAR SSH-WS ESTABLISHED 200"

    systemctl stop gost-http80 2>/dev/null
    systemctl disable gost-http80 2>/dev/null

    systemctl stop squid 2>/dev/null
    systemctl disable squid 2>/dev/null

    systemctl stop nginx 2>/dev/null
    systemctl disable nginx 2>/dev/null
    systemctl mask nginx 2>/dev/null

    systemctl stop socks-python-ws@80 2>/dev/null
    systemctl disable socks-python-ws@80 2>/dev/null
    systemctl mask socks-python-ws@80 2>/dev/null

    systemctl stop socks-python2-ws 2>/dev/null
    systemctl disable socks-python2-ws 2>/dev/null

    systemctl stop ssh-ws 2>/dev/null
    systemctl disable ssh-ws 2>/dev/null
    systemctl unmask ssh-ws 2>/dev/null

    fuser -k 80/tcp 2>/dev/null
    sleep 2

    mkdir -p /opt/darkzsaid

    read -p "Marca final del response [ADM SJCC]: " MARCA_WS
    MARCA_WS=${MARCA_WS:-ADM SJCC}

    cat > /opt/darkzsaid/ssh-ws-direct.py <<PYEOF
#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import socket
import threading
import select

LISTEN_HOST = "0.0.0.0"
LISTEN_PORT = 80

SSH_HOST = "127.0.0.1"
SSH_PORT = 22

BRAND = "$MARCA_WS"

def response_200():
    return (
        "HTTP/1.1 200 Connection established " + BRAND + "\\r\\n"
        "\\r\\n"
    )

def is_http_payload(data):
    if not data:
        return False

    d = data[:500].upper()

    if d.startswith("GET "):
        return True
    if d.startswith("POST "):
        return True
    if d.startswith("CONNECT "):
        return True
    if d.startswith("OPTIONS "):
        return True
    if d.startswith("HTTP/"):
        return True
    if "HOST:" in d:
        return True
    if "UPGRADE:" in d:
        return True
    if "HTTP/" in d:
        return True

    return False

def tunnel(client, remote):
    sockets = [client, remote]

    try:
        while True:
            readable, _, errors = select.select(sockets, [], sockets, 180)

            if errors:
                break

            if not readable:
                break

            for s in readable:
                data = s.recv(8192)

                if not data:
                    return

                if s is client:
                    remote.sendall(data)
                else:
                    client.sendall(data)
    except:
        pass

    try:
        client.close()
    except:
        pass

    try:
        remote.close()
    except:
        pass

def handle_client(client, addr):
    try:
        client.settimeout(15)

        try:
            first = client.recv(8192)
        except:
            first = ""

        client.sendall(response_200())

        remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        remote.settimeout(15)
        remote.connect((SSH_HOST, SSH_PORT))

        client.settimeout(None)
        remote.settimeout(None)

        if first and not is_http_payload(first):
            remote.sendall(first)

        tunnel(client, remote)

    except:
        try:
            client.close()
        except:
            pass

def main():
    print("[DarkZsaid] SSH WebSocket Established")
    print("[DarkZsaid] 0.0.0.0:80 -> 127.0.0.1:22")
    print("[DarkZsaid] Response: HTTP/1.1 200 Connection established " + BRAND)

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LISTEN_HOST, LISTEN_PORT))
    server.listen(500)

    while True:
        client, addr = server.accept()
        t = threading.Thread(target=handle_client, args=(client, addr))
        t.daemon = True
        t.start()

if __name__ == "__main__":
    main()
PYEOF

    chmod +x /opt/darkzsaid/ssh-ws-direct.py

    cat > /etc/systemd/system/ssh-ws.service <<'EOFSERVICE'
[Unit]
Description=SSH WebSocket Python Direct Proxy Puerto 80 - DarkZsaid
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python2 /opt/darkzsaid/ssh-ws-direct.py
Restart=always
RestartSec=3
User=root
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOFSERVICE

    ufw allow 80/tcp 2>/dev/null || true
    ufw allow 22/tcp 2>/dev/null || true

    systemctl daemon-reload
    systemctl enable ssh-ws
    systemctl restart ssh-ws

    echo ""
    echo -e "${VERDE}SSH WebSocket Established instalado correctamente.${RESET}"
    echo ""
    estado_ws_established
}

estado_ws_established() {
    titulo "ESTADO SSH-WS ESTABLISHED"

    echo "Servicio:"
    systemctl is-active ssh-ws 2>/dev/null || echo "inactive"

    echo ""
    echo "Puerto 80:"
    ss -tulnp | grep ':80' || echo "Puerto 80 no está escuchando"

    echo ""
    echo "Response configurado:"
    grep 'BRAND =' /opt/darkzsaid/ssh-ws-direct.py 2>/dev/null || echo "No instalado"

    echo ""
    echo "Datos para HTTP Custom:"
    echo "Host/IP: $(get_ip)"
    echo "Puerto: 80"
    echo "SSH Host: $(get_ip)"
    echo "SSH Puerto: 22"
    echo "Response: HTTP/1.1 200 Connection established"
    echo ""
    pausa
}

cambiar_marca_ws_established() {
    titulo "CAMBIAR MARCA SSH-WS"

    if [[ ! -f /opt/darkzsaid/ssh-ws-direct.py ]]; then
        echo "SSH-WS Established no está instalado."
        pausa
        return
    fi

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



instalar_ssh_ws_permanente() {
    titulo "SOCKS PYTHON DIRECTO WS"

    echo "Este módulo usa el método permanente:"
    echo "SSH WebSocket Established 200 ADM SJCC"
    echo ""
    echo "Puerto público: 80"
    echo "Destino local: SSH 22"
    echo ""

    if systemctl is-active --quiet ssh-ws; then
        echo -e "${VERDE}Estado: ON${RESET}"
        echo ""
        ss -tulnp | grep ':80' || true
        pausa
        return
    fi

    echo "Estado: OFF"
    echo "Instalando / activando método permanente..."
    sleep 1

    if ! command -v python2 >/dev/null 2>&1; then
        echo "Python2 no está instalado. Instálalo antes de activar este módulo."
        echo "Comando recomendado:"
        echo "python2 --version"
        pausa
        return
    fi

    systemctl stop gost-http80 2>/dev/null
    systemctl disable gost-http80 2>/dev/null

    systemctl stop squid 2>/dev/null
    systemctl disable squid 2>/dev/null

    systemctl stop nginx 2>/dev/null
    systemctl disable nginx 2>/dev/null
    systemctl mask nginx 2>/dev/null

    systemctl stop socks-python-ws@80 2>/dev/null
    systemctl disable socks-python-ws@80 2>/dev/null
    systemctl mask socks-python-ws@80 2>/dev/null

    systemctl stop socks-python2-ws 2>/dev/null
    systemctl disable socks-python2-ws 2>/dev/null

    fuser -k 80/tcp 2>/dev/null
    sleep 2

    mkdir -p /opt/darkzsaid

    cat > /opt/darkzsaid/ssh-ws-direct.py <<'PYEOF'
#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import socket
import threading
import select

LISTEN_HOST = "0.0.0.0"
LISTEN_PORT = 80

SSH_HOST = "127.0.0.1"
SSH_PORT = 22

BRAND = "ADM SJCC"

def response_200():
    return (
        "HTTP/1.1 200 Connection established " + BRAND + "\r\n"
        "\r\n"
    )

def is_http_payload(data):
    if not data:
        return False

    d = data[:500].upper()

    if d.startswith("GET "):
        return True
    if d.startswith("POST "):
        return True
    if d.startswith("CONNECT "):
        return True
    if d.startswith("OPTIONS "):
        return True
    if d.startswith("HTTP/"):
        return True
    if "HOST:" in d:
        return True
    if "UPGRADE:" in d:
        return True
    if "HTTP/" in d:
        return True

    return False

def tunnel(client, remote):
    sockets = [client, remote]

    try:
        while True:
            readable, _, errors = select.select(sockets, [], sockets, 180)

            if errors:
                break

            if not readable:
                break

            for s in readable:
                data = s.recv(8192)

                if not data:
                    return

                if s is client:
                    remote.sendall(data)
                else:
                    client.sendall(data)
    except:
        pass

    try:
        client.close()
    except:
        pass

    try:
        remote.close()
    except:
        pass

def handle_client(client, addr):
    try:
        client.settimeout(15)

        try:
            first = client.recv(8192)
        except:
            first = ""

        client.sendall(response_200())

        remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        remote.settimeout(15)
        remote.connect((SSH_HOST, SSH_PORT))

        client.settimeout(None)
        remote.settimeout(None)

        if first and not is_http_payload(first):
            remote.sendall(first)

        tunnel(client, remote)

    except:
        try:
            client.close()
        except:
            pass

def main():
    print("[DarkZsaid] Socks Python Directo WS")
    print("[DarkZsaid] 0.0.0.0:80 -> 127.0.0.1:22")
    print("[DarkZsaid] Response: HTTP/1.1 200 Connection established " + BRAND)

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LISTEN_HOST, LISTEN_PORT))
    server.listen(500)

    while True:
        client, addr = server.accept()
        t = threading.Thread(target=handle_client, args=(client, addr))
        t.daemon = True
        t.start()

if __name__ == "__main__":
    main()
PYEOF

    chmod +x /opt/darkzsaid/ssh-ws-direct.py

    cat > /etc/systemd/system/ssh-ws.service <<'EOF'
[Unit]
Description=Socks Python Directo WS - Established 200 ADM SJCC
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python2 /opt/darkzsaid/ssh-ws-direct.py
Restart=always
RestartSec=3
User=root
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

    ufw allow 80/tcp 2>/dev/null || true
    ufw allow 22/tcp 2>/dev/null || true

    systemctl daemon-reload
    systemctl enable ssh-ws
    systemctl restart ssh-ws

    echo ""
    echo -e "${VERDE}SOCKS PYTHON DIRECTO WS activado correctamente.${RESET}"
    echo ""
    echo "Método: HTTP/1.1 200 Connection established ADM SJCC"
    echo "Puerto: 80"
    echo "Destino: SSH 22"
    echo ""
    ss -tulnp | grep ':80' || true
    pausa
}


menu_ssh_ws_permanente() {
    while true; do
        titulo "SOCKS PYTHON DIRECTO WS"

        echo -e "${ROJO}[1]${RESET} ${AZUL}ACTIVAR / INSTALAR PUERTO 80${RESET}"
        echo -e "${ROJO}[2]${RESET} ${AZUL}DETENER PUERTO 80${RESET}"
        echo -e "${ROJO}[3]${RESET} ${AZUL}REINICIAR PUERTO 80${RESET}"
        echo -e "${ROJO}[4]${RESET} ${AZUL}REMOVER PUERTO 80${RESET}"
        echo -e "${ROJO}[5]${RESET} ${AZUL}VER ESTADO${RESET}"
        echo -e "${ROJO}[6]${RESET} ${AZUL}VER LOGS${RESET}"
        echo -e "${ROJO}[0]${RESET} ${BLANCO}VOLVER${RESET}"
        echo ""
        read -p "Opción: " op

        case "$op" in
            1) instalar_ssh_ws_permanente ;;
            2) detener_ssh_ws_permanente ;;
            3) reiniciar_ssh_ws_permanente ;;
            4) remover_ssh_ws_permanente ;;
            5) estado_ssh_ws_permanente ;;
            6) journalctl -u ssh-ws -n 80 --no-pager -l; pausa ;;
            0) return ;;
            *) echo "Opción inválida"; sleep 1 ;;
        esac
    done
}

estado_ssh_ws_permanente() {
    titulo "ESTADO SOCKS PYTHON DIRECTO WS"

    echo "Servicio:"
    systemctl is-active ssh-ws 2>/dev/null || echo "inactive"

    echo ""
    echo "Puerto 80:"
    ss -tulnp | grep ':80' || echo "Puerto 80 no está escuchando"

    echo ""
    echo "Response:"
    grep 'Connection established' /opt/darkzsaid/ssh-ws-direct.py 2>/dev/null || echo "No instalado"

    echo ""
    echo "Datos:"
    echo "Host/IP: $(get_ip)"
    echo "Puerto: 80"
    echo "SSH Host: $(get_ip)"
    echo "SSH Puerto: 22"
    echo "Response: HTTP/1.1 200 Connection established ADM SJCC"
    pausa
}

detener_ssh_ws_permanente() {
    titulo "DETENER SOCKS PYTHON DIRECTO WS"

    systemctl stop ssh-ws 2>/dev/null

    echo "Servicio ssh-ws detenido."
    echo ""
    ss -tulnp | grep ':80' || echo "Puerto 80 libre."
    pausa
}

reiniciar_ssh_ws_permanente() {
    titulo "REINICIAR SOCKS PYTHON DIRECTO WS"

    systemctl restart ssh-ws 2>/dev/null

    echo "Servicio ssh-ws reiniciado."
    echo ""
    ss -tulnp | grep ':80' || echo "Puerto 80 no está escuchando."
    pausa
}

remover_ssh_ws_permanente() {
    titulo "REMOVER SOCKS PYTHON DIRECTO WS"

    read -p "¿Seguro que quieres remover el puerto 80 SSH-WS? [s/n]: " r

    if [[ "$r" != "s" && "$r" != "S" ]]; then
        echo "Cancelado."
        pausa
        return
    fi

    systemctl stop ssh-ws 2>/dev/null
    systemctl disable ssh-ws 2>/dev/null

    rm -f /etc/systemd/system/ssh-ws.service
    rm -f /opt/darkzsaid/ssh-ws-direct.py

    systemctl daemon-reload

    echo "SSH WebSocket removido."
    echo ""
    ss -tulnp | grep ':80' || echo "Puerto 80 libre."
    pausa
}
