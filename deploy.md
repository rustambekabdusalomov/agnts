# Deploy

How the production server is updated by hand: the server builds its own
image. This repository has no CI workflow for now (Actions minutes), so run
`make test` and `make lint` before deploying.

## Server

| | |
|---|---|
| Host | `root@45.138.158.39` (SSH key auth) |
| Stack | `/opt/agnts` (Docker Compose) |
| Website | https://agnts.uz, static files in `/opt/agnts/website` |
| Admin panel | https://app.agnts.uz |
| API | https://api.agnts.uz |

What lives in `/opt/agnts`:

- `docker-compose.yml`, `Caddyfile.cloud`, `.env`: the server's own copies.
  They have edits that are not in the repo (the pitch-day site, for one), so
  **do not overwrite them from `deploy/`**. Merge by hand if the repo version changes.
- `src/`: a copy of the repo that the image is built from.
- `website/`: the generated website, served by Caddy (`root * /srv/website`).
- `pitch-day/`: a separate static site, also served by Caddy.
- `backups/`: nightly Postgres dumps (03:00).

`.env` sets `AGNTS_IMAGE=agnts:local`, so the `agnts` and `egress` services run
an image built on the server, not one pulled from `registry.agnts.uz`.

## What is built where

| Part | Built by | Ends up as |
|---|---|---|
| Backend (Go, `server/`) | `Dockerfile` on the server | `agnts:local` image |
| Admin panel (Vue, `apps/admin/`) | the same `Dockerfile` (admin stage) | `/srv/web` inside `agnts:local` |
| Website (Nuxt, `apps/website/`) | `npm run generate` on the laptop | `/opt/agnts/website` |

The admin panel and the backend are one image, so you can't deploy one without the other.

## Steps

Run from the repo root. The working tree is what ships, uncommitted changes
included, so check `git status` first.

### 1. Copy the source

```sh
rsync -az --stats \
  --exclude node_modules --exclude .git --exclude dist --exclude .nuxt --exclude .output \
  --exclude '.dev-data*' --exclude apps/mobile --exclude cli/target --exclude .env.dev \
  ./ root@45.138.158.39:/opt/agnts/src/
```

The excludes matter: `.dev-data/` holds about 20k files of local test repos,
and `apps/mobile` isn't part of the image.

agnts-muse, the Muse engine, is a sibling module (`server/go.mod` replaces it
with `../../agnts-muse`). Copy it beside `src/`:

```sh
rsync -az --stats --exclude .git ../agnts-muse/ root@45.138.158.39:/opt/agnts/agnts-muse/
```

### 2. Build the image on the server

Tag the running image first so you can roll back:

```sh
ssh root@45.138.158.39 'docker tag agnts:local agnts:prev; cd /opt/agnts/src && \
  docker build --build-context agnts-muse=/opt/agnts/agnts-muse --build-arg COMMIT=$(date +%Y%m%d%H%M) -t agnts:local . > /opt/agnts/build.log 2>&1; \
  echo exit=$?; tail -5 /opt/agnts/build.log'
```

This takes a few minutes. Run it in the background and do step 4 meanwhile.

### 3. Restart the backend

```sh
ssh root@45.138.158.39 'cd /opt/agnts && \
  docker build --build-arg AGNTS_IMAGE=agnts:local -t agnts-ovpn:latest src/deploy/ovpn > /opt/agnts/ovpn-build.log 2>&1 && \
  docker compose --profile private-network up -d agnts egress gateway && \
  docker rm -f $(docker ps -aq --filter label=agnts=ovpn) 2>/dev/null; \
  docker compose --profile private-network ps && docker compose logs --since 2m agnts | grep -iE "error|fatal|migrat"'
```

`egress` and `gateway` use the same image, so recreate them too; without
`--profile private-network` compose leaves `gateway` on the old image. The
OpenVPN sidecars carry the agnts binary as well: the command rebuilds their
image and removes the running ones, and agnts starts them again on the new
image within 30 seconds (VPN tunnels drop for that long).

Database migrations run automatically when `agnts` starts. Wait until `agnts`
shows `(healthy)`. A warning from `gateway` or `egress` that they could not
reach `agnts:8081` right after the restart is expected: they started before
`agnts` was up, and they try again on their own.

