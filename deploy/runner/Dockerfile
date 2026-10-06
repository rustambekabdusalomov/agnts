# agnts run container: Claude Code plus the toolchains the checks need.
# Build on the server:  docker compose --profile build build runner
#
# Every run gets a fresh container from this image with a read-only root
# filesystem; only /workspace, /home/agent, /agnts/out and /tmp are writable.

FROM golang:1.26-trixie AS go

FROM node:22-trixie-slim

# Pin Claude Code: agnts parses its stream-json output, including the
# undocumented rate_limit_event, so upgrades are deliberate.
ARG CLAUDE_CODE_VERSION=2.1.289

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash ca-certificates coreutils curl git jq make build-essential procps ripgrep tar \
 && rm -rf /var/lib/apt/lists/*

COPY --from=go /usr/local/go /usr/local/go

RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
 && npm cache clean --force

# The node image's user has uid 1000; agnts's archives expect "agent" there.
RUN userdel -r node \
 && useradd --uid 1000 --create-home --home-dir /home/agent --shell /bin/bash agent \
 && mkdir -p /workspace /agnts/out /home/agent/.claude \
 && chown -R agent:agent /workspace /agnts /home/agent

# Managed settings outrank anything in the repository's .claude/ folder, so
# a ticket's repo cannot loosen the deny list.
COPY managed-settings.json /etc/claude-code/managed-settings.json

ENV HOME=/home/agent \
    PATH=/usr/local/go/bin:/home/agent/go/bin:/home/agent/.npm-global/bin:$PATH \
    GOPATH=/home/agent/go \
    GOCACHE=/home/agent/.cache/go-build \
    GOFLAGS=-buildvcs=false \
    NPM_CONFIG_CACHE=/home/agent/.npm \
    NPM_CONFIG_PREFIX=/home/agent/.npm-global \
    DISABLE_AUTOUPDATER=1 \
    CI=true

USER agent
WORKDIR /workspace
RUN git config --global init.defaultBranch main \
 && git config --global advice.detachedHead false

CMD ["sleep", "infinity"]
