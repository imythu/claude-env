# Docker dev proxy

This image provides a local HTTP/SOCKS proxy backed by an upstream SOCKS5 server. Configure only the upstream connection; the container listens on port `7890`.

The image includes Node.js 22, Claude Code (`claude`) and Codex (`codex`). After the container starts, verify them with `docker exec -it dev-proxy bash -lc 'node --version; claude --version; codex --version'`.

```bash
cp .env.example .env
# edit SOCKS_SERVER, SOCKS_PORT and optional credentials
docker compose up -d --build
```

The container keeps the HTTP/SOCKS proxy on its internal `7890` port and does not publish that port to the host by default. Add `ports: ["7890:7890"]` only when host access is needed. The image enables Mihomo TUN mode and DNS interception; Docker must be started with `NET_ADMIN`, `NET_RAW`, and `/dev/net/tun` (the included Compose file already sets these). The image is built automatically by GitHub Actions and published to GHCR on every release or push to `main`.

## Looklook client

The image includes the native Looklook client at `/opt/looklook`. It does not install or run any additional repair, backup, scheduler, or task-injection scripts. Use Looklook directly, for example `docker exec -it dev-proxy looklook login` or `docker exec -it dev-proxy looklook run --no-browser`.
