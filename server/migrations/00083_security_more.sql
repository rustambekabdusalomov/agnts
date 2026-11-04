-- +goose Up
-- Security testing, phase 1b/1c: scheduled scans, and the security check
-- of agnts's own changes (a side stage like review and preview).

-- When a repository's scheduled scan is next due (NULL: not scheduled).
ALTER TABLE repositories ADD COLUMN security_next_at timestamptz;

-- +goose Down
ALTER TABLE repositories DROP COLUMN security_next_at;
