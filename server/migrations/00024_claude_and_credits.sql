-- +goose Up
-- Claude in a workspace. A connection belongs to a workspace (shared mode:
-- every run uses it) or to a person (per-member mode: runs of their
-- tickets use it, in every workspace they are in). kind says whether the
-- token is a Claude subscription token (`claude setup-token`) or an
-- Anthropic API key. paused_until is set when the account is at its usage
-- limit, so only the runs on that account wait.
CREATE TABLE claude_connections (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint      REFERENCES workspaces (id) ON DELETE CASCADE,
    user_id      bigint      REFERENCES users (id) ON DELETE CASCADE,
    kind         text        NOT NULL CHECK (kind IN ('subscription', 'api_key')),
    token_enc    bytea       NOT NULL,
    account      text        NOT NULL DEFAULT '',
    last_error   text        NOT NULL DEFAULT '',
    paused_until timestamptz,
    checked_at   timestamptz,
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now(),
    CHECK ((workspace_id IS NULL) <> (user_id IS NULL))
);
CREATE UNIQUE INDEX claude_connections_workspace_idx ON claude_connections (workspace_id) WHERE workspace_id IS NOT NULL;
CREATE UNIQUE INDEX claude_connections_user_idx ON claude_connections (user_id) WHERE user_id IS NOT NULL;

-- The install's Claude integration becomes the default workspace's shared
-- connection. Its token stays sealed as it was; the server opens it with
-- the integration's old binding until it is saved again.
INSERT INTO claude_connections (workspace_id, kind, token_enc, account, last_error, checked_at)
SELECT i.workspace_id, 'subscription', i.token_enc, i.account, i.last_error, i.checked_at
FROM integrations i WHERE i.provider = 'claude' AND i.connected AND i.token_enc IS NOT NULL;

-- Usage readings belong to the account they were read on (NULL: agnts's
-- own API key, or readings from before).
ALTER TABLE usage_snapshots ADD COLUMN connection_id bigint REFERENCES claude_connections (id) ON DELETE CASCADE;
UPDATE usage_snapshots SET connection_id = (SELECT id FROM claude_connections ORDER BY id LIMIT 1);
CREATE INDEX usage_snapshots_connection_idx ON usage_snapshots (connection_id, id DESC);

-- Which account a run used, and what it cost in credits when it ran on
-- them (settled from claude_calls.cost_usd when the run ends).
ALTER TABLE runs
    ADD COLUMN claude_connection_id bigint REFERENCES claude_connections (id) ON DELETE SET NULL,
    ADD COLUMN on_credits boolean NOT NULL DEFAULT false;

-- Credits: every change of a workspace's balance, so the balance is the
-- sum and every spend can be explained. 1 credit is $0.01 of API cost at
-- the markup.
CREATE TABLE credit_ledger (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id bigint      NOT NULL REFERENCES workspaces (id) ON DELETE CASCADE,
    amount       bigint      NOT NULL,
    reason       text        NOT NULL CHECK (reason IN ('purchase', 'run', 'refund', 'grant')),
    run_id       bigint      REFERENCES runs (id) ON DELETE SET NULL,
    ticket_key   text        NOT NULL DEFAULT '',
    payment_id   bigint,
    note         text        NOT NULL DEFAULT '',
    created_by   bigint      REFERENCES users (id) ON DELETE SET NULL,
    created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX credit_ledger_workspace_idx ON credit_ledger (workspace_id, id DESC);
CREATE UNIQUE INDEX credit_ledger_run_idx ON credit_ledger (run_id) WHERE reason = 'run';

-- Payments for credits through Payme or Click. state follows the
-- provider's transaction: created, paid (credits added), cancelled.
CREATE TABLE payments (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id  bigint      NOT NULL REFERENCES workspaces (id) ON DELETE CASCADE,
    provider      text        NOT NULL CHECK (provider IN ('payme', 'click')),
    amount_uzs    bigint      NOT NULL CHECK (amount_uzs > 0),
    credits       bigint      NOT NULL CHECK (credits > 0),
    state         text        NOT NULL DEFAULT 'created' CHECK (state IN ('created', 'pending', 'paid', 'cancelled')),
    provider_txn  text        NOT NULL DEFAULT '',
    provider_time bigint      NOT NULL DEFAULT 0,
    reason        integer,
    created_by    bigint      REFERENCES users (id) ON DELETE SET NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),
    performed_at  timestamptz,
    cancelled_at  timestamptz
);
CREATE INDEX payments_workspace_idx ON payments (workspace_id, id DESC);
CREATE UNIQUE INDEX payments_txn_idx ON payments (provider, provider_txn) WHERE provider_txn <> '';

-- +goose StatementBegin
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'agnts_tenant') THEN
        GRANT SELECT, INSERT, UPDATE, DELETE ON claude_connections, credit_ledger, payments TO agnts_tenant;
    END IF;
EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'grants skipped: %', SQLERRM;
END;
$$;
-- +goose StatementEnd

-- +goose Down
DROP TABLE payments;
DROP TABLE credit_ledger;
ALTER TABLE runs DROP COLUMN on_credits, DROP COLUMN claude_connection_id;
DROP INDEX usage_snapshots_connection_idx;
ALTER TABLE usage_snapshots DROP COLUMN connection_id;
DROP TABLE claude_connections;
