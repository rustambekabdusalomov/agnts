# Deploy

How the production server is updated by hand. CI's deploy job
(`.github/workflows/ci.yml`) is not used: the server builds its own image.

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

### 2. Build the image on the server

Tag the running image first so you can roll back:

```sh
ssh root@45.138.158.39 'docker tag agnts:local agnts:prev; cd /opt/agnts/src && \
  docker build --build-arg COMMIT=$(date +%Y%m%d%H%M) -t agnts:local . > /opt/agnts/build.log 2>&1; \
  echo exit=$?; tail -5 /opt/agnts/build.log'
```

This takes a few minutes. Run it in the background and do step 4 meanwhile.

### 3. Restart the backend

```sh
ssh root@45.138.158.39 'cd /opt/agnts && docker compose up -d agnts egress && \
  docker compose ps && docker compose logs --since 2m agnts | grep -iE "error|fatal|migrat"'
```

`egress` uses the same image, so recreate it too. Database migrations run
automatically when `agnts` starts. Wait until `agnts` shows `(healthy)`.

### 4. Website

```sh
cd apps/website && npm run generate
rsync -az --delete --stats .output/public/ root@45.138.158.39:/opt/agnts/website/
```

`--delete` is safe here because `website/` holds only generated output. Caddy
serves the files directly, so nothing needs restarting.

### 5. Check

```sh
for u in https://agnts.uz/ https://app.agnts.uz/; do curl -s -o /dev/null -w "$u %{http_code}\n" $u; done
ssh root@45.138.158.39 'cd /opt/agnts && docker compose ps'
```

Both URLs should return `200`. `https://api.agnts.uz/healthz` returns `302`,
which is how that path is routed; the container's own health check is what counts.

## Rollback

```sh
ssh root@45.138.158.39 'docker tag agnts:prev agnts:local && cd /opt/agnts && docker compose up -d agnts egress'
```

Migrations only go forward. If a deploy applied a migration the old image
doesn't understand, restore from `/opt/agnts/backups` instead.

## Useful

- Logs: `ssh root@45.138.158.39 'cd /opt/agnts && docker compose logs -f agnts'`
- Last build output: `/opt/agnts/build.log`
- Changing Caddy config: edit `/opt/agnts/Caddyfile.cloud` on the server, then
  `docker compose restart caddy`.
