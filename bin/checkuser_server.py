#!/usr/bin/env python3
import json
import os
import urllib.parse
from datetime import datetime, date
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.environ.get("CHECKUSER_PORT", "2095"))
DB = "/opt/darkzsaid/data/usuarios_ssh.db"

def parse_date(txt):
    txt = (txt or "").strip()
    for fmt in ("%Y-%m-%d", "%d/%m/%Y", "%d-%m-%Y"):
        try:
            return datetime.strptime(txt, fmt).date()
        except:
            pass
    return None

def buscar(valor):
    valor = (valor or "").strip()
    if not valor:
        return None

    if not os.path.isfile(DB):
        return None

    with open(DB, "r", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line or "|" not in line:
                continue

            p = line.split("|")
            c1 = p[0].strip() if len(p) > 0 else ""
            c2 = p[1].strip() if len(p) > 1 else ""
            c3 = p[2].strip() if len(p) > 2 else ""
            c4 = p[3].strip() if len(p) > 3 else ""

            if c4.upper() == "TOKEN":
                token = c1
                usuario = c2
                fecha = c3
                tipo = "TOKEN"
            else:
                token = c1
                usuario = c1
                fecha = c3
                tipo = "NORMAL"

            if valor == token or valor == usuario:
                d = parse_date(fecha)
                if d:
                    dias = (d - date.today()).days
                    expira = d.strftime("%Y-%m-%d")
                else:
                    dias = 0
                    expira = ""

                return {
                    "token": token,
                    "Token": token,
                    "TOKEN": token,

                    "usuario": usuario,
                    "user": usuario,
                    "username": usuario,

                    "expira": expira,
                    "Expira": expira,
                    "EXPIRA": expira,
                    "expire": expira,
                    "expires": expira,
                    "expiration": expira,
                    "vencimiento": expira,
                    "fecha": expira,
                    "fecha_expira": expira,
                    "fecha_vencimiento": expira,
                    "expiration_date": expira,
                    "expirationDate": expira,
                    "expiry_date": expira,
                    "expiryDate": expira,
                    "expireDate": expira,

                    "dias": str(dias),
                    "Dias": str(dias),
                    "DIAS": str(dias),
                    "tequedan": str(dias),
                    "teQuedan": str(dias),
                    "TeQuedan": str(dias),
                    "te_quedan": str(dias),
                    "dias_restantes": str(dias),
                    "remainingDays": str(dias),
                    "daysRemaining": str(dias),
                    "days_left": str(dias),
                    "leftDays": str(dias),

                    "estado": "ACTIVO",
                    "status": "ACTIVO",
                    "success": True,
                    "ok": True,
                    "found": True,
                    "tipo": tipo
                }

    return None

class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print("%s - %s" % (self.address_string(), fmt % args), flush=True)

    def responder(self, data, code=200):
        body = json.dumps(data, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def obtener_valor(self):
        parsed = urllib.parse.urlparse(self.path)
        q = urllib.parse.parse_qs(parsed.query)

        valor = (
            q.get("token", [""])[0]
            or q.get("user", [""])[0]
            or q.get("usuario", [""])[0]
            or q.get("username", [""])[0]
        )

        if self.command == "POST":
            length = int(self.headers.get("Content-Length", "0") or 0)
            body = self.rfile.read(length).decode(errors="ignore") if length else ""

            if body:
                try:
                    js = json.loads(body)
                    valor = (
                        js.get("token", "")
                        or js.get("user", "")
                        or js.get("usuario", "")
                        or js.get("username", "")
                        or valor
                    )
                except:
                    form = urllib.parse.parse_qs(body)
                    valor = (
                        form.get("token", [""])[0]
                        or form.get("user", [""])[0]
                        or form.get("usuario", [""])[0]
                        or form.get("username", [""])[0]
                        or body.strip()
                        or valor
                    )

        print(f"CHECKUSER valor={valor}", flush=True)
        return valor

    def do_OPTIONS(self):
        self.responder({"ok": True})

    def do_GET(self):
        self.handle()

    def do_POST(self):
        self.handle()

    def handle(self):
        valor = self.obtener_valor()
        r = buscar(valor)

        if r:
            self.responder(r, 200)
        else:
            self.responder({
                "token": valor,
                "expira": "",
                "Expira": "",
                "dias": "0",
                "TeQuedan": "0",
                "estado": "NO_EXISTE",
                "success": False,
                "ok": False
            }, 404)

if __name__ == "__main__":
    print(f"DarkZsaid CheckUser simple activo puerto {PORT}", flush=True)
    HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
