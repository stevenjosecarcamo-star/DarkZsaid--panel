#!/bin/bash

CONFIG="/etc/udpmod/config.json"
DB="/opt/darkzsaid/data/usuarios_udpmod.db"

mkdir -p /opt/darkzsaid/data
touch "$DB"

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"

pausa() {
    echo ""
    read -r -p "Presiona ENTER para continuar..."
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

crear_usuario_udp() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║        CREAR USUARIO UDPMod / HYSTERIA     ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
    echo ""

    read -r -p "Usuario UDP: " usuario
    read -r -p "Contraseña UDP: " clave
    read -r -p "Días de duración: " dias

    if [[ -z "$usuario" || -z "$clave" || -z "$dias" ]]; then
        echo -e "${ROJO}Datos incompletos.${RESET}"
        pausa
        return
    fi

    if ! [[ "$dias" =~ ^[0-9]+$ ]]; then
        echo -e "${ROJO}Los días deben ser número.${RESET}"
        pausa
        return
    fi

    expira=$(date -d "+$dias days" +%Y-%m-%d 2>/dev/null)

    if [[ -z "$expira" ]]; then
        echo -e "${ROJO}No se pudo calcular fecha de expiración.${RESET}"
        pausa
        return
    fi

    grep -v "^${usuario}|" "$DB" > "$DB.tmp" 2>/dev/null || true
    mv "$DB.tmp" "$DB"

    echo "${usuario}|${clave}|${expira}" >> "$DB"

    sync_udp_config

    clear
    echo -e "${VERDE}Usuario UDPMod creado correctamente.${RESET}"
    echo ""
    echo -e "${CYAN}Usuario:${RESET} $usuario"
    echo -e "${CYAN}Contraseña:${RESET} $clave"
    echo -e "${CYAN}Expira:${RESET} $expira"
    echo -e "${CYAN}OBFS:${RESET} DarkZsaid"
    echo -e "${CYAN}Puerto real:${RESET} 36712"
    echo ""
    pausa
}

listar_usuarios_udp() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║           USUARIOS UDPMod / HYSTERIA       ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
    echo ""

    if [[ ! -s "$DB" ]]; then
        echo -e "${AMARILLO}No hay usuarios UDPMod guardados.${RESET}"
    else
        printf "%-5s %-18s %-18s %-15s\n" "N°" "USUARIO" "CONTRASEÑA" "EXPIRA"
        echo "------------------------------------------------------------"
        n=1
        while IFS='|' read -r user pass exp; do
            [[ -z "$user" ]] && continue
            printf "%-5s %-18s %-18s %-15s\n" "$n" "$user" "$pass" "$exp"
            n=$((n+1))
        done < "$DB"
    fi

    echo ""
    echo "Auth actual en /etc/udpmod/config.json:"
    grep -A30 '"auth"' "$CONFIG" 2>/dev/null || true
    pausa
}

eliminar_usuario_udp() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║          ELIMINAR USUARIO UDPMod           ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
    echo ""

    if [[ ! -s "$DB" ]]; then
        echo -e "${AMARILLO}No hay usuarios UDPMod para eliminar.${RESET}"
        pausa
        return
    fi

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

    sync_udp_config

    echo -e "${VERDE}Usuario UDPMod eliminado: $usuario${RESET}"
    pausa
}

while true; do
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║        USUARIOS UDPMod / HYSTERIA          ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${ROJO}[1]${RESET} Crear usuario UDPMod"
    echo -e "${ROJO}[2]${RESET} Ver usuarios UDPMod"
    echo -e "${ROJO}[3]${RESET} Eliminar usuario UDPMod"
    echo -e "${ROJO}[4]${RESET} Sincronizar usuarios con UDPMod"
    echo -e "${ROJO}[0]${RESET} Volver"
    echo ""
    read -r -p "Opción: " op

    case "$op" in
        1|01) crear_usuario_udp ;;
        2|02) listar_usuarios_udp ;;
        3|03) eliminar_usuario_udp ;;
        4|04) sync_udp_config; pausa ;;
        0|00) exit 0 ;;
        *) echo "Opción inválida."; sleep 1 ;;
    esac
done
