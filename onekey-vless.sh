bash
#!/bin/bash

read -p "请输入你的域名(domain):" domain

# 安装必要的软件
apt update
apt install -y unzip curl wget

# 下载并安装Xray
wget https://github.com/XTLS/Xray-install/releases/latest/download/Xray-install.sh
bash Xray-install.sh

# 安装Caddy
wget https://caddyserver.com/v2/download/linux/amd64?license=personal
mv caddy_v2_linux_amd64 /usr/bin/caddy

# 创建Caddy配置文件 
cat > /etc/caddy/Caddyfile <<EOF
$domain {
    reverse_proxy 127.0.0.1:9000
}
EOF

# 生成Xray配置文件
cat > /etc/Xray/config.json <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "ffffffff-ffff-ffff-ffff-ffffffffffff"
          }
        ],
        "decryption": "none", 
        "fallbacks": [
           {
              "dest": 80,
              "xver": 1
           }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "Haoba!2053"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ] 
}
EOF

# 设置Xray开机启动
cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
After=network.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/xray/xray run -confdir /etc/Xray
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable xray

# 启动Caddy和Xray服务
systemctl start caddy
systemctl start xray

# 获取vless的url
vless_url=vless://$(echo -n '{"id": "ffffffff-ffff-ffff-ffff-ffffffffffff", "host": "'$domain'", "port": 443,"net":"ws", "path":"Haoba!2053", "encryption":"none", "security": "tls"}' | base64 -w 0)

# 输出vless的url 
echo "Xray+VLESS服务已成功部署!"  
echo "请使用以下VLESS URL配置您的客户端:"
echo ""$vless_url""
