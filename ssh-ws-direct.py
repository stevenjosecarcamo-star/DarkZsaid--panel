#!/usr/bin/env python3
import socket
import threading
import select
import sys

LISTEN_HOST = "0.0.0.0"
LISTEN_PORT = 80

SSH_HOST = "127.0.0.1"
SSH_PORT = 22

RESPONSE_200 = (
    "HTTP/1.1 200 Connection established ADM SJCC\r\n"
    "Connection: keep-alive\r\n"
    "Proxy-Agent: ADM SJCC\r\n"
    "\r\n"
).encode()

BUFFER_SIZE = 65535


def pipe(src, dst):
    try:
        while True:
            data = src.recv(BUFFER_SIZE)
            if not data:
                break
            dst.sendall(data)
    except Exception:
        pass
    finally:
        try:
            src.close()
        except Exception:
            pass
        try:
            dst.close()
        except Exception:
            pass


def handle_client(client, addr):
    ssh = None
    try:
        client.settimeout(10)

        # Leer payload HTTP/WebSocket inicial
        try:
            data = client.recv(BUFFER_SIZE)
        except Exception:
            data = b""

        # Responder 200 Establish siempre que haya un payload inicial
        if data:
            client.sendall(RESPONSE_200)

        # Conectar al SSH local
        ssh = socket.create_connection((SSH_HOST, SSH_PORT), timeout=10)

        # Si el cliente envió datos después del header, no los reenviamos como HTTP.
        # Desde aquí empieza el túnel SSH limpio.
        client.settimeout(None)
        ssh.settimeout(None)

        t1 = threading.Thread(target=pipe, args=(client, ssh), daemon=True)
        t2 = threading.Thread(target=pipe, args=(ssh, client), daemon=True)

        t1.start()
        t2.start()

        t1.join()
        t2.join()

    except Exception:
        try:
            client.close()
        except Exception:
            pass
        try:
            if ssh:
                ssh.close()
        except Exception:
            pass


def main():
    print("DarkZsaid SSH WS Direct 200 Establish")
    print(f"Escuchando en {LISTEN_HOST}:{LISTEN_PORT}")
    print(f"Redirigiendo a {SSH_HOST}:{SSH_PORT}")

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LISTEN_HOST, LISTEN_PORT))
    server.listen(500)

    while True:
        client, addr = server.accept()
        threading.Thread(target=handle_client, args=(client, addr), daemon=True).start()


if __name__ == "__main__":
    main()
