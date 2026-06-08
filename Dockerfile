# ─────────────────────────────────────────────
#  SPX Graphics Controller — v1.4.0
#  Build from official source (master branch)
# ─────────────────────────────────────────────
FROM node:20-alpine

LABEL description="SPX Graphics Controller 1.4.0" \
      org.opencontainers.image.source="https://github.com/TuomoKu/SPX-GC"

WORKDIR /SPX

# git pour cloner, puis on le supprime pour garder l'image légère
RUN apk add --no-cache git \
    && git clone --depth 1 https://github.com/TuomoKu/SPX-GC.git . \
    && npm ci --omit=dev \
    && apk del git \
    && rm -rf /tmp/* /root/.npm

# Entrypoint : initialise le config + lance le serveur
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Données persistantes à monter en volume :
#   /SPX/ASSETS   → tes templates HTML
#   /SPX/DATAROOT → projets et rundowns
VOLUME ["/SPX/ASSETS", "/SPX/DATAROOT"]

EXPOSE 5656

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:5656 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