### 4. Website

```sh
cd apps/website && \
  NUXT_PUBLIC_GOOGLE_CLIENT_ID=340542876762-6bqfc0a1s9eumku5qv7b14nvpu5qdvs1.apps.googleusercontent.com \
  NUXT_PUBLIC_APP_URL=https://app.agnts.uz \
  npm run generate
rsync -az --delete --stats .output/public/ root@45.138.158.39:/opt/agnts/website/
```

The two variables are baked into the static build. Without them the site falls back to
`nuxt.config.ts`'s dev defaults (no client id, `appUrl` on localhost) and "Sign in" does not work.
The client id must match the server's `AGNTS_GOOGLE_CLIENT_ID`.

`--delete` is safe here because `website/` holds only generated output. Caddy
serves the files directly, so nothing needs restarting.

### 5. Check

```sh
for u in https://agnts.uz/ https://app.agnts.uz/; do curl -s -o /dev/null -w "$u %{http_code}\n" $u; done
ssh root@45.138.158.39 'cd /opt/agnts && docker compose ps'
```

Both URLs should return `200`. `https://api.agnts.uz/healthz` returns `302`,
which is how that path is routed; the container's own health check is what counts.

## Runner image (when deploy/runner changes)

The agnts image (step 2) carries agnts-guard, the hooks inside every run, and
the runner copies it into each run. The runner image itself only needs a
rebuild when `deploy/runner/` changes (managed settings with the hooks and the
repository lockdown, the `/agnts/context` volume, `agnts-act`):

Tag the running image first so you can roll back:

```sh
ssh root@45.138.158.39 'docker tag agnts-runner:latest agnts-runner:prev; cd /opt/agnts/src/deploy/runner && \
  docker build -t agnts-runner:latest . > /opt/agnts/runner-build.log 2>&1; \
  echo exit=$?; tail -3 /opt/agnts/runner-build.log'
```

Use `docker build`, not `docker compose --profile build build runner`: the
compose file in `src/deploy` needs `AGNTS_DOMAIN`, which only `/opt/agnts/.env`
sets, so compose fails before it builds anything. The tag must match
`AGNTS_RUNNER_IMAGE` in `/opt/agnts/.env` (unset means `agnts-runner:latest`).

Codex CLI is installed at the version pinned in the Dockerfile (`ARG
CODEX_VERSION`). Add `--build-arg CODEX_VERSION=<version>` for another one,
or an empty value to leave it out (then remove `codex` from `AGNTS_PROVIDERS`).
New runs use the new image; runs in progress keep theirs.

Check it, and roll back if a run misbehaves:

```sh
ssh root@45.138.158.39 'docker run --rm agnts-runner:latest muse --version'
ssh root@45.138.158.39 'docker tag agnts-runner:prev agnts-runner:latest'
```

Claude Code is a native binary that needs a CPU with SSE4.2/AVX. Before
moving to a new server, check that `grep -o -w avx2 /proc/cpuinfo` prints
something: on a VM with the generic CPU type (kvm64) claude hangs at 100% CPU.
Ask the provider for CPU type `host`.

## Private networks (once)

Settings → Private networks needs three more pieces on the server: the
`gateway` service, the OpenVPN sidecar image, and Caddy's `/link` route.
Until `AGNTS_GATEWAY` is set the feature stays off and the page says so.

1. Add to `/opt/agnts/.env`:

   ```sh
   AGNTS_GATEWAY=gateway:3129
   AGNTS_GATEWAY_SECRET=<openssl rand -hex 32>
   AGNTS_LINK_URL=https://api.agnts.uz/link
   ```

2. Merge from `deploy/docker-compose.yml` into the server's copy by hand: the
   `gateway` service, the three new `egress` environment lines, the `ovpn`
   network and the build-only `ovpn` service.
3. Add the `handle /link { reverse_proxy gateway:3130 }` block to the API
   domain in `/opt/agnts/Caddyfile.cloud` (see `deploy/Caddyfile.cloud`).
4. Build the sidecar image after the main image (step 2 above):

   ```sh
   ssh root@45.138.158.39 'docker build --build-arg AGNTS_IMAGE=agnts:local -t agnts-ovpn:latest /opt/agnts/src/deploy/ovpn'
   ```

