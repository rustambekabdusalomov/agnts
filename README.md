# hiro

A self-hosted agent that takes Jira tickets and side-project tasks, codes them
with Claude Code in isolated containers, and ships nothing without your
approval. See [Implementation plan.md](Implementation%20plan.md).

## Layout

| Path | What |
| --- | --- |
| `server/` | Go server: REST API, auth, and later orchestrator, runner, MCP |
| `apps/admin/` | Admin panel: Vue 3 + Vite, served by the Go binary |
| `apps/mobile/` | Mobile app: Flutter (iOS and Android) |
| `shared/openapi/` | OpenAPI spec, the contract for both clients and the server |
| `shared/i18n/` | EN/RU/UZ dictionaries (ICU MessageFormat) |
| `deploy/` | Docker Compose stack: Caddy, hiro, PostgreSQL, nightly backups |
| `admin.html`, `mobile.html` | The original demos the UI is ported from |

Server packages follow Clean Architecture: `domain` (types, no imports) ←
use cases (`auth`, …) ← adapters (`httpapi`, `store/postgres`). Use cases
depend on interfaces they declare; adapters implement them.

## Requirements

Go 1.26, Node 22, Java 17 (for the Dart client generator), Docker, and
Flutter 3.44+ for the mobile app.

## Local development

```sh
make dev-db          # PostgreSQL on localhost:5442 (Docker)
make dev-user        # create your user: password + authenticator app
make dev-server      # API on :8080, migrations applied on start
make dev-admin       # admin panel on http://localhost:5173
```

Database tests run when `HIRO_TEST_DATABASE_URL` is set; the dev database
creates `hiro_test` for them:

```sh
HIRO_TEST_DATABASE_URL=postgres://hiro:hiro@localhost:5442/hiro_test?sslmode=disable make test
```

After editing `shared/openapi/openapi.yaml` or `shared/i18n/*.json`, run
`make gen` and commit the generated files. CI fails if they are stale.

## Connecting hiro to your work

Everything is set up in the admin panel (Integrations, Repositories,
Settings). The CLI equivalents still work for a headless first run, as
`docker compose exec hiro hiro ...`:

```sh
hiro integration set claude    # token from `claude setup-token` (your Claude plan)
hiro integration set github    # fine-grained PAT: Contents + Pull requests, read/write
hiro integration set jira      # site, email, API token, label; prints the webhook to create
hiro repo add --name api --url https://github.com/acme/api.git --jira PAY \
  --build "go build ./..." --lint "go vet ./..." --test "go test ./..."
hiro jira sync                 # pick up already-labelled issues now
hiro mcp token                 # static MCP token for Claude Code / Claude Desktop
```

- **Jira:** Integrations → Jira shows the webhook URL and secret to paste into
  Jira (Settings → System → WebHooks).
- **GitHub / GitLab webhooks:** the integration page shows a URL and secret.
  Merged pull requests then mark the ticket merged and move the Jira issue.
- **Telegram:** create a bot with @BotFather, send `/start` to it to learn
  your chat id, then connect it under Integrations. hiro registers the webhook.
- **Push:** set `HIRO_FCM_CREDENTIALS` to a Firebase service account file; see
  `apps/mobile/README.md` for the app side.
- **Claude chat:** Settings → Claude chat shows the connector URL. In Claude,
  add a custom connector with it; Claude sends you to hiro to approve. Every
  change requested in chat is prepared first and runs only after you confirm.

Then label a Jira issue `hiro`. The flow: hiro reads the code and either asks
questions (answer them on the ticket page) or starts coding; it runs your
build, lint and tests inside the container and sends failures back to Claude
up to twice; you review the diff and approve; only then does hiro push
`hiro/<KEY>` and open the pull request.

**Learn.** After each push, a short learn run reads the change in a
container and checks the repository and its lesson list for anything the
codebase never did before (a pattern, algorithm, library, architecture
boundary). Each find becomes a lesson with an explanation, code references,
a quiz and further reading, under Learn in the admin panel and the app, and
through the `list_lessons` / `get_lesson` MCP tools. Learn runs only take the
worker when no ticket is waiting. Turn them off or pick their model in
Settings, or start one by hand from a finished ticket.

Secrets are stored encrypted with `HIRO_ENC_KEY`. Run containers get the
Claude token and a copy of the repository, never the GitHub token.

## Deploy

1. Point DNS for your domain at the server and install Docker.
2. Copy `deploy/` to `/opt/hiro`, then `cp .env.example .env` and fill it in.
   Generate `HIRO_ENC_KEY` with `docker run --rm <image> keygen` and keep a
   copy off the server: without it, stored secrets cannot be decrypted.
3. Build the runner image once (and after changing `deploy/runner/`):
   `docker compose --profile build build runner`.
4. `docker compose up -d`, then `docker compose exec hiro hiro user create <name>`.
5. To deploy from CI on every push to `main`, set the repository variable
   `DEPLOY_ENABLED=true` and the secrets listed in `.github/workflows/ci.yml`.

Run containers sit on the internal `hiro-runs` network; the `egress`
service is their only way out and allows the Claude API, GitHub, GitLab.com
and the Go, npm and PyPI registries. Add hosts (a self-hosted GitLab, a
private registry) with `HIRO_EGRESS_ALLOW`.

Prometheus metrics are served on `HIRO_METRICS_ADDR` (for example `:9090`),
which Caddy does not expose.

Backups land in `/opt/hiro/backups` nightly at 03:00. Copy them off the server
(rclone, restic, or similar) — that part is not automated yet.
