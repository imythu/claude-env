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
  # Looklook 登录、升级、下载和远程终端连接走直连
  - DOMAIN-SUFFIX,looklook.dev,DIRECT
  - DOMAIN-SUFFIX,looklook.app,DIRECT
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

looklook_bootstrap() {
  [ "${LOOKLOOK_AUTO_LOGIN:-0}" = "1" ] || return 0
  (
    set +e
    command -v looklook >/dev/null 2>&1 || curl -fsSL https://looklook.dev/install.sh | sh
    if command -v looklook >/dev/null 2>&1; then
      looklook run --no-browser >/tmp/looklook-run.log 2>&1 &
      sleep 2
      looklook login --no-browser </dev/null >/tmp/looklook-login.log 2>&1 || true
    fi
  ) >/tmp/looklook-bootstrap.log 2>&1 &
}
looklook_bootstrap
exec mihomo -d /etc/mihomo
