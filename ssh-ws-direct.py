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
    return (
        d.startswith("GET ") or d.startswith("POST ") or d.startswith("CONNECT ") or
        d.startswith("OPTIONS ") or d.startswith("HTTP/") or
        "HOST:" in d or "UPGRADE:" in d or "HTTP/" in d
    )

def tunnel(client, remote):
    sockets = [client, remote]
    try:
        while True:
            readable, _, errors = select.select(sockets, [], sockets, 180)
            if errors or not readable:
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
    try: client.close()
    except: pass
    try: remote.close()
    except: pass

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
        try: client.close()
        except: pass

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
