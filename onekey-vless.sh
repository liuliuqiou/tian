#!/bin/bash

# 提示用户输入Domain Name
read -p "请输入 Domain Name（例如example.com）: " domain

# 生成随机的path
path="Haoba!2053"

# 安装Caddy
curl https://getcaddy.com | bash -s personal tls.dns.cloudflare

# 生成Caddy配置文件
cat > /etc/caddy/Caddyfile << EOF
{
    email fck_v@dyns.tk
}

$domain {
    tls {
        dns cloudflare
    }
    encode gzip

    reverse_proxy /$path 127.0.0.1:443 {
        header_upstream -Origin
    }
}
EOF

# 安装Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root

# 生成Xray配置文件
cat > /usr/local/etc/xray/config.json << EOF
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "ffffffff-ffff-ffff-ffff-ffffffffffff",
                        "flow": "xtls-rprx-direct",
                        "level": 0
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/$path"
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

# 启动Caddy和Xray服务
systemctl enable caddy
systemctl start caddy
systemctl enable xray
systemctl start xray

# 显示VLESS URL
echo "VLESS URL: vless://ffffffff-ffff-ffff-ffff-ffffffffffff@$domain:443?encryption=none&security=tls&sni=$domain&type=ws&path=/$path#VLESS-WebSocket"

# 删除脚本文件
rm -- "$0"
