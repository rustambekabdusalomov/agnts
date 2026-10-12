# agnts Private Networks (VPN) — Plan

Oct 11, 2026 · implemented (phases 1–3)

## Overview

Many teams keep GitLab, Jira and their package registry on their own servers, reachable only over a VPN. agnts can't reach them today. The server's GitLab and Jira clients (`vcs/gitlab`, `tracker/jira`) dial out from the `agnts` container. Run containers reach the internet only through the egress proxy, which allows a fixed list of public hostnames and refuses IP addresses (`internal/egress`). A GitLab at `gitlab.corp.local` or `10.20.0.5` is unreachable from both.

This plan gives each workspace a **private network**: a tunnel into the customer's network plus a list of **routes** (the hosts and ranges that go through it). Anything that matches a route goes through the tunnel; everything else goes out as it does today. Two kinds of tunnel use the same routing:

- **VPN config.** The owner uploads a WireGuard or OpenVPN config, and agnts holds the tunnel open.
- **Connector.** The customer runs a small agent, `agnts-link`, inside their network. It dials out to agnts and carries traffic back. It needs no VPN credentials and no inbound firewall rule, and it can relay webhooks.

```
                 ┌──────────── agnts server ─────────────┐        customer network
run container ──▶│ egress ──┐                            │
                 │          ├──▶ gateway ── WireGuard ───┼──▶ gitlab.corp.local
agnts (API) ─────┼──────────┘       │  ── OpenVPN ─────┼──▶ jira.corp.local
                 │                  └── link session ◀──┼─── agnts-link (outbound wss)
                 └───────────────────────────────────────┘
```

**Goals**

- A workspace connects a self-hosted GitLab, Jira or Plane that sits behind a VPN, and tickets run end to end: tickets sync, the run clones, installs from the internal registry and pushes, and the MR is opened and commented on.
- Workspaces stay strictly isolated. A tunnel belongs to one workspace, and no other workspace's runs or API calls can use it, even when two workspaces use the same IP ranges.
- No new privileges for run containers. They keep `CapDrop: ALL`, a read-only rootfs and an internal network, and they never see the VPN config.
- Setup is self-serve under Settings → Network: paste a config or run one `docker run` command, list the routes, press Test.

**Out of scope for v1:** VPNs that need interactive login (Cisco AnyConnect, GlobalProtect or FortiClient with SAML/MFA; `openconnect` with a static certificate can come later), IPsec/L2TP, git over SSH (agnts uses HTTPS with a token), UDP traffic through the tunnel, more than one tunnel per workspace, and self-hosted installs (they sit inside the customer's network already and don't need this).

**Principles**

1. **One routing layer, three tunnel types.** Egress and the server's HTTP clients ask a single question: does this host match the workspace's routes? If so, they dial through the gateway. WireGuard, OpenVPN and the connector are only different ways for the gateway to dial.
2. **Tunnels live outside the API process.** A new `gateway` service holds every tunnel. A broken config or a crashing tunnel never takes the API down, and the gateway is the only process that ever holds decrypted VPN keys.
3. **Routes are explicit and narrow.** Only listed hosts and private ranges go through a tunnel, never the default route. A run can reach exactly what the owner listed.
4. **The server decides who is asking.** Egress identifies a run by the source IP of its container, which the run can't change (`CapDrop: ALL` drops `NET_RAW`). The run never presents a credential it could leak.

## How it works

### Routing a request from a run

1. When agnts starts a run container for a workspace with a private network, it uses a per-run network (`RunNetworkPerRun`, now forced on for these workspaces). It records the container IP against the run and workspace in an in-memory table, which the internal listener (`:8081`) serves.
2. A tool in the container (git, npm, Claude Code) sends `CONNECT gitlab.corp.local:443` to `egress:3128`, exactly as today.
3. Egress looks up the source IP: `GET agnts:8081/egress/whois?ip=…` returns the workspace ID and its routes. It caches the answer until the run ends, and agnts pushes an invalidation when the container is removed.
4. If the target matches a route of that workspace, egress opens `CONNECT gitlab.corp.local:443` to `gateway:3129` with `X-Agnts-Workspace: 42` and the shared gateway secret, then splices the two connections. If the target doesn't match, the normal allowlist applies.
5. The gateway dials through workspace 42's tunnel. Name resolution happens **on the tunnel side**: the DNS server from the WireGuard config, the DNS pushed by OpenVPN, or the connector's own resolver. Egress never resolves a private name itself.

IP literals stay refused unless they fall inside one of the workspace's route CIDRs. Ports are limited to 80 and 443 plus the ports the route lists, so a GitLab on `:8443` or a Nexus on `:8081` works.

### Routing a request from the server

