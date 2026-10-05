-- +goose Up
ALTER TABLE tickets ADD COLUMN merged_at timestamptz;
-- GitHub: workflow file run by "Deploy" (workflow_dispatch). GitLab uses
-- manual pipeline jobs instead and ignores this.
ALTER TABLE repositories ADD COLUMN deploy_workflow text NOT NULL DEFAULT '';
CREATE INDEX tickets_pr_url_idx ON tickets (pr_url) WHERE pr_url <> '';
CREATE INDEX runs_started_at_idx ON runs (started_at);

-- +goose Down
DROP INDEX runs_started_at_idx;
DROP INDEX tickets_pr_url_idx;
ALTER TABLE repositories DROP COLUMN deploy_workflow;
ALTER TABLE tickets DROP COLUMN merged_at;
