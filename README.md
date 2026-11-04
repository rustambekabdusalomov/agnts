# agnts

**An AI engineering teammate for your whole team, powered by Meta's Muse Code.**

agnts is a self-hosted agent. It takes tickets from Jira, Plane, chats and
meetings, and codes them with Muse Code in isolated containers. It also reads
your logs, scans your repositories for security holes, reviews pull requests,
writes up your meetings and answers your team's questions in chat. Nothing is
pushed without a person's approval.

> **Meta AI developer hackathon, Indie Developer track.** agnts drives Muse Code
> through **[agnts-muse](https://github.com/rustambekabdusalomov/agnts-muse)**,
> our open-source Go module (MIT) that runs Muse under a hard, live-enforced
> budget over Muse's session protocol (MSP): per-call metering, mid-turn
> steering, interrupts, in-session model escalation and tool approvals.
> Start there to see how Muse is integrated; this repository is the product
> built on it.
> What changed during the hackathon: [Built during the hackathon](#built-during-the-hackathon).

- Live: [agnts.uz](https://agnts.uz) (website), [app.agnts.uz](https://app.agnts.uz) (admin panel)
- Plans and design notes: [`plans/`](plans), starting with
  [Muse plan.md](plans/Muse%20plan.md) and
  [Implementation plan.md](plans/Implementation%20plan.md)

## Built during the hackathon

The hackathon work starts on 26 October 2026. The tag
[`pre-hackathon`](https://github.com/rustambekabdusalomov/agnts/tree/pre-hackathon) marks the last commit before it
(`1766a46`, 25 October), so one link shows everything that changed since:

**[Compare pre-hackathon...master](https://github.com/rustambekabdusalomov/agnts/compare/pre-hackathon...master)**
(over 200 commits; every pull request from #1 on)

[agnts-muse](https://github.com/rustambekabdusalomov/agnts-muse) was started during the hackathon (first commit on
27 October): all of its history is hackathon work.

| Feature | Built | Where |
| --- | --- | --- |
| Muse Code as the primary coding module | During | [agnts-muse](https://github.com/rustambekabdusalomov/agnts-muse) (whole repo), [`server/internal/ai/providers/musecode`](server/internal/ai/providers/musecode), [`2041641`](https://github.com/rustambekabdusalomov/agnts/commit/2041641) |
| Sign in with Meta, free credits, budget per run, live spend meter | During | [`be6ac02`](https://github.com/rustambekabdusalomov/agnts/commit/be6ac02), [`b06bd5d`](https://github.com/rustambekabdusalomov/agnts/commit/b06bd5d), [`dcd14d7`](https://github.com/rustambekabdusalomov/agnts/commit/dcd14d7), [#7](https://github.com/rustambekabdusalomov/agnts/pull/7) |
| Code mode: tickets driven from a conversation, `@repo` mentions | During | [#1](https://github.com/rustambekabdusalomov/agnts/pull/1), [#3](https://github.com/rustambekabdusalomov/agnts/pull/3), [#4](https://github.com/rustambekabdusalomov/agnts/pull/4) |
| Voice questions to the assistant (Muse transcribes) | During | [`63a189b`](https://github.com/rustambekabdusalomov/agnts/commit/63a189b) |
| Meetings: LiveKit calls, Muse notes, draft tickets per member | During | [#6](https://github.com/rustambekabdusalomov/agnts/pull/6), [#42](https://github.com/rustambekabdusalomov/agnts/pull/42), [#44](https://github.com/rustambekabdusalomov/agnts/pull/44), [`server/internal/meetings`](server/internal/meetings) |
| Saved work: a stopped run's change is picked up by the next | During | [#13](https://github.com/rustambekabdusalomov/agnts/pull/13) |
| Coding modules per person (Muse, Claude, Codex) | During | [#17](https://github.com/rustambekabdusalomov/agnts/pull/17), [#18](https://github.com/rustambekabdusalomov/agnts/pull/18), [#20](https://github.com/rustambekabdusalomov/agnts/pull/20), [#21](https://github.com/rustambekabdusalomov/agnts/pull/21), [`server/internal/modules`](server/internal/modules) |
| AI gateway: one service for every model call, retry on the next route | During | [#22](https://github.com/rustambekabdusalomov/agnts/pull/22), [#23](https://github.com/rustambekabdusalomov/agnts/pull/23), [`server/internal/ai`](server/internal/ai) |
| Log watcher: log sources, OpenTelemetry, grouped findings, Fix it | During | [#24](https://github.com/rustambekabdusalomov/agnts/pull/24), [#43](https://github.com/rustambekabdusalomov/agnts/pull/43), [#58](https://github.com/rustambekabdusalomov/agnts/pull/58), [`server/internal/logwatch`](server/internal/logwatch) |
| Team chat with `@agnts`: memory, citations, voice messages, files | During | [#33](https://github.com/rustambekabdusalomov/agnts/pull/33), [#34](https://github.com/rustambekabdusalomov/agnts/pull/34), [#40](https://github.com/rustambekabdusalomov/agnts/pull/40), [#48](https://github.com/rustambekabdusalomov/agnts/pull/48), [#50](https://github.com/rustambekabdusalomov/agnts/pull/50), [`server/internal/chat`](server/internal/chat) |
| Security testing: scans, findings judged by Muse, Fix this, verify | During | [#47](https://github.com/rustambekabdusalomov/agnts/pull/47), [#52](https://github.com/rustambekabdusalomov/agnts/pull/52), [#53](https://github.com/rustambekabdusalomov/agnts/pull/53), [#55](https://github.com/rustambekabdusalomov/agnts/pull/55), [#56](https://github.com/rustambekabdusalomov/agnts/pull/56), [#63](https://github.com/rustambekabdusalomov/agnts/pull/63), [`server/internal/security`](server/internal/security) |
| Performance reviews from delivered complexity | During | [#59](https://github.com/rustambekabdusalomov/agnts/pull/59), [`server/internal/perfreview`](server/internal/perfreview) |
| Tickets from Jira and Plane, coded in isolated containers, PR after approval | Before | [`server/internal/orchestrator`](server/internal/orchestrator), [`server/internal/runner`](server/internal/runner) |
| Code review, pull request reviews, CI watching | Before | [`server/internal/ciwatch`](server/internal/ciwatch), [`server/internal/vcs`](server/internal/vcs) |
| UI previews with screenshots, Learn, team rules, queue order | Before | [`deploy/runner/preview`](deploy/runner/preview), [`plans/`](plans) |
| AI Chat assistant and the MCP server | Before | [`server/internal/mcpserver`](server/internal/mcpserver) |
| Documents and slides | Before | [`server/internal/documents`](server/internal/documents) |
| Private networks (VPN to a workspace's servers) | Before | [`server/internal/privnet`](server/internal/privnet) |
| Installer CLI, mobile app, website | Before | [`cli/`](cli), [`apps/mobile/`](apps/mobile), [`apps/website/`](apps/website) |

"Before" features keep getting work during the hackathon. For example, the
ticket flow moved to Muse Code, and code review gained a read-only view
([#30](https://github.com/rustambekabdusalomov/agnts/pull/30)).

## What it does

| Area | What agnts does | Muse Code's part |
| --- | --- | --- |
| **Tickets** | Labelled Jira or Plane issues, or a message in Code mode, become tickets. agnts analyses the code, asks questions or codes the change, runs your build, lint and tests, and opens the PR once you approve. | Analysis, coding and fix rounds, under a live budget; a person can steer a running turn and approve risky calls ([agnts-muse](https://github.com/rustambekabdusalomov/agnts-muse)) |
| **Assistant** | AI Chat answers questions about the workspace. Code mode drives tickets from a conversation, with `@repo` mentions. You can also ask by voice. | Answers, code changes, `muse voice transcribe` |
| **Meetings** | Video calls on self-hosted LiveKit, with recordings. | Transcribes the call and writes the notes. Action items become draft tickets on the member who took them. |
| **Log watcher** | Reads Loki, Elasticsearch, OpenSearch, Graylog, Datadog, CloudWatch, Splunk or OpenTelemetry. Groups errors and security mistakes by cause and reports them or opens a fix ticket. | Fixes the cause |
| **Security testing** | Scans repositories with opengrep, gitleaks, osv-scanner and trivy, keeps findings across scans, and re-scans to verify a fix. It also checks agnts's own changes while they wait for review. | Judges each hit, audits what scanners miss, fixes findings ("Fix this") |
| **Team chat** | Channels where members and agnts work together. Cards have buttons that act (Fix it, Approve, Merge). Voice messages and files. "Turn into ticket". | `@agnts` answers from the workspace's memory, with checked citations, in the language you asked in |
| **Reviews and CI** | Code review of every change, reviews of other people's PRs, CI failure triage and fixes, UI previews with screenshots. | Reviewer and fixer |
| **Team insight** | Learn (lessons from new patterns in the code), team rules, queue order by dependencies and conflicts, performance reviews from delivered complexity. | Lessons, rule checks, complexity scores |

agnts runs on Muse Code by default. Claude Code and Codex are optional
modules (see below). The web admin panel and the Flutter mobile app are in
English, Russian and Uzbek.

## Muse Code

Muse Code is agnts's primary coding module; Claude Code and Codex are the
others. `AGNTS_PROVIDERS` lists the ones this server can run; within it, the
platform Admin chooses the modules the server offers and who may use which
(Admin → Modules, and Set modules on Admin → Users), and each person orders
their own (Profile). Every model call goes through one AI gateway
(`server/internal/ai`), which picks the module, account and payer and, when
a call fails early (an account at its limit, a refused credential), runs it
again on the next route.

agnts drives Muse with
[agnts-muse](https://github.com/rustambekabdusalomov/agnts-muse), which speaks
Muse's session protocol (`muse serve`) inside each run container
(`server/internal/ai/providers/musecode`):

- **Live cost.** Every model call is charged as Muse reports it and shows on the
  ticket's log; a run on credits holds money ahead of its spend and is told to
  wrap up at 80% of its budget, then stopped before the call that would pass it.
- **A person in the loop.** People following a run send it messages mid-turn
  (MSP `turn/steer`), and calls the rules leave to a person, such as installing
  a dependency, wait for their Allow or Deny.
- **Escalation without a restart.** A Spark session that keeps failing moves to
  Wonder in the same session, with its context.
- **agnts's rules decide tool calls.** The guard vetoes `git push`, reading
  secrets, piping downloads into a shell and the like through Muse's approvals.
- **Voice.** Spoken questions, team chat voice messages and meeting recordings
  are transcribed with `muse voice transcribe`.
- **Accounts.** A person or workspace connects Muse by signing in with Meta
  (Muse Code's own `muse login`) or with a Meta Model API key. Without one,
  runs use agnts's key (`AGNTS_MUSE_PLATFORM_KEY`) and are paid with credits:
  first the person's **free credits** (set by an Admin per person, 0 by
  default; Admin → Users), then the workspace's bought credits, under a
  monthly cap for the whole server (`AGNTS_MUSE_GLOBAL_CAP_USD`) and an
  optional monthly limit per person.

## Getting started

agnts imports agnts-muse from a sibling folder (`replace` directives in
`server/go.mod`), so clone both side by side:

```sh
git clone https://github.com/rustambekabdusalomov/agnts.git
git clone https://github.com/rustambekabdusalomov/agnts-muse.git
cd agnts
```

The server image builds with
`docker build --build-context agnts-muse=../agnts-muse .` (`make image` does;
`MUSE_DIR` overrides the path). The runner image (`deploy/runner/`) installs
Muse Code, Claude Code and Codex for the run containers.

## Layout

| Path | What |
| --- | --- |
| `server/` | Go server: REST API, auth, orchestrator, runner, AI gateway, MCP server, log watcher, security, meetings, chat |
| `server/cmd/` | `agnts` (the server and its commands), `agnts-guard` (the tool guard inside run containers), `agnts-link` |
| `apps/admin/` | Admin panel: Vue 3 + Vite, served by the Go binary |
| `apps/website/` | Public website (agnts.uz): Nuxt 3, fully static build in EN/RU/UZ |
| `apps/mobile/` | Mobile app: Flutter (iOS and Android) |
| `shared/openapi/` | OpenAPI spec, the contract for both clients and the server |
| `shared/i18n/` | EN/RU/UZ dictionaries (ICU MessageFormat) |
| `deploy/` | Docker Compose stack: Caddy, agnts, PostgreSQL, egress proxy, LiveKit, nightly backups; the runner image; Loki and demo services for the log watcher |
| `cli/` | Rust CLI that installs and manages agnts on a server; see [CLI plan.md](plans/CLI%20plan.md) |
| `plans/` | Design plans for each feature, with notes on where the build differs |
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
`make gen` and commit the generated files.

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
- **OpenTelemetry:** Collectors and SDKs send OTLP/HTTP logs (protobuf or
  JSON, gzip) to `/webhooks/logs/v1/logs`. A source's trace link template
  (`{traceId}`) links each finding to its trace in Tempo, Jaeger or Grafana.
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

## Meetings

Video calls for a workspace's members and their guests, on a self-hosted
**LiveKit** server; **LiveKit Egress** records them. agnts is the control
plane: who joins, with what rights, and what happened. See
[Meetings plan.md](plans/Meetings%20plan.md) and
[Meeting tasks plan.md](plans/Meeting%20tasks%20plan.md).

- **Calls:** reusable links (`/m/abc-defg-hij`), instant or scheduled; camera,
  mic, screen sharing, chat, hands and reactions; host and co-host controls;
  guests knock and are admitted. Email invitations carry an `.ics`.
- **Notes:** Muse transcribes the recording and writes the notes as a
  document. Each action item becomes a held draft ticket on the member who
  took it: the spoken name is matched to a member in Latin or Cyrillic, and
  "I'll do it" resolves to the speaker. A recording of a meeting held
  elsewhere can be uploaded too: agnts keeps only its sound and writes the
  same notes and drafts.
- **Today's meeting** sits in the header: its time and title, a Join button
  15 minutes before, and Live while it runs.

## Security testing

agnts scans repositories, keeps their findings across scans and fixes them
through ordinary tickets. See [Security plan.md](plans/Security%20plan.md);
its status section lists what is built.

- **Scans:** in a run container, `agnts-sec` runs opengrep (with agnts's own
  rules for SQL built from input in Go, Python, JavaScript, Java and PHP),
  gitleaks (the whole git history on the first scan), osv-scanner and trivy
  config, offline, against vulnerability databases the server keeps up to date.
- **Judged by the agent:** Muse (or the workspace's module) judges each hit,
  audits what tools miss (authorization, IDOR, mass assignment) and writes
  each finding with its location, source and confidence.
- **Fix this** opens a ticket for a finding. After the fix merges, a verify
  scan checks it is gone; fixes merged close together share one scan.
- **agnts's own changes** get a security check beside the code review while
  they wait for approval. It is advice and never blocks Approve.
- **Schedules and alerts:** scans on a schedule, notices in Telegram, and the
  `list_security_findings` / `get_security_finding` MCP tools, so the
  assistant can answer "what's our worst open security issue?".

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
build, lint and tests inside the container and sends failures back to the
coding agent up to twice; you review the diff and approve; only then does agnts push
`agnts/<KEY>` and open the pull request.

**Code review.** While a ticket waits for your review, a review run reads
the result in a read-only container (the diff with its checks, or the
report against the code) and writes findings next to it: severity,
category, file and line, and a suggestion you can add to your feedback in
one click. It is advice, never a gate: approving or requesting changes
cancels a review still running, and each new revision is reviewed again.
With the review model on Auto (Settings), the strong model reviews tickets the
analysis rated complex or large changes, and the light one the rest. Turn it off in
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
  run is triaged without a model: logs are read and redacted, infra failures
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
  pushes to their branches. Runs from forks are never given to the agent.
- *Token:* GitHub needs **Actions: Read** (logs) and **Actions: Read and
  write** (re-runs); GitLab needs `api`. The CI tab shows what is missing.

**Preview.** For front-end work a diff is not enough, so agnts can show the
change running. Give a repository a preview command and port (Repositories →
Preview): when a change touches its UI files, a preview run starts the app
in a container, the agent opens the pages the diff affects, and the ticket's
Preview tab shows screenshots at desktop and phone width with console errors
and visual problems it noticed. Tick Compare with the default branch on a
ticket for before/after shots. Add to feedback attaches a screenshot to
Request changes, and the coding run gets the image. Like the code review it
is advice, never a gate, and runs again for each revision. With Let coding
runs look at the app on (Settings → Previews), the agent also checks the pages
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
the two disagree). Saving a rule queues a short review run in a container
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
  generated code, translation files), make a conflict. Relations the agent reads
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
credential of their coding module and a copy of the repository, never the
GitHub token.

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
service is their only way out and allows Meta's API (Muse), the Claude and OpenAI APIs, GitHub, GitLab.com,
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

## License

Copyright © 2026 Rustambek Abdusalomov. All rights reserved. The source is
published so it can be read and evaluated; no license to use, copy, modify or
distribute it is granted.

[agnts-muse](https://github.com/rustambekabdusalomov/agnts-muse), the Muse
Code module agnts is built on, is open source under the MIT License. Muse Code
is Meta's, Claude Code is Anthropic's and Codex is OpenAI's.
