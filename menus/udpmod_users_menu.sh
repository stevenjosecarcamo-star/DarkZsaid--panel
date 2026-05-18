#!/bin/bash

CONFIG="/etc/udpmod/config.json"
DB="/opt/darkzsaid/data/usuarios_udpmod.db"

mkdir -p /opt/darkzsaid/data
touch "$DB"

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
AZUL="\e[34m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

pausa() {
    echo ""
    read -r -p "Presiona ENTER para continuar..."
}

linea() {
    echo -e "${CYAN}════════════════════════════════════════════${RESET}"
}

titulo() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
    printf "${CYAN}║${RESET} ${BLANCO}${BOLD}%-42s${RESET} ${CYAN}║${RESET}\n" "$1"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
    echo ""
}

get_ip() {
    curl -4 -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}'
}

get_json_value() {
    local key="$1"
    python3 <<PY 2>/dev/null
import json
path="$CONFIG"
key="$key"
try:
    with open(path) as f:
        cfg=json.load(f)
    print(cfg.get(key,""))
except Exception:
    print("")
PY
}

sync_udp_config() {
python3 <<PY
import json, os

config = "$CONFIG"
db = "$DB"

if not os.path.exists(config):
    print("No existe", config)
    raise SystemExit(1)

usuarios = []

if os.path.exists(db):
    with open(db, "r", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line or "|" not in line:
                continue
            partes = line.split("|")
            if len(partes) >= 2:
                user = partes[0].strip()
                passwd = partes[1].strip()
                if user and passwd:
                    usuarios.append(f"{user}:{passwd}")

with open(config, "r") as f:
    cfg = json.load(f)

cfg.setdefault("auth", {})
cfg["auth"]["mode"] = "passwords"
cfg["auth"]["config"] = usuarios
cfg["obfs"] = cfg.get("obfs") or "DarkZsaid"

with open(config, "w") as f:
    json.dump(cfg, f, indent=2)

print("UDPMod sincronizado con", len(usuarios), "usuario(s).")
PY

systemctl restart udpmod 2>/dev/null || true
}

mostrar_tarjeta_usuario() {
    local usuario="$1"
    local clave="$2"
    local expira="$3"

    IP_PUBLICA=$(get_ip)
    OBFS=$(get_json_value "obfs")
    UP=$(get_json_value "up_mbps")
    DOWN=$(get_json_value "down_mbps")

    [[ -z "$OBFS" ]] && OBFS="DarkZsaid"
    [[ -z "$UP" ]] && UP="17"
    [[ -z "$DOWN" ]] && DOWN="15"

    clear
    echo -e "${VERDE}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${VERDE}║${RESET} ${BLANCO}${BOLD}      USUARIO UDP-HYSTERIA CREADO       ${RESET}${VERDE}║${RESET}"
    echo -e "${VERDE}╚════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}│${RESET} ${AMARILLO}👤 Usuario      :${RESET} ${BLANCO}$usuario${RESET}"
    echo -e "${CYAN}│${RESET} ${AMARILLO}🔑 Contraseña  :${RESET} ${BLANCO}$clave${RESET}"
    echo -e "${CYAN}│${RESET} ${AMARILLO}📅 Expira      :${RESET} ${BLANCO}$expira${RESET}"
    echo -e "${CYAN}│${RESET} ${AMARILLO}🌐 IP VPS      :${RESET} ${BLANCO}$IP_PUBLICA${RESET}"
    echo -e "${CYAN}│${RESET} ${AMARILLO}📡 Puerto      :${RESET} ${BLANCO}36712${RESET}"
    echo -e "${CYAN}│${RESET} ${AMARILLO}🛡️ OBFS        :${RESET} ${BLANCO}$OBFS${RESET}"
    echo -e "${CYAN}│${RESET} ${AMARILLO}⬆️ UP Mbps     :${RESET} ${BLANCO}$UP${RESET}"
    echo -e "${CYAN}│${RESET} ${AMARILLO}⬇️ DOWN Mbps   :${RESET} ${BLANCO}$DOWN${RESET}"
    echo -e "${CYAN}└────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -e "${VERDE}✅ Usuario guardado en base UDPMod.${RESET}"
    echo -e "${VERDE}✅ Configuración sincronizada.${RESET}"
    echo -e "${VERDE}✅ Servicio UDPMod reiniciado.${RESET}"
    echo ""
    echo -e "${AMARILLO}Datos para la app:${RESET}"
    echo ""
    echo -e "${BLANCO}IP: $IP_PUBLICA${RESET}"
    echo -e "${BLANCO}Puerto: 36712${RESET}"
    echo -e "${BLANCO}Usuario: $usuario${RESET}"
    echo -e "${BLANCO}Contraseña: $clave${RESET}"
    echo -e "${BLANCO}OBFS: $OBFS${RESET}"
    echo ""
    pausa
}

crear_usuario_udp() {
    titulo "CREAR USUARIO UDPMod / HYSTERIA"

    echo -e "${AMARILLO}Complete los datos del usuario UDP:${RESET}"
    echo ""
    read -r -p "Usuario UDP: " usuario
    read -r -p "Contraseña UDP: " clave
    read -r -p "Días de duración: " dias

    if [[ -z "$usuario" || -z "$clave" || -z "$dias" ]]; then
        echo ""
        echo -e "${ROJO}Datos incompletos.${RESET}"
        pausa
        return
    fi

    if ! [[ "$dias" =~ ^[0-9]+$ ]]; then
        echo ""
        echo -e "${ROJO}Los días deben ser número.${RESET}"
        pausa
        return
    fi

    expira=$(date -d "+$dias days" +%Y-%m-%d 2>/dev/null)

    if [[ -z "$expira" ]]; then
        echo ""
        echo -e "${ROJO}No se pudo calcular fecha de expiración.${RESET}"
        pausa
        return
    fi

    grep -v "^${usuario}|" "$DB" > "$DB.tmp" 2>/dev/null || true
    mv "$DB.tmp" "$DB"

    echo "${usuario}|${clave}|${expira}" >> "$DB"

    echo ""
    echo -e "${CYAN}Sincronizando usuario con UDPMod...${RESET}"
    sleep 1
    sync_udp_config

    mostrar_tarjeta_usuario "$usuario" "$clave" "$expira"
}

listar_usuarios_udp() {
    titulo "USUARIOS UDPMod / HYSTERIA"

    if [[ ! -s "$DB" ]]; then
        echo -e "${AMARILLO}No hay usuarios UDPMod guardados.${RESET}"
    else
        echo -e "${CYAN}┌─────┬──────────────────┬──────────────────┬───────────────┐${RESET}"
        printf "${CYAN}│${RESET} %-3s ${CYAN}│${RESET} %-16s ${CYAN}│${RESET} %-16s ${CYAN}│${RESET} %-13s ${CYAN}│${RESET}\n" "N°" "USUARIO" "CONTRASEÑA" "EXPIRA"
        echo -e "${CYAN}├─────┼──────────────────┼──────────────────┼───────────────┤${RESET}"

        n=1
        while IFS='|' read -r user pass exp; do
            [[ -z "$user" ]] && continue
            printf "${CYAN}│${RESET} %-3s ${CYAN}│${RESET} %-16s ${CYAN}│${RESET} %-16s ${CYAN}│${RESET} %-13s ${CYAN}│${RESET}\n" "$n" "$user" "$pass" "$exp"
            n=$((n+1))
        done < "$DB"

        echo -e "${CYAN}└─────┴──────────────────┴──────────────────┴───────────────┘${RESET}"
    fi

    echo ""
    echo -e "${AMARILLO}Auth actual en UDPMod:${RESET}"
    grep -A20 '"auth"' "$CONFIG" 2>/dev/null || echo "No se pudo leer config.json"
    pausa
}

eliminar_usuario_udp() {
    titulo "ELIMINAR USUARIO UDPMod"

    if [[ ! -s "$DB" ]]; then
        echo -e "${AMARILLO}No hay usuarios UDPMod para eliminar.${RESET}"
        pausa
        return
    fi

    echo -e "${AMARILLO}Usuarios actuales:${RESET}"
    echo ""
    cat "$DB"
    echo ""
    read -r -p "Usuario a eliminar: " usuario

    if [[ -z "$usuario" ]]; then
        echo -e "${ROJO}Usuario vacío.${RESET}"
        pausa
        return
    fi

    grep -v "^${usuario}|" "$DB" > "$DB.tmp" 2>/dev/null || true
    mv "$DB.tmp" "$DB"

    echo ""
    echo -e "${CYAN}Sincronizando cambios con UDPMod...${RESET}"
    sync_udp_config

    echo ""
    echo -e "${VERDE}Usuario UDPMod eliminado: $usuario${RESET}"
    pausa
}

estado_udpmod_premium() {
    titulo "ESTADO UDPMod / HYSTERIA"

    if systemctl is-active --quiet udpmod 2>/dev/null; then
        echo -e "${VERDE}✅ Servicio UDPMod: ACTIVO${RESET}"
    else
        echo -e "${ROJO}❌ Servicio UDPMod: APAGADO${RESET}"
    fi

    if ss -ulnp | grep -q ':36712'; then
        echo -e "${VERDE}✅ Puerto 36712: ESCUCHANDO${RESET}"
    else
        echo -e "${ROJO}❌ Puerto 36712: NO ESCUCHA${RESET}"
    fi

    echo ""
    echo -e "${AMARILLO}Configuración:${RESET}"
    echo -e "OBFS      : $(get_json_value obfs)"
    echo -e "UP Mbps   : $(get_json_value up_mbps)"
    echo -e "DOWN Mbps : $(get_json_value down_mbps)"
    echo ""

    echo -e "${AMARILLO}Usuarios cargados en UDPMod:${RESET}"
    grep -A20 '"auth"' "$CONFIG" 2>/dev/null || echo "No se pudo leer config.json"
    pausa
}

while true; do
    clear

    TOTAL_UDP=$(grep -c "|" "$DB" 2>/dev/null || echo 0)

    if systemctl is-active --quiet udpmod 2>/dev/null; then
        ESTADO_UDP="${VERDE}ACTIVO${RESET}"
    else
        ESTADO_UDP="${ROJO}APAGADO${RESET}"
    fi

    if ss -ulnp 2>/dev/null | grep -q ":36712"; then
        PUERTO_UDP="${VERDE}36712 ABIERTO${RESET}"
    else
        PUERTO_UDP="${ROJO}36712 CERRADO${RESET}"
    fi

    OBFS_ACTUAL=$(python3 - <<PY2 2>/dev/null
import json
try:
    with open("/etc/udpmod/config.json") as f:
        cfg=json.load(f)
    print(cfg.get("obfs","DarkZsaid"))
except Exception:
    print("DarkZsaid")
PY2
)

    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET} ${BLANCO}${BOLD}        UDPMod / HYSTERIA USER CENTER       ${RESET}${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${AMARILLO} Servicio UDPMod :${RESET} $ESTADO_UDP"
    echo -e "${AMARILLO} Puerto UDP      :${RESET} $PUERTO_UDP"
    echo -e "${AMARILLO} OBFS actual     :${RESET} ${VERDE}$OBFS_ACTUAL${RESET}"
    echo -e "${AMARILLO} Usuarios UDP    :${RESET} ${BLANCO}$TOTAL_UDP${RESET}"
    echo ""
    echo -e "${CYAN}┌──────────────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}│${RESET} ${ROJO}[1]${RESET} ${BLANCO}Crear usuario UDP-Hysteria${RESET}"
    echo -e "${CYAN}│${RESET} ${ROJO}[2]${RESET} ${BLANCO}Ver usuarios UDP guardados${RESET}"
    echo -e "${CYAN}│${RESET} ${ROJO}[3]${RESET} ${BLANCO}Eliminar usuario UDP${RESET}"
    echo -e "${CYAN}│${RESET} ${ROJO}[4]${RESET} ${BLANCO}Sincronizar base con UDPMod${RESET}"
    echo -e "${CYAN}│${RESET} ${ROJO}[5]${RESET} ${BLANCO}Estado premium del servicio${RESET}"
    echo -e "${CYAN}│${RESET} ${ROJO}[0]${RESET} ${AMARILLO}Volver al menú anterior${RESET}"
    echo -e "${CYAN}└──────────────────────────────────────────────────┘${RESET}"
    echo ""
    read -r -p "⚡ Seleccione una opción: " op

    case "$op" in
        1|01) crear_usuario_udp ;;
        2|02) listar_usuarios_udp ;;
        3|03) eliminar_usuario_udp ;;
        4|04) titulo "SINCRONIZAR UDPMod"; sync_udp_config; pausa ;;
        5|05) estado_udpmod_premium ;;
        0|00) exit 0 ;;
        *) echo "Opción inválida."; sleep 1 ;;
    esac
done
