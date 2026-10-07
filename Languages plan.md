# agnts Any-Language Runs — Plan

Oct 7, 2026 · implemented (phases 1, 2, 3)

## Overview

Every run uses one image, `deploy/runner/Dockerfile`: `node:22-trixie-slim` with Go 1.26 copied in. A repository written in anything else (Python, Rust, Java/Kotlin, .NET, Ruby, PHP, Elixir, Dart and so on) clones and Claude can read it, but `build`, `lint` and `test` fail with `command not found`, and Claude cannot run anything to check its work. Even Go and Node repos break when they need a version other than 1.26 or 22.

What is hardcoded today:

| Where | What |
| --- | --- |
| `deploy/runner/Dockerfile` | Only Node 22 and Go 1.26; `GOPATH`, `GOCACHE`, `NPM_*` env |
| Root filesystem | Read-only, so nothing can `apt install` or drop a toolchain in at run time |
| `runner.go` `Open` | `/home/agent` is a fresh anonymous volume, so every run downloads all dependencies again |
| `egress.DefaultAllow` | Go, npm/yarn and PyPI registries only; crates.io, Maven, NuGet, RubyGems and the like are blocked |
| `RepoDrawer.vue` | Placeholders `go build ./...`, `go test ./...` |
| `domain.Repository.Stack` | Stored, but nothing sets or reads it |
| Claude Code itself | Runs on the image's Node, so a repo that needs Node 18 would also change the Node Claude runs on |

**Goals**

- A repository in any mainstream language gets working build, lint and test checks with no image rebuild and no work on the server.
- The toolchain version comes from the repository (`go.mod`, `.nvmrc`, `.python-version`, `rust-toolchain.toml`, `.tool-versions`, `mise.toml`, ...), not from what the image happens to ship.
- Still fits the 2 GB VPS: the base image gets smaller, not bigger.
- The run container stays as locked down as today: read-only root, no capabilities, egress allowlist, no secrets.
- Escape hatch for anything unusual: a per-repository custom image.

**Out of scope:** iOS/macOS builds (Xcode needs macOS), Android SDK and emulators, Windows-only .NET Framework, GPU work, and running the repository's own `Dockerfile`/devcontainer automatically (building untrusted Dockerfiles on the host daemon is a separate security problem; see Decisions).

## Approach

Three options were considered:

| Option | For | Against |
| --- | --- | --- |
| **A. One fat image** with every toolchain | Simple | 8 to 10 GB, one version per language, rebuild for every new language. Does not fit the VPS |
| **B. One image per language** (`agnts-runner-python`, ...) | Small images | Polyglot repos (Go API with a Vue admin, like this one) need two; still one version each; N images to build and release |
| **C. Small base image plus toolchains installed on demand** into a shared, cached volume, with versions read from the repository | Any language and version, installed once, then cached | A provisioning step and a cache volume to manage |

