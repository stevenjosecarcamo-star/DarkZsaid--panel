#!/bin/bash
source /opt/darkzsaid/menus/ui_instalacion.sh 2>/dev/null || true
[[ -f /opt/darkzsaid/lib/ui.sh ]] && source /opt/darkzsaid/lib/ui.sh

ZIVPN_SERVICE="zivpn"
ZIVPN_CONFIG="/etc/zivpn/config.json"
ZIVPN_BIN="/usr/local/bin/zivpn"
ZIVPN_PORT="5667"

titulo_zivpn() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}              ${BLANCO}⚡ ZIVPN ⚡${RESET}                 ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${AMARILLO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "              ${VERDE}$1${RESET}"
    echo -e "${AMARILLO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

estado_zivpn() {
    if systemctl is-active --quiet zivpn 2>/dev/null; then
        echo -e "${VERDE}[ON]${RESET}"
    else
        echo -e "${ROJO}[OFF]${RESET}"
    fi
}

asegurar_motor_zivpn() {
    mkdir -p /etc/zivpn

    if [[ ! -x "$ZIVPN_BIN" ]]; then
        if [[ -x "/usr/usr/local/bin/zivpn" ]]; then
            cp -a /usr/usr/local/bin/zivpn "$ZIVPN_BIN"
            chmod +x "$ZIVPN_BIN"
        elif [[ -x "/etc/ADMcgh/usr/local/bin/zivpn" ]]; then
            cp -a /etc/ADMcgh/usr/local/bin/zivpn "$ZIVPN_BIN"
            chmod +x "$ZIVPN_BIN"
        else
            error_msg "No se encontró el motor ZIVPN."
            echo "Debe existir /usr/local/bin/zivpn o /usr/usr/local/bin/zivpn."
            pausa_bonita
            return 1
        fi
    fi

    if [[ ! -f /etc/zivpn/zivpn.crt || ! -f /etc/zivpn/zivpn.key ]]; then
        openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=DarkZsaid/L=Server/O=ZIVPN/OU=Panel/CN=zivpn" \
        -keyout "/etc/zivpn/zivpn.key" \
        -out "/etc/zivpn/zivpn.crt" >/dev/null 2>&1
    fi

    if [[ ! -f "$ZIVPN_CONFIG" ]]; then
        cat > "$ZIVPN_CONFIG" <<'EOFCONF'
{
  "listen": ":5667",
  "cert": "/etc/zivpn/zivpn.crt",
  "key": "/etc/zivpn/zivpn.key",
  "max_conn": 0,
  "obfs": "zivpn",
  "auth": {
    "mode": "passwords",
    "config": []
  }
}
EOFCONF
    fi

    cat > /etc/systemd/system/zivpn.service <<EOF_SERVICE
[Unit]
Description=ZIVPN Service - DarkZsaid
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/zivpn
ExecStart=$ZIVPN_BIN server -c $ZIVPN_CONFIG
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF_SERVICE

    systemctl daemon-reload >/dev/null 2>&1 >/dev/null 2>&1
}

normalizar_config_zivpn() {
    mkdir -p /etc/zivpn

    python3 <<'PY'
import json
from pathlib import Path

p = Path("/etc/zivpn/config.json")

try:
    data = json.loads(p.read_text())
except Exception:
    data = {}

claves = []

for campo in [
    data.get("auth", {}).get("config", []),
    data.get("auth", {}).get("Config", []),
    data.get("config", []),
    data.get("users", [])
]:
    if isinstance(campo, list):
        for c in campo:
            c = str(c).strip()
            if c and c not in claves:
                claves.append(c)

nuevo = {
    "listen": ":5667",
    "cert": "/etc/zivpn/zivpn.crt",
    "key": "/etc/zivpn/zivpn.key",
    "max_conn": 0,
    "obfs": "zivpn",
    "auth": {
        "mode": "passwords",
        "config": claves
    }
}

p.write_text(json.dumps(nuevo, indent=2))
PY
}

red_zivpn() {
    ufw allow 5667/udp >/dev/null 2>&1 || true

    sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1
    grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

    IFACE=$(ip -4 route | awk '/default/ {print $5; exit}')

    iptables -C INPUT -p udp --dport 5667 -j ACCEPT 2>/dev/null || iptables -I INPUT -p udp --dport 5667 -j ACCEPT
    iptables -C FORWARD -j ACCEPT 2>/dev/null || iptables -I FORWARD -j ACCEPT
    iptables -t nat -C POSTROUTING -o "$IFACE" -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE

    netfilter-persistent save >/dev/null 2>&1 || true
}

liberar_puerto_zivpn() {
    systemctl stop zvpn 2>/dev/null || true
    systemctl stop sipvpn-activex 2>/dev/null || true

    pkill -f "zivpn server" 2>/dev/null || true
    pkill -f "/usr/local/bin/zivpn" 2>/dev/null || true

    sleep 1
}

reiniciar_zivpn_limpio() {
    systemctl daemon-reload >/dev/null 2>&1 >/dev/null 2>&1
    systemctl enable zivpn >/dev/null 2>&1 >/dev/null 2>&1

    systemctl stop zivpn >/dev/null 2>&1 || true
    liberar_puerto_zivpn
    systemctl start zivpn >/dev/null 2>&1

    sleep 1
}

activar_zivpn() {
    titulo_zivpn "ACTIVAR / INSTALAR ZIVPN"

    cargando "Cargando binarios ZIVPN"
    asegurar_motor_zivpn || return

    cargando "Aplicando configuración"
    normalizar_config_zivpn

    cargando "Preparando puerto UDP"
    red_zivpn

    cargando "Iniciando servicio"
    reiniciar_zivpn_limpio

    ok_msg "ZIVPN activado correctamente."
    echo -e "${AMARILLO}Estado:${RESET} $(estado_zivpn)"

    pausa_bonita
}

crear_clave_zivpn() {
    titulo_zivpn "CREAR CLAVE ZIVPN"

    asegurar_motor_zivpn || return
    normalizar_config_zivpn

    read -r -p "Nueva clave: " clave
    clave="$(echo "$clave" | xargs 2>/dev/null)"

    if [[ -z "$clave" ]]; then
        error_msg "No escribiste ninguna clave."
        pausa_bonita
        return
    fi

    cp "$ZIVPN_CONFIG" "$ZIVPN_CONFIG.bak.key.$(date +%s)" 2>/dev/null || true

    python3 <<PY
import json
from pathlib import Path

p = Path("/etc/zivpn/config.json")
data = json.loads(p.read_text())

clave = """$clave"""

claves = data.get("auth", {}).get("config", [])

if clave not in claves:
    claves.append(clave)

data["auth"]["mode"] = "passwords"
data["auth"]["config"] = claves

p.write_text(json.dumps(data, indent=2))
PY

    cargando "Actualizando claves"
    red_zivpn

    cargando "Reiniciando servicio"
    reiniciar_zivpn_limpio

    echo ""
    ok_msg "Clave creada correctamente."
    echo -e "${AMARILLO}Clave:${RESET} ${BLANCO}$clave${RESET}"
    echo -e "${AMARILLO}Estado:${RESET} $(estado_zivpn)"

    pausa_bonita
}

listar_claves_zivpn() {
    titulo_zivpn "LISTAR CLAVES ZIVPN"

    normalizar_config_zivpn

    python3 <<'PY'
import json
from pathlib import Path

p = Path("/etc/zivpn/config.json")
data = json.loads(p.read_text())
claves = data.get("auth", {}).get("config", [])

if not claves:
    print("No hay claves registradas.")
else:
    print("CLAVES REGISTRADAS")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    for i, clave in enumerate(claves, 1):
        print(f"[{i:02}]  {clave}")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"TOTAL: {len(claves)} clave(s)")
PY

    pausa_bonita
}

