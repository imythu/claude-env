FROM ubuntu:24.04

ARG MIHOMO_VERSION=v1.19.20
ARG LOOKLOOK_CACHE=manual
ENV DEBIAN_FRONTEND=noninteractive
ENV LOOKLOOK_PREFIX=/usr/local/lib/looklook

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl gzip iproute2 iptables locales git openssh-client build-essential ripgrep less procps tzdata && \
    locale-gen en_US.UTF-8 && \
    arch="amd64" && curl -fsSL "https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-linux-${arch}-${MIHOMO_VERSION}.gz" -o /tmp/mihomo.gz && \
    gunzip /tmp/mihomo.gz && install -m 0755 /tmp/mihomo /usr/local/bin/mihomo && rm -f /tmp/mihomo && \
    echo "Looklook cache: ${LOOKLOOK_CACHE}" && curl -fsSL https://looklook.dev/install.sh | sh && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && mkdir -p /etc/mihomo /workspace

EXPOSE 7890
VOLUME ["/workspace"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
