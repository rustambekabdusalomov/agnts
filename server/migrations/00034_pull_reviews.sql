-- +goose Up
-- Reviews of pull requests waiting for you. Each is a ticket of kind
-- review from source git: pull_request holds the pull request as of the
-- last sync (number, head and base, author, who it waits for). Approving
-- the review merges the pull request; nothing else is ever pushed.
ALTER TABLE tickets DROP CONSTRAINT tickets_kind_check,
    ADD CONSTRAINT tickets_kind_check CHECK (kind IN ('code', 'test', 'plan', 'analysis', 'bug', 'review'));
ALTER TABLE tickets DROP CONSTRAINT tickets_source_check,
    ADD CONSTRAINT tickets_source_check CHECK (source IN ('jira', 'plane', 'local', 'git'));
ALTER TABLE tickets ADD COLUMN pull_request jsonb;
CREATE INDEX tickets_pull_idx ON tickets (repo_id, pr_number) WHERE kind = 'review';

-- What people told agnts about its reviews (a re-review note, a reason to
-- dismiss one), per git host user. Review runs read the notes newer than
-- the user's profile and fold them into it.
CREATE TABLE reviewer_notes (
    id           bigserial   PRIMARY KEY,
    workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    login        text        NOT NULL,
    user_id      bigint      REFERENCES users (id) ON DELETE SET NULL,
    repo_id      bigint      REFERENCES repositories (id) ON DELETE SET NULL,
    ticket_key   text        NOT NULL DEFAULT '',
    pull_title   text        NOT NULL DEFAULT '',
    kind         text        NOT NULL CHECK (kind IN ('rereview', 'dismissed', 'manual')),
    note         text        NOT NULL,
    created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX reviewer_notes_login_idx ON reviewer_notes (workspace_id, login, id);
ALTER TABLE reviewer_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviewer_notes FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON reviewer_notes USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- How each git host user reviews, as agnts learned it from their notes
-- (or as they wrote it). learned_through is the newest note folded in.
CREATE TABLE reviewer_profiles (
    workspace_id    bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    login           text        NOT NULL,
    body            text        NOT NULL DEFAULT '',
    learned_through bigint      NOT NULL DEFAULT 0,
    notes           integer     NOT NULL DEFAULT 0,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (workspace_id, login)
);
ALTER TABLE reviewer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviewer_profiles FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON reviewer_profiles USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- +goose Down
DROP TABLE reviewer_profiles;
DROP TABLE reviewer_notes;
DELETE FROM tickets WHERE kind = 'review' OR source = 'git';
DROP INDEX tickets_pull_idx;
ALTER TABLE tickets DROP COLUMN pull_request;
ALTER TABLE tickets DROP CONSTRAINT tickets_source_check,
    ADD CONSTRAINT tickets_source_check CHECK (source IN ('jira', 'plane', 'local'));
ALTER TABLE tickets DROP CONSTRAINT tickets_kind_check,
    ADD CONSTRAINT tickets_kind_check CHECK (kind IN ('code', 'test', 'plan', 'analysis', 'bug'));
