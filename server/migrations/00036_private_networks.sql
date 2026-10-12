-- +goose Up
-- A workspace's private network: a tunnel into its own network (a
-- WireGuard or OpenVPN config, or the agnts-link connector it runs) and
-- the routes that go through it. secret_enc holds the VPN config (and an
-- OpenVPN username and password), sealed with the server key; only the
-- gateway service opens it. token_hash is the connector token's sha256.
-- status, last_error, up_at and handshake_at are what the gateway last
-- reported.
CREATE TABLE private_networks (
    workspace_id bigint      PRIMARY KEY DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
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
    updated_at   timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE private_networks ENABLE ROW LEVEL SECURITY;
ALTER TABLE private_networks FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON private_networks USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- Every connection made (or refused) through a private network, for the
-- owner's activity list. Kept 30 days.
CREATE TABLE private_dials (
    id           bigserial   PRIMARY KEY,
    workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    ticket_key   text        NOT NULL DEFAULT '',
    source       text        NOT NULL DEFAULT '',
    target       text        NOT NULL,
    ok           boolean     NOT NULL,
    error        text        NOT NULL DEFAULT '',
    bytes_in     bigint      NOT NULL DEFAULT 0,
    bytes_out    bigint      NOT NULL DEFAULT 0,
    at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX private_dials_ws_idx ON private_dials (workspace_id, at DESC);
ALTER TABLE private_dials ENABLE ROW LEVEL SECURITY;
ALTER TABLE private_dials FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON private_dials USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- +goose Down
DROP TABLE private_dials;
DROP TABLE private_networks;
