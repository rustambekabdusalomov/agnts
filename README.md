# agnts

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
| `deploy/` | Docker Compose stack: Caddy, agnts, PostgreSQL, nightly backups |
| `cli/` | Rust CLI that installs and manages agnts on a server; see [CLI plan.md](CLI%20plan.md) |
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

Database tests run when `AGNTS_TEST_DATABASE_URL` is set; the dev database
creates `hiro_test` for them:

```sh
AGNTS_TEST_DATABASE_URL=postgres://hiro:hiro@localhost:5442/hiro_test?sslmode=disable make test
```

After editing `shared/openapi/openapi.yaml` or `shared/i18n/*.json`, run
`make gen` and commit the generated files. CI fails if they are stale.

## Connecting agnts to your work

Everything is set up in the admin panel (Integrations, Repositories,
Settings). The server commands still work for a headless first run, through
the CLI as `agnts server -- ...`:

```sh
agnts server -- integration set claude    # token from `claude setup-token` (your Claude plan)
agnts server -- integration set github    # fine-grained PAT: Contents + Pull requests, read/write
agnts server -- integration set jira      # site, email, API token, label; prints the webhook to create
agnts server -- repo add --name api --url https://github.com/acme/api.git --jira PAY \
  --build "go build ./..." --lint "go vet ./..." --test "go test ./..."
agnts server -- jira sync                 # pick up already-labelled issues now
agnts server -- mcp token                 # static MCP token for Claude Code / Claude Desktop
```

- **Jira:** Integrations → Jira shows the webhook URL and secret to paste into
  Jira (Settings → System → WebHooks).
- **GitHub / GitLab webhooks:** the integration page shows a URL and secret.
  Merged pull requests then mark the ticket merged and move the Jira issue.
- **Telegram:** create a bot with @BotFather, send `/start` to it to learn
  your chat id, then connect it under Integrations. agnts registers the webhook.
- **Push:** set `AGNTS_FCM_CREDENTIALS` to a Firebase service account file; see
  `apps/mobile/README.md` for the app side.
- **Claude chat:** Settings → Claude chat shows the connector URL. In Claude,
  add a custom connector with it; Claude sends you to agnts to approve. Every
  change requested in chat is prepared first and runs only after you confirm.

Then label a Jira issue `agnts`. The flow: agnts reads the code and either asks
questions (answer them on the ticket page) or starts coding; it runs your
build, lint and tests inside the container and sends failures back to Claude
up to twice; you review the diff and approve; only then does agnts push
`agnts/<KEY>` and open the pull request.

**Code review.** While a ticket waits for your review, a review run reads
the result in a read-only container (the diff with its checks, or the
report against the code) and writes findings next to it: severity,
category, file and line, and a suggestion you can add to your feedback in
one click. It is advice, never a gate: approving or requesting changes
cancels a review still running, and each new revision is reviewed again.
With the review model on Auto (Settings), Opus reviews tickets the analysis
rated complex or large changes, and Sonnet the rest. Turn it off in
Settings, or run it again from the ticket.

**Learn.** After each push, a short learn run reads the change in a
container and checks the repository and its lesson list for anything the
codebase never did before (a pattern, algorithm, library, architecture
boundary). Each find becomes a lesson with an explanation, code references,
a quiz and further reading, under Learn in the admin panel and the app, and
through the `list_lessons` / `get_lesson` MCP tools. Learn runs only take the
worker when no ticket is waiting. Turn them off or pick their model in
Settings, or start one by hand from a finished ticket.

