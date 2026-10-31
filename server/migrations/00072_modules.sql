-- +goose Up
-- Coding modules per person: the platform Admin chooses which of Muse
-- Code, Claude Code and Codex the server offers and who may use them.
-- The general choice is system_settings 'modules' ({"enabled": [...],
-- "default": [...]}); the server writes it at start from AGNTS_PROVIDERS
-- when it is missing, so deploying changes nothing until an Admin acts.
-- A person's own list overrides the default; NULL follows it.
ALTER TABLE users ADD COLUMN modules        text[] CHECK (modules <@ ARRAY['muse', 'claude', 'codex']::text[]);
ALTER TABLE users ADD COLUMN modules_set_by bigint REFERENCES users (id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN modules_set_at timestamptz;

-- A person or a workspace may hold one account per module: a Claude one
-- and a Muse one at once. Codex runs on the workspace's OpenAI key.
ALTER TABLE claude_connections ADD COLUMN provider text NOT NULL
    GENERATED ALWAYS AS (CASE WHEN kind IN ('muse_api_key', 'muse_login') THEN 'muse' ELSE 'claude' END) STORED;
DROP INDEX claude_connections_workspace_idx;
DROP INDEX claude_connections_user_idx;
CREATE UNIQUE INDEX claude_connections_workspace_idx ON claude_connections (workspace_id, provider) WHERE workspace_id IS NOT NULL;
CREATE UNIQUE INDEX claude_connections_user_idx ON claude_connections (user_id, provider) WHERE user_id IS NOT NULL;

-- +goose Down
-- Keep one connection per owner: the newest.
DELETE FROM claude_connections c USING claude_connections n
    WHERE c.workspace_id IS NOT NULL AND n.workspace_id = c.workspace_id AND n.id > c.id;
DELETE FROM claude_connections c USING claude_connections n
    WHERE c.user_id IS NOT NULL AND n.user_id = c.user_id AND n.id > c.id;
DROP INDEX claude_connections_workspace_idx;
DROP INDEX claude_connections_user_idx;
ALTER TABLE claude_connections DROP COLUMN provider;
CREATE UNIQUE INDEX claude_connections_workspace_idx ON claude_connections (workspace_id) WHERE workspace_id IS NOT NULL;
CREATE UNIQUE INDEX claude_connections_user_idx ON claude_connections (user_id) WHERE user_id IS NOT NULL;
DELETE FROM system_settings WHERE key = 'modules';
ALTER TABLE users DROP COLUMN modules_set_at;
ALTER TABLE users DROP COLUMN modules_set_by;
ALTER TABLE users DROP COLUMN modules;
