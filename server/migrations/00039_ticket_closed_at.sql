-- +goose Up
-- When an agnts pull request was closed without being merged (Analytics
-- plan): from the pull request webhook, or found by checking the git host.
-- Reopening clears it. A closed pull request is no longer polled for a merge.
ALTER TABLE tickets ADD COLUMN closed_at timestamptz;

-- +goose Down
ALTER TABLE tickets DROP COLUMN closed_at;
