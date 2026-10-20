# Docker dev proxy

This image provides a local HTTP/SOCKS proxy backed by an upstream SOCKS5 server. Configure only the upstream connection; the container listens on port `7890`.

```bash
cp .env.example .env
# edit SOCKS_SERVER, SOCKS_PORT and optional credentials
docker compose up -d --build
```

The container keeps the HTTP/SOCKS proxy on its internal `7890` port and does not publish that port to the host by default. Add `ports: ["7890:7890"]` only when host access is needed. The image enables Mihomo TUN mode and DNS interception; Docker must be started with `NET_ADMIN`, `NET_RAW`, and `/dev/net/tun` (the included Compose file already sets these). The image is built automatically by GitHub Actions and published to GHCR on every release or push to `main`.

## Optional Looklook client

The host-side `install-docker.sh` needs the Docker CLI and cannot run inside this container. Set `LOOKLOOK_AUTO_LOGIN=1` in `.env` to install the official client and start its login flow asynchronously at startup. Check `/tmp/looklook-bootstrap.log` and complete interactive sign-in with `docker exec -it dev-proxy looklook login`.
