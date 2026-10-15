# agnts Multiple Private Networks — Plan

Oct 12, 2026 · implemented (phases 1–3) · builds on `VPN plan.md`

## Overview

Today a workspace has **one** private network: one tunnel (WireGuard, OpenVPN or agnts-link) and one list of routes. That covers a team whose GitLab, Jira and registry all sit behind the same VPN. It doesn't cover the teams we keep meeting:

- An agency or outsourcing team works for several clients from one workspace. Client A's GitLab is behind A's WireGuard, and client B's Nexus is behind B's OpenVPN.
- One company has its source code in one data center and its Jira and package registry in another, each behind its own VPN.
- A team is moving from OpenVPN to WireGuard and needs both for a while.

This plan lets a workspace hold **several private networks**. Each has a name, a tunnel, its own routes and its own CA bundle. Every connection, whether from a run or from the server, is matched against the routes of all the workspace's networks. The most specific route decides which tunnel carries it.

```
                         ┌───────────── gateway ─────────────┐
run / agnts ── egress ──▶│ pick(ws 42, "nexus.b.local:8081") │
                         │   ws 42 · net 7  "Client A" WG ───┼──▶ gitlab.a.local
                         │   ws 42 · net 9  "Client B" OVPN ─┼──▶ nexus.b.local
                         │   ws 42 · net 12 "Office"  link ──┼──▶ 10.30.0.0/16
                         └───────────────────────────────────┘
```

**Goals**

- A workspace adds, edits, turns off and removes networks one at a time, and each has its own status, test and activity.
- Routing is predictable: the most specific route wins (longest match), and two networks can never claim the same target. Agnts refuses that conflict when a network is saved, not when a run hits it.
- Everything the single network guarantees still holds: isolation between workspaces, no new privileges for runs, and configs that only the gateway can open.

**Out of scope:** load balancing or failover between networks (a target uses exactly one network), routing a whole run through one network, and sharing a network between workspaces.

## Routing

### Picking a network

`privnet.Pick(nets []Network, host string, port int) (id int64, ok bool)` replaces `privnet.Match` everywhere: in the gateway, `netroute.Router`, `/egress/route` and the settings Test. Among the enabled networks whose routes match the target and port, it picks the most specific route:

| Route kind | Specificity |
|---|---|
| Exact host `gitlab.a.local` | highest |
| Domain `.a.local`, `.b.a.local` | by number of labels (more labels wins) |
| CIDR `10.20.0.0/16` | by prefix length (only for IP literals, as today) |

Names never match a CIDR, because names are resolved on the tunnel side. So host routes and CIDR routes never compete.

### Conflicts are refused on save

`privnet.CheckConflicts(networks)` runs when a network is saved. It looks at the network being saved plus the workspace's other networks, **disabled ones included**, so turning a network back on can't create an ambiguity. It refuses the save when:

- the same host or domain appears in two networks with overlapping ports, or
- the same CIDR (identical prefix) appears in two networks with overlapping ports.

Nesting is allowed and is the point: network "Office" routes `10.0.0.0/8`, and network "Lab" routes `10.30.0.0/16`, which wins for its range. The error names the other network ("`.corp.local` is already routed through *Client A*").

### Limits

- `AGNTS_PRIVATE_NETWORKS_MAX` networks per workspace (default 5).
- `MaxRoutes` (50) stays per network.
- The gateway also keeps a global cap per kind, so a single server can't be asked for 500 OpenVPN sidecars (`AGNTS_OVPN_MAX`, default 50).

## Data model

The numbers are now fixed: `00036_private_networks.sql` (uncommitted) and `00037_ci_failures.sql` (CI plan). `Harness plan.md` takes later numbers as it builds them.

