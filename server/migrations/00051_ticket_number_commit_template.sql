-- +goose Up
-- The team's own number for a task (AMANAT-2288), used in branch and
-- commit names; '' uses the ticket key.
ALTER TABLE tickets ADD COLUMN ticket_number text NOT NULL DEFAULT '';
-- How agnts writes a repository's commit messages, with placeholders:
-- {number} {key} {type} {scope} {subject} {title}. Empty keeps KEY: Title.
ALTER TABLE repositories ADD COLUMN commit_template text NOT NULL DEFAULT '';

-- +goose Down
ALTER TABLE repositories DROP COLUMN commit_template;
ALTER TABLE tickets DROP COLUMN ticket_number;