eliminar_clave_zivpn() {
    titulo_zivpn "ELIMINAR CLAVE ZIVPN"

    normalizar_config_zivpn

    python3 <<'PY'
import json
from pathlib import Path

p = Path("/etc/zivpn/config.json")
data = json.loads(p.read_text())
claves = data.get("auth", {}).get("config", [])

print("CLAVES REGISTRADAS")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
for i, clave in enumerate(claves, 1):
    print(f"[{i:02}]  {clave}")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
PY

    echo ""
    read -r -p "Escribe la clave que quieres eliminar: " clave
    clave="$(echo "$clave" | xargs 2>/dev/null)"

    if [[ -z "$clave" ]]; then
        error_msg "No escribiste ninguna clave."
        pausa_bonita
        return
    fi

    python3 <<PY
import json
from pathlib import Path

p = Path("/etc/zivpn/config.json")
data = json.loads(p.read_text())

clave = """$clave"""

claves = data.get("auth", {}).get("config", [])
data["auth"]["config"] = [c for c in claves if c != clave]

p.write_text(json.dumps(data, indent=2))
PY

    cargando "Actualizando lista de claves"
    reiniciar_zivpn_limpio

    echo ""
    ok_msg "Clave eliminada si existía."
    echo -e "${AMARILLO}Clave:${RESET} $clave"
    echo -e "${AMARILLO}Estado:${RESET} $(estado_zivpn)"

    pausa_bonita
}

