# agnts

A self-hosted agent that takes Jira tickets and side-project tasks, codes them
with Meta's Muse Code in isolated containers, and ships nothing without your
approval. See [Implementation plan.md](plans/Implementation%20plan.md) and
[Muse plan.md](plans/Muse%20plan.md).

## Muse Code

Muse Code is one of agnts's three coding modules, with Claude Code and Codex.
`AGNTS_PROVIDERS` lists the ones this server can run; within it, the platform
Admin chooses the modules the server offers and who may use which (Admin →
Modules, and Set modules on Admin → Users). agnts drives Muse with
[agnts-muse](https://github.com/rustambekabdusalomov/agnts-muse), which speaks
Muse's session protocol (`muse serve`) inside each run container:

- **Live cost.** Every model call is charged as Muse reports it and shows on the
  ticket's log; a run on credits holds money ahead of its spend and is told to
  wrap up at 80% of its budget, then stopped before the call that would pass it.
- **Escalation without a restart.** A Spark session that keeps failing moves to
  Wonder in the same session, with its context.
- **agnts's rules decide tool calls.** The guard vetoes `git push`, reading
  secrets, piping downloads into a shell and the like through Muse's approvals.
- **Accounts.** A person or workspace connects Muse by signing in with Meta
  (a code to confirm, like `muse login`) or with a Meta Model API key. Without
  one, runs use agnts's key (`AGNTS_MUSE_PLATFORM_KEY`) and are paid with
  credits: first the person's **free credits** (set by an Admin per person,
  0 by default; Admin → Users), then the workspace's bought credits, under a
  monthly cap for the whole server (`AGNTS_MUSE_GLOBAL_CAP_USD`).

agnts-muse sits beside this repository (`../agnts-muse`, see
`server/go.mod`); the server image builds with
`docker build --build-context agnts-muse=../agnts-muse .` (`make build` does).

## Layout

| Path | What |
| --- | --- |
| `server/` | Go server: REST API, auth, and later orchestrator, runner, MCP |
| `apps/admin/` | Admin panel: Vue 3 + Vite, served by the Go binary |
| `apps/website/` | Public website (agnts.uz): Nuxt 3, fully static build in EN/RU/UZ |
| `apps/mobile/` | Mobile app: Flutter (iOS and Android) |
| `shared/openapi/` | OpenAPI spec, the contract for both clients and the server |
| `shared/i18n/` | EN/RU/UZ dictionaries (ICU MessageFormat) |
| `deploy/` | Docker Compose stack: Caddy, agnts, PostgreSQL, nightly backups |
| `cli/` | Rust CLI that installs and manages agnts on a server; see [CLI plan.md](plans/CLI%20plan.md) |
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
make dev-website     # public website on http://localhost:3000
make dev-meetings    # LiveKit, Redis and Egress for video calls (Docker)
```

Meetings use the LiveKit values in `deploy/.env.dev`; start `make dev-meetings`
before `make dev-server`. The LiveKit tests run when `AGNTS_TEST_LIVEKIT_URL`
is set (`ws://localhost:7880`).

Database tests run when `AGNTS_TEST_DATABASE_URL` is set; the dev database
creates `hiro_test` for them:

```sh
AGNTS_TEST_DATABASE_URL=postgres://hiro:hiro@localhost:5442/hiro_test?sslmode=disable make test
```

After editing `shared/openapi/openapi.yaml` or `shared/i18n/*.json`, run
`make gen` and commit the generated files. CI fails if they are stale.

## Log watcher

agnts reads your projects' logs, finds errors (exceptions, panics, crash loops,
5xx bursts) and security mistakes (secrets and personal data written to logs,
stack traces sent to clients, debug mode in production, brute force and
scanning), groups them by cause and, as Settings → Log watcher says, reports
them or opens a ticket on the service's repositories. Automatic tickets are
off until you turn them on; every fix waits for your approval.

- **Log sources** (Log watcher → Log sources): Loki, Elasticsearch,
  OpenSearch, Graylog, Datadog, CloudWatch Logs or Splunk by address and
  read-only credentials, tested before they are saved. An address on a
  workspace's private network goes through it; `AGNTS_LOGS_PRIVATE_ALLOW` lets
  a logger next to agnts be read directly.
