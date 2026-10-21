# Docker dev proxy

This image provides a local HTTP/SOCKS proxy backed by an upstream SOCKS5 server. Configure only the upstream connection; the container listens on port `7890`.

```bash
cp .env.example .env
# edit SOCKS_SERVER, SOCKS_PORT and optional credentials
docker compose up -d --build
```

The container keeps the HTTP/SOCKS proxy on its internal `7890` port and does not publish that port to the host by default. Add `ports: ["7890:7890"]` only when host access is needed. The image enables Mihomo TUN mode and DNS interception; Docker must be started with `NET_ADMIN`, `NET_RAW`, and `/dev/net/tun` (the included Compose file already sets these). The image is built automatically by GitHub Actions and published to GHCR on every release or push to `main`.

## Optional Looklook client

The image also includes `claudeflag` at `/root/.local/bin/claudeflag` and the `yiancode/fuck-claude` project at `/opt/fuck-claude`. The container copy `/opt/fuck-claude/bin/apply-docker.sh` always runs the Linux repair script with `--force`. It runs once at startup and every hour by default; set `FUCK_CLAUDE_AUTO_APPLY=0` to disable it or change `FUCK_CLAUDE_APPLY_INTERVAL` (seconds). Run a check manually with `docker exec -it dev-proxy /root/.local/bin/claudeflag` and a repair with `docker exec -it dev-proxy /opt/fuck-claude/bin/apply-docker.sh`.

The host-side `install-docker.sh` needs the Docker CLI and cannot run inside this container. Set `LOOKLOOK_AUTO_UPDATE=1` in `.env` to check for and install the latest Looklook client asynchronously at container startup. Set `LOOKLOOK_AUTO_LOGIN=1` to start the login flow as well. The Compose file maps `./looklook/backup` to the Looklook backup directory; a watcher checks the executable every 30 seconds, restores it when missing, and saves upgraded files back to the mapped directory. Check `/tmp/looklook-bootstrap.log` and complete interactive sign-in with `docker exec -it dev-proxy looklook login`.
