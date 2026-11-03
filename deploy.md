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
`AGNTS_CODEX_MODELS` (`light=<model>,strong=<model>`) names the Codex models
for each tier; without it, calls never switch to Codex.
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

## Loki for the log watcher (once)

The log watcher reads this server's own container logs from a Loki in
`/opt/loki` (files in `deploy/loki/`): Grafana Alloy ships every container's
output there through a read-only Docker socket proxy, logs are kept 14 days,
and nothing is published. Loki joins `agnts_default`, so agnts reaches it at
`http://loki:3100`, which `AGNTS_LOGS_PRIVATE_ALLOW=loki` in `/opt/agnts/.env`
allows.

```sh
ssh root@45.138.158.39 'mkdir -p /opt/loki'
scp deploy/loki/docker-compose.yml deploy/loki/loki-config.yaml deploy/loki/config.alloy root@45.138.158.39:/opt/loki/
ssh root@45.138.158.39 'cd /opt/loki && docker compose up -d'
```

Alloy's first start backfills each container's history; Loki refuses lines
older than 7 days (Alloy logs "timestamp too old" once). The log source is
`server-loki` in workspace 1, its services labelled by compose service.

This server has it set up (2 November 2026).

## Muse through another network (when Meta refuses this server's)

Since 3 November 2026 Meta returns an empty model catalog ("model catalog has no
visible models") to Muse from this server's network (AS35682), for every login and
key; the same key works from elsewhere. agnts shows it as "not logged in: run /login to
add an API key". `egress` can send Muse's hosts (`api.meta.ai`, `auth.meta.com`)
through another proxy, `AGNTS_EGRESS_UPSTREAM`, while everything else stays direct.

1. In `/opt/agnts/docker-compose.yml`, the `egress` service's environment needs
   (see `deploy/docker-compose.yml`):

   ```yaml
         AGNTS_EGRESS_UPSTREAM: ${AGNTS_EGRESS_UPSTREAM:-}
         AGNTS_EGRESS_UPSTREAM_HOSTS: ${AGNTS_EGRESS_UPSTREAM_HOSTS:-}
   ```

2. Set the proxy in `/opt/agnts/.env` (back it up first) and recreate egress:

   ```sh
   AGNTS_EGRESS_UPSTREAM=socks5://user:pass@proxy-host:1080   # or http://user:pass@host:3128
   ssh root@45.138.158.39 'cd /opt/agnts && docker compose up -d egress'
   ```

   Test a proxy before using it: `muse exec --api-key-stdin "Reply OK"` from that
   machine must answer, not "no visible models". Another server at the same provider
   (5.182.26.104) gets the same refusal.

**A laptop as the proxy (demos).** OpenSSH's remote dynamic forward makes a SOCKS5
proxy on the server whose traffic leaves through the laptop. sshd must let it bind
to the Docker network's gateway (once: `/etc/ssh/sshd_config.d/agnts-tunnel.conf`
with `GatewayPorts clientspecified`, then `systemctl reload ssh`). Find the gateway
with `docker network inspect agnts_default -f '{{(index .IPAM.Config 0).Gateway}}'`
(172.19.0.1 here), set `AGNTS_EGRESS_UPSTREAM=socks5://172.19.0.1:1080`, and keep this
running on the laptop:

```sh
ssh -N -o ServerAliveInterval=30 -o ExitOnForwardFailure=yes -R 172.19.0.1:1080 root@45.138.158.39
```

**Seeing it, and alerts.** Admin → Dashboard has a *Muse route* card (egress checks the way every
30 seconds; the Dashboard menu item is marked while it is down). When it fails two checks in a
row (or egress is silent for 3 minutes), agnts sends an alert to the Telegram chat of the workspace
in `AGNTS_ALERT_WORKSPACE` (here `1`), and emails the Admins when mail is set up; another when it
works again.

The port is reachable only from the host and its containers. While the tunnel is
down, Muse calls fail as before; set `AGNTS_EGRESS_UPSTREAM=` and recreate egress
to go direct again.

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
