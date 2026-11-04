# agnts run container: Claude Code, mise, and the system libraries native
# builds need. Language toolchains are not baked in: agnts installs the
# ones a repository needs (tool@version, read from its go.mod, .nvmrc,
# .python-version, mise.toml, ...) with mise into the shared volume
# mounted at /opt/toolchains, once per version, and mounts it read-only
# into every run.
# Build on the server:  docker compose --profile build build runner
#
# Every run gets a fresh container from this image with a read-only root
# filesystem; only /workspace, /home/agent, /agnts/out and /tmp are writable
# (and /home/agent/.cache, the repository's package cache volume).

# Pinned like Claude Code: mise decides how every toolchain is installed.
FROM jdxcode/mise:2026.10.3 AS mise
# Claude Code's own Node, kept apart from whatever Node a repository uses.
FROM node:22-trixie-slim AS node

FROM debian:trixie-slim

# Pin Claude Code: agnts parses its stream-json output, including the
# undocumented rate_limit_event, so upgrades are deliberate.
# Claude Code is a native binary that needs a CPU with SSE4.2/AVX: on a VM
# that hides them (CPU type "QEMU Virtual CPU", kvm64) it starts, then spins
# at 100% CPU with no output.
ARG CLAUDE_CODE_VERSION=2.1.299

# Custom runner images are built FROM this one; agnts checks the label.
LABEL agnts.runner="1"

