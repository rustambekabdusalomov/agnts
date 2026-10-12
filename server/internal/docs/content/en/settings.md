# Settings

How agnts connects to your tools and behaves during runs. Changes apply after you press Save changes.

## Appearance

Theme and language. Saved in this browser and applied right away.

## Jira and GitHub

Where tickets come from, which label agnts picks up, and whose name commits are made under.

## Claude Code

Which model runs each stage, the turn limit and timeout, and which commands Claude Code may or may never run.

**Coding on Codex** runs coding on Codex CLI instead of Claude Code: connect OpenAI under Integrations and add api.openai.com to the allowed hosts. Codex runs have no agnts-guard hooks; agnts's checks after the run apply as usual.

## Runs

Defaults for questions, resuming after limits, when to stop starting new runs, and how many run at once.

## Guardrails

agnts-guard checks Claude's work inside every run, as it happens; agnts's checks after the run still apply. The **profile** decides how strict it is: *Minimal* refuses credentials and dotenv files, enforces team rules that have a pattern, and wants a green build before Claude finishes; *Standard* also refuses skipped tests, silenced linters, deleted tests and changes to check configuration, adds lint to that stop gate and checks each edited file; *Strict* also runs the tests in the stop gate, refuses swallowed errors and removed assertions, and, for a share of tickets, asks Claude for facts (who uses a file, how to undo a destructive command) before its first edits, so Analytics can compare. A person lifts one refusal for a ticket by writing `agnts: allow skipped_test` (or another kind) in the ticket or an answer.

Also here: what agnts does when a run **looks stuck** (note it, or tell Claude to step back once), **Prove bug fixes** (a test that fails before the change and passes after it), **Deep review** (specialist passes for security, silent failures, tests and types; *Auto* for large or complex work), **Learn from runs** (tips from runs that had trouble) and a **Second opinion** model that reads the chosen approach of complex tickets. **Advanced** turns single guard hooks off.

## Previews

Screenshots of every UI change in repositories with a preview command, the model that picks the pages and judges them, whether coding runs may look at the app themselves, and the extra hosts run containers may reach (a staging API your app calls).

## Private networks

Tunnels into your own networks for a self-hosted GitLab, Jira, Plane or package registry that is only reachable over a VPN. A workspace can keep several, one per company, office or data center. For each, pick **agnts-link** (a small agent you run inside the network; it connects out, needs no VPN credentials and relays webhooks), **WireGuard** or **OpenVPN** (paste the client config), then list its routes: the hosts, domains (.corp.local) or private ranges that go through it. A connection goes through the network whose route matches it most closely: an exact host beats a domain, a longer domain beats a shorter one, a narrower range beats a wider one. Two networks can't list the same route; a narrower route inside another network's is fine. Everything else goes out as before. Add each network's company CA if its hosts use internal certificates, and use **Test** to see which network a host:port goes through before you connect an integration. Code agnts runs for your tickets can reach every listed host, so list only what it needs.

## Notifications

Telegram messages when something needs you, a run stops, or changes are pushed.

## Secrets

Tokens live in your server's environment and are never shown on this page.
