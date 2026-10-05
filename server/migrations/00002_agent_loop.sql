-- +goose Up
ALTER TABLE repositories ADD COLUMN jira_project text NOT NULL DEFAULT '';
CREATE UNIQUE INDEX repositories_jira_project_idx ON repositories (jira_project) WHERE jira_project <> '';

ALTER TABLE tickets
    ADD COLUMN resume_state text NOT NULL DEFAULT 'new',
    ADD COLUMN branch       text NOT NULL DEFAULT '',
    ADD COLUMN head_sha     text NOT NULL DEFAULT '',
    ADD COLUMN pr_url       text NOT NULL DEFAULT '',
    -- Reviewer feedback waiting to be picked up by the next coding run.
    ADD COLUMN feedback     text NOT NULL DEFAULT '';

-- At most one unfinished run per ticket: the claim in the orchestrator
-- relies on this to never start two containers for the same ticket.
CREATE UNIQUE INDEX runs_one_active_idx ON runs (ticket_id) WHERE finished_at IS NULL;

-- +goose Down
DROP INDEX runs_one_active_idx;
ALTER TABLE tickets DROP COLUMN feedback, DROP COLUMN pr_url, DROP COLUMN head_sha, DROP COLUMN branch, DROP COLUMN resume_state;
DROP INDEX repositories_jira_project_idx;
ALTER TABLE repositories DROP COLUMN jira_project;
