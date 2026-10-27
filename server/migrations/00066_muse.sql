-- +goose Up
-- Muse Code (Meta) becomes agnts's primary coding tool.

-- A Muse account is connected like a Claude one: a Meta Model API key, or
-- a Meta sign-in (Muse Code's credential file, sealed like any token).
ALTER TABLE claude_connections DROP CONSTRAINT IF EXISTS claude_connections_kind_check;
ALTER TABLE claude_connections ADD CONSTRAINT claude_connections_kind_check
    CHECK (kind IN ('subscription', 'api_key', 'muse_api_key', 'muse_login'));

-- Free credits an Admin gives a person (hackathon judges, trials): runs on
-- agnts's Meta key spend them before the workspace's bought credits. The
-- money itself is in agnts-muse's ledger (muse_* tables, created by the
-- server at start); this is the limit the Admin set, and who set it.
ALTER TABLE users ADD COLUMN free_credits_limit  bigint NOT NULL DEFAULT 0 CHECK (free_credits_limit >= 0);
ALTER TABLE users ADD COLUMN free_credits_set_by bigint REFERENCES users (id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN free_credits_set_at timestamptz;

-- Run history records Muse invocations as their own engine.
ALTER TABLE transcripts DROP CONSTRAINT IF EXISTS transcripts_engine_check;
ALTER TABLE transcripts ADD CONSTRAINT transcripts_engine_check CHECK (engine IN ('claude', 'codex', 'muse'));

-- +goose Down
DELETE FROM transcripts WHERE engine = 'muse';
ALTER TABLE transcripts DROP CONSTRAINT IF EXISTS transcripts_engine_check;
ALTER TABLE transcripts ADD CONSTRAINT transcripts_engine_check CHECK (engine IN ('claude', 'codex'));
ALTER TABLE users DROP COLUMN free_credits_set_at;
ALTER TABLE users DROP COLUMN free_credits_set_by;
ALTER TABLE users DROP COLUMN free_credits_limit;
DELETE FROM claude_connections WHERE kind IN ('muse_api_key', 'muse_login');
ALTER TABLE claude_connections DROP CONSTRAINT IF EXISTS claude_connections_kind_check;
ALTER TABLE claude_connections ADD CONSTRAINT claude_connections_kind_check CHECK (kind IN ('subscription', 'api_key'));
