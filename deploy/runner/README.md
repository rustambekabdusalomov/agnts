# Runner image

The container image every Claude Code run uses: Debian, Node 22, Go 1.26,
git, build tools, and a pinned Claude Code.

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
- the container is destroyed after each run.

Network egress is not yet restricted to the git host, package registries and
the Claude API; that allowlist is part of the phase 5 hardening pass.

To add a toolchain (Python, Rust, ...), extend the Dockerfile and rebuild.
