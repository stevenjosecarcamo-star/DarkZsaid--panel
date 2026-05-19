#!/bin/bash

VERDE="\e[32m"
ROJO="\e[31m"
AMARILLO="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

echo -e "${CYAN}===== INSTALANDO UDP CUSTOM HTTP CUSTOM =====${RESET}"

apt-get update -y
apt-get install -y curl iptables libpam0g

ARCH=$(uname -m)

if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    BIN_URL="https://github.com/firewallfalcons/FirewallFalcon-Manager/raw/main/udp/udp-custom-linux-arm"
else
    BIN_URL="https://github.com/firewallfalcons/FirewallFalcon-Manager/raw/main/udp/udp-custom-linux-amd64"
fi

echo -e "${AMARILLO}Descargando binario UDP Custom...${RESET}"
curl -L -s -f -o /usr/bin/udp "$BIN_URL"

if [[ ! -s /usr/bin/udp ]]; then
    echo -e "${ROJO}❌ Error descargando /usr/bin/udp${RESET}"
    exit 1
fi

chmod +x /usr/bin/udp

cat > /usr/bin/config.json <<'JSON'
{
  "listen": ":36712",
  "stream_buffer": 8388608,
  "receive_buffer": 8388608,
  "auth": {
    "mode": "passwords"
  }
}
JSON

cat > /etc/systemd/system/udp-custom.service <<'EOF2'
[Unit]
Description=UDP Custom HTTP Custom
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/udp server --exclude 22,80,443,7300,7100,7200 /usr/bin/config.json
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF2

ufw allow 36712/udp >/dev/null 2>&1 || true
iptables -I INPUT -p udp --dport 36712 -j ACCEPT 2>/dev/null || true

systemctl daemon-reload
systemctl enable udp-custom >/dev/null 2>&1
systemctl restart udp-custom

sleep 1

if systemctl is-active --quiet udp-custom && ss -ulnp | grep -q ":36712"; then
    echo -e "${VERDE}✅ UDP Custom instalado y activo en puerto 36712${RESET}"
else
    echo -e "${ROJO}❌ UDP Custom no levantó correctamente${RESET}"
    systemctl status udp-custom --no-pager
fi
