# agnts Security Testing — Plan

Oct 14, 2026 · draft · builds on `Preview plan.md`, `CI plan.md` and `Log watcher plan.md`
Revised Nov 4, 2026 after a review against the current code: provider-neutral (Claude or Muse), stable finding identity, scope-aware closing, log watcher overlap, egress ports and token handling, DNS-only proof by default.

"Claude" below means the agent of the run's provider: Claude Code or Muse Code, whichever the workspace's modules make the default (`domain.ToolName`). Nothing in the plan depends on which one it is.

## Implementation status (Nov 4, 2026)

**Phase 1a is built** on branch `security-scan`: runner tools and `agnts-sec`, the vulnerability-database volume and daily updater, migrations `00083_security.sql` and `00084_security_more.sql`, store, scheduler class, scan job, the `security` prompt, fingerprints and closing rules, Fix this → SEC tickets with verify-on-merge, the API, and the admin Security page, finding page, repository tab and ticket card. Phases 1b, 1c and 2 are not started.

Where 1a differs from the text below:

- **agnts's own opengrep rules** (`deploy/runner/security/rules`, 25 annotated tests) instead of a community set: `opengrep-rules` carries a Commons Clause that forbids selling a service built on it.
- **Paths:** inputs are in `/agnts/context` (`hits.json`, `security.json`, `sec-exclude.txt`), not `/agnts/in`; raw tool output stays in the container and is not stored under `DataDir` (gitleaks's raw report is deleted before the agent runs).
- **Code findings are fingerprinted by CWE + file + function**, not by rule, so two rules on one query, and the agent's report of it, are one finding. Dependencies are one finding per package and lockfile.
- **Merges are followed by polling** the fix ticket's `MergedAt` once a minute (as the log watcher does), not by a merge hook.
- **Not in 1a:** repository settings (exclusions, schedule, `MinNotify`), the security model in the Settings page (it follows the preview model), the log watcher link, Telegram, mobile screens, MCP tools, analytics. The test repository lives at `server/internal/security/testdata/vulnapp`; its fake secret is generated at test time, never committed.

## Overview

agnts writes code, reviews it and shows it running, but nobody asks the question a breach answers too late: **what in this application can be attacked, and how do I close it?** Today the code review has one security pass over the diff and nothing else. There's no dependency audit, no secret scan, no look at the running app, and no view of the repository as a whole.

This plan adds **security testing**. agnts scans a repository's code, dependencies and secrets, starts the app in the sandbox and probes it on `localhost`, and, for domains the user proves they own, scans the live site. Every weakness becomes a **finding** with its severity, evidence, why it matters and how to fix it. **Fix this** turns a finding into an ordinary agnts ticket that goes through the usual flow: analysis, code, checks, review and your approval. Once the fix merges, the next scan confirms the finding is gone.

```
Security · api                                   last scan 2h ago · nightly · ▲ 1 new
┌─────────────────────────────────────────────────────────────────────────────────────┐
│ ● critical  SQL injection in /orders search        handlers/orders.go:88   → SEC-12 │
│             confirmed on the running app: ' OR 1=1 -- returns every order           │
│ ● high      lodash 4.17.20 · prototype pollution   package-lock.json   CVE-2021-23337│
│             reachable: _.merge used in api/merge.ts:14            [Fix this]        │
│ ● high      AWS key committed                      config/dev.yml:3  (rotate first!) │
│ ● medium    Session cookie without Secure/HttpOnly https://staging.acme.com  [Fix]  │
│ ○ low       Missing Content-Security-Policy        all pages          dismissed: WIP │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

**Goals**

- A user gets a prioritized list of real weaknesses in their app, each with a concrete fix, in one click from a repository page, without installing or configuring a scanner.
- Every fix is a normal agnts ticket, so it gets the same approval guarantees as every other change. Nothing is pushed before approval.
- Findings have an identity that survives across scans: new, still open, fixed or dismissed. A nightly scan alerts on **what changed**, not on the same 40 items every night.
- agnts's own changes get a cheap security check before you approve them, as a side stage next to review and preview.
- Live scanning never touches a host the user hasn't proved they control, and it is rate-limited and non-destructive by default.

**Out of scope for v1:** authenticated scanning of live sites (login flows on production), mobile binaries (APK/IPA), cloud account posture (AWS/GCP configuration), container image scanning of registries, penetration-style exploitation chains, compliance reports (SOC 2, PCI), and rewriting git history to purge leaked secrets.

**Principles**

1. **Tools find, Claude judges.** Pinned open-source scanners do the wide, cheap sweep. Claude removes false positives using the code around each hit, checks whether a vulnerable dependency is actually reachable, looks for what scanners miss (broken authorization, IDOR, business logic), and writes the fix. A scan with no tool hits on a diff costs no Claude turns.
2. **Copy what exists.** Repository scans are ticketless repo-level jobs, like briefs. The change scan is a side stage, like preview. Fix tickets come from findings, like CI failures. The running app uses the preview configuration as it is.
3. **A finding is not a scan result.** Findings are deduplicated by fingerprint across scans, like CI failure groups. One finding has many sightings and at most one fix ticket. **agnts computes the fingerprint, never the model,** so the same weakness keeps its identity however differently it is worded from one scan to the next.
4. **Only a check that ran can close a finding.** A finding becomes `fixed` when the thing that found it ran again and didn't see it, not because it is missing from a manifest.
5. **Scope is enforced by agnts, not by the prompt.** Claude can't use `curl`. It probes through agnts scripts that refuse any target outside `localhost` and the scan's verified hosts, and the egress proxy allows a live host only to the container scanning it.
6. **Never store a secret we found.** Secret findings keep a masked value and a hash, never the value itself.
7. **One security inbox.** The log watcher already reports security hits from production logs (`exposure`, `weakness`, `attack`). Those that point at the code become findings here too (see *Log watcher*), so a person never triages the same `.env` exposure twice.

## How it works

```mermaid
flowchart LR
  T1["Run scan (repo page)"] --> Q["security_scans<br/>status=pending"]
  T2["Schedule (nightly/weekly)"] --> Q
  T3["Ticket kind: security"] --> W
  T4["agnts change<br/>security_state=pending"] --> SS["side stage: security<br/>diff only"]
  Q --> W["security run<br/>container on default branch"]
  W --> S1["agnts-sec static<br/>opengrep · gitleaks · osv-scanner · trivy config"]
  S1 --> S2["agnts-preview start<br/>(if preview command)"]
  S2 --> S3["agnts-sec dynamic<br/>nuclei + agnts-probe on localhost"]
  S3 --> L["live targets<br/>(verified hosts only)"]
  L --> C["Claude triage + audit<br/>/agnts/out/security.json"]
  SS --> C
  C --> F["security_findings<br/>dedup by fingerprint"]
  F --> UI["Admin · Mobile · Telegram"]
  F --> FX["Fix this → SEC-n ticket"]
  FX --> M["merged → rescan → fixed"]
```

### The four ways a scan starts

| Trigger | What it scans | Where it lives | Claude |
| --- | --- | --- | --- |
| **Run scan** on a repository | Whole repo at the default branch, the app on localhost when it has a preview command, and verified live targets when ticked | `security_scans` row, ticketless repo job (`ClassSecurityScan`) | Always (the `security` model of the run's provider, up to 60 turns) |
| **Schedule** per repository (off / daily / weekly) | Same as Run scan; skipped when the default branch commit and the vulnerability databases haven't changed since the last scan | Same | Always, but notifies only on new or reopened findings |
| **Side stage** on an agnts change | Changed files, changed lockfiles and new secrets in the diff. The app is probed only when the change touches routes or middleware (globs) | `Ticket.SecurityState`, `StageSecurity` | Only when a tool reports something, to triage and suggest a fix |
| **Ticket kind `security`** | What the ticket asks for ("audit the payment flow", "is our file upload safe?"), with all tools available | Ordinary ticket, report output, `Implementable` | Always; the report's findings are also saved as findings |

### A repository scan, step by step

1. The orchestrator's minute tick enqueues due schedules (`repositories.security_next_at <= now()`). **Run scan** inserts a `pending` scan directly. `ClaimSecurityScan` picks the oldest pending scan in the `security-scan` queue class. Today's ranking is rule, main, document, brief, review, preview, learn, reflect (`scheduler.go:35`); the two security classes go between preview and learn, and learn and reflect move down one. A scan, like learn and reflect, starts only when `capacity.Spare(mem)` says there is room for it, so it never delays coding and never pushes the server out of memory.
2. `runSecurityScan` opens a container like `runSurvey` does (`runner.Open(WorkspaceSpec{TicketKey: "sec-<id>"})`) on the default branch. It mounts the vulnerability-database volume `/opt/secdb` read-only (see *Vulnerability data*) and writes:
   - `/agnts/in/security.json`: the scope (static, app, live targets), the repository's exclusions, the rate limits, and the repository's **known findings**: every `open`, `fixing`, `verifying`, `reopened` and `dismissed` finding with its id, fingerprint, title, location and status (no evidence, no secret values). Claude rechecks each one and refers to it by id instead of describing it again.
   - `/agnts/in/preview.env`: the preview environment, as preview runs do
3. **Static sweep, before Claude.** agnts runs `agnts-sec static`, which runs each tool with fixed flags and writes SARIF/JSON into `/agnts/out/sec/raw/`, then a normalized `/agnts/out/sec/hits.json`:
   - **opengrep** (Semgrep-compatible, LGPL): language rules for injection, XSS, SSRF, path traversal, weak crypto, unsafe deserialization
   - **gitleaks**: secrets in the working tree and the history (the full history on a repository's first scan, capped at 10 minutes; the last 200 commits after that). `agnts-sec` counts the commits actually present first and records the depth it scanned (`scan.ran.history`), so a shallow clone shows as "history: 12 commits" instead of a silent gap.
   - **osv-scanner**: vulnerable dependencies from every lockfile, in offline mode against `/opt/secdb/osv`
   - **trivy config**: Dockerfile, Kubernetes, Terraform and Compose misconfiguration
4. **Dynamic sweep** (when the repository has a preview command). agnts runs `agnts-preview start` exactly as preview does. If it starts, `agnts-sec dynamic` runs **nuclei** with the safe template tags (`exposure, misconfig, cve, headers, tech`, excluding `dos, intrusive, fuzz, brute-force`) against `http://127.0.0.1:<port>`, and a crawl with `agnts-probe crawl` (Playwright) to collect routes, forms and API calls. An app that doesn't start is recorded on the scan as `app: failed` and the log tail, and the static results still count.
5. **Live targets** (when ticked and verified): agnts re-checks verification, issues the run a proxy credential that allows exactly those hosts (see *Live targets*), and runs the same nuclei profile and `agnts-probe` with the target's rate limit.
6. **Claude** runs with the `security` prompt, read-only permissions, the `security` model of the run's provider and `securityMaxTurns = 60` / `securityTimeoutMin = 30` (the same limits for Claude Code and Muse Code; the prompt uses only tools both have: reading files, running the allowed `agnts-*` scripts, writing `/agnts/out`). The prompt tells it to:
   - triage every hit in `hits.json`: confirm or reject it with the code it looked at, and adjust severity for reachability (a vulnerable function never called is `low`, a confirmed injection is `critical`)
   - recheck every known finding from `security.json` and report it by id as `present`, `gone` (with the code that shows it fixed) or `unchecked` (it ran out of turns or the app didn't start)
   - audit what tools miss, guided by the stack: authentication and session handling, authorization on every handler (missing ownership checks, IDOR), mass assignment, file upload, SSRF in outbound calls, CORS, rate limiting on login, and secrets in logs
   - **prove** what it can on the running app with `agnts-probe request` (a confirmed finding beats a suspected one), within the request budget
   - write a fix for each finding: an explanation, the exact change (a short patch or code block), and for secrets, "rotate first", since removing a committed key doesn't revoke it
   - write `/agnts/out/security.json`
7. agnts reads the manifest, checks it (see *Security*), fingerprints each finding (see *Fingerprints*), upserts `security_findings` (new / seen again / reopened), closes findings only by the rules in *Closing a finding*, stores raw tool output under `DataDir/security/<ws>/<repo>/<scan>/`, records the scope that **actually ran** (`scan.ran`: which tools finished, whether the app started, which targets answered, whether Claude finished or hit its limit), and appends `EventSecurity`.

### Manifest Claude writes

```json
{
  "summary": "2 critical, 3 high. The orders search builds SQL by string concatenation; confirmed on the running app.",
  "app": "ok",
  "findings": [
    {
      "id": "f1",
      "severity": "critical",
      "category": "injection",
      "cwe": "CWE-89",
      "owasp": "A03",
      "title": "SQL injection in /orders search",
      "location": { "file": "handlers/orders.go", "line": 88, "url": "/api/orders?q=" },
      "source": "claude",
      "toolRule": "go.lang.security.audit.sqli.string-formatted-query",
      "confidence": "confirmed",
      "evidence": "GET /api/orders?q=' OR 1=1 -- returned 412 rows for a user who owns 3.",
      "impact": "Any signed-in user can read every customer's orders.",
      "fix": { "explanation": "Use a parameterized query.", "patch": "--- a/handlers/orders.go\n+++ b/handlers/orders.go\n..." },
      "references": ["https://cwe.mitre.org/data/definitions/89.html"]
    }
  ],
  "rejected": [ { "toolRule": "generic.secrets.gitleaks.aws-access-token", "file": "docs/example.md", "reason": "AWS's published example key" } ],
  "known": [
    { "findingId": 41, "status": "present", "note": "still concatenated at handlers/orders.go:91" },
    { "findingId": 37, "status": "gone", "note": "lodash is 4.17.21 in package-lock.json" },
    { "findingId": 29, "status": "unchecked", "note": "needs the running app; it did not start" }
  ]
}
```

- A new finding that is really a known one (Claude sees it again at a moved location) goes into `known` as `present` with the new location, not into `findings`.
- `hits[]` ids: each finding from a tool hit names the hit (`"hit": "h12"`), so agnts can take the rule, file and package from the tool's output rather than from the model's text.

- Severities: `critical, high, medium, low, info`. CVSS is kept for dependency findings when the advisory has one.
- `confidence`: `confirmed` (reproduced on the app or unambiguous in code), `likely`, `possible`. The UI sorts by severity, then confidence.
- `rejected` hits are stored on the scan so a person can audit Claude's triage, and they don't become findings.

### Fingerprints and finding lifecycle

agnts computes every fingerprint from fields it derives itself; the model's title and wording never go into it.

| Finding from | Fingerprint fields |
| --- | --- |
| a tool hit (opengrep, trivy config) | `repo_id | tool | rule id | file | enclosing symbol` |
| a dependency (osv-scanner) | `repo_id | osv | advisory id | package | lockfile` |
| a secret (gitleaks) | `repo_id | gitleaks | rule id | file | sha256(secret)` |
| a probe or nuclei (app or live) | `repo_id | template id or probe kind | normalized route | parameter` |
| Claude only (no tool hit) | `repo_id | cwe | file | enclosing symbol`, and for routes `| method | normalized route` |

- **Enclosing symbol** is found by agnts, not reported by the model: a small symbol finder in `server/internal/security/symbol.go` (Go through `go/parser`; JavaScript/TypeScript, Python, Java and PHP through function and class header patterns) names the function, method or handler around the reported line, falling back to the file alone for other languages. Line numbers are left out so findings survive unrelated edits.
- **Normalized route** replaces ids and UUIDs with `:id` (the log watcher's `NormalizeLogLine` rules), so `/api/orders/412` and `/api/orders/7` are the same route.
- **Matching before inserting.** A Claude-only finding whose fingerprint is new is still compared with the open findings of the same repo, CWE and file. If one matches by symbol or route it's treated as that finding (the model was asked to use `known`, this catches the times it didn't). Only a finding that matches nothing is `new`.

```
open ──Fix this──▶ fixing (SEC-n) ──merged──▶ verifying ──next scan clean──▶ fixed
  │                                                   └──still there──▶ open (ticket linked)
  ├──Dismiss (false positive / accepted risk / won't fix, with reason)──▶ dismissed
  └──closed by a check that ran (below)──▶ fixed          fixed ──seen again──▶ reopened (alert)
```

A dismissed finding stays dismissed while its fingerprint matches. If the code at the location changes, it comes back as `open` with "dismissed earlier" shown.

### Closing a finding

A finding missing from one manifest proves nothing: the app may not have started, a tool may have timed out, or Claude may have run out of turns. agnts closes a finding only when **the check that found it ran** in this scan, judged from `scan.ran`, not from the requested scope:

| Finding from | Becomes `fixed` when |
| --- | --- |
| a tool hit, dependency or secret | that tool finished on that path (not excluded, not timed out) and reported nothing with the same fingerprint |
| a probe or nuclei | the app (or target) started and answered, the same template or probe ran on that route, and it didn't reproduce |
| Claude only | Claude reported it `gone` in `known`, with the code that shows it, and Claude finished normally (not cut off by the turn or time limit) |

A finding that was rechecked and is still there gets `last_seen`; anything else stays as it was, with `last_checked` (the last scan that actually ran its check) left alone; a finding reported `unchecked`, or not mentioned at all, is unchanged. The scan page shows "3 findings not rechecked: the app didn't start", so a partial scan never looks clean.

### Fix this

Modelled on `ciwatch.FixIt` → `orchestrator.CreateCITicket`:

- `CreateSecurityTicket(ctx, findingIDs, origin)` creates a local ticket with `Source = SourceSecurity`, prefix `SEC`, kind `code` (`test` when the fix is "add a regression test" only), priority from severity, and the finding's evidence, impact and suggested patch as the description and an attachment. Several findings can go into one ticket (for example "upgrade all vulnerable npm packages"), and the UI offers this for findings of the same category in the same repo.
- The code prompt gets the finding block: "make this fail first, then fix it" where a test is feasible, as CI fixes do.
- `security_findings.ticket_key` links it. When the ticket's pull request merges (the existing merge webhook path), the finding moves to `verifying` and a **verification scan** of just that scope (the rule plus the file, or the dependency, or the probe) is queued. For tool, dependency, secret and probe findings it needs no Claude: the tool reruns and the closing rule above decides. A Claude-only finding needs a short Claude run (`securityVerifyMaxTurns = 10`) that gets only that finding in `known` and answers `present` or `gone`. It counts against `SecurityDailyBudget`.
- A ticket with a tracker (Jira/Plane) can be filed there instead, like follow-ups (`acceptToTracker`).
- Side-stage findings on an agnts change don't create tickets. They show on the ticket, and **Add to feedback** puts them into the request-changes text, as preview issues do. The change is still being written, so the fix belongs in it.

## Log watcher

The log watcher (`domain/logwatch.go`, `logdetect.go`) already classifies production log hits as `leak`, `exposure`, `weakness` and `attack`, with its own fingerprints, Fix it and Mute. Security testing doesn't duplicate it:

- **Into findings:** a log finding of class `exposure` or `weakness` on a source linked to a repository also upserts a security finding (`source: "logs"`, fingerprint `repo_id | logs | detector | normalized route`), linked back to the log finding. It shows in the Security page with "seen in production logs" and the log lines as evidence (already masked by the log watcher).
- **Not into findings:** `attack` (someone probing; not a weakness in the code), `leak` (stays with the log watcher, whose fix is about logging), and `noise`.
- **One ticket:** Fix it on either side creates one ticket and links both, and Mute on the log side doesn't dismiss the security finding (muting is about alerts, dismissing is a judgement on the code).
- **Closing:** the log side never closes a security finding; a scan does, by the closing rules. When a security finding is fixed and the log watcher sees the same detector on the same route again, the finding is reopened.
- **The other way:** a security scan's live passive checks overlap with `logdetect.go`'s exposure detector (`.env`, `.git` served). Both produce the same route fingerprint, so they meet in one finding.

## Live targets

A **target** is a base URL (`https://staging.acme.com`, or with a port: `https://staging.acme.com:8443`) in a workspace, linked to one or more repositories.

**Verification (required before any request is sent):**

- DNS: a TXT record `agnts-verify=<token>` on the host or its parent domain (never on a public suffix such as `herokuapp.com` or `github.io`, checked against the public suffix list). This is the only method by default.
- File: `https://<host>/.well-known/agnts-verify.txt` containing the token. **Off by default** and allowed only when a workspace Admin turns on "allow file proof" for self-hosted installs, because on shared hosting and platforms that serve user uploads, someone who doesn't own the domain can sometimes publish a file on it. A file proof is never accepted on hosted (billing enabled).
- agnts checks it from the server, not from a run container. Verification is re-checked right before every scan, and a target whose proof disappears is suspended.
- **Private networks are out of v1.** Verification refuses private and loopback addresses after resolving (so a target can't point at agnts's own network), which also means a staging host reached only through the VPN or private-network routes (`egress.SetPrivate`) can't be a target. That is deliberate for v1; see *Open questions*.
- Adding a target also needs a checkbox: "I own this system or have written permission to test it". It is stored with the user and the timestamp (`security_targets.authorized_by/at`), and the audit log records every scan of it.

**Profile per target:** `environment` (`staging` / `production`), `max_rps` (default 5, max 20), `max_requests` per scan (default 2,000), excluded paths, and `active_checks` (off by default; allowed only on `staging`). With active checks off, live scans are **passive and safe**: TLS and certificate, security headers, cookie flags, CORS, exposed files (`/.git/`, `/.env`, backups, source maps), directory listing, version disclosure, known-CVE fingerprints via nuclei's non-intrusive templates, and open redirects with harmless payloads. Active checks add injection probes on discovered parameters, still without destructive payloads.

**Egress per run.** The egress allowlist is global today (`AGNTS_EGRESS_ALLOW` plus `Settings.EgressAllow`, served by `GET /egress/allow` in `serve.go`), and it allows ports 443 and 80 only. A live host must not become reachable by every run, so:

- each scan run gets a random proxy credential in `HTTP(S)_PROXY` (`http://run:<token>@egress:3128`)
- the proxy reads `Proxy-Authorization` on CONNECT and on plain HTTP **before** it strips the header for forwarding (`egress.go:361` deletes it today), and drops it from what it logs
- it asks agnts's internal listener `GET /egress/run` with the token in a header (`X-Agnts-Run-Token`), never in the path, so the token doesn't end up in access logs; the answer (hosts, ports, rps) is cached 30 s
- only the scan run's token maps to its verified targets, each with its own port: a target on `:8443` opens `host:8443` for that token only, and the global 443/80 rule is unchanged for everyone else
- requests without a token, or for hosts outside its list, are refused as today, and IP literals stay refused
- **the proxy rechecks the address when it connects:** after resolving a target host it refuses private, loopback and link-local addresses, as verification does, so a DNS record changed after verification (DNS rebinding) can't point the scan at an internal service. Target hosts never go through the private-network routes.
- the proxy enforces `max_rps` and `max_requests` per token too, so a runaway script can't flood a site

## Repository settings

New fields, in a **Security** section of `RepoDrawer.vue` (kept in the existing `harness` jsonb as `RepoHarness.Security`, so no new columns on `repositories` except the schedule):

| Field | Example | Notes |
| --- | --- | --- |
| `Schedule` | `weekly` | `off` / `daily` / `weekly`, at a quiet hour (workspace time zone) |
| `ScanApp` | `true` | Probe the app on localhost when there's a preview command |
| `Targets` | `staging.acme.com` | Verified live targets linked to this repo |
| `Exclude` | `vendor/**`, `testdata/**`, `**/*.min.js` | Paths no tool reports on |
| `RouteGlobs` | `internal/httpapi/**`, `src/middleware/**` | When the side stage also probes the app |
| `MinNotify` | `high` | Lowest severity that alerts |

## Vulnerability data

Scanner binaries are pinned in the image. Their **data** must be fresh, and run containers have a read-only root with no route to the vulnerability feeds:

- A new `secdb` volume, filled by the agnts server (not a run) once a day, the same way the toolchain volume is filled: the osv offline database for the ecosystems the workspace's repositories use, the trivy misconfiguration checks, nuclei templates (pinned to a release, not `main`), and the opengrep rule set agnts ships.
- Runs mount it read-only at `/opt/secdb`. A scan records the database versions it used, and a scheduled scan is skipped when neither the commit nor the databases changed.
- The download hosts are `osv-vulnerabilities.storage.googleapis.com`, `github.com/projectdiscovery/nuclei-templates` releases and `ghcr.io` for trivy checks. Note that run containers can already reach `storage.googleapis.com` and `github.com` through the global allowlist (Go and toolchain downloads need them), so **offline runs are guaranteed by the tools' flags, not by the network**: `agnts-sec` passes each tool's offline, local-database and no-update-check flags (looked up for the pinned version of each tool and kept next to the pin in the Dockerfile; for example nuclei's `-duc` with templates from `/opt/secdb/nuclei`), with telemetry off, and the runner smoke test asserts from the proxy log that a scan makes no request to those hosts.

## Changes by package

### Runner image (`deploy/runner/`)

- Install pinned static binaries in `/usr/local/bin`: `opengrep`, `gitleaks`, `osv-scanner`, `trivy`, `nuclei`. About +250 MB in total.
- `security/agnts-sec` (bash): `static` and `dynamic` subcommands. It runs each tool with fixed flags, points them at `/opt/secdb`, disables update checks and telemetry, caps runtime per tool (static 10 min, dynamic 10 min), and normalizes into `hits.json`. Claude can run it again with a narrower scope (`--rule`, `--path`, `--package`).
- `security/agnts-probe.mjs` (Node, Playwright and fetch): `crawl <base>`, `request <method> <url> [--header] [--body] [--as <session>]`, `login <session> <steps.json>`. It only accepts `http://localhost`, `http://127.0.0.1` and the hosts in `/agnts/in/security.json`. It counts requests against the budget, applies the rate limit, masks secrets in what it prints (`MaskSecret` rules ported), and logs every request to `/agnts/out/sec/probe.log` for the audit trail.
- `managed-settings.json` keeps denying `curl` and `wget`; `agnts-sec` and `agnts-probe` are allowed.

### Domain (`server/internal/domain/`)

- New `security.go`: `SecurityScan{ID, RepoID, TicketID, Trigger, Scope, Ran, Status, Commit, DBVersions, App, Counts, Summary, Rejected, RunID, Provider, CreatedAt, FinishedAt}`, `SecurityFinding{ID, RepoID, Fingerprint, Severity, Category, CWE, OWASP, Title, Location, Symbol, Source, ToolRule, Confidence, Evidence, Impact, Fix, References, Status, DismissReason, TicketKey, LogFindingID, FirstSeen, LastSeen, LastChecked, LastScanID}`, `SecurityTarget{...}`, `SecurityManifest` (with `Known []KnownCheck{FindingID, Status, Note}`) and `Normalize()` (caps of 200 findings and 8 KB of evidence each, severity/confidence/known-status enums, `known` ids limited to the ids agnts sent, `SafeOutFile` paths).
- `Fingerprint(f, symbol)` per source as in *Fingerprints*, and `Closes(f, ran)`, the closing rule as a pure function, so both are unit tested without a database.
- `ticket.go`: `StageSecurity`, which `Side()` includes (today `StageLearn || StageReview || StagePreview`, `ticket.go:317`), `Ticket.SecurityState`, `EventSecurity = "security_done"`, `SourceSecurity = "security"`.
- `kind.go`: `KindSecurity: {Output: OutputReport, NeedsRepo: true, Implementable: true, MultiRepo: true}`, added to `Kinds`.
- `settings.go`: `AutoSecurity` (default true; only affects agnts changes), `ModelSecurity = "security"` next to `ModelReview` and `ModelPreview`, resolved per provider like them (Claude: Sonnet; Muse: the provider's review-tier model), `Notify.Security`, `SecurityDailyBudget` (agent-run scans per day per workspace, default 10, counting verify runs that need the agent) and `SecurityFileProof` (default false, ignored on hosted).
- `harness.go`: `RepoHarness.Security` with the repository settings above.

### Migration `server/migrations/00083_security.sql`

(The last migration today is `00081_meeting_tasks.sql`; take the next free number when the work starts.)

```sql
CREATE TABLE security_scans (
  id           bigserial PRIMARY KEY,
  workspace_id bigint NOT NULL DEFAULT agnts_ws(),
  repo_id      bigint NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
  ticket_id    bigint REFERENCES tickets(id) ON DELETE CASCADE,   -- side stage / security kind
  trigger      text   NOT NULL CHECK (trigger IN ('manual','schedule','change','ticket','verify')),
  scope        jsonb  NOT NULL,                                    -- static/app/targets, narrowed for verify
  ran          jsonb  NOT NULL DEFAULT '{}',                       -- what actually ran: tools, app, targets, agent finished
  provider     text   NOT NULL DEFAULT '',                         -- claude / muse, for spend and comparing triage
  status       text   NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','running','done','failed','cancelled')),
  commit_sha   text   NOT NULL DEFAULT '',
  db_versions  jsonb  NOT NULL DEFAULT '{}',
  app_status   text   NOT NULL DEFAULT '',
  counts       jsonb  NOT NULL DEFAULT '{}',
  summary      text   NOT NULL DEFAULT '',
  rejected     jsonb  NOT NULL DEFAULT '[]',
  run_id       bigint REFERENCES runs(id),
  created_by   bigint REFERENCES users(id),
  created_at   timestamptz NOT NULL DEFAULT now(),
  finished_at  timestamptz
);
CREATE TABLE security_findings (
  id             bigserial PRIMARY KEY,
  workspace_id   bigint NOT NULL DEFAULT agnts_ws(),
  repo_id        bigint NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
  fingerprint    text   NOT NULL,
  severity       text   NOT NULL,
  category       text   NOT NULL,
  data           jsonb  NOT NULL,          -- title, location, cwe, evidence, impact, fix, references
  status         text   NOT NULL DEFAULT 'open'
                 CHECK (status IN ('open','fixing','verifying','fixed','dismissed','reopened')),
  dismiss_reason text   NOT NULL DEFAULT '',
  dismissed_by   bigint REFERENCES users(id),
  ticket_key     text   NOT NULL DEFAULT '',
  source         text   NOT NULL,          -- tool / deps / secret / probe / claude / logs
  symbol         text   NOT NULL DEFAULT '',  -- enclosing function found by agnts
  log_finding_id bigint REFERENCES log_findings(id) ON DELETE SET NULL,
  first_seen     timestamptz NOT NULL DEFAULT now(),
  last_seen      timestamptz NOT NULL DEFAULT now(),
  last_checked   timestamptz NOT NULL DEFAULT now(),  -- last scan that actually ran this finding's check
  last_scan_id   bigint REFERENCES security_scans(id),
  UNIQUE (repo_id, fingerprint)
);
CREATE INDEX security_findings_match ON security_findings (repo_id, (data->>'cwe'), (data->'location'->>'file')) WHERE status <> 'fixed';
CREATE TABLE security_targets (
  id            bigserial PRIMARY KEY,
  workspace_id  bigint NOT NULL DEFAULT agnts_ws(),
  base_url      text   NOT NULL,
  environment   text   NOT NULL CHECK (environment IN ('staging','production')),
  token         text   NOT NULL,
  method        text   NOT NULL DEFAULT '' CHECK (method IN ('','dns','file')),
  verified_at   timestamptz,
  profile       jsonb  NOT NULL DEFAULT '{}',   -- max_rps, max_requests, exclude, active_checks
  repo_ids      bigint[] NOT NULL DEFAULT '{}',
  authorized_by bigint NOT NULL REFERENCES users(id),
  authorized_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (workspace_id, base_url)
);
ALTER TABLE repositories ADD COLUMN security_next_at timestamptz;
ALTER TABLE tickets      ADD COLUMN security_state  text NOT NULL DEFAULT '';
-- tickets_kind_check += 'security'; tickets_source_check += 'security'
-- RLS: ENABLE + FORCE + workspace_isolation policy on all three tables (as 00037_ci_failures.sql)
```

### Store (`server/internal/store/postgres/`)

- New `security.go`: scans (create, claim, finish, recover `running` → `pending`), findings (`UpsertFindings(scanID, ran, []Finding, []KnownCheck)` in one transaction: match, insert or update, then apply `domain.Closes` to every open finding of the repo using `ran`; it returns new/reopened/fixed/unchecked counts for the event), `OpenFindings(repoID)` for `security.json`, targets.
- `tickets.go`: queue class `security` for the side stage in `queueClassSQL`, `startRun` taking the class instead of `preview bool`, and `RecoverInterrupted` and `ticketCols` gaining `security_state`.
- The scheduler (`orchestrator/scheduler.go`) gets `ClassSecurityScan` (repo job) and `ClassSecurity` (side stage), ranked after `preview` and before `learn` (`ClassLearn` and `ClassReflect` move to 8 and 9). `ClassSecurityScan` is gated by `capacity.Spare(mem)` like learn and reflect, with the repo's `MemoryMB` raised to at least 2 GB for the static sweep, instead of a fixed limit of one scan at a time.

### Orchestrator (`server/internal/orchestrator/`)

New `security.go`, mirroring `preview.go` and `brief.go`:

- constants `securityMaxTurns = 60`, `securityTimeoutMin = 30`, `securitySideMaxTurns = 20`, `securityVerifyMaxTurns = 10`, `securityMaxFindings = 200`, the same for both providers
- the run goes through the same provider selection as review and preview (the workspace's default module, `ModelSecurity`), so a Muse workspace scans with Muse Code and a Claude workspace with Claude Code
- `Scan(ctx, repoID, scope, origin)` (manual), `enqueueDueScans(ctx)` (minute tick in `Run`, which advances `security_next_at`, honours `SecurityDailyBudget` and skips unchanged commits and databases)
- `runSecurityScan(ctx, scan)` (the repo job above), `securitySide(ctx, s, t, run)` (the side stage: tools on the diff only, Claude only when there are hits)
- `securityState(s, repo, files)` at the end of `code()` next to `previewState`, and `dropSecurity` added to `dropSideRuns`
- `parseSecurity`, `saveSecurity`, `securityFailed`, `latestSecurity`
- `CreateSecurityTicket(ctx, findingIDs, origin)` (CI twin), and a hook in the merge path that moves linked findings to `verifying` and queues a `verify` scan
- `prompts.go`: a `security` template (repo scan and ticket kind), `security-side` (diff triage) and `security-verify` (one known finding: present or gone). Reuse the security specialist pass of the review prompt (the "security:" checklist at about `prompts.go:1204`, and the security line of the review checklist at about `:1041`) and the per-language `review/*.md` notes. Written for both agents: no tool names that only one of them has. `kindWork[KindSecurity]` for the classifier. Bump `PromptVersion`.
- the log watcher link: when `logwatch` saves an `exposure` or `weakness` finding on a source linked to a repo, it calls `UpsertLogFinding` (see *Log watcher*); `CreateSecurityTicket` and `logwatch.Fix` both check the other side's link first, so they share one ticket
- `KindSecurity` work runs reuse `runSecurityScan`'s tool step before Claude, and the report's findings go through `saveSecurity` too.

### Egress (`server/internal/egress/` and `cmd/agnts/serve.go`)

- Per-run proxy credentials: `Proxy-Authorization` parsed in CONNECT and plain HTTP before the existing strip at `egress.go:361`, a `RunHosts func(token) (hosts []HostPort, rps, maxRequests int)` lookup against `GET /egress/run` (token in `X-Agnts-Run-Token`) on the internal listener, cached for 30 s, plus a per-token token bucket and request counter.
- Ports: today `ports` is `{443, 80}` for everyone (`egress.go:234`). A run token's `HostPort` entries add their port for that host and that token only.
- Address check at connect time for token hosts: refuse private, loopback and link-local results after resolving, and never route them through `SetPrivate`'s private-network routes.
- `runner.proxyEnv` (`runner.go:313`) takes an optional token, set only for security runs with live targets.

### Vulnerability data (`server/internal/secdb/`, new)

- `Updater.Refresh(ctx)`, daily through `every(...)` in `serve.go`: it downloads into a staging directory, checks checksums and swaps atomically into the `secdb` volume. It exposes `Versions()` for the scan record and a health line on the admin System page.

### Targets verification (`server/internal/security/verify.go`, new)

- `Verify(ctx, target)`: DNS TXT lookup (host, then parent, stopping above the registrable domain from the public suffix list), and the HTTPS GET of the well-known file only when file proof is allowed (`SecurityFileProof` on a self-hosted install). It follows no redirects to other hosts, has a 5 s timeout, and refuses private and loopback IPs after resolving, so a "target" can't point at agnts's own network.

### API (`shared/openapi/openapi.yaml`, then `make gen`)

- `GET /repos/{id}/security` (summary: counts by severity and status, last scan, schedule), `POST /repos/{id}/security/scans` (`{app, targets[]}`), `GET /repos/{id}/security/scans`, `GET /security/scans/{id}` (with rejected hits), `DELETE /security/scans/{id}` (cancel).
- `GET /security/findings?repo=&status=&severity=` (workspace-wide), `GET /security/findings/{id}`, `POST /security/findings/{id}/dismiss` (`{reason, note}`), `POST /security/findings/{id}/reopen`, `POST /security/fix` (`{findingIds[], start}`), which returns the ticket key.
- `GET/POST/PATCH/DELETE /security/targets`, `POST /security/targets/{id}/verify`.
- `Ticket.securityState`, `TicketDetail.security` (side-stage result), `POST /tickets/{key}/security`.
- `Settings`: `autoSecurity`, `models.security`, `notify.security`, `securityDailyBudget`. Add `security` to the stage/model enums, `TicketKind`, and the ticket source enum.
- `Repository.harness.security` for the settings above.

### Admin panel (`apps/admin/`)

- **Security** page in the nav under Side projects, next to CI (`/w/:ws/security`): open findings across repos grouped by severity, filters, a per-repo posture strip (critical/high open, last scan, schedule), and "new since last week". Bulk select → **Fix together**.
- **Finding** page (`/w/:ws/security/findings/:id`): severity, confidence, location with a code excerpt (from the repo browser), evidence, impact, the suggested fix as a diff, references, history (seen in scans, dismissed by, ticket), and the **Fix this** / **Dismiss** / **Reopen** actions.
- Repository page: a **Security** tab in `RepoPage.vue` (`components/repo/SecurityTab.vue`) with scans, findings for the repo and **Run scan** (with checkboxes for App and each linked target). The `RepoDrawer.vue` **Security** section holds the settings.
- **Targets** under Settings → Security: add a URL, show the token and the DNS record to add (and the file method only when file proof is allowed), the port when not 443, **Verify**, the authorization checkbox, and the profile fields.
- Ticket page: a **Security** tab next to Preview (`components/ticket/SecurityFindings.vue`) for the side stage and the `security` kind, with **Add to feedback**.
- Settings: Auto security toggle, security model, daily budget, notification toggle.
- `KindBadge`, `KindPicker`, `types.ts` `KINDS`/`REPORT_KINDS`, `trackerLabels.ts`; i18n in `shared/i18n/{en,ru,uz}/security.json`, `kind.json`, `settings.json`, `repos.json`, `ticket.json`.

### Mobile (`apps/mobile/`)

- `features/security/`: a findings list (filters by severity/repo), finding detail with evidence, the fix as a code block, and **Fix this** / **Dismiss**. Route `/security` and `/security/findings/:id`, with a row in the More menu.
- `features/tickets/security_findings.dart`: a section on the ticket screen under preview.
- `features/repos/repo_screen.dart`: posture card and **Run scan**.
- `kinds.dart` gets `security`. Regenerate `agnts_api` and the ARB files.

### Notifications (`server/internal/notify/`)

- `EventSecurity`: "api: scan done · 1 new critical, 2 new high · 3 fixed" with a link. Silent when nothing new reaches `MinNotify`.
- Telegram: up to three new findings with a **Fix it** button (`sec:<id>`, handled in `notify/bot.go` like `cif:` and `lgf:` through a `SecurityFixer` interface). The callback looks the finding up in the workspace the chat is linked to (RLS), so an id from another workspace is "Not available". Fix it only creates a ticket, and nothing is pushed without approval, so the chat link is enough, as for CI and log fixes. **Dismiss** is not offered in Telegram, because it needs the Admin role.
- Reopened findings always alert ("fixed in SEC-12, back since a41c0de").

### MCP (`server/internal/mcpserver/`)

- `list_security_findings(repo, status, severity)` and `get_security_finding(id)`. No values of secrets, and evidence masked. Lets Claude chat answer "what's our worst open issue?" and start a fix.

### Analytics (`apps/admin` Analytics page)

- Open findings by severity over time, mean time to fix by severity, and findings introduced by agnts changes vs. found in existing code.

## Phases

**1a: Repository scan (admin).** Runner image tools, `agnts-sec static`, the `secdb` volume and updater, migration, the store, `ClassSecurityScan`, `runSecurityScan` (static only), the security prompt, findings with fingerprints and lifecycle, the admin Security page, Finding page and repo tab, and **Fix this** → SEC tickets with verify-on-merge. *Done when* a scan of a seeded vulnerable fixture repo (`server/internal/security/testdata/vulnapp`, which has a SQL injection, a vulnerable lodash, a committed fake key and a root Dockerfile) finds all four with fixes, a SEC ticket fixes the injection, and the verification scan marks it `fixed`; **and** three rescans of the unchanged fixture, at least one with Claude and one with Muse, report 0 new and 0 fixed (identity is stable across runs and providers).

The fixture's "secret" is AWS's published example key (`AKIAIOSFODNN7EXAMPLE`), never a real-looking one, and the fixture path is in agnts's own `.gitleaks.toml` allowlist and the red-flag hook's skip list, so the fixture doesn't trip GitHub push protection or agnts's own checks on its repository.

**1b: Running app + agnts changes.** `agnts-sec dynamic`, `agnts-probe`, app scanning through the preview config, the side stage (`StageSecurity`, `AutoSecurity`, ticket tab, Add to feedback). *Done when* an agnts ticket that adds an unauthenticated handler on this repo gets a side-stage finding before review, and a repo scan confirms the fixture's injection on the running app.

**1c: Everywhere and on a schedule.** Schedules and budget, notifications with Telegram Fix it, mobile, the `security` ticket kind with tracker labels, MCP tools, analytics, and the log watcher link (exposure/weakness log findings as security findings, one shared ticket). *Done when* a weekly scan that finds nothing new sends nothing, and a newly introduced vulnerable dependency arrives on the phone with a working Fix it button.

**2: Live targets.** Targets, verification, the authorization record, per-run egress credentials and rate limits, the passive live profile, and active checks for staging. *Done when* a scan of a verified staging host (including one on a non-standard port) stays within its rate and request budget (asserted from the proxy's counters), an unverified host is never contacted (asserted from the proxy log), a target whose DNS is changed to a private address after verification is refused at connect time, and removing the TXT record suspends the target.

## Testing

- `domain`: `SecurityManifest.Normalize` (caps, bad paths, unknown severity, `known` ids that weren't sent are dropped), `Fingerprint` per source: stable across line shifts and across reworded titles, changed on function rename. `Closes`: a tool finding isn't closed when the tool timed out or the path was excluded; a probe finding isn't closed when the app didn't start; a Claude-only finding isn't closed when it's `unchecked`, missing, or the run hit its turn limit.
- `security/symbol`: enclosing symbol per supported language, and the file-only fallback.
- `store/postgres`: `UpsertFindings` (new, seen again, matched by CWE+file+symbol despite a new fingerprint, closed only by `Closes`, reopened, dismissed stays dismissed), claim order, recovery, RLS isolation between workspaces; log finding upsert and the shared ticket.
- `orchestrator/security_test.go` with the fake workspace: the side stage queued only when tools have something to scan, dropped on approve/request changes, no Claude run when there are no hits; schedule skipping on unchanged commit and databases; daily budget; `CreateSecurityTicket` single and grouped; verify-on-merge.
- `egress`: per-token hosts and ports, no token means the global list and 443/80 only, the token is read before the header is stripped and never logged, rate and request limits, IP literals still refused, a token host resolving to a private address refused.
- `security/verify`: DNS proof, parent lookup stops at the public suffix, file proof refused unless allowed and never on hosted, redirect to another host refused, private IP after resolution refused.
- `notify`: `sec:` with an id from another workspace is refused; no Dismiss button.
- `httpapi`: every endpoint's authz (workspace member, role for dismiss/targets), evidence masking.
- Runner smoke (`make runner-smoke`): each tool runs offline against `/opt/secdb` on the fixture with the read-only root, the proxy log shows no request to the feed hosts during the scan, and `agnts-probe` refuses a non-local URL without a target file.
- An end-to-end test on the `vulnapp` fixture in CI, with the agent step stubbed by recorded manifests: one from Claude and one from Muse that word the same findings differently, which must land on the same finding ids.

## Security

- **Scope is enforced in three places:** `agnts-probe` and `agnts-sec` refuse targets outside the scan's list, the egress proxy only opens verified hosts (and their ports) to the token of that scan run and rechecks their addresses at connect time, and verification re-runs before every scan. The prompt is the fourth place, not the first.
- **The run token is a credential:** it's read from `Proxy-Authorization` and sent to the internal listener in a header, never in a URL, and it's dropped from proxy and access logs. It expires with the run.
- **Unapproved code runs only in the existing hardened container,** as preview: read-only root, no capabilities, internal network.
- **Secrets found are never stored or shown in full:** gitleaks runs with `--redact`, findings keep `MaskSecret` output and a sha256, and evidence from probes is masked before it leaves the container's manifest parsing.
- **Findings are sensitive:** they're a map for an attacker. They're visible only to workspace members (RLS), dismissing and adding targets need the admin role, the API never puts findings in URLs or webhooks, and Telegram messages carry the title and severity only (no evidence).
- **The manifest is untrusted input:** paths are checked with `SafeOutFile`, sizes are capped, enums are validated, and patches are stored as text and shown, never applied by agnts outside a ticket run.
- **Live scanning is legally sensitive:** DNS proof of control (file proof only on self-hosted installs that opt in) plus an explicit authorization record by a named user, rate limits enforced in the proxy, non-destructive defaults, a production profile that can't enable active checks, and a full request log per scan kept 90 days.
- **The tools themselves are supply chain:** binaries are pinned by version and checksum in the Dockerfile, rule and template data is pinned to releases and checksummed by the updater, and all telemetry and update checks are off.

## Costs and limits

- **Time.** Static sweep 1–5 min, app sweep 3–10 min, Claude triage 5–15 min. A full repository scan takes about 10–30 min in a worker slot after reviews and previews. The side stage takes about 1–2 min when tools find nothing.
- **Plan usage.** One agent session per repository scan (≤60 turns) on the workspace's provider, capped by `SecurityDailyBudget`. Side stages use the agent only on hits (≤20 turns), and verifying a Claude-only finding takes ≤10 turns. Shown under the stage `security` in spend, split by provider.
- **Disk.** `secdb` is about 1–2 GB (osv databases for the used ecosystems plus templates). Raw tool output is about 1–10 MB per scan, kept 30 days. Findings rows are small.
- **Image.** About +250 MB.
- **Memory.** opengrep on a large repo can use about 1–2 GB. It runs before the app starts, with at least 2 GB reserved, and a scan starts only when `capacity.Spare` has room for it, so on the 2 GB VPS scans wait for an idle server instead of competing with coding runs.

## Decisions

1. **Opengrep, not Semgrep.** Semgrep's registry rules are under a license that forbids use in a competing hosted service, and agnts has a billed hosted option (`billing`). Opengrep is LGPL with community rules. agnts ships and pins its own curated rule set.
2. **Findings live per repository, not per ticket.** Side-stage results are per ticket and stay advice. Only repository scans and the `security` kind write to `security_findings`.
3. **The side stage is advice, never a gate,** like review and preview, in v1. Later, a workspace option can make a confirmed critical block **Approve** unless someone overrides it, with the override logged (who and why).
4. **Live targets are a phase of their own** because they're the only part that sends traffic outside the sandbox.
5. **agnts owns finding identity.** Fingerprints come from tool output and agnts's own parsing, and findings close only by the check that found them. The model's text never decides whether something is new or fixed.
6. **Provider-neutral.** Scans run on the workspace's default agent (Claude Code or Muse Code) with the same prompts and limits. Findings don't depend on which agent ran.
7. **DNS proof by default.** File proof is an opt-in for self-hosted installs and never available on hosted.
8. **Secret history:** the first scan of a repository scans its full history, capped at 10 minutes (it records how far it got); later scans scan the last 200 commits.
9. **Reports export after 1c.** A per-repository PDF/Markdown report is not part of v1.

## Open questions

1. **Authenticated live scans:** staging login credentials stored like the preview env, or out of scope until someone asks?
2. **Hosted workspaces:** should live scanning be limited by plan (billing)?
3. **Private staging:** allow targets reached through the VPN or private-network routes (`SetPrivate`), with a separate proof of control since DNS TXT on a private name proves little, or keep them out?
4. **Log `attack` findings:** should repeated attacks on one route (brute force on login) become a finding that suggests rate limiting, or stay in the log watcher?
