-- +goose Up
-- A code task made from an approved plan or bug report points back to it,
-- by key, so the link reads the same in events and on both ticket pages.
-- One implementation per report.
ALTER TABLE tickets ADD COLUMN parent_key text;
CREATE UNIQUE INDEX tickets_parent_key_idx ON tickets (parent_key) WHERE parent_key IS NOT NULL;

-- +goose Down
DROP INDEX tickets_parent_key_idx;
ALTER TABLE tickets DROP COLUMN parent_key;
