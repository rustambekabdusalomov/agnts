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
ARG CLAUDE_CODE_VERSION=2.1.289

# Custom runner images are built FROM this one; agnts checks the label.
LABEL agnts.runner="1"

# Tools, the native libraries that pip, gem, cargo, mix and friends link
# against (they cannot be installed at run time: the root is read-only),
# ICU for .NET, and PHP with Composer (PHP has no prebuilt mise backend).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash bzip2 ca-certificates coreutils curl file git jq less make procps ripgrep tar unzip xz-utils zstd \
      build-essential pkg-config autoconf automake libtool cmake \
      libssl-dev libffi-dev zlib1g-dev libbz2-dev liblzma-dev libreadline-dev libncurses-dev libsqlite3-dev \
      libgdbm-dev libgmp-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev libpq-dev \
      default-libmysqlclient-dev libjpeg-dev libpng-dev uuid-dev libicu76 libkrb5-3 libunwind8 \
      php-cli php-curl php-mbstring php-xml php-zip php-intl php-bcmath php-gd php-sqlite3 php-pgsql php-mysql composer \
 && rm -rf /var/lib/apt/lists/*

COPY --from=mise /usr/local/bin/mise /usr/local/bin/mise
COPY --from=node /usr/local /opt/claude/node

RUN PATH=/opt/claude/node/bin:$PATH npm install -g --prefix /opt/claude "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
 && PATH=/opt/claude/node/bin:$PATH npm cache clean --force \
 && rm -rf /root/.npm
# `claude` always runs on /opt/claude/node, by absolute path, so the
# repository's Node (first on PATH) never changes the Node Claude runs on.
COPY claude-wrapper /usr/local/bin/claude

# Previews: Chromium (with its system libraries) through Playwright, and
# the two commands preview runs use. The browsers live outside $HOME so the
# read-only root filesystem keeps them intact; Playwright is pinned in
# preview/package.json like Claude Code is here.
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright
COPY preview/package.json /opt/agnts-shot/package.json
RUN cd /opt/agnts-shot \
 && export PATH=/opt/claude/node/bin:$PATH \
 && npm install --omit=dev --no-audit --no-fund \
 && npx playwright install --with-deps chromium \
 && npm cache clean --force \
 && rm -rf /var/lib/apt/lists/* /root/.npm
COPY preview/agnts-shot.mjs /opt/agnts-shot/agnts-shot.mjs
COPY preview/agnts-preview /usr/local/bin/agnts-preview
RUN printf '#!/bin/sh\nexec /opt/claude/node/bin/node /opt/agnts-shot/agnts-shot.mjs "$@"\n' > /usr/local/bin/agnts-shot \
 && chmod 0755 /usr/local/bin/agnts-shot /usr/local/bin/agnts-preview /usr/local/bin/claude /opt/agnts-shot/agnts-shot.mjs

# agnts's archives expect the "agent" user at uid 1000. /opt/toolchains and
# /home/agent/.cache are owned by it so the volumes mounted there start out
# writable for it.
RUN useradd --uid 1000 --create-home --home-dir /home/agent --shell /bin/bash agent \
 && mkdir -p /workspace /agnts/out /home/agent/.claude /home/agent/.cache /home/agent/.local/bin /opt/toolchains \
 && chown -R agent:agent /workspace /agnts /home/agent /opt/toolchains

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
