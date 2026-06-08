# spx-docker

A minimal Docker image for [SPX Graphics Controller](https://github.com/TuomoKu/SPX-GC) (SPX-GC) v1.4.0, built from the official source on each image build.

## What's inside

- `Dockerfile` — builds a lightweight `node:20-alpine` image, clones SPX-GC's `master` branch, installs production dependencies, and runs the controller on port `5656`.
- `entrypoint.sh` — generates a default `config.json` on first launch and starts the server.

## Persistent data

Two volumes should be mounted for persistence:

- `/SPX/ASSETS` — HTML templates and the generated `config.json`
- `/SPX/DATAROOT` — projects and rundowns

## Running locally

```bash
docker build -t spx-gc .
docker run -d \
  -p 5656:5656 \
  -v spx-assets:/SPX/ASSETS \
  -v spx-dataroot:/SPX/DATAROOT \
  spx-gc
```

Then open `http://localhost:5656` in your browser.

## Environment variables

| Variable             | Default          | Description |
|----------------------|------------------|-------------|
| `SPX_TEMPLATE_SOURCE` | `spx-ip-address` | Where SPX-GC tells CasparCG to fetch HTML templates from. The default uses the container's local IP address, which works for a LAN setup where CasparCG and SPX-GC sit on the same network. If CasparCG reaches SPX-GC over a public domain instead (e.g. behind a reverse proxy), set this to that public URL, e.g. `https://spx.example.com`, so generated template links resolve correctly. |

This only affects the `config.json` generated on **first launch** — once the file exists, edit `ASSETS/CONFIG/config.json` directly to change it.

## Deploying on Coolify

This image works out of the box behind Coolify's built-in reverse proxy (Traefik):

- The Dockerfile exposes port `5656`, which Coolify auto-detects to generate a public domain with HTTPS.
- The server binds to all interfaces (`0.0.0.0`), so the proxy can reach it.
- Real-time features (Socket.IO/WebSockets) are proxied transparently by Traefik — no extra configuration needed.

Steps:

1. Create a new application in Coolify from this repository (Dockerfile-based deployment).
2. Mount two persistent volumes: `/SPX/ASSETS` and `/SPX/DATAROOT`.
3. (Optional) If CasparCG will fetch templates from SPX-GC over the public internet rather than a local network, set the `SPX_TEMPLATE_SOURCE` environment variable to the domain Coolify generates for the application.
4. Deploy — Coolify will build the image, expose it behind its proxy, and provide a public link with automatic HTTPS.
