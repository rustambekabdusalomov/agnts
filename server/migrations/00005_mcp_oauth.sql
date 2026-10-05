-- +goose Up
-- OAuth 2.1 for Claude's MCP connectors (dynamic client registration,
-- authorization code with PKCE). Only hashes of codes and tokens are stored.
CREATE TABLE oauth_clients (
    id            text        PRIMARY KEY,
    name          text        NOT NULL DEFAULT '',
    redirect_uris jsonb       NOT NULL,
    created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE oauth_codes (
    code_hash      bytea       PRIMARY KEY,
    client_id      text        NOT NULL REFERENCES oauth_clients (id) ON DELETE CASCADE,
    user_id        bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    redirect_uri   text        NOT NULL,
    code_challenge text        NOT NULL,
    resource       text        NOT NULL DEFAULT '',
    expires_at     timestamptz NOT NULL,
    used_at        timestamptz
);

CREATE TABLE oauth_tokens (
    token_hash bytea       PRIMARY KEY,
    kind       text        NOT NULL CHECK (kind IN ('access', 'refresh')),
    client_id  text        NOT NULL REFERENCES oauth_clients (id) ON DELETE CASCADE,
    user_id    bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL
);
CREATE INDEX oauth_tokens_expires_idx ON oauth_tokens (expires_at);

-- +goose Down
DROP TABLE oauth_tokens;
DROP TABLE oauth_codes;
DROP TABLE oauth_clients;
