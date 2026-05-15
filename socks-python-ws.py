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