# Tools (ffmpeg cuts meeting audio into the clips Muse hears), the native
# libraries that pip, gem, cargo, mix and friends link
# against (they cannot be installed at run time: the root is read-only),
# ICU for .NET, and PHP with Composer (PHP has no prebuilt mise backend).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash bzip2 ca-certificates coreutils curl file git jq less make procps ripgrep tar unzip xz-utils zstd \
      ffmpeg \
      build-essential pkg-config autoconf automake libtool cmake \
      libssl-dev libffi-dev zlib1g-dev libbz2-dev liblzma-dev libreadline-dev libncurses-dev libsqlite3-dev \
      libgdbm-dev libgmp-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev libpq-dev \
      default-libmysqlclient-dev libjpeg-dev libpng-dev uuid-dev libicu76 libkrb5-3 libunwind8 \
      php-cli php-curl php-mbstring php-xml php-zip php-intl php-bcmath php-gd php-sqlite3 php-pgsql php-mysql composer \
      fonts-noto-core fonts-noto-mono fonts-dejavu-core \
 && rm -rf /var/lib/apt/lists/*

COPY --from=mise /usr/local/bin/mise /usr/local/bin/mise
COPY --from=node /usr/local /opt/claude/node

# Claude Code is a native binary in a per-platform optional package. npm
# skips an optional package it fails to download, which leaves a stub that
# only fails once a run starts ("claude native binary not installed"), so
# retry slow downloads and fail the build unless claude actually runs.
RUN export PATH=/opt/claude/node/bin:$PATH \
 && npm install -g --prefix /opt/claude --fetch-retries=5 --fetch-timeout=600000 "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
 && /opt/claude/bin/claude --version \
 && npm cache clean --force \
 && rm -rf /root/.npm
# `claude` always runs on /opt/claude/node, by absolute path, so the
# repository's Node (first on PATH) never changes the Node Claude runs on.
COPY claude-wrapper /usr/local/bin/claude

# Muse Code (Meta), agnts's primary coding tool. Pinned like Claude Code:
# agnts speaks its session protocol (MSP, `muse serve`), checked against
# the schema of this release. The binary comes straight from Meta's
# release manifest and is verified against its sha256; the self-updating
# launcher is not installed, so a run never changes its Muse version.
ARG MUSE_VERSION=1.4.13-R6996.1
RUN set -eu; \
    case "$(uname -m)" in x86_64) p=x86_linux ;; aarch64|arm64) p=aarch64_linux ;; *) echo "no Muse build for $(uname -m)"; exit 1 ;; esac; \
    curl -fsSL --retry 5 "https://lookaside.facebook.com/lookaside/muse/download/?channel=muse&version=${MUSE_VERSION}&file=manifest.json" -o /tmp/muse.json; \
    url="$(jq -r --arg p "$p" '.artifacts[$p].url' /tmp/muse.json)"; \
    sum="$(jq -r --arg p "$p" '.artifacts[$p].checksum' /tmp/muse.json)"; \
    curl -fsSL --retry 5 "$url" -o /usr/local/bin/muse; \
    echo "$sum  /usr/local/bin/muse" | sha256sum -c -; \
    chmod 0755 /usr/local/bin/muse; rm /tmp/muse.json; \
    /usr/local/bin/muse --version

# Codex CLI, one of agnts's coding modules, pinned like Claude Code since
# agnts parses its `codex exec --json` stream. It runs on Claude's Node too.
# --build-arg CODEX_VERSION= (empty) leaves it out.
ARG CODEX_VERSION=0.166.0
RUN if [ -n "$CODEX_VERSION" ]; then \
      export PATH=/opt/claude/node/bin:$PATH \
   && npm install -g --prefix /opt/codex --fetch-retries=5 "@openai/codex@${CODEX_VERSION}" \
   && printf '#!/bin/sh\nexec /opt/claude/node/bin/node /opt/codex/lib/node_modules/@openai/codex/bin/codex.js "$@"\n' > /usr/local/bin/codex \
   && chmod 0755 /usr/local/bin/codex && /usr/local/bin/codex --version \
   && npm cache clean --force && rm -rf /root/.npm; \
    fi

# Previews: Chromium (with its system libraries) through Playwright, and
# the two commands preview runs use. The browsers live outside $HOME so the
# read-only root filesystem keeps them intact; Playwright is pinned in
# preview/package.json like Claude Code is here.
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright
COPY preview/package.json /opt/agnts-shot/package.json
RUN cd /opt/agnts-shot \
 && export PATH=/opt/claude/node/bin:$PATH \
 && npm install --omit=dev --no-audit --no-fund \
 && npx playwright install --with-deps --only-shell chromium \
 && npm cache clean --force \
 && rm -rf /var/lib/apt/lists/* /root/.npm
COPY preview/agnts-shot.mjs /opt/agnts-shot/agnts-shot.mjs
COPY preview/agnts-act.mjs /opt/agnts-shot/agnts-act.mjs
COPY preview/agnts-preview /usr/local/bin/agnts-preview
RUN printf '#!/bin/sh\nexec /opt/claude/node/bin/node /opt/agnts-shot/agnts-shot.mjs "$@"\n' > /usr/local/bin/agnts-shot \
 && printf '#!/bin/sh\nexec /opt/claude/node/bin/node /opt/agnts-shot/agnts-act.mjs "$@"\n' > /usr/local/bin/agnts-act \
 && chmod 0755 /usr/local/bin/agnts-shot /usr/local/bin/agnts-act /usr/local/bin/agnts-preview /usr/local/bin/claude /opt/agnts-shot/agnts-shot.mjs /opt/agnts-shot/agnts-act.mjs

# Security testing: pinned scanners, each checked against its sha256 (from
# the release's checksum file, or computed when the release has none:
# opengrep). agnts-sec runs them with fixed flags, offline: their update
# checks and telemetry are off, and the vulnerability databases come from
# the read-only volume at /opt/secdb, filled by agnts's daily updater.
# agnts ships its own opengrep rules (security/rules): the community rule
# sets carry licenses that forbid a hosted service. See plans/Security plan.md.
ARG OPENGREP_VERSION=1.33.1
ARG GITLEAKS_VERSION=8.30.1
ARG OSV_SCANNER_VERSION=2.7.0
ARG TRIVY_VERSION=0.76.1
RUN set -eu; \
    case "$(uname -m)" in \
      x86_64) og=x86; og_sum=46e8133cc490f9f50518061590ce2f6be5a08afaeda034471c0ceda4b3899808; \
              gl=x64; gl_sum=551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb; \
              osv=amd64; osv_sum=160c6253e2922e9e0a6a9771c5c4c40a4b3c6090b34a3cdd5e80c96cc2e4218b; \
              tv=64bit; tv_sum=c7cbe3137fb8a48a17574bede3dd6beb16742d1e9772929940fc90082c39d9c0 ;; \
      aarch64|arm64) og=aarch64; og_sum=d1433f63a90b8bc0b6ad4b498a13b372b856ce9a754a43484ba4920fe2d76dcf; \
              gl=arm64; gl_sum=e4a487ee7ccd7d3a7f7ec08657610aa3606637dab924210b3aee62570fb4b080; \
              osv=arm64; osv_sum=4061ef4c021ed3c47f203b818f337e351336cc5cd67c0274fc36bd1dfc728dd7; \
              tv=ARM64; tv_sum=e174dff2a6dba5e3ae41f8d0537a6324405bd08132497340304c6b20e0f16a1f ;; \
      *) echo "no security scanners for $(uname -m)"; exit 1 ;; \
    esac; \
    gh=https://github.com; \
    curl -fsSL --retry 5 -o /usr/local/bin/opengrep "$gh/opengrep/opengrep/releases/download/v${OPENGREP_VERSION}/opengrep_manylinux_${og}"; \
    echo "$og_sum  /usr/local/bin/opengrep" | sha256sum -c -; \
    curl -fsSL --retry 5 -o /tmp/gl.tgz "$gh/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${gl}.tar.gz"; \
    echo "$gl_sum  /tmp/gl.tgz" | sha256sum -c -; \
    tar -xzf /tmp/gl.tgz -C /usr/local/bin gitleaks; \
    curl -fsSL --retry 5 -o /usr/local/bin/osv-scanner "$gh/google/osv-scanner/releases/download/v${OSV_SCANNER_VERSION}/osv-scanner_linux_${osv}"; \
    echo "$osv_sum  /usr/local/bin/osv-scanner" | sha256sum -c -; \
    curl -fsSL --retry 5 -o /tmp/trivy.tgz "$gh/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${tv}.tar.gz"; \
    echo "$tv_sum  /tmp/trivy.tgz" | sha256sum -c -; \
    tar -xzf /tmp/trivy.tgz -C /usr/local/bin trivy; \
    rm -f /tmp/gl.tgz /tmp/trivy.tgz; \
    chmod 0755 /usr/local/bin/opengrep /usr/local/bin/gitleaks /usr/local/bin/osv-scanner /usr/local/bin/trivy; \
    opengrep --version && gitleaks version && osv-scanner --version && trivy --version
COPY security/rules/*.yaml /opt/agnts-sec/rules/
COPY security/agnts-sec /usr/local/bin/agnts-sec
RUN chmod 0755 /usr/local/bin/agnts-sec && chmod -R a+rX /opt/agnts-sec

# agnts's archives expect the "agent" user at uid 1000. /opt/toolchains,
# /opt/secdb and /home/agent/.cache are owned by it so the volumes mounted
# there start out writable for it.
RUN useradd --uid 1000 --create-home --home-dir /home/agent --shell /bin/bash agent \
 && mkdir -p /workspace /agnts/out /agnts/context /home/agent/.claude /home/agent/.cache /home/agent/.local/bin /opt/toolchains /opt/secdb \
 && chown -R agent:agent /workspace /agnts /home/agent /opt/toolchains /opt/secdb

# Managed settings outrank anything in the repository's .claude/ folder, so
# a ticket's repo cannot loosen the deny list.
COPY managed-settings.json /etc/claude-code/managed-settings.json

# mise only ever runs in agnts's provision container, with explicit
# tool@version arguments. Backends that run third-party scripts or package
# installs (asdf and vfox plugins, npm, pipx, cargo, go, gem, spm) are off:
# toolchains come from prebuilt, checksummed artifacts (core, aqua, ubi,
# github, http). Rust's rustup homes live in the volume too.
ENV MISE_DATA_DIR=/opt/toolchains \
    MISE_CACHE_DIR=/opt/toolchains/.cache \
    MISE_STATE_DIR=/home/agent/.local/state/mise \
    MISE_DISABLE_BACKENDS=asdf,vfox,npm,pipx,cargo,go,gem,spm \
    MISE_YES=1 \
    MISE_PYTHON_COMPILE=0 \
    MISE_RUSTUP_HOME=/opt/toolchains/rustup \
    MISE_CARGO_HOME=/opt/toolchains/cargo \
    MISE_NODE_COREPACK=1

# Writable bin dirs first, the system next. Claude's Node 22 comes last: a
# fallback for repositories without a Node toolchain, never ahead of theirs.
ENV HOME=/home/agent \
    PATH=/home/agent/.local/bin:/home/agent/go/bin:/home/agent/.npm-global/bin:/home/agent/.cache/cargo/bin:/home/agent/.cache/gems/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/claude/node/bin \
    NPM_CONFIG_PREFIX=/home/agent/.npm-global \
    DISABLE_AUTOUPDATER=1 \
    CI=true

USER agent
WORKDIR /workspace
RUN git config --global init.defaultBranch main \
 && git config --global advice.detachedHead false

CMD ["sleep", "infinity"]
