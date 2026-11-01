# Runner image

The container image every Claude Code run uses: Debian, a pinned Claude Code
(on its own Node, in `/opt/claude`), [mise](https://mise.jdx.dev), PHP with
Composer, the system libraries native builds link against, and Chromium for
previews.

## Languages: toolchains

Language toolchains are not baked into the image. Each repository has a list
of toolchains (`go@1.24`, `node@20`, `python@3.12`, `rust@stable`,
`java@temurin-21`, `dotnet@8`, `ruby@3.3`, ...), detected from its files
(`mise.toml`, `.tool-versions`, `go.mod`, `.nvmrc`, `package.json`,
`.python-version`, `pyproject.toml`, `rust-toolchain.toml`, `pom.xml`,
`build.gradle`, `global.json`, `*.csproj`, `.ruby-version`, `Gemfile`,
`mix.exs`, `pubspec.yaml`, ...) or set by hand under Repositories.

Before a run, agnts makes sure they are installed:

1. A **provision container** (this image, same hardening, egress proxy) mounts
   the shared volume `agnts-toolchains` read-write at `/opt/toolchains` and
   runs `mise install tool@version ...` with arguments agnts built and checked
   itself. It never sees repository code, so no repository config, plugin or
   hook runs. Only backends that download prebuilt, checksummed artifacts are
   enabled (core, aqua, ubi, github, http); asdf and vfox plugins and the
   npm/pipx/cargo/go/gem backends are off (`MISE_DISABLE_BACKENDS`).
   A version is installed once; later runs reuse it.
2. The **run container** mounts `agnts-toolchains` **read-only** and gets the
   toolchains' bin directories on `PATH` and their variables (`JAVA_HOME`,
   `GOROOT`, `RUSTUP_TOOLCHAIN`, ...). mise itself never runs there.
3. Each repository has a **package cache** volume, `agnts-cache-repo-<id>`,
   at `/home/agent/.cache`: Go modules, npm, pip, uv, Cargo, Maven, Gradle,
   NuGet, gems, Hex, pub and the Python virtualenv
   (`/home/agent/.cache/venv-<version>`, active in every run) survive between
   runs. One volume per repository, so a run cannot poison another
   repository's dependencies. agnts empties a cache that grows past
   `AGNTS_CACHE_MAX_GB` (5 GB) when no run uses it.

Claude Code always runs on `/opt/claude/node`, called by full path, so a
repository pinned to an old Node never changes the Node Claude runs on. That
Node is also last on `PATH`, a fallback for repositories without a Node
toolchain.

PHP and Composer come from Debian (PHP has no prebuilt mise backend), so a
PHP repository's toolchain is `php@system`.

### What does not work this way

- **Flutter** writes into its own SDK directory, which is read-only here.
- **Android** builds need the Android SDK; **iOS/macOS** builds need macOS.
- **.NET Framework** (not .NET 5+) needs Windows.
- Anything else that needs a system package the image does not have.

For these, build a custom image on the server and set it under Repositories →
Advanced → Runner image. It must be built `FROM` this image (agnts checks the
`agnts.runner` label) and keep its user and paths:

```dockerfile
FROM registry.agnts.uz/agnts-runner:latest
USER root
RUN apt-get update && apt-get install -y --no-install-recommends libvips-dev \
 && rm -rf /var/lib/apt/lists/*
USER agent
```

    docker build -t agnts-runner-vips:1 .

Runs of that repository then use it with the same hardening; toolchains are
still installed with mise unless the image already has what the checks need.

## Security

`managed-settings.json` is installed at `/etc/claude-code/managed-settings.json`,
the highest-priority settings file, so a repository's own `.claude/settings.json`
cannot override it. agnts runs Claude with `--permission-mode dontAsk`: only the
allowed tools run, and the deny list always wins.

