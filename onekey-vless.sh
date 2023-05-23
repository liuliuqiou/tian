#!/bin/bash

uuid=ffffffff-ffff-ffff-ffff-ffffffffffff
read -p "Domain? >" domain
## update system
apt update -y 

## install curl wget unzip git 
apt install curl wget unzip debian-keyring debian-archive-keyring apt-transport-https gnupg -y
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt update -y
apt install caddy nano -y

# install xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
cat > /usr/local/etc/xray/config.json << EOF
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": 1325,
            "listen": "127.0.0.1",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$uuid", //UUID
                        "level": 0,
                        "email": "fck_v@dyns.tk"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "/Haoba!2053" 
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF
cat > /etc/caddy/Caddyfile << EOF

http://$domain {
        root * /usr/share/caddy
        file_server
        reverse_proxy /up2ws 127.0.0.1:1325
}
EOF
systemctl reload caddy
systemctl enable xray --now
clear
echo "vless://$uuid@$domain:443?encryption=none&security=tls&sni=$domain&type=ws&host=$domain&path=%2fup2ws#Vless+WS"
rm -f $0
