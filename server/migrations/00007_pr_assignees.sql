-- +goose Up
-- Who the pull request is assigned to, chosen when the review is approved.
ALTER TABLE tickets ADD COLUMN assignees text[] NOT NULL DEFAULT '{}';

-- +goose Down
ALTER TABLE tickets DROP COLUMN assignees;
