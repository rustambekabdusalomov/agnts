-- +goose Up
-- The checkable part of a repository's brief: layers and which may import
-- which, shared helpers, recipes and files to copy (Code quality plan,
-- Phase 5). The survey drafts it with the brief; approving the brief
-- approves it too.
ALTER TABLE repo_briefs ADD COLUMN architecture jsonb;
ALTER TABLE repo_briefs ADD COLUMN architecture_draft jsonb;

-- +goose Down
ALTER TABLE repo_briefs DROP COLUMN architecture_draft;
ALTER TABLE repo_briefs DROP COLUMN architecture;
