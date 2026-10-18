-- +goose Up
-- A group's branch and commit message formats: set, they replace each
-- member repository's own in the group's tickets, so every repository of a
-- ticket gets the same branch name and commit style. '' keeps the
-- repository's own.
ALTER TABLE repository_groups ADD COLUMN branch_template text NOT NULL DEFAULT '';
ALTER TABLE repository_groups ADD COLUMN commit_template text NOT NULL DEFAULT '';

-- +goose Down
ALTER TABLE repository_groups DROP COLUMN commit_template;
ALTER TABLE repository_groups DROP COLUMN branch_template;
