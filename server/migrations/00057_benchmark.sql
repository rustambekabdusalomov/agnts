-- +goose Up
-- The benchmark: merged tickets a person picked, which every change to
-- agnts's prompts or models is replayed against (Code quality plan, Phase 1).
ALTER TABLE tickets ADD COLUMN benchmark boolean NOT NULL DEFAULT false;
CREATE INDEX tickets_benchmark_idx ON tickets (workspace_id) WHERE benchmark;

-- What a ticket's pull request merged as: its files and patches on the git
-- host when it merged, people's commits on the branch included. Replays are
-- scored against it, and agnts learns from how people changed its work.
CREATE TABLE merged_changes (
  workspace_id  bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id     bigint      NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  repo_id       bigint      NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  pr_number     integer     NOT NULL,
  head_sha      text        NOT NULL DEFAULT '',  -- agnts's last commit on the branch
  files         jsonb       NOT NULL DEFAULT '[]',
  created_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (ticket_id, repo_id)
);
CREATE INDEX merged_changes_workspace_idx ON merged_changes (workspace_id);

ALTER TABLE merged_changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE merged_changes FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON merged_changes USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- +goose Down
DROP TABLE merged_changes;
DROP INDEX tickets_benchmark_idx;
ALTER TABLE tickets DROP COLUMN benchmark;
