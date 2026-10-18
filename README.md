# Docker dev proxy

This image provides a local HTTP/SOCKS proxy backed by an upstream SOCKS5 server. Configure only the upstream connection; the container listens on port `7890`.

```bash
cp .env.example .env
# edit SOCKS_SERVER, SOCKS_PORT and optional credentials
docker compose up -d --build
```

Use `http://127.0.0.1:7890` for HTTP/HTTPS traffic and `socks5://127.0.0.1:7890` for SOCKS traffic. The image is built automatically by GitHub Actions and published to GHCR on every release or push to `main`.
