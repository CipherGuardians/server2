
#!/bin/bash

apt update && apt upgrade -y
apt install -y curl gnupg2 apt-transport-https

mkdir -p /etc/apt/keyrings
curl -fsSL https://sing-box.app/gpg.key -o /etc/apt/keyrings/sagernet.asc
chmod a+r /etc/apt/keyrings/sagernet.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/sagernet.asc] https://deb.sagernet.org/ * *" > /etc/apt/sources.list.d/sagernet.list

apt update && apt install -y sing-box

cat > /etc/sing-box/config.json <<EOF
{
  "log": { "level": "info" },
  "inbounds": [
    {
      "type": "shadowsocks",
      "tag": "in-ss",
      "listen": "0.0.0.0",
      "listen_port": 2443,
      "method": "2022-blake3-aes-256-gcm",
      "password": "noI3Pm4FEcM7gTg/gzKV2xaHEkUyAm3EUuKWS+1pkTM=",
      "sniff": false
    }
  ],
  "outbounds": [
    {
      "type": "shadowsocks",
      "tag": "out-ss",
      "server":"45.32.20.216",
      "server_port": 3443,
      "method": "2022-blake3-aes-256-gcm",
      "password": "noI3Pm4FEcM7gTg/gzKV2xaHEkUyAm3EUuKWS+1pkTM="
    }
  ]
}
EOF

ufw allow 2443/tcp
ufw allow 2443/udp
iptables -I INPUT -p tcp --dport 2443 -j ACCEPT
iptables -I INPUT -p udp --dport 2443 -j ACCEPT

systemctl enable sing-box --now