- If `00036` **hasn't been applied on the server yet**, edit `00036_private_networks.sql` in place to the schema below.
- If it has been applied, never edit it (the Harness plan's rule). Add the next free migration (`00038_private_networks_multi.sql` today), which converts each workspace's existing row into a network named "Private network" (the `ALTER` path at the end of this section).

```sql
CREATE TABLE private_networks (
    id           bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    name         text        NOT NULL CHECK (length(name) BETWEEN 1 AND 60),
    kind         text        NOT NULL CHECK (kind IN ('wireguard', 'openvpn', 'connector')),
    enabled      boolean     NOT NULL DEFAULT true,
    secret_enc   bytea,
    summary      text        NOT NULL DEFAULT '',
    token_hash   text        NOT NULL DEFAULT '',
    routes       jsonb       NOT NULL DEFAULT '[]',
    ca_pem       text        NOT NULL DEFAULT '',
    status       text        NOT NULL DEFAULT 'connecting',
    last_error   text        NOT NULL DEFAULT '',
    up_at        timestamptz,
    handshake_at timestamptz,
    detail       text        NOT NULL DEFAULT '',
    updated_at   timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, name)
);
CREATE UNIQUE INDEX private_networks_token_idx ON private_networks (token_hash) WHERE token_hash <> '';
-- RLS as before

ALTER TABLE private_dials ADD COLUMN network_id bigint REFERENCES private_networks (id) ON DELETE SET NULL;
```

The `ALTER` path, if the old table is live: add `id` and `name` (default `'Private network'`), drop the old primary key, and add `network_id` to `private_dials`, backfilled from `workspace_id`.

**Secrets are bound to the network.** `privnet.SecretAAD(ws, id)` becomes `privnet:<ws>:<id>`, so a sealed config can't be copied to another network row, even within the same workspace. A live upgrade re-seals the existing row once at startup, opening it with the old AAD.

## Changes by package

### `privnet`

- `Network` gains `ID` and `Name`.
- `Status` and `Dial` carry `Network` (the ID) instead of keying on the workspace.
- `Pick` and `CheckConflicts` as above, with table tests for the precedence rules and conflict cases.
- `HeaderNetwork = "X-Agnts-Network"` on CONNECT to the gateway.
- `SidecarName(id)` becomes `agnts-ovpn-<id>`. `SidecarPassword(secret, id)` is derived from the network ID.

### `gateway`

- `entries` and `links` are keyed by **network ID**, not by workspace. Sync, version checks and restarts work the same, just per network.
- CONNECT carries both workspace and network. The gateway checks that the network belongs to that workspace and re-runs `Pick` for that workspace. If the result differs from the network asked for, the request is refused. Egress or agnts with stale routes can't push traffic into the wrong tunnel.
- `linkWorkspace` becomes `linkNetwork`: the token identifies one network. With the unique `token_hash` index, the lookup can't be ambiguous.
- Relayed webhooks get `X-Agnts-Link-Network` as well as the workspace header.

### `network.Service`

- The CRUD API gets a network ID: `List`, `Get(id)`, `Create`, `Update(id)`, `Delete(id)`, `Reconnect(id)`, `RotateToken(id)`, `Activity(id?)`.
- `Save` runs `CleanRoutes`, then `CheckConflicts` against the other networks in a transaction: `SELECT … FOR UPDATE` on the workspace's rows, so two concurrent saves can't both pass.
- `Refresh` gives the router `map[ws][]netroute.Network`.
- `syncSidecars` keys by network ID, and labels gain `agnts.network`.
- `CA(ctx)` returns **all** enabled networks' bundles concatenated, deduplicated by certificate fingerprint, so a run trusts each company's CA.
- `ForEachPolled`: a workspace is polled faster when its Jira or Plane host is routed through a **non-connector** network. It uses `Pick` on the tracker's host instead of "any non-connector network exists".
- GitLab behind a VPN: the new CI poller (`ciwatch.Poll`, every 5 minutes for every workspace) already reads finished pipelines through the routed GitLab client. Pipeline results arrive without webhooks, and nothing here has to change for it. MR state and new notes are still not polled. That gap is separate from this plan; see "Related work".
- `Test(target, networkID?)` shows which network `Pick` chose. With an ID, it tests through that network even when another would win, and says so. This helps when setting up a network before its routes are final.

### `netroute`

- `Router.Match` becomes `Router.Pick(ws, host, port) (Network, bool)`.
- Connection pools are keyed by **network ID + version**, and TLS roots come from that network's CA.
- `Dial` sends the network ID.

### Egress

`/egress/route` returns `{workspace, network, ticket}`, and `egress.Private` gains `Network`. No other change.

### HTTP API (`openapi.yaml`)

| Method | Path | Role |
|---|---|---|
| GET | `/networks` | member: `{available, linkUrl, max, networks: [PrivateNetwork]}` |
| POST | `/networks` | owner: create, returns `PrivateNetworkSaved` (token once for a connector) |
| GET / PUT / DELETE | `/networks/{id}` | GET member, others owner |
| POST | `/networks/{id}/reconnect`, `/networks/{id}/token` | owner |
| POST | `/networks/test` `{target, network?}` | owner, result adds `network: {id, name}` |
| GET | `/networks/activity?network=` | member |

`PrivateNetwork` gains `id` and `name`. Since nothing is released, the old `/network` endpoints are replaced, not kept. Then regenerate `schema.gen.ts`, `api.gen.go` and the mobile `agnts_api` package.

## UI

Settings → Private networks becomes a list, with the current form moved into an editor:

```
Private networks                                          [+ Add network]
┌──────────────────────────────────────────────────────────────────────┐
│ ● Client A        WireGuard   gitlab.a.local, .a.local       [Edit] ⟳│
│ ● Client B        OpenVPN     nexus.b.local :8081            [Edit] ⟳│
│ ○ Office (off)    agnts-link  10.0.0.0/8                     [Edit]  │
└──────────────────────────────────────────────────────────────────────┘
Which network?  [ nexus.b.local:8081 ]  [Test]
                → Client B (OpenVPN) · resolved 10.9.0.4 · TCP 41 ms · TLS ok
Activity        612 connections today · 2 refused     [All networks ▾] [View]
```

- `PrivateNetworkCard.vue` is split into `PrivateNetworksCard.vue` (list, test, activity) and `PrivateNetworkEditor.vue` (today's form plus a Name field, opened as a drawer). The editor keeps today's per-kind fields, CA bundle and agnts-link install command.
- Route conflicts come back as a 400 with the other network's name and are shown next to the route field.
- The activity table gets a Network column and filter.
- New i18n keys in `shared/i18n/{en,ru,uz}/network.json`. Update the docs pages (`docs/content/*/settings.md`).

## Phases

1. **Model and routing.** Migration, `privnet.Pick` / `CheckConflicts`, the store, `network.Service` CRUD, gateway keyed by network, `netroute`, egress, and the per-network AAD. Tests: precedence, conflicts, a gateway that refuses a mismatched network, two WireGuard networks in one workspace with overlapping AllowedIPs.
2. **API and UI.** The OpenAPI endpoints, regenerated clients, list and editor, Test with network choice, activity per network, i18n and docs.
3. **Polish.** Polling decided per tracker host, the CA bundle merged across networks, and the per-kind caps and their errors.

## As built

Differences from the plan above, decided while building it:

- **Migration** is `00038_private_networks_multi.sql`, since `00036` was already applied on the dev database. Re-sealing old secrets is marked by a `secret_v` column (1 = bound to the workspace, 2 = bound to the network). Until a secret is re-sealed, agnts leaves it out of the gateway feed.
- **Saves are serialized** with a per-workspace advisory lock (`pg_advisory_xact_lock`) instead of `SELECT … FOR UPDATE`, so the first network of a workspace is covered too.
- **Test with a network** doesn't force the connection through that network: the gateway would refuse it. When another network wins, the result says which one and why.
- **Caps:** `AGNTS_PRIVATE_NETWORKS_MAX` (default 5) and `AGNTS_OVPN_MAX` (default 50, OpenVPN only; WireGuard and connectors cost no container).
- **Tracker polling** follows `network.Service.PolledBy(trackerURL)`: the Jira site or Plane base URL is matched with `Pick`, and only a VPN-kind network makes it poll faster.
- **Sidecars** are named `agnts-ovpn-net-<network>` and labelled `agnts.network`. Sidecars from before are removed and replaced on the first sync.
- **UI:** `PrivateNetworksCard.vue` (list, Test with "Through", activity with a network filter) and `PrivateNetworkEditor.vue` (drawer). A new connector keeps the drawer open to show its token once, and each network's install command uses its own container name.

## Related work

Checked against the uncommitted CI work (`ciwatch`, `vcs/*/ci.go`, `gitrepo.IsAncestor`) and `Harness plan.md`:

- **No conflict.** Every new server call (pipelines, job logs, retries, MR notes, the `IsAncestor` fetch) goes through the GitLab/GitHub clients or the routed go-git client. All of them use `netroute.Transport` with the workspace in the context. After this plan they pick the right network by host with no change in `ciwatch`.
- **CI webhooks** (`workflow_run`, GitLab pipeline hooks) are under `/webhooks/`, which agnts-link already relays. With several connectors in one workspace, any of them can relay the workspace's webhooks. The gateway adds `X-Agnts-Link-Network` for the activity log only.
- **CI fix runs** are ordinary runs and go through egress and `Pick` like any other.
- **Harness plan:** `agnts-guard` and `agnts-act` stay inside the container's egress rules. Nothing there reads the private network tables.
- The API paths `/networks/*` don't clash with the new `/ci/*` paths. The Settings anchor stays `#s-network`, next to the new `#s-ci`.

## Open questions

- **Has `00036_private_networks.sql` been applied on the server?** This decides between editing it in place and adding `00038` (see Data model).
- **Scope networks to repositories?** Two clients both using `10.0.0.0/8` or `gitlab.local` in one workspace can't be told apart by route alone; `CheckConflicts` refuses it. Letting a network apply only to chosen repositories would solve it for runs, since a run knows its repository. Server calls to the single GitLab or Jira integration don't know a repository. Proposal: leave it out of v1, and suggest one workspace per client for that case.
- **Pricing.** Should more than one network be a paid-plan feature? Each OpenVPN network is a sidecar (about 30 MB) running all the time.