**Choice: C**, using [mise](https://mise.jdx.dev) as the installer. It is one static binary, reads all the usual version files (`.nvmrc`, `.python-version`, `.tool-versions`, `rust-toolchain.toml`, `.java-version`, `go.mod`'s `go` line through agnts), and installs prebuilt toolchains for Node, Python, Go, Rust, Java, Ruby, .NET, Deno, Bun, Erlang/Elixir, Zig, Dart/Flutter, Kotlin, PHP and hundreds more through its core, aqua and ubi backends. Plus **option D-lite**: a repository can name its own image built `FROM agnts-runner`, for system libraries or tools mise cannot provide.

## How it works

```
repo added / default branch changes
  └─ detect (server, from the git mirror): markers + version files → Toolchains, suggested commands
run starts
  ├─ provision (if a toolchain is missing from the cache)
  │    short container, no Claude, no repo code executed:
  │    mise install go@1.24.2 node@20.11.1 python@3.12   → volume agnts-toolchains
  └─ run container (unchanged hardening)
       /opt/toolchains   ← agnts-toolchains, mounted READ-ONLY
       /home/agent/.cache ← agnts-cache-<repo id>, read-write (package caches)
       PATH = toolchain bin dirs for this repo, then the base image
       Claude Code runs on its own Node in /opt/claude, independent of the repo's Node
```

### Detection

A new `toolchain` package in the server reads the default branch from the existing git mirror (no container needed) and returns:

```go
type Toolchain struct {
    Tool    string // mise name: "go", "node", "python", "rust", "java", "dotnet", "ruby", ...
    Version string // exact or prefix: "1.24.2", "20", "3.12", "temurin-21"
    Source  string // "go.mod", ".nvmrc", "mise.toml", "default"
    Dir     string // "" or a subdirectory: "apps/admin" for a monorepo
}
```

Order of precedence per tool: `mise.toml` / `.mise.toml` / `.tool-versions` → the language's own version file (`.nvmrc`, `.node-version`, `package.json` `engines.node` and `packageManager`, `.python-version`, `pyproject.toml` `requires-python`, `rust-toolchain(.toml)`, `go.mod` `toolchain`/`go`, `.java-version`, `global.json`, `.ruby-version`, `pubspec.yaml` `environment.sdk`) → a default (latest LTS/stable) when only a marker exists (`Cargo.toml`, `pom.xml`, `build.gradle(.kts)`, `*.csproj`, `Gemfile`, `composer.json`, `mix.exs`, `pubspec.yaml`, ...).

Detection scans the root and one or two directory levels down, so `server/go.mod` and `apps/admin/package.json` in this repo are both found.

It also suggests check commands from a table, used only as defaults the user confirms:

| Marker | Build | Lint | Test |
| --- | --- | --- | --- |
| `go.mod` | `go build ./...` | `go vet ./...` | `go test ./...` |
| `package.json` + lockfile | `<pm> ci/install && <pm> run build` | `<pm> run lint` (if script exists) | `<pm> test` (if script exists) |
| `pyproject.toml` (uv/poetry/pip) | `uv sync` / `poetry install` / `pip install -e .` | `ruff check .` if configured | `pytest` |
| `Cargo.toml` | `cargo build --locked` | `cargo clippy -- -D warnings` | `cargo test` |
| `pom.xml` | `./mvnw -q -DskipTests package` | — | `./mvnw -q test` |
| `build.gradle(.kts)` | `./gradlew assemble` | — | `./gradlew test` |
| `*.sln` / `*.csproj` | `dotnet build` | `dotnet format --verify-no-changes` | `dotnet test` |
| `Gemfile` | `bundle install` | `bundle exec rubocop` if present | `bundle exec rspec` / `rake test` |
| `composer.json` | `composer install` | — | `vendor/bin/phpunit` |
| `mix.exs` | `mix deps.get && mix compile` | `mix format --check-formatted` | `mix test` |
| `pubspec.yaml` | `dart pub get` / `flutter pub get` | `dart analyze` | `dart test` / `flutter test` |
| `Makefile` with `build`/`test` targets | `make build` | `make lint` | `make test` |

Monorepos get commands prefixed with `cd <dir> && ` and joined with `&&`. When nothing matches, the fields stay empty and the admin panel says so; Claude still works, just without checks.

Optional (phase 3): when the table finds nothing, a cheap analyze-model run reads the repo's README, CI files (`.github/workflows/*.yml`, `.gitlab-ci.yml`) and build files and proposes toolchains and commands as JSON. The CI file is usually the best source for how a project really builds.

### Provisioning

Before opening a workspace the orchestrator asks the runner for the repo's toolchains. Each `tool@version` is resolved to an exact version and checked against the cache volume. Missing ones are installed by a **provision container**:

- same image, same hardening, egress proxy, read-only root;
- `agnts-toolchains` mounted **read-write** here and only here;
- runs only `mise install <tool>@<version> ...` with arguments agnts built from parsed values. No repository files are in this container, so no repo config, plugin or hook can run code during install;
- only mise backends that download prebuilt, checksummed artifacts are enabled (core, aqua, ubi). asdf/vfox plugins (arbitrary shell scripts) are disabled with `MISE_DISABLE_BACKENDS`;
- one provision at a time per `tool@version` (singleflight, like translations); its output goes to the run's events as a `toolchain` step, so the live log shows "installing python 3.12.7 (first use, about 40 s)".

Versions are validated (`^[a-z0-9.+-]+$`) before they reach the command line.

### The run container

- `/opt/toolchains` (the volume) is mounted **read-only**: a ticket can never change a toolchain that another repository's run will use.
- `PATH` gets the exact install dirs for this repo's toolchains (`/opt/toolchains/installs/python/3.12.7/bin`, ...), resolved by agnts, not mise shims, so nothing reads repo config at command time. `MISE_*` env is not set inside the run.
- Language env moves out of the Dockerfile into a per-tool table in the runner: `GOPATH`, `GOCACHE`, `GOFLAGS=-buildvcs=false`, `CARGO_HOME`, `npm_config_cache`, `PIP_CACHE_DIR`, `UV_CACHE_DIR`, `GRADLE_USER_HOME`, `MAVEN_OPTS=-Dmaven.repo.local=...`, `NUGET_PACKAGES`, `BUNDLE_PATH`, `DOTNET_CLI_TELEMETRY_OPTOUT=1`, ... all pointing under `/home/agent/.cache`.
- **Package caches**: `/home/agent/.cache` becomes a named volume per repository, `agnts-cache-<repo id>`, instead of part of the anonymous home volume. Per repository, not shared, so one repo's run cannot poison another's dependencies. A size cap (default 5 GB) is enforced by a sweep that deletes the volume when it is over and lets the next run refill it.
- **Claude Code's own Node** moves to `/opt/claude/node` and the `claude` wrapper calls it by full path. The repo's Node on `PATH` never affects Claude.

### Base image (`deploy/runner/Dockerfile`)

Smaller and language-neutral:

- `debian:trixie-slim`, plus `mise` (pinned, checksum-verified), Claude Code with its own Node, Playwright/Chromium for previews (unchanged);
- the common native build dependencies that pip/gem/cargo builds need and that cannot be installed later because the root is read-only: `build-essential pkg-config libssl-dev libffi-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev libpq-dev libxml2-dev libyaml-dev unzip xz-utils`;
- Go and project Node no longer baked in; they come through provisioning like everything else. To keep the first run of the two existing stacks fast, the CLI's `setup` step pre-provisions `go@latest` and `node@lts` into the volume.

### Egress

Add to `DefaultAllow` (only registries and toolchain download hosts):

- toolchains: `nodejs.org`, `go.dev`, `dl.google.com`, `static.rust-lang.org`, `api.adoptium.net`, `.adoptium.net`, `builds.dotnet.microsoft.com`, `dotnetcli.azureedge.net`, `.github.com`/`.githubusercontent.com` (already there; python-build-standalone, aqua and ubi assets), `storage.googleapis.com` (already there; Dart/Flutter);
- registries: `crates.io`, `index.crates.io`, `static.crates.io`, `repo.maven.apache.org`, `repo1.maven.org`, `plugins.gradle.org`, `services.gradle.org`, `api.nuget.org`, `rubygems.org`, `index.rubygems.org`, `repo.packagist.org`, `pub.dev`, `repo.hex.pm`, `builds.hex.pm`.

Private registries (company Nexus/Artifactory) are added through the existing extra allowlist in Settings. Registry credentials are phase 3.

## Repository settings

New fields, editable in the repository drawer:

| Field | Default | Notes |
| --- | --- | --- |
| Toolchains | detected | List of `tool@version`, each with its source ("from .nvmrc"). Editable; an override is stored and wins over detection |
| Build / Lint / Test | suggested | Same fields as today; placeholders come from detection instead of `go build ./...` |
| Runner image | empty | Custom image, see below |
| Memory | server default | Per-repo override for heavy builds (JVM, Rust); capped by the server limit |

`Stack` (already in the table, unused) is filled with the detected tool names (`go,node`) and shown as chips in the repository list.

The drawer gets a **Detect again** button, and the server re-detects when the default branch's version files change (checked on each sync).

### Custom image (escape hatch)

For needs mise cannot cover (Oracle JDK, a C library not in the base image, a vendored SDK): the admin builds an image `FROM registry.agnts.uz/agnts-runner:<version>`, adds what they need, and sets it on the repository. agnts checks on save that the image exists locally and has the `agnts.runner=1` label and `/opt/claude`; runs then use it with the same hardening. Documented in `deploy/runner/README.md` with an example.

## Changes by package

### Runner image (`deploy/runner/`)
New base as above; `/opt/toolchains` created and owned by `agent`; `mise` config at `/etc/mise/config.toml` disabling plugin backends and setting `MISE_DATA_DIR=/opt/toolchains`. README rewritten ("To add a toolchain, extend the Dockerfile" goes away).

### Domain (`server/internal/domain/`)
`Toolchain` type; `Repository` gets `Toolchains []Toolchain`, `ToolchainsOverride bool`, `RunnerImage string`, `MemoryMB int`.

### Migration `server/migrations/00020_toolchains.sql`
`repositories`: `toolchains jsonb not null default '[]'`, `toolchains_override boolean not null default false`, `runner_image text not null default ''`, `memory_mb int not null default 0`.

### New package `server/internal/toolchain/`
`Detect(fs.FS) (Detection, error)` returning toolchains and suggested commands; pure, table-driven, tested against fixture trees under `testdata/` (one per language plus a monorepo). The orchestrator calls it through the existing git mirror.

### Runner (`server/internal/runner/`)
- `Provision(ctx, []Toolchain) ([]Resolved, error)`: resolve, check cache, run the provision container.
- `Open`: mounts `agnts-toolchains` read-only and `agnts-cache-<repo>`; builds `PATH` and per-tool env; uses `spec.Image` from the repo when set; memory override.
- `docker.go`: `ContainerConfig.Volumes` becomes a list of mounts with name, target and read-only, so named volumes can be used.

### Orchestrator (`server/internal/orchestrator/`)
- `WorkspaceSpec` gets `Toolchains` and `CacheKey`; every `runner.Open` call site (code run, review, preview, rules, translate) passes them. Translate and rules runs pass none.
- A `toolchain` step before the first check, with events.
- Prompt: a short "Environment" section listing the toolchains on `PATH` with versions, the check commands, and "do not try to install other toolchains or use sudo/apt; if something is missing, say so in the summary". Today Claude wastes turns discovering this.
- When a check fails with exit 127 (`command not found`), the result says "toolchain missing" instead of a build failure and the ticket page links to the repository's Toolchains setting, rather than burning the two fix-up retries on it.

### Egress (`server/internal/egress/`)
New hosts above, grouped by language in comments.

### API (`shared/openapi/openapi.yaml`, then `make gen`)
Repository schema gets the new fields; `POST /repos/{id}/detect` returns a detection without saving it.

### Server CLI (`server/cmd/agnts/cli.go`)
`repo add` runs detection when `--build/--lint/--test` are not given and prints what it chose; `--toolchain go@1.24 --toolchain node@20` overrides.

### Admin panel (`apps/admin/`)
`RepoDrawer.vue`: Toolchains editor with source hints, detected placeholders, Detect again, Runner image and Memory under "Advanced". `ImportDrawer.vue`: shows detected stack per repository before import. Repository list: stack chips. i18n keys in EN/RU/UZ.

### Mobile (`apps/mobile/`)
Stack chips on the repository screen; nothing editable.

### Rust CLI (`cli/`)
`setup`: create `agnts-toolchains` and pre-provision Go and Node LTS. `status`: show toolchain volume size and cache volumes. `capacity.rs`: count the toolchain volume (about 0.3 to 1 GB per toolchain version) in the disk check.

## Phases

**1 — Any language works.** New base image with mise, provisioning, read-only toolchain volume, per-tool env, Claude on its own Node, egress hosts, `Toolchains` field set by hand in the drawer and CLI. Done when a Python (uv + pytest), a Rust and a Java (Gradle) sample repo each go through a ticket with green checks, and this repo still does.

**2 — Zero setup.** Detection package, suggested commands, Detect again, import shows stacks, prompt Environment section, exit-127 handling, per-repo package caches.

**3 — Hard cases.** Custom runner image per repo, memory override, AI-assisted detection from CI files, private registry credentials (sealed like preview env, written to `.npmrc`/`pip.conf`/`settings.xml` in the container, never shown to Claude in the prompt).

## Testing

- `toolchain` package: fixture trees per language, monorepo, conflicting version files (mise.toml must win), garbage versions rejected.
- Runner: `Open` builds the right mounts, `PATH` and env for a mix of toolchains (unit, no Docker); provision skips cached versions.
- Integration (behind the existing Docker test flag): provision `python@3.12` then run `python -c 'import ssl, sqlite3'` in a run container with the volume read-only, and check that writing to `/opt/toolchains` fails.
- End-to-end samples in `scripts/samples/` (Python, Rust, Java, .NET, Ruby): a fixed ticket each, run in CI weekly, not on every push.

## Security

- The toolchain volume is shared across repositories, so it is writable only in the provision container, which never sees repository code and only runs `mise install` with validated arguments, prebuilt-artifact backends and checksum checks.
- Package caches are per repository, so cache poisoning stays inside the repository that did it.
- Same container hardening as today for every run, including custom images (agnts sets the hardening, not the image).
- New egress hosts are package registries and official download hosts only.

## Costs and limits

- Disk: base image about 1.5 GB (down from about 2.5 GB). Toolchains 100 MB (Go, Node) to 1 GB (.NET, Flutter) each, once per version. Package caches capped at 5 GB per repository.
- First run with a new toolchain: plus 20 to 90 s for provisioning; later runs: nothing. Dependency installs become warm after the first run thanks to the cache volume, which also helps Go and Node repos today.
- Memory: JVM, Rust and .NET builds can need more than the default container limit; on the 2 GB VPS a single heavy build is the practical limit. The per-repo memory override and a clear "killed (out of memory)" check message (exit 137) cover this.

## Decisions

- **mise over per-language images or a fat image:** one mechanism for every language and version, cached, and the base image shrinks.
- **agnts parses version files, not mise:** mise would read `mise.toml` hooks and env from the repo; agnts reads only versions and passes them explicitly.
- **No automatic use of the repo's Dockerfile/devcontainer:** building an untrusted Dockerfile on the host daemon runs arbitrary code outside the run sandbox. A custom image built by the admin covers the same need deliberately.
- **Go and Node are no longer special:** they go through the same path, pre-provisioned only for speed.

## Where the build differs from the draft

- **Image size.** The base image is 2.5 GB, about what it was, not the 1.5 GB the draft guessed: Chromium for previews and the native build libraries outweigh the Go toolchain that left. Toolchains now cost disk only for the versions repositories actually use.
- **Re-detection runs on every run**, from the branch being worked on (the checkout is already on disk, and the scan reads a few small files), not only when Jira or a webhook syncs. A ticket that bumps `.nvmrc` gets the new Node in its next run.
- **Check commands are filled in only when a repository has none at all.** Detection never overwrites a command someone typed.
- **Java defaults to Temurin** (`java@temurin-21`): mise's plain `java@21` resolves to an old OpenJDK GA build without updates.
- **PHP is `php@system`**: PHP only has asdf/vfox plugins in mise, which stay disabled, so PHP 8.4 and Composer ship in the image.
- **Flutter is not supported by toolchains** (its SDK writes into its own directory, which is read-only); detection says so and points to a custom image. Android and .NET Framework likewise.
- **Exit 137 (out of memory) also stops without fix attempts**, like exit 127, and names the memory setting.
- **Importing a repository runs detection when its drawer opens**, rather than for every row of the import list (each detection is a clone).
- **`agnts server -- repo add` clones and detects right away**; `--no-detect` leaves it to the first run, `repo detect <name>` runs it again.
- **JVM builds need the proxy spelled out.** Java ignores `HTTPS_PROXY`: runs get `JAVA_TOOL_OPTIONS` with the proxy properties (Gradle, sbt), and the run setup writes `~/.m2/settings.xml` with a `<proxies>` block (Maven reads nothing else).
- **More egress hosts than drafted**, found by provisioning through the real proxy: `.jdx.dev` (mise's Java index), `tuf-repo-cdn.sigstore.dev`, `sh.rustup.rs`, `downloads.python.org`, `dot.net`.
- **mise's output is colored even without a TTY**; the provisioner sets `NO_COLOR` and strips ANSI codes so "installed python@3.12.15" reaches the ticket log.

## How to test

See the report in the conversation, or in short:

- `cd server && go test ./internal/toolchain ./internal/runner ./internal/admin ./internal/orchestrator`
- with the dev database: `AGNTS_TEST_DATABASE_URL=... make test`
- with Docker: `docker build -t agnts-runner:dev deploy/runner`, then
  `AGNTS_TEST_RUNNER_IMAGE=agnts-runner:dev go test ./internal/runner -run TestProvisionDocker -v`
  (add `AGNTS_TEST_ALL_LANGUAGES=1` and `-run TestProvisionLanguagesDocker` for Rust, Java, .NET, Ruby, Elixir and PHP).
