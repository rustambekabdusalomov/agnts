-- +goose Up
-- Rules agnts suggests from what people told it (status suggested: never
-- given to tickets until someone adopts it; dismissed: declined, kept so it
-- is not suggested again). source_ticket and reason say where a suggestion
-- came from. kind tells instructions (rule) from business knowledge
-- (context: glossary, invariants, roles), which runs get as a file.
ALTER TABLE rules DROP CONSTRAINT rules_status_check;
ALTER TABLE rules ADD CONSTRAINT rules_status_check
    CHECK (status IN ('pending', 'analyzing', 'questions', 'ready', 'failed', 'suggested', 'dismissed'));
ALTER TABLE rules ADD COLUMN source_ticket text NOT NULL DEFAULT '';
ALTER TABLE rules ADD COLUMN reason text NOT NULL DEFAULT '';
ALTER TABLE rules ADD COLUMN kind text NOT NULL DEFAULT 'rule' CHECK (kind IN ('rule', 'context'));

-- Feedback waiting for agnts to learn from: a change request or a
-- rejection by a person, read by a reflect run that may suggest rules.
CREATE TABLE reflections (
    id           bigserial   PRIMARY KEY,
    workspace_id bigint      NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
    ticket_key   text        NOT NULL,
    repo_id      bigint      REFERENCES repositories (id) ON DELETE SET NULL,
    source       text        NOT NULL CHECK (source IN ('changes', 'rejected')),
    feedback     text        NOT NULL,
    status       text        NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'done', 'failed')),
    suggested    integer     NOT NULL DEFAULT 0,
    error        text        NOT NULL DEFAULT '',
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX reflections_workspace_idx ON reflections (workspace_id);
CREATE INDEX reflections_pending_idx ON reflections (updated_at) WHERE status = 'pending';
ALTER TABLE reflections ENABLE ROW LEVEL SECURITY;
ALTER TABLE reflections FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON reflections USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

-- +goose Down
DROP TABLE reflections;
DELETE FROM rules WHERE status IN ('suggested', 'dismissed');
ALTER TABLE rules DROP COLUMN kind;
ALTER TABLE rules DROP COLUMN reason;
ALTER TABLE rules DROP COLUMN source_ticket;
ALTER TABLE rules DROP CONSTRAINT rules_status_check;
ALTER TABLE rules ADD CONSTRAINT rules_status_check CHECK (status IN ('pending', 'analyzing', 'questions', 'ready', 'failed'));
