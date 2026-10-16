-- +goose Up
-- How agnts names a repository's branches, with placeholders: {prefix}
-- {type} {key} {slug} {user}. Empty uses {prefix}{key}, the old naming.
ALTER TABLE repositories ADD COLUMN branch_template text NOT NULL DEFAULT '';

-- +goose Down
ALTER TABLE repositories DROP COLUMN branch_template;