- **Push:** a push source's token lets Vector, Fluent Bit, Promtail or Grafana
  Alloy send to `/webhooks/logs` (Loki's push API under
  `/webhooks/logs/loki/api/v1/push`).
- **No logging system:** `agnts watch` runs on the project's server and follows
  containers labelled `agnts.watch=logs` (crashes, OOM kills and failed health
  checks too) and log files, through a read-only Docker socket proxy.
- Each service is mapped to the repositories it runs on (several for a
  gateway); without one, its findings are only reported.

Tests against a real Loki run when `AGNTS_TEST_LOKI_URL` is set
(`docker run -p 3100:3100 grafana/loki:3.2.0`); with `AGNTS_TEST_DATABASE_URL`
as well, `internal/logwatch`'s end-to-end test runs the whole flow.

## Team chat

Workspace members talk in channels (Chat in the admin panel), and agnts is in
the room. See [Team chat plan.md](plans/Team%20chat%20plan.md).

- **Cards with real buttons.** A new log finding, a ticket waiting for review
  and the pull request it opened arrive as cards in agnts's channel (#general
  unless another is marked). **Fix it**, **Approve** (push and open the PR),
  **Request changes** and **Merge** (on the git host, with the workspace's
  merge method) run the same checked actions as the ticket page and MCP. A card
  is pressed once; Merge shows CI's state and is refused when someone pushed
  after agnts.
- **Links.** Ticket keys, PR numbers and URLs and repository names link a
  message at once; the Team chat model's light sibling links the rest from the
  workspace's open tickets, PRs, repositories and findings (confidence ≥ 0.7).
- **@agnts** answers from the workspace's memory: tickets and their progress,
  PRs, repositories' briefs, log findings and the chat itself (links and
  Postgres full-text search, no vector index), and cites what it used; a
  citation it was not given is removed. A question about how code works that no
  brief answers is answered by reading the repository, read-only, with links
  to the lines.
- **Turn into ticket** drafts a task from a message and its thread; **Create
  and assign** gives it to the coding agent, and its cards come back to the
  same channel.
- **Nothing lost or doubled.** A message carries a client id (a resend returns
  the stored one), its model work is queued in the same transaction
  (`chat_jobs`), and a reconnecting client replays the event stream and fetches
  `messages?after=` to fill any gap.

