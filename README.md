# spx-docker

A minimal Docker image for [SPX Graphics Controller](https://github.com/TuomoKu/SPX-GC) (SPX-GC) v1.4.0, built from the official source on each image build.

## What's inside

- `Dockerfile` — builds a lightweight `node:20-alpine` image, clones SPX-GC's `master` branch, installs production dependencies, and runs the controller on port `5656`.
- `entrypoint.sh` — generates a default `config.json` on first launch and starts the server.

## Staying up to date

The Dockerfile always builds from SPX-GC's `master` branch, so the running app is
always current. The version label/comments in the Dockerfile, however, are kept in
sync automatically by [.github/workflows/update-spx-version.yml](.github/workflows/update-spx-version.yml):
it checks the [latest SPX-GC release](https://github.com/TuomoKu/SPX-GC/releases/latest)
daily and, if a new version was published, bumps the version references in the
Dockerfile and pushes the change to this repo (which then triggers a fresh build/deploy
on platforms like Coolify that watch this repository).

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

## Uploading files to a remote deployment

SPX-GC has no upload button — its built-in file browser only lists files that already
exist on the server's filesystem (`/SPX/ASSETS`, `/SPX/DATAROOT`). That's transparent
when SPX runs on your own machine, but on a remote deployment there's no way to get
files you created locally into those folders from the browser.

[docker-compose.yml](docker-compose.yml) solves this by running a small
[filebrowser](https://github.com/filebrowser/filebrowser) sidecar alongside SPX-GC,
mounting the **same** `spx-assets` / `spx-dataroot` volumes already used by your SPX
deployment. Deploy it as a "Docker Compose" application in Coolify and you get a
second public link with a drag-and-drop web UI: anything you drop there lands directly
in SPX's `ASSETS`/`DATAROOT` folders and is immediately visible to SPX.

Before deploying, edit the `name:` fields under `volumes:` in `docker-compose.yml` to
match the actual volume names of your existing SPX deployment in Coolify. Also make
sure to set a strong admin password for filebrowser (it grants direct filesystem
access) — see its [documentation](https://filebrowser.org/configuration/authentication-method)
for configuration options.