**Rules.** Under Rules in the admin panel, write instructions agnts follows on
every ticket: global ones, and ones for a single repository (which win where
the two disagree). Saving a rule queues a short Claude review in a container
(next to the repository's code for a repository rule) that looks for vague
wording, missing scope and conflicts with other rules, and asks questions
when something is unclear. A rule applies only once it is clear, or once you
choose to use it as written; every analysis and coding prompt then gets it
under "Team rules", and the ticket's log lists the rules it followed.

**Queue order.** agnts codes several tickets at once (Settings → Runs at the
same time) and works out which ones must wait. A ticket does not start coding
until every ticket it depends on is merged (or rejected), and two tickets
that change the same code never code side by side: whichever starts second
waits until the first is merged. Analysis never waits. Relations come from:

- Jira "blocks" / "is blocked by" links (and similar dependency link types);
- the ticket's Order tab, where you can add "Waits for" or "Not alongside";
- the analysis, which predicts each ticket's footprint (files, what it adds
  and needs) and compares it with the other open tickets. The same files, or
  a shared hot spot (database migrations, lockfiles, an API spec and its
  generated code, translation files), make a conflict. Relations Claude reads
  from the tickets apply when it is confident and are only proposed when it
  is not: accept or dismiss them on the ticket's Order tab.

The queue then takes the highest priority first, then the ticket that frees
the most waiting work. A dependent's first coding run starts from the default
branch with its dependencies merged in. Finished changes are checked against
the other unmerged ones and against what landed since the branch was cut;
same-line overlaps are flagged on both tickets and in the pull request. Without
a merge webhook, mark a pull request merged from the ticket page.
`agnts eval relations` scores the predictions (footprint precision and
recall, predicted vs real collisions), and `/metrics` exports the same.

Secrets are stored encrypted with `AGNTS_ENC_KEY`. Run containers get the
Claude token and a copy of the repository, never the GitHub token.

## Deploy

You need a Linux server (Ubuntu 22.04/24.04 or Debian 12, amd64, 2 GB RAM,
20 GB free disk), a domain, and an access key from your cabinet at
https://agnts.uz/cabinet/keys. One key is good for one install.

```sh
curl -fsSL https://agnts.uz/install.sh | sh            # Windows: irm https://agnts.uz/install.ps1 | iex
agnts install root@203.0.113.10 --domain agnts.acme.com # from your laptop, over SSH
# or, on the server itself:
sudo agnts install --local --domain agnts.acme.com
```

The CLI installs Docker, opens the firewall, shows the DNS record to create and
waits for it, writes the stack to `/opt/agnts` with fresh secrets, pulls the
images from `registry.agnts.uz`, starts everything, waits for HTTPS and creates
your admin user. If anything fails, run the same command again: it continues
where it stopped. In remote mode the CLI also keeps a copy of `AGNTS_ENC_KEY`
on your laptop, since stored secrets cannot be decrypted without it.

Afterwards:

```sh
agnts status            # containers, version, certificate, disk, last backup
agnts doctor            # every check, with fixes
agnts upgrade           # backup, new version, roll back if it does not come up
agnts backup --pull     # copy backups to your laptop
agnts logs agnts -f
agnts domain set agnts.new.com
agnts server -- mcp token
```

`agnts --help` lists the rest. Manage several servers with `--profile`.

**Manual install.** Without the CLI: point DNS at the server and install
Docker; copy `deploy/` to `/opt/agnts`, `cp .env.example .env` and fill it in
(generate `AGNTS_ENC_KEY` with `docker run --rm <image> keygen` and keep a copy
off the server); `docker login registry.agnts.uz` with your install id and
access key, or build the images yourself (`docker compose --profile build build
runner`); then `docker compose up -d` and `docker compose exec agnts agnts user
create <name>`.

To deploy your own build from CI on every push to `main`, set the repository
variable `DEPLOY_ENABLED=true` and the secrets listed in
`.github/workflows/ci.yml`. Tagging `v*` runs `.github/workflows/release.yml`,
which publishes the images to `registry.agnts.uz` and the CLI to agnts.uz.

Run containers sit on the internal `agnts-runs` network; the `egress`
service is their only way out and allows the Claude API, GitHub, GitLab.com
and the Go, npm and PyPI registries. Add hosts (a self-hosted GitLab, a
private registry) with `AGNTS_EGRESS_ALLOW`.

Prometheus metrics are served on `AGNTS_METRICS_ADDR` (for example `:9090`),
which Caddy does not expose.

Backups land in `/opt/agnts/backups` nightly at 03:00. Copy them off the server
with `agnts backup --pull` (or rclone, restic, or similar); scheduled off-site
copies are not automated yet.
