-- +goose Up
-- Archived repositories keep their history but take no new tickets or tasks.
ALTER TABLE repositories ADD COLUMN archived_at timestamptz;

-- +goose Down
ALTER TABLE repositories DROP COLUMN archived_at;
