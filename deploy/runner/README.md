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