The managed settings also lock out a repository's own agent configuration:
`allowManagedHooksOnly` keeps hooks from the repository's `.claude/` files
from running, and `enableAllProjectMcpServers: false` with an empty
`allowedMcpServers` keeps its `.mcp.json` servers from starting. Without this,
a pull request from someone else's fork, reviewed by agnts, could run its own
commands next to the Claude token. `TestHostileRepoInRunner` (below) proves it
against the real image.

The deny list is a guard rail, not the security boundary. A determined agent
could reach a denied command indirectly (`bash -c ...`). What actually protects
you:

- the container never holds a push token; pushes happen on the server after
  you approve;
- the root filesystem is read-only, all capabilities are dropped,
  `no-new-privileges` is set, and CPU, memory and PIDs are limited;
- toolchains are read-only in runs; only the provision container, which never
  sees repository code, writes them;
- the container is destroyed after each run.

A repository's build environment (Repositories → Advanced, KEY=value lines such
as registry tokens) is given to every run container. Claude can read it, so use
read-only tokens.

## agnts-guard: the hooks inside every run

The managed settings register four Claude Code hooks, all served by one
static binary, `agnts-guard` (server/cmd/agnts-guard):

| Hook | Event | What it does |
| --- | --- | --- |
| `pre` | PreToolUse, every tool | Refuses edits that add credentials or dotenv files, skip or focus tests, silence linters, delete tests or change check configuration (by profile), enforced team rules, and, in the fact-check group, the first edit of a file until Claude states its callers and public surface. Delivers a stall notice from the server. |
| `post` | PostToolUse, edits and commands | Runs the per-file checks (gofmt, eslint, ruff, ...) on the edited file and sends problems back; reminds Claude of warn-only team rules. |
| `stop` | Stop | The stop gate: build and lint (and tests in strict) must pass before Claude may finish; at most 3 rounds, then agnts's own checks take over. |
| `session` | SessionStart (compact, resume) | Gives Claude back `/agnts/out/progress.md`, its plan and progress. |

The server does not bake the binary into this image: the agnts server image
carries it (`/usr/local/bin/agnts-guard`, or `AGNTS_GUARD_BIN`) and the runner
copies it into every run at `/home/agent/.agnts/bin/agnts-guard`, so the guard
always matches the server's version. A run without it (an older server, or
`make dev-server` without `make dev-guard`) works as before: the hooks exit 0.
What to enforce comes with each Claude invocation in `AGNTS_GUARD_CONFIG`;
decisions are logged to `/agnts/out/.guard/guard.jsonl`, which the server reads
after the run. Every guard has a check on the server after the run (the diff
scan, the checks), so a guard Claude works around never lets work through
unchecked. Like the deny list, the guard is a guard rail inside the container
boundary, not the boundary itself.

Team knowledge (the brief, business context, precedents, review checklists)
is written to `/agnts/context`, a volume of its own: the root file system is
read-only, and before this volume existed those files never reached runs.

## agnts-api: the Swagger test client

Swagger test runs call the API under test only through `agnts-api`. It is
not a separate install: it is the agnts-guard binary run under another name.
The runner links `~/.local/bin/agnts-api` to `/home/agent/.agnts/bin/agnts-guard`
in every run (and `agnts-guard api ...` does the same).

    agnts-api run <plan.json>             every case of the plan, in order
    agnts-api GET /path [--query k=v] [--json '{...}'] [--no-auth | --auth wrong]
    agnts-api describe <METHOD /path>     one operation with its schemas
    agnts-api fetch-spec <url>            download a spec (agnts runs this, not Claude)

It sends through the egress proxy (`HTTPS_PROXY`, as the runner sets it) to
the test's base URL host only, adds the credential from
`/agnts/context/api/.auth` (which agnts-guard keeps every tool away from),
refuses writes in a read-only test, keeps to the rate, request and
auth-failure caps, and logs every exchange to `/agnts/out/api/log.jsonl`.
The egress proxy lets the run reach the base URL by a per-container grant,
after checking the host resolves to a public address. Grants need
`AGNTS_GATEWAY_SECRET` on agnts and the egress proxy (a gateway is not
needed).

## Codex CLI

