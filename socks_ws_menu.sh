#!/bin/bash
[[ -f /opt/darkzsaid/lib/puertas_reales.sh ]] && source /opt/darkzsaid/lib/puertas_reales.sh

ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
AZUL="\e[34m"
BLANCO="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

IP="216.238.113.15"

pausa() {
    echo ""
    read -p "Presiona ENTER para continuar..."
}

titulo() {
    clear
    echo -e "${ROJO}══════════════════════════ / / / ══════════════════════════${RESET}"
    echo -e "${BLANCO}${BOLD}          $1${RESET}"
    echo -e "${ROJO}══════════════════════════ / / / ══════════════════════════${RESET}"
    echo ""
}

instalar_ws() {
    titulo "ACTIVAR SOCKS PYTHON DIRECTO WS"

    if ! command -v python2 >/dev/null 2>&1; then
        echo "Python2 no está instalado."
        echo "Instala Python2 antes de activar este módulo."
        pausa
        return
    fi

    echo "Liberando puerto 80..."

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

    cat > /etc/systemd/system/ssh-ws.service <<'EOFSERVICE'
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
EOFSERVICE

    ufw allow 80/tcp 2>/dev/null || true
    ufw allow 22/tcp 2>/dev/null || true

    systemctl daemon-reload
    systemctl enable ssh-ws
    systemctl restart ssh-ws

    echo ""
    echo -e "${VERDE}SOCKS PYTHON DIRECTO WS activado.${RESET}"
    echo ""
    ss -tulnp | grep ':80' || echo "Puerto 80 no está escuchando."
    pausa
}

detener_ws() {
    titulo "DETENER SOCKS PYTHON DIRECTO WS"

    systemctl stop ssh-ws 2>/dev/null

    echo "Servicio detenido."
    echo ""
    ss -tulnp | grep ':80' || echo "Puerto 80 libre."
    pausa
}

reiniciar_ws() {
    titulo "REINICIAR SOCKS PYTHON DIRECTO WS"

    systemctl restart ssh-ws 2>/dev/null

    echo "Servicio reiniciado."
    echo ""
    ss -tulnp | grep ':80' || echo "Puerto 80 no está escuchando."
    pausa
}

remover_ws() {
    titulo "REMOVER SOCKS PYTHON DIRECTO WS"

    read -p "¿Seguro que quieres removerlo? [s/n]: " r

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

    echo "Removido."
    echo ""
    ss -tulnp | grep ':80' || echo "Puerto 80 libre."
    pausa
}

estado_ws() {
    titulo "ESTADO SOCKS PYTHON DIRECTO WS"

    echo -e "${AMARILLO}Servicio:${RESET}"
    systemctl is-active ssh-ws 2>/dev/null || echo "inactive"

    echo ""
    echo -e "${AMARILLO}Puerto 80:${RESET}"
    ss -tulnp | grep ':80' || echo "Puerto 80 no está escuchando."

    echo ""
    echo -e "${AMARILLO}Response:${RESET}"
    grep 'Connection established' /opt/darkzsaid/ssh-ws-direct.py 2>/dev/null || echo "No instalado."

    echo ""
    echo -e "${VERDE}Datos:${RESET}"
    echo "Host/IP: $IP"
    echo "Puerto: 80"
    echo "SSH Host: $IP"
    echo "SSH Puerto: 22"
    echo "Response: HTTP/1.1 200 Connection established ADM SJCC"
    pausa
}

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
        1) instalar_ws ;;
        2) detener_ws ;;
        3) reiniciar_ws ;;
        4) remover_ws ;;
        5) estado_ws ;;
        6) journalctl -u ssh-ws -n 80 --no-pager -l; pausa ;;
        0) exit 0 ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
