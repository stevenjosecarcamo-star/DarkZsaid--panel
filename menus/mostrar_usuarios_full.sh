#!/bin/bash

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
AZUL="\e[34m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"

USERDIR="/etc/adm-lite/userDIR"
HOY_SEC=$(date +%s)

dias_restantes() {
    local fecha="$1"

    if [ -z "$fecha" ] || [ "$fecha" = "-" ]; then
        echo "-"
        return
    fi

    fecha_sec=$(date -d "$fecha" +%s 2>/dev/null || echo 0)

    if [ "$fecha_sec" -eq 0 ]; then
        echo "-"
        return
    fi

    diff=$(( (fecha_sec - HOY_SEC) / 86400 ))

    if [ "$diff" -lt 0 ]; then
        echo "EXP"
    else
        echo "$diff"
    fi
}

clear
echo -e "${CYAN}======>>> 🐉 DarkZsaid 💥 Plus 🐉 <<<======${RESET}"
echo ""
echo -e "${AMARILLO}────────────────────────────────────────────${RESET}"
echo -e "${AMARILLO}🔐 ADMINISTRADOR DE USUARIOS SSH|SSL|DROPBEAR 🔐${RESET}"
echo -e "${AZUL}  ▸ M LIBRE: $(free -m | awk '/Mem:/ {print int(($4)/1024)"G"}')   ▸ USO DE CPU: $(top -bn1 | awk -F'id,' '/Cpu/ {split($1,a,","); print int(100-a[length(a)])"%"}' 2>/dev/null || echo "0%")${RESET}"
echo -e "${AMARILLO}────────────────────────────────────────────${RESET}"
echo ""
echo -e "${AMARILLO}────────────────────────────────────────────${RESET}"
printf "${AZUL}%-5s %-13s %-14s %-10s %-8s${RESET}\n" "➜" "USUARIO" "CONTRASEÑA" "LIMITE" "CADUCA"
echo -e "${AMARILLO}────────────────────────────────────────────${RESET}"

total=0
tk=0

if [ -d "$USERDIR" ]; then
    for archivo in "$USERDIR"/*; do
        [ -f "$archivo" ] || continue

        nombre_archivo=$(basename "$archivo")

        usuario="$(grep -m1 '^usuario:' "$archivo" 2>/dev/null | cut -d':' -f2- | xargs)"
        senha="$(grep -m1 '^senha:' "$archivo" 2>/dev/null | cut -d':' -f2- | xargs)"
        token="$(grep -m1 '^token:' "$archivo" 2>/dev/null | cut -d':' -f2- | xargs)"
        limite="$(grep -m1 '^limite:' "$archivo" 2>/dev/null | cut -d':' -f2- | xargs)"
        data="$(grep -m1 '^data:' "$archivo" 2>/dev/null | cut -d':' -f2- | xargs)"

        [ -z "$usuario" ] && usuario="$nombre_archivo"
        [ -z "$senha" ] && senha="-"
        [ -z "$limite" ] && limite="-"
        [ -z "$data" ] && data="-"

        caduca="$(dias_restantes "$data")"

        total=$((total+1))

        if [ "$limite" = "TOKEN" ]; then
            tk=$((tk+1))
            [ -z "$token" ] && token="$senha"

            printf "${ROJO}[%s]>${RESET} %-13s %-14s ${ROJO}%-10s${RESET} ${VERDE}%-8s${RESET}\n" "$total" "$usuario" "" "TK$tk" "$caduca"
            echo -e "     ${CYAN}↪ TOKEN -${RESET} ${ROJO}$token${RESET}"

        elif [ "$limite" = "HWID" ]; then
            printf "${ROJO}[%s]>${RESET} %-13s %-14s ${ROJO}%-10s${RESET} ${VERDE}%-8s${RESET}\n" "$total" "$usuario" "" "HWID" "$caduca"
            echo -e "     ${CYAN}↪ HWID -${RESET} ${ROJO}$senha${RESET}"

        else
            printf "${ROJO}[%s]>${RESET} %-13s ${ROJO}%-14s${RESET} ${VERDE}%-10s${RESET} ${VERDE}%-8s${RESET}\n" "$total" "$usuario" "$senha" "$limite" "$caduca"
        fi
    done
fi

echo -e "${AMARILLO}────────────────────────────────────────────${RESET}"
echo -e "${VERDE}🛡 # TIENES [ $total ] CLIENTES EN TU SERVIDOR 🛡 #${RESET}"
echo -e "${AMARILLO}────────────────────────────────────────────${RESET}"
echo ""
read -p "Presiona ENTER para continuar..."