Runs whose model is `codex:<model>` use Codex CLI instead of Claude Code. The
image installs the version pinned in the Dockerfile (`ARG CODEX_VERSION`). To
build another one, or none (an empty value):

    docker compose --profile build build --build-arg CODEX_VERSION=<version> runner

Codex runs need an OpenAI API key (Integrations → OpenAI) and `api.openai.com`
among the hosts runs may reach (Settings → Preview → allowed hosts). They have
no hooks, so agnts-guard's in-run checks do not apply; the server's checks
after the run, the diff scan and stall detection do.

## Previews

The image also carries Chromium (through Playwright, pinned in
`preview/package.json`) and two commands that preview runs use:

- `agnts-preview start|stop|status|logs|base` starts the repository's app
  from `/agnts/out/preview-config.json`, with the environment in
  `/agnts/out/preview.env` (KEY=value lines, never evaluated), and waits until
  it answers. `base` checks out the default branch where the change started
  and restarts the app, for before shots.
- `agnts-shot <url> --viewport desktop|phone --out <file.png>` takes one
  screenshot (optionally after `--fill` and `--click` steps) and prints the
  page's console errors and failed requests. It only opens localhost URLs;
  the app's own calls go through the egress proxy like everything else.
- `agnts-act <steps.json>` runs scripted steps (goto, fill, click, press,
  expectText, expectUrl, expectVisible, request with expectStatus and
  expectBody, shot) against the app, for the acceptance check of a ticket's
  criteria. It stops at the first failed step, keeps a screenshot of it, and
  only reaches localhost.

## Smoke tests after a rebuild

Toolchains (installs Python and Node into a scratch volume, then uses them
read-only as the agent user):

    docker volume create agnts-smoke-tc
    docker run --rm -v agnts-smoke-tc:/opt/toolchains agnts-runner:latest \
      mise install python@3.12 node@lts
    docker run --rm --read-only --tmpfs /tmp:rw,exec -v /home/agent \
      -v agnts-smoke-tc:/opt/toolchains:ro agnts-runner:latest bash -c '
        export PATH=$(ls -d /opt/toolchains/installs/python/3.12/bin):$(ls -d /opt/toolchains/installs/node/lts*/bin | head -1):$PATH
        python3 -c "import ssl, sqlite3; print(\"python ok\")" && node -e "console.log(\"node ok\")" &&
        (touch /opt/toolchains/x 2>/dev/null && echo WRITABLE || echo "toolchains read-only") && claude --version'
    docker volume rm agnts-smoke-tc

Or the Go test, which goes through agnts's own provisioning:

    cd server && AGNTS_TEST_RUNNER_IMAGE=agnts-runner:latest go test ./internal/runner -run TestProvisionDocker -v

Previews:

    docker run --rm --read-only --cap-drop ALL --tmpfs /tmp:rw,exec,size=1g \
      -v /workspace -v /home/agent -v /agnts/out agnts-runner:latest bash -c '
        cd /workspace && echo "require(\"http\").createServer((q,s)=>s.end(\"hi\")).listen(4173)" > s.js &&
        echo "{\"command\":\"node s.js\",\"port\":4173}" > /agnts/out/preview-config.json &&
        agnts-preview start && agnts-shot http://localhost:4173/ --viewport phone --out /tmp/x.png'

agnts-guard and the lockdown (needs Docker, this image, and a Claude token;
it builds agnts-guard for Linux itself):

    cd server && AGNTS_TEST_DOCKER=1 AGNTS_TEST_CLAUDE_TOKEN=sk-ant-... go test ./internal/runner -run 'Hostile|WriteFile' -v

agnts-api in this image, against a tiny API in the container (builds
agnts-guard for Linux itself):

    cd server && AGNTS_TEST_DOCKER=1 go test ./internal/runner/ -run TestAgntsAPIInContainer

agnts-act (after a preview has started, in the same container):

    echo '{"steps":[{"goto":"/"},{"expectText":"hi"},{"shot":"home"}]}' > /tmp/s.json && agnts-act /tmp/s.json
