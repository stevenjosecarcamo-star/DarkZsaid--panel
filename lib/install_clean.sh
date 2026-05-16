#!/bin/bash

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
CYAN="\e[36m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

LOG_DIR="/opt/darkzsaid/logs"
mkdir -p "$LOG_DIR"
INSTALL_LOG="$LOG_DIR/install-clean.log"
: > "$INSTALL_LOG"

clean_title() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
    printf "${CYAN}║${RESET} ${BLANCO}${BOLD}%-48s${RESET} ${CYAN}║${RESET}\n" "$1"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

clean_task() {
    local msg="$1"
    local cmd="$2"

    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    bash -c "$cmd" >> "$INSTALL_LOG" 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local c="${spin:i++%${#spin}:1}"
        echo -ne "\r${CYAN}${c}${RESET} ${AMARILLO}${msg}...${RESET} "
        sleep 0.12
    done

    wait "$pid"
    local status=$?

    if [[ $status -eq 0 ]]; then
        echo -e "\r${VERDE}✓${RESET} ${BLANCO}${msg}${RESET}                      "
        return 0
    else
        echo -e "\r${ROJO}✗${RESET} ${BLANCO}${msg}${RESET}                      "
        echo ""
        echo -e "${ROJO}${BOLD}Error durante:${RESET} $msg"
        echo -e "${AMARILLO}Revisa el log:${RESET} $INSTALL_LOG"
        return 1
    fi
}

clean_task_soft() {
    local msg="$1"
    local cmd="$2"

    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    bash -c "$cmd" >> "$INSTALL_LOG" 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local c="${spin:i++%${#spin}:1}"
        echo -ne "\r${CYAN}${c}${RESET} ${AMARILLO}${msg}...${RESET} "
        sleep 0.12
    done

    wait "$pid" >/dev/null 2>&1 || true

    echo -e "\r${VERDE}✓${RESET} ${BLANCO}${msg}${RESET}                      "
    return 0
}

clean_done() {
    echo ""
    echo -e "${VERDE}${BOLD}✓ Proceso completado correctamente.${RESET}"
    echo ""
}

clean_fail() {
    echo ""
    echo -e "${ROJO}${BOLD}✗ El proceso tuvo un error.${RESET}"
    echo -e "${AMARILLO}Log:${RESET} $INSTALL_LOG"
    echo ""
}

clean_info() {
    echo -e "${CYAN}$1${RESET}"
}

clean_ok() {
    echo -e "${VERDE}$1${RESET}"
}

clean_error() {
    echo -e "${ROJO}$1${RESET}"
}

clean_kill_port80() {
    for s in darkzsaid-ws80 ssh-ws socks-python-ws@80.service socks-ws socks-python socks-python-ws python-ws nginx; do
        systemctl stop "$s" >> "$INSTALL_LOG" 2>&1 || true
        systemctl disable "$s" >> "$INSTALL_LOG" 2>&1 || true
        systemctl reset-failed "$s" >> "$INSTALL_LOG" 2>&1 || true
    done

    PIDS=$(ss -ltnp 2>/dev/null | awk '/:80 / {print $NF}' | grep -oP 'pid=\K[0-9]+' | sort -u)

    if [[ -n "$PIDS" ]]; then
        kill -9 $PIDS >> "$INSTALL_LOG" 2>&1 || true
    fi

    pkill -9 -f "python2 /opt/darkzsaid/ssh-ws-direct.py" >> "$INSTALL_LOG" 2>&1 || true
    pkill -9 -f "python3 /opt/darkzsaid/ssh-ws-direct.py" >> "$INSTALL_LOG" 2>&1 || true
    pkill -9 -f "/opt/darkzsaid/socks-python-ws.py" >> "$INSTALL_LOG" 2>&1 || true

    return 0
}
