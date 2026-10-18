# Docker dev proxy

This image provides a local HTTP/SOCKS proxy backed by an upstream SOCKS5 server. Configure only the upstream connection; the container listens on port `7890`.

```bash
cp .env.example .env
# edit SOCKS_SERVER, SOCKS_PORT and optional credentials
docker compose up -d --build
```

Use `http://127.0.0.1:7890` for HTTP/HTTPS traffic and `socks5://127.0.0.1:7890` for SOCKS traffic. The image is built automatically by GitHub Actions and published to GHCR on every release or push to `main`.

## Optional Looklook client

The host-side `install-docker.sh` needs the Docker CLI and cannot run inside this container. Set `LOOKLOOK_AUTO_LOGIN=1` in `.env` to install the official client and start its login flow asynchronously at startup. Check `/tmp/looklook-bootstrap.log` and complete interactive sign-in with `docker exec -it dev-proxy looklook login`.
