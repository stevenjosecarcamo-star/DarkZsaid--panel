#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import socket
import threading
import select

LISTEN_HOST = "127.0.0.1"
LISTEN_PORT = 8081

LOCAL_HOST = "127.0.0.1"
LOCAL_PORT = 22

RESPONSE_CODE = "101"
MINI_BANNER = "DarkZsaid NGINX WS"

def build_response():
    if RESPONSE_CODE == "101":
        return (
            "HTTP/1.1 101 Switching Protocols\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            "Server: %s\r\n"
            "\r\n"
        ) % MINI_BANNER

    return (
        "HTTP/1.1 200 Connection Established\r\n"
        "Server: %s\r\n"
        "Connection: established\r\n"
        "Content-Length: 0\r\n"
        "\r\n"
    ) % MINI_BANNER

def pipe(client, remote):
    sockets = [client, remote]

    try:
        while True:
            readable, _, error = select.select(sockets, [], sockets, 120)

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
        try:
            first = client.recv(8192)
        except:
            first = ""

        client.sendall(build_response())

        remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        remote.connect((LOCAL_HOST, LOCAL_PORT))

        if first:
            upper = first[:200].upper()

            if not (
                upper.startswith("GET ")
                or upper.startswith("POST ")
                or upper.startswith("CONNECT ")
                or upper.startswith("OPTIONS ")
                or "HTTP/" in upper
            ):
                remote.sendall(first)

        pipe(client, remote)

    except:
        try:
            client.close()
        except:
            pass

def main():
    print("[DarkZsaid NGINX Python2 WS] 127.0.0.1:8081 -> 127.0.0.1:22")

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LISTEN_HOST, LISTEN_PORT))
    server.listen(300)

    while True:
        client, addr = server.accept()
        t = threading.Thread(target=handle_client, args=(client, addr))
        t.daemon = True
        t.start()

if __name__ == "__main__":
    main()