5. Start it:

   ```sh
   ssh root@45.138.158.39 'cd /opt/agnts && docker compose --profile private-network up -d gateway agnts egress && docker compose restart caddy'
   ```

The command the page shows for agnts-link uses `registry.agnts.uz/agnts-link:latest`.
Build it with `docker build -f deploy/link/Dockerfile -t registry.agnts.uz/agnts-link:latest .`
and push it before telling teams about the connector.

This server has it set up (14 October 2026). Every later deploy rebuilds the
sidecar image and recreates `gateway` in step 3.

Migration `00038_private_networks_multi.sql` lets a workspace keep several
networks (`AGNTS_PRIVATE_NETWORKS_MAX`, default 5). On the first start after
it, agnts seals each existing VPN config again for its network (the gateway
picks it up within 15 seconds; the tunnel keeps running) and replaces each
OpenVPN sidecar `agnts-ovpn-<workspace>` with `agnts-ovpn-net-<network>`.
Deploy agnts, egress and gateway together: an egress or gateway from before
does not send or check the network.

## Meetings (once)

Video calls run on LiveKit (`livekit`, `redis`, `livekit-egress`, the
`meetings` profile). Until `AGNTS_LIVEKIT_URL` is set the Meetings page says
they are off. The server needs about 1 CPU per 25 people in calls, and 2–4
CPUs for each recording while it runs (`AGNTS_MEET_MAX_RECORDINGS`, default 2).

1. Open the media ports (signaling goes through Caddy), in ufw or the provider's firewall:

   ```sh
   ssh root@45.138.158.39 'ufw allow 7881/tcp && ufw allow 7882/udp && ufw allow 3478/udp'
   ```

2. Add to `/opt/agnts/.env` (the URL is the domain whose Caddy block has `/rtc`):

   ```sh
   AGNTS_LIVEKIT_URL=wss://app.agnts.uz
   AGNTS_LIVEKIT_API_KEY=agnts
   AGNTS_LIVEKIT_API_SECRET=<openssl rand -hex 32>
   AGNTS_LIVEKIT_EGRESS=true
   ```

3. Merge from `deploy/docker-compose.yml` into the server's copy by hand: the
   `livekit`, `redis` and `livekit-egress` services, the `meetingmedia` volume,
   and the `agnts` service's new environment lines and `meetingmedia` mount.
4. In `/opt/agnts/Caddyfile.cloud`, add the `handle /rtc* { reverse_proxy livekit:7880 }`
   block to the admin panel's domain, and the CSP (`wss://`, `media-src`) and
   `Permissions-Policy` changes (see `deploy/Caddyfile.cloud`).
5. Rebuild the runner image (it now carries ffmpeg, which notes need), see
   [Runner image](#runner-image-when-deploy-runner-changes).
6. Deploy as usual (steps 1–3), then start it:

   ```sh
   ssh root@45.138.158.39 'cd /opt/agnts && docker compose --profile meetings up -d livekit redis livekit-egress agnts && docker compose restart caddy'
   ```

Check: open `/m/<code>` from two devices on different networks (one on mobile
data). If they see each other only on the same Wi-Fi, a port is closed.
Notes need Muse connected in the workspace and `AGNTS_AGENT_ENABLED=true`.
Networks that block UDP and 7881 need TURN over TLS on 443, which this setup
doesn't have yet.

This server has it set up (28 October 2026). The server's compose file, `.env`
and `Caddyfile.cloud` from before are kept beside them as `*.pre-meetings`.
Step 3 leaves `livekit`, `redis` and `livekit-egress` running; recreate them
with `--profile meetings up -d` only when their settings change.

## Rollback

```sh
ssh root@45.138.158.39 'docker tag agnts:prev agnts:local && cd /opt/agnts && docker compose --profile private-network up -d agnts egress gateway'
```

Migrations only go forward. If a deploy applied a migration the old image
doesn't understand, restore from `/opt/agnts/backups` instead.

## Useful

- Logs: `ssh root@45.138.158.39 'cd /opt/agnts && docker compose logs -f agnts'`
- Last build output: `/opt/agnts/build.log`
- Changing Caddy config: edit `/opt/agnts/Caddyfile.cloud` on the server, then
  `docker compose restart caddy`.