encender_zivpn() {
    titulo_zivpn "ENCENDER ZIVPN"

    asegurar_motor_zivpn || return
    normalizar_config_zivpn
    red_zivpn

    systemctl enable zivpn >/dev/null 2>&1 >/dev/null 2>&1
    systemctl start zivpn >/dev/null 2>&1

    ok_msg "ZIVPN encendido."
    echo -e "${AMARILLO}Estado:${RESET} $(estado_zivpn)"

    pausa_bonita
}

detener_zivpn() {
    titulo_zivpn "DETENER ZIVPN"

    systemctl stop zivpn >/dev/null 2>&1
    pkill -f "zivpn server" 2>/dev/null || true

    warn_msg "ZIVPN detenido."
    echo -e "${AMARILLO}Estado:${RESET} $(estado_zivpn)"

    pausa_bonita
}

reiniciar_zivpn() {
    titulo_zivpn "REINICIAR ZIVPN"

    asegurar_motor_zivpn || return
    normalizar_config_zivpn
    red_zivpn

    cargando "Reiniciando ZIVPN"
    reiniciar_zivpn_limpio

    ok_msg "ZIVPN reiniciado."
    echo -e "${AMARILLO}Estado:${RESET} $(estado_zivpn)"

    pausa_bonita
}

remover_zivpn() {
    titulo_zivpn "REMOVER ZIVPN"

    read -r -p "¿Seguro que quieres remover ZIVPN? [s/n]: " r

    if [[ "$r" == "s" || "$r" == "S" ]]; then
        systemctl stop zivpn >/dev/null 2>&1 || true
        systemctl disable zivpn >/dev/null 2>&1 || true
        pkill -f "zivpn server" 2>/dev/null || true
        rm -f /etc/systemd/system/zivpn.service
        systemctl daemon-reload >/dev/null 2>&1 >/dev/null 2>&1
        ok_msg "ZIVPN removido del servicio."
        echo "Las claves quedan guardadas en /etc/zivpn/config.json"
    else
        echo "Cancelado."
    fi

    pausa_bonita
}

menu_zivpn() {
    while true; do
        titulo_zivpn "MENÚ ZIVPN"

        echo -e "${ROJO}[01]${RESET} ${CYAN}➜${RESET} ${BLANCO}ACTIVAR / INSTALAR${RESET}      $(estado_zivpn)"
        echo -e "${ROJO}[02]${RESET} ${CYAN}➜${RESET} ${BLANCO}CREAR CLAVE${RESET}"
        echo -e "${ROJO}[03]${RESET} ${CYAN}➜${RESET} ${BLANCO}LISTAR CLAVES${RESET}"
        echo -e "${ROJO}[04]${RESET} ${CYAN}➜${RESET} ${BLANCO}ELIMINAR CLAVE${RESET}"
        echo -e "${ROJO}[05]${RESET} ${CYAN}➜${RESET} ${BLANCO}ENCENDER${RESET}"
        echo -e "${ROJO}[06]${RESET} ${CYAN}➜${RESET} ${BLANCO}DETENER${RESET}"
        echo -e "${ROJO}[07]${RESET} ${CYAN}➜${RESET} ${BLANCO}REINICIAR${RESET}"
        echo -e "${ROJO}[08]${RESET} ${CYAN}➜${RESET} ${ROJO}REMOVER${RESET}"
        echo ""
        echo -e "${ROJO}[00]${RESET} ${CYAN}➜${RESET} ${ROJO}[ VOLVER ]${RESET}"

        leer_opcion op "⚡ Opción: "

        case "$op" in
            1|01) activar_zivpn ;;
            2|02) crear_clave_zivpn ;;
            3|03) listar_claves_zivpn ;;
            4|04) eliminar_clave_zivpn ;;
            5|05) encender_zivpn ;;
            6|06) detener_zivpn ;;
            7|07) reiniciar_zivpn ;;
            8|08) remover_zivpn ;;
            0|00) return ;;
            *) opcion_invalida ;;
        esac
    done
}

menu_zivpn
