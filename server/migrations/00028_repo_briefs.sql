-- +goose Up
-- What agnts knows about how a repository works (architecture, recipes,
-- conventions, pitfalls). A survey run writes the draft; a person approves
-- it into body, which is what runs read. merges_since counts tickets merged
-- since then, so the brief is surveyed again when it goes stale. revision
-- counts a person's changes, so a survey of an older revision cannot
-- overwrite a newer one.
CREATE TABLE repo_briefs (
    repo_id      bigint      PRIMARY KEY REFERENCES repositories (id) ON DELETE CASCADE,
    workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    body         text        NOT NULL DEFAULT '',
    body_sha     text        NOT NULL DEFAULT '',
    draft        text        NOT NULL DEFAULT '',
    draft_sha    text        NOT NULL DEFAULT '',
    status       text        NOT NULL DEFAULT 'idle' CHECK (status IN ('idle', 'pending', 'surveying', 'failed')),
    merges_since integer     NOT NULL DEFAULT 0,
    error        text        NOT NULL DEFAULT '',
    revision     integer     NOT NULL DEFAULT 0,
    surveyed_at  timestamptz,
    approved_at  timestamptz,
    updated_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX repo_briefs_workspace_idx ON repo_briefs (workspace_id);
CREATE INDEX repo_briefs_pending_idx ON repo_briefs (updated_at) WHERE status = 'pending';
ALTER TABLE repo_briefs ENABLE ROW LEVEL SECURITY;
ALTER TABLE repo_briefs FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON repo_briefs USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- +goose Down
DROP TABLE repo_briefs;
