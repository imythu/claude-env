FROM ubuntu:24.04

ARG MIHOMO_VERSION=v1.19.20
ARG LOOKLOOK_CACHE=manual
ENV DEBIAN_FRONTEND=noninteractive
ENV LOOKLOOK_PREFIX=/usr/local/lib/looklook
ENV PATH=/root/.local/bin:${PATH}

COPY apply-docker.sh /usr/local/bin/apply-docker.sh

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl gzip iproute2 iptables locales git openssh-client build-essential ripgrep less procps python3 tzdata && \
    locale-gen en_US.UTF-8 && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g @anthropic-ai/claude-code @openai/codex && \
    arch="amd64" && curl -fsSL "https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-linux-${arch}-${MIHOMO_VERSION}.gz" -o /tmp/mihomo.gz && \
    gunzip /tmp/mihomo.gz && install -m 0755 /tmp/mihomo /usr/local/bin/mihomo && rm -f /tmp/mihomo && \
    echo "Looklook cache: ${LOOKLOOK_CACHE}" && curl -fsSL https://looklook.dev/install.sh | sh && \
    curl -fsSL https://claudeflag.com/install-cli.sh | sh && \
    git clone --depth 1 https://github.com/yiancode/fuck-claude.git /opt/fuck-claude && \
    cp /usr/local/bin/apply-docker.sh /opt/fuck-claude/bin/apply-docker.sh && \
    chmod +x /opt/fuck-claude/bin/*.sh && \
    mkdir -p /usr/local/share/looklook-backup && cp -a /usr/local/lib/looklook/. /usr/local/share/looklook-backup/ && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY looklook-watch.sh /usr/local/bin/looklook-watch.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/looklook-watch.sh /usr/local/bin/apply-docker.sh && mkdir -p /etc/mihomo /workspace /var/lib/looklook-backup

EXPOSE 7890
VOLUME ["/workspace"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
