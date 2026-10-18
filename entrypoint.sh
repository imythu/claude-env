#!/usr/bin/env bash
set -euo pipefail
: "${SOCKS_SERVER:?Set SOCKS_SERVER, for example proxy.example.com}"
: "${SOCKS_PORT:?Set SOCKS_PORT, for example 13579}"

cat > /etc/mihomo/config.yaml <<EOF
mixed-port: 7890
allow-lan: false
mode: rule
log-level: info
ipv6: false
proxies:
  - name: upstream
    type: socks5
    server: ${SOCKS_SERVER}
    port: ${SOCKS_PORT}
    username: ${SOCKS_USERNAME:-}
    password: ${SOCKS_PASSWORD:-}
    udp: true
proxy-groups:
  - name: GLOBAL
    type: select
    proxies: [upstream]
rules:
  - DOMAIN-SUFFIX,lan,DIRECT
  - DOMAIN-SUFFIX,local,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
  - IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
  - IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
  - MATCH,GLOBAL
EOF

export http_proxy="${HTTP_PROXY:-http://127.0.0.1:7890}"
export https_proxy="${HTTPS_PROXY:-http://127.0.0.1:7890}"
export all_proxy="${ALL_PROXY:-socks5://127.0.0.1:7890}"
exec mihomo -d /etc/mihomo
