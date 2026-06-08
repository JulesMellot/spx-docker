#!/bin/sh
set -e

CONFIG_FILE="ASSETS/CONFIG/config.json"

# Source used by SPX-GC to advertise where CasparCG should fetch HTML templates from.
# Defaults to "spx-ip-address" (the container's local IP — fine for a LAN setup).
# When deploying behind a reverse proxy (e.g. Coolify/Traefik) where CasparCG reaches
# SPX-GC over a public domain rather than the LAN, set SPX_TEMPLATE_SOURCE to that
# public URL (e.g. https://spx.example.com) so generated template links resolve correctly.
TEMPLATE_SOURCE="${SPX_TEMPLATE_SOURCE:-spx-ip-address}"

# ── Création des dossiers persistants si absents ──────────────────────────────
mkdir -p /SPX/ASSETS/CONFIG
mkdir -p /SPX/DATAROOT

# ── Génération du config.json au premier lancement ───────────────────────────
if [ ! -f "/SPX/${CONFIG_FILE}" ]; then
    echo "[SPX] Premier lancement — génération de config.json..."
    cat > "/SPX/${CONFIG_FILE}" << EOF
{
    "general": {
        "username": "",
        "password": "",
        "hostname": "SPX",
        "langfile": "english.json",
        "loglevel": "production",
        "port": "5656",
        "dataroot": "/SPX/DATAROOT/",
        "templatesource": "${TEMPLATE_SOURCE}",
        "preview": "selected",
        "renderer": "normal",
        "resolution": "HD",
        "launchchrome": false,
        "disableLocalRenderer": false,
        "disableOpenFolderCommand": true
    },
    "casparcg": {
        "servers": []
    }
}
EOF
    echo "[SPX] config.json créé."
fi

echo "[SPX] Démarrage SPX Graphics Controller 1.4.0..."
exec node /SPX/server.js "${CONFIG_FILE}"
