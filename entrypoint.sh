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
tun:
  enable: true
  device: mihomo0
  stack: mixed
  auto-route: true
  auto-detect-interface: true
  strict-route: true
  dns-hijack:
    - any:53
    - tcp://any:53
  mtu: 1500
dns:
  enable: true
  listen: 127.0.0.1:1053
  ipv6: false
  enhanced-mode: fake-ip
  fake-ip-filter:
    - 4.kleeclub.top
    - '*.lan'
    - '*.local'
  fake-ip-range: 198.18.0.1/16
  respect-rules: true
  default-nameserver:
    - 8.8.8.8
    - 1.1.1.1
  proxy-server-nameserver:
    - 8.8.8.8
    - 1.1.1.1
  nameserver:
    - 'https://1.1.1.1/dns-query#upstream'
    - 'https://8.8.8.8/dns-query#upstream'
rules:
  - DOMAIN,4.kleeclub.top,DIRECT
  # 仅将 Looklook 中继节点走直连
  - DOMAIN,r2.looklook.dev,DIRECT
  - DOMAIN,r3.looklook.dev,DIRECT
  - IP-CIDR,154.219.107.44/32,DIRECT,no-resolve
  - IP-CIDR,47.108.195.230/32,DIRECT,no-resolve
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
    if ! looklook --version >/dev/null 2>&1; then
      LOOKLOOK_PREFIX="${LOOKLOOK_PREFIX:-/usr/local/lib/looklook}" curl -fsSL https://looklook.dev/install.sh | LOOKLOOK_PREFIX="${LOOKLOOK_PREFIX:-/usr/local/lib/looklook}" sh
    fi
    if looklook --version >/dev/null 2>&1; then
      looklook run --no-browser >/tmp/looklook-run.log 2>&1 &
      sleep 2
      looklook login --no-browser </dev/null >/tmp/looklook-login.log 2>&1 || true
    fi
  ) >/tmp/looklook-bootstrap.log 2>&1 &
}
looklook_bootstrap
exec mihomo -d /etc/mihomo
