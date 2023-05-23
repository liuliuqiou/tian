#!/bin/bash

echo "Please enter your domain name:"
read domain

echo "Please enter your UUID:"
read uuid

echo "Deploying Xray+caddy+tls+websocket+vless..."

cat > Procfile <<EOF
web: /app/.apt/usr/bin/caddy run --config /app/Caddyfile
EOF

cat > Caddyfile <<EOF
$domain {
  tls {
    dns cloudflare
  }
  reverse_proxy /Haoba!2053 localhost:10086 {
    header_up Host {host}
    header_up X-Real-IP {remote}
    header_up X-Forwarded-For {remote}
    header_up X-Forwarded-Port {server_port}
    header_up X-Forwarded-Proto {scheme}
  }
}

EOF

cat > config.json <<EOF
{
  "inbounds": [
    {
      "port": 10086,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$uuid",
            "flow": "xtls-rprx-direct"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 80,
            "xver": 1
          },
          {
            "path": "/Haoba!2053",
            "dest": 10086,
            "xver": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
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

echo -e "\nDone!"