The model is **Settings → Models → Team chat** (any connected module; unset,
the assistant's). Daily caps per workspace: 500 links, 200 answers, 30 code
answers, 100 drafts.

## Connecting agnts to your work

Everything is set up in the admin panel (Integrations, Repositories,
Settings). The server commands still work for a headless first run, through
the CLI as `agnts server -- ...`:

```sh
agnts server -- integration set claude    # token from `claude setup-token` (only while an Admin has Claude enabled)
agnts server -- integration set github    # fine-grained PAT: Contents + Pull requests, read/write (+ Actions for CI watching)
agnts server -- integration set jira      # site, email, API token, label; prints the webhook to create
agnts server -- integration set plane     # API address, workspace, API key; prints the webhook to create in Plane
agnts server -- repo add --name api --url https://github.com/acme/api.git --jira PAY
                                          # clones it, detects toolchains (go@1.24, node@20, python@3.12, ...)
                                          # and the build/lint/test commands; override with --toolchain/--build/...
agnts server -- repo detect api           # detect again, e.g. after adding a language
agnts server -- jira sync                 # pick up already-labelled issues now
agnts server -- plane sync                # same for Plane work items (repos linked with --plane WEB)
agnts server -- mcp token                 # static MCP token for Claude Code / Claude Desktop
```

- **Jira:** Integrations → Jira shows the webhook URL and secret to paste into
  Jira (Settings → System → WebHooks).
- **Plane:** Plane Cloud or self-hosted. Integrations → Plane takes the API
  address, workspace slug and a personal access token, and shows the webhook
  URL to add in Plane (Workspace settings → Webhooks, work item events). Plane
  generates the secret: paste it back on the same page. Link a repository to
  a Plane project by its identifier (WEB in WEB-123) and label work items
  `agnts`. Statuses left empty move to the first state of the matching group.
- **Whose issues:** agnts takes a labelled Jira issue only when it is assigned
  to the account agnts connects with (Integrations → Jira → Only issues
  assigned to me; on by default). Turn it off to take every labelled issue.
- **Edited issues:** each sync (and each webhook) refreshes the tickets agnts
  has. One it has not started takes the new title and description; a priority
  change is taken at any time. One it started keeps working on the version it
  started with, and the ticket shows the new version with Restart with the new
  version (drops the analysis, answers, commits and reviews so far, and starts
  over) or Keep the current version (not asked again for that version). You
  are notified on the phone and in Telegram, with the same two buttons. A
  ticket already pushed cannot restart.
- **Which repository:** a Jira issue or Plane work item goes to the repository
  linked to its project. A `repo:<name>` label (the repository's name in
  agnts, any case, e.g. `repo:web`) overrides that, so one project can feed
  several repositories. Adding or changing the label moves a ticket that has
  not started; once work starts it keeps its repository. A name agnts does not
  know falls back to the project's repository and logs a warning on the ticket.
- **GitHub / GitLab webhooks:** the integration page shows a URL and secret.
  Merged pull requests then mark the ticket merged and move the Jira issue.
  For CI watching also send **Workflow runs** (GitHub) or **Pipeline events**
  (GitLab); without them agnts polls watched repositories every 5 minutes.
- **Telegram:** create a bot with @BotFather, send `/start` to it to learn
  your chat id, then connect it under Integrations. agnts registers the webhook.
- **Push:** set `AGNTS_FCM_CREDENTIALS` to a Firebase service account file; see
  `apps/mobile/README.md` for the app side.
- **Claude chat:** Settings → Claude chat shows the connector URL. In Claude,
  add a custom connector with it; Claude sends you to agnts to approve. Every
  change requested in chat is prepared first and runs only after you confirm.

**Languages.** Runs work in any language mise can install from prebuilt
binaries: Go, Node, Bun, Deno, Python, Rust, Java/Kotlin/Scala, .NET, Ruby,
Elixir/Erlang, Gleam, Dart, Zig, Swift, Crystal, Nim, Julia, Haskell (stack)
and more, plus PHP from the runner image. Each repository's toolchains are
detected from its files (or set under Repositories → Toolchains), installed
once per version into the shared `agnts-toolchains` volume and mounted
read-only into runs; each repository keeps a package cache between runs. See
[deploy/runner/README.md](deploy/runner/README.md) and
[Languages plan.md](plans/Languages%20plan.md).

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

**Pull request reviews.** agnts also reviews the pull requests other people
open and assign to you (or ask your review on), on GitHub and GitLab, in the
repositories you added. Reviews → Sync now, or turn on Review pull requests
waiting for you to sync every five minutes. Each pull request becomes a
ticket of kind review (`API-PR42`): agnts fetches its head (forks too, from
`refs/pull/N/head` or `refs/merge-requests/N/head`) into its own clone, and a
read-only review run writes findings with the diff on the ticket page. Then
you decide: **Merge** merges it on the git host at the commit agnts reviewed
(a newer head sends it back for another review instead), **Review again**
takes your note, and **Dismiss** leaves the pull request to you on the git
host. **Post review on GitHub/GitLab** puts agnts's findings on the pull
request as one comment from your account, once per reviewed commit, and only
when you click it. agnts never pushes to a pull request. What you write when you ask for
another review or dismiss one is kept per git host user and folded into a
reviewer profile on the next review, which every later review reads: what you
care about, what you call noise, how severe you rate things. Read and edit it
(or add notes) on the Reviews page. New commits on a reviewed pull request
are reviewed again, and one merged or closed on the git host ends its
review. Merging needs the GitHub token's Contents: Read and write permission.

**CI watching.** agnts watches GitHub Actions and GitLab pipelines and
turns red builds into work; see [CI plan.md](plans/CI%20plan.md).
- *agnts's own pull requests:* when CI fails on a pull request agnts opened,
  the failed jobs' errors go back to its ticket as feedback and it codes a fix
  (Settings → CI → feedback rounds, 2 by default). The fix goes through checks
  and review again and is pushed to the same pull request after you approve.
- *Watched branches:* turn it on per repository (Repositories → CI). The
  default branch is always watched; add globs such as `release/*`. A failed
  run is triaged without Claude: logs are read and redacted, infra failures
  (lost runners, rate limits, no disk) are set aside, a new failure is
  re-run once and marked flaky if it passes, and the same failure on many
  commits is one entry (a fingerprint of the failing tests or first error).
  A confirmed failure gets **Fix it**, or a `CI-n` ticket by itself with
  Settings → CI → auto-fix (at most 5 a day by default). The ticket compares
  the failing commit with the last green one, reproduces the failure, and
  fixes it on a branch from the current default branch, or writes a report
  when the cause is not in the code. Nothing is pushed before you
  approve. A green run resolves the entry; failing again after the fix was
  merged reopens it as a regression.
- *Other people's pull requests:* off, or one diagnosis comment per pull
  request (what failed, whether `main` fails the same way). agnts never
  pushes to their branches. Runs from forks are never given to Claude.
- *Token:* GitHub needs **Actions: Read** (logs) and **Actions: Read and
  write** (re-runs); GitLab needs `api`. The CI tab shows what is missing.

**Preview.** For front-end work a diff is not enough, so agnts can show the
change running. Give a repository a preview command and port (Repositories →
Preview): when a change touches its UI files, a preview run starts the app
in a container, Claude opens the pages the diff affects, and the ticket's
Preview tab shows screenshots at desktop and phone width with console errors
and visual problems it noticed. Tick Compare with the default branch on a
ticket for before/after shots. Add to feedback attaches a screenshot to
Request changes, and the coding run gets the image. Like the code review it
is advice, never a gate, and runs again for each revision. With Let coding
runs look at the app on (Settings → Previews), Claude also checks the pages
it changed before it finishes. A staging API the app calls goes under
Settings → Previews → Allowed hosts; the preview environment (KEY=value) is
stored encrypted. Screenshots are kept on disk under the data dir and
deleted 30 days after a ticket is done.

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

You need a Linux server (Ubuntu 22.04/24.04 or Debian 12, amd64) with at
least 2 vCPU, 4 GB RAM and 25 GB free disk (recommended: 4 vCPU, 8 GB RAM,
80 GB SSD), a domain, and an access key from your cabinet at
https://agnts.uz/cabinet/keys. One key is good for one install.
`agnts capacity root@203.0.113.10` checks a server without installing
anything; `agnts install` runs the same check first and stops, changing
nothing, when the server is too small.

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
agnts capacity          # CPU, memory, disk and disk speed against what agnts needs
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

There is no CI workflow for this repository for now (it was using up the
GitHub Actions minutes); run `make test` and `make lint` before merging.
agnts-muse keeps its own CI. Tagging `v*` runs `.github/workflows/release.yml`,
which publishes the images to `registry.agnts.uz` and the CLI to agnts.uz.

Run containers sit on the internal `agnts-runs` network; the `egress`
service is their only way out and allows the Claude API, GitHub, GitLab.com,
the toolchain downloads (nodejs.org, go.dev, static.rust-lang.org, Adoptium,
dot.net, ...) and the package registries of the supported languages (npm,
PyPI, crates.io, Maven Central, NuGet, RubyGems, Packagist, Hex, pub.dev, ...).
Add hosts (a self-hosted GitLab, a private registry) under Settings → Previews → Allowed hosts;
`AGNTS_EGRESS_ALLOW` replaces the built-in list.

Prometheus metrics are served on `AGNTS_METRICS_ADDR` (for example `:9090`),
which Caddy does not expose.

Backups land in `/opt/agnts/backups` nightly at 03:00. Copy them off the server
with `agnts backup --pull` (or rclone, restic, or similar); scheduled off-site
copies are not automated yet.
