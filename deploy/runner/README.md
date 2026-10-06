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

Smoke test after a rebuild:

    docker run --rm --read-only --cap-drop ALL --tmpfs /tmp:rw,exec,size=1g \
      -v /workspace -v /home/agent -v /agnts/out agnts-runner:latest bash -c '
        cd /workspace && echo "require(\"http\").createServer((q,s)=>s.end(\"hi\")).listen(4173)" > s.js &&
        echo "{\"command\":\"node s.js\",\"port\":4173}" > /agnts/out/preview-config.json &&
        agnts-preview start && agnts-shot http://localhost:4173/ --viewport phone --out /tmp/x.png'