The GitLab, Jira and Plane clients get their `http.Client` from a new `netroute.Client(ws, base)`. Its `Transport.DialContext` checks the workspace's routes and dials through the gateway on a match, and dials directly otherwise. "Test connection" on an integration goes through the same path, so a wrong route shows up at setup time rather than on the first ticket.

### The gateway service

The gateway is a new compose service built from the same image, running `command: ["gateway"]`. It is on the default network (to reach agnts and to get out) and on a new internal `gateway` network that only egress and agnts join. Every 30 seconds it reads the active private networks from `agnts:8081/gateway/networks` (as egress `Follow` already does for the allowlist). It gets configs encrypted and decrypts them with `AGNTS_SECRET_KEY`.

| Kind | How the gateway dials | Privileges |
|---|---|---|
| WireGuard | In process, with userspace WireGuard on a gVisor netstack (`golang.zx2c4.com/wireguard/tun/netstack`). One netstack per workspace, so overlapping ranges are fine. | None |
| OpenVPN | A per-workspace sidecar `agnts-ovpn-<ws>` that agnts starts through the Docker socket. It runs `openvpn` and a small SOCKS5 server (`agnts ovpn-socks`) and is attached only to the `gateway` network plus its own outbound network. The gateway dials through its SOCKS. | `NET_ADMIN` and `/dev/net/tun`, only in that sidecar's own network namespace |
| Connector | A yamux session over the WebSocket that `agnts-link` opened to `wss://api.agnts.uz/link`. Caddy routes `/link` to the gateway. Each dial is one yamux stream. | None |

Each tunnel reports a status: `connecting`, `up` (with the last WireGuard handshake, OpenVPN `CONNECTED` or connector heartbeat), or `error` with the message. The gateway writes it back to agnts, and Settings → Network shows it.

### The connector (`agnts-link`)

`agnts-link` is one static Go binary (`server/cmd/agnts-link`), also shipped as an image:

```sh
docker run -d --restart unless-stopped --name agnts-link \
  -e AGNTS_LINK_TOKEN=lnk_… \
  -e AGNTS_LINK_ALLOW=gitlab.corp.local,jira.corp.local,10.20.0.0/16 \
  registry.agnts.uz/agnts-link:latest
```

- It dials out to `wss://api.agnts.uz/link` with its token and reconnects with backoff. It needs nothing inbound.
- `AGNTS_LINK_ALLOW` is the customer's own allowlist, a second check that agnts can't change. Dials outside it are refused on their side and logged there.
- **Webhook relay.** It listens on `:8080` inside the customer network. GitLab and Jira point their webhooks at `http://agnts-link:8080/hooks/<path>`, and the link forwards each request to agnts over the session, where it hits the same handlers as today (`vcs/hooks.go`, `tracker/jira/webhook.go`). Signature checks are unchanged.
- The token is per workspace, stored hashed, shown once and rotatable. Rotating it drops the current session.

### Webhooks without a connector

A GitLab behind a VPN can't send webhooks to `api.agnts.uz`. With a VPN config:

- **Jira** already reconciles on an interval (`JiraSyncEach`, the `Search` query), so new tickets arrive with a delay of one interval. For private Jira the interval drops to 1 minute.
- **Plane** works the same way through `PlaneSyncEach`.
- **GitLab** gets a new poller for workspaces whose GitLab host matches a route. Every minute it reads open agnts MRs (state, new notes, pipeline status) and feeds the same events `vcs/hooks.go` produces. It uses ETags or `updated_after` so an idle repository costs one request.

The UI says which mode a workspace is in: "Webhooks via connector" or "Polling every 1 min".

### Internal certificates

Self-hosted GitLab and Nexus often use a company CA. Settings → Network takes an optional **CA bundle** (PEM).

- The server's `netroute` clients add it to their `RootCAs`.
- Run containers get it at `/agnts/in/ca.pem`, plus `SSL_CERT_FILE`, `GIT_SSL_CAINFO`, `NODE_EXTRA_CA_CERTS`, `REQUESTS_CA_BUNDLE` and `PIP_CERT`. JVM tools get a truststore that the provision script builds (next to the existing Maven proxy block in `runner/provision.go`).
- There is no "skip TLS verification" switch.

## Data model

Migration `00036_private_networks.sql`, with the workspace row-level security from `00023`:

```sql
CREATE TABLE private_networks (
    workspace_id bigint      PRIMARY KEY REFERENCES workspaces(id) ON DELETE CASCADE,
    kind         text        NOT NULL CHECK (kind IN ('wireguard', 'openvpn', 'connector')),
    config_enc   bytea,                -- WireGuard/OpenVPN config, secret.Encrypt; NULL for a connector
    token_hash   bytea,                -- connector token, sha256; NULL for a VPN
    routes       jsonb       NOT NULL DEFAULT '[]',
    ca_pem       text,
    enabled      boolean     NOT NULL DEFAULT true,
    status       text        NOT NULL DEFAULT 'connecting',
    last_error   text,
    up_at        timestamptz,
    updated_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE private_dials (            -- audit, kept 30 days
    id           bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint      NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    run_id       bigint,                 -- NULL for the server's own calls
    target       text        NOT NULL,   -- host:port
    ok           boolean     NOT NULL,
    bytes_in     bigint, bytes_out bigint,
    at           timestamptz NOT NULL DEFAULT now()
);
```

Routes:

```json
[
  { "host": "gitlab.corp.local", "ports": [443] },
  { "host": ".corp.local", "ports": [443] },
  { "cidr": "10.20.0.0/16", "ports": [443, 8443, 8081] }
]
```

## Security

- **Who can set it up.** Only the workspace Owner. Every change appears in the workspace's activity log.
- **Keys.** VPN configs are encrypted at rest with the `secret` package. Only the gateway decrypts them, and only in memory, except for the OpenVPN sidecar, which gets its config on a tmpfs. Configs are never logged, never returned by the API after saving (the UI shows "WireGuard · peer vpn.corp.com:51820 · saved"), and never reach a run container.
- **Route limits.** A CIDR must be private: RFC 1918, `100.64.0.0/10` or IPv6 ULA. Public ranges, `0.0.0.0/0`, link-local (`169.254.0.0/16`, cloud metadata), loopback and the Docker ranges the server itself uses are refused. Host routes may not cover agnts' own domains or anything on the public allowlist. A route can't steal `github.com`.
- **Isolation.** Each workspace has its own netstack, sidecar or yamux session, and the gateway picks the tunnel only from the workspace ID that egress or agnts sends. The gateway port is on the internal `gateway` network, which run containers never join, and requests without the shared secret are refused.
- **Run identity.** Egress trusts the source IP only on per-run networks, where agnts assigned the address and the container can't forge another (`CapDrop: ALL`). An IP with no live run gets the public allowlist only.
- **Blast radius.** Code from a ticket can reach every host the routes list. The setup page says this plainly and suggests listing exact hosts rather than whole ranges. Owners see each dial in the audit list (Settings → Network → Activity).
- **Connector.** Tokens are hashed and rotatable. `AGNTS_LINK_ALLOW` gives the customer a limit agnts can't widen. The link carries only streams agnts opens plus webhook requests the customer's own servers send it.

## UI

Settings → Network gets a **Private network** card:

```
Private network                                         ● Up · handshake 12s ago
( ) Connector (recommended)   (•) WireGuard   ( ) OpenVPN

Config        [ wg0.conf · peer vpn.corp.com:51820 · saved ]  [Replace]
Routes        gitlab.corp.local :443
              10.20.0.0/16      :443 :8443           [+ Add route]
CA bundle     corp-root-ca.pem · expires 2029-03-01   [Replace]

Test          [ gitlab.corp.local:443 ]  [Test]
              ✓ resolved 10.20.0.5 · TCP 38 ms · TLS ok (CN=gitlab.corp.local, corp-root-ca)

Webhooks      Polling every 1 min (connect agnts-link to get webhooks)
Activity      214 connections today · 0 refused   [View]
```

The GitLab, Jira and Plane integration forms show a "via private network" badge when their host matches a route, and their "Test connection" result says which path it took.

## Phases

**Phase 1: routing and WireGuard.** The `gateway` service with WireGuard on netstack, the `private_networks` table, `netroute` for the server clients, egress source-IP lookup and route matching, the CA bundle, private-network polling for GitLab, and the UI card with Test. This alone answers "we have a WireGuard VPN".

**Phase 2: connector.** `agnts-link` (binary and image), the `/link` WebSocket endpoint and yamux sessions in the gateway, webhook relay, token rotation, and the install command in the UI. It becomes the recommended option on the card.

**Phase 3: OpenVPN.** The `agnts-ovpn-<ws>` sidecar with `NET_ADMIN`, the SOCKS bridge, and sidecar lifecycle (start, restart on failure, remove when disabled or the workspace is deleted). It handles `.ovpn` files with inline certificates and username/password, but not MFA.

**Later:** `openconnect` for AnyConnect/GlobalProtect with certificate auth, and git over SSH through the tunnel.

## Open questions

- **Pricing.** Should a private network be part of a paid plan? It holds one always-on tunnel per workspace: a few MB for WireGuard, about 30 MB for an OpenVPN sidecar.
- **Polling cost.** A 1-minute GitLab poll across many private workspaces adds up. Should the interval scale with how active the workspace is?
- **Previews.** Should preview runs (`Preview plan.md`) reach private staging APIs through the tunnel too? It works for free with routes, but it widens what a preview can touch.
