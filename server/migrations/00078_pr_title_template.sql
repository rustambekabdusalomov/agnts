-- +goose Up
-- How agnts titles a repository's pull requests, with the commit
-- template's placeholders: {number} {key} {type} {scope} {subject} {title}.
-- Empty uses the workspace's PR title (Settings → Git). A group's, set,
-- replaces its members' in the group's tickets.
ALTER TABLE repositories ADD COLUMN pr_template text NOT NULL DEFAULT '';
ALTER TABLE repository_groups ADD COLUMN pr_template text NOT NULL DEFAULT '';

-- +goose Down
ALTER TABLE repository_groups DROP COLUMN pr_template;
ALTER TABLE repositories DROP COLUMN pr_template;
