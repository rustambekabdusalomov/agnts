-- +goose Up
-- A repository takes side-project tasks and, when it names a Jira project,
-- Jira tickets too. kind is now derived from jira_project.
UPDATE repositories SET kind = CASE WHEN jira_project <> '' THEN 'jira' ELSE 'side' END;

-- +goose Down
-- Nothing to undo: every row still satisfies the kind check.
SELECT 1;
