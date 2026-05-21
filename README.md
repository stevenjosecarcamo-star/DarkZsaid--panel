# DarkZsaid Panel v1.0 Beta

Panel premium para administración de VPS con SSH, SSL, UDP Custom, ZiVPN, BadVPN, Dropbear, Stunnel y herramientas de gestión.

## Instalación

Ejecuta como root en una VPS limpia:

wget -q -O install-public.sh "https://raw.githubusercontent.com/DarkZsaid/DarkZsaid-panel/main/install-public.sh" && chmod +x install-public.sh && bash install-public.sh

## Abrir panel

menu

o:

darkzsaid

## Protocolos incluidos

- SSH
- SSL / Stunnel 443
- Dropbear
- UDP Custom para HTTP Custom
- ZiVPN
- UDP Hysteria / UDPMod
- BadVPN UDPGW
- SOCKS Python Directo WS
- Panel Web 3X-UI

## Puertos principales

SSH: 22  
DNS: 53  
SOCKS / WS: 80  
SSL / Stunnel: 443  
UDP Custom: 36712  
ZiVPN: 5667  
BadVPN: 7300  

## Actualizar

cd /opt/darkzsaid
git pull origin main
cp panel.sh /usr/local/bin/menu
cp panel.sh /usr/local/bin/darkzsaid 2>/dev/null || true
chmod +x /usr/local/bin/menu /usr/local/bin/darkzsaid
menu

## Personalización

El logo superior se cambia desde:

<7> LOGO SUPERIOR

La línea del creador queda fija:

Gestor VPN/SSH by @DarkZsaid ◆ v1.0
