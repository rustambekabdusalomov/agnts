-- +goose Up
-- Security testing, phase 1b/1c: scheduled scans, and the security check
-- of agnts's own changes (a side stage like review and preview).

-- When a repository's scheduled scan is next due (NULL: not scheduled).
ALTER TABLE repositories ADD COLUMN security_next_at timestamptz;

-- Where the security check of a ticket's change stands, like
-- preview_state: '', pending, running, done, failed. Its result is the
-- run's result (results), as previews are.
ALTER TABLE tickets ADD COLUMN security_state text NOT NULL DEFAULT '';

-- +goose Down
ALTER TABLE tickets DROP COLUMN security_state;
ALTER TABLE repositories DROP COLUMN security_next_at;
