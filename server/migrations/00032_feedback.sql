-- +goose Up
-- Feedback people send from their account (a title and a description), read
-- by the platform's Admins. It belongs to the platform, not a workspace: the
-- workspace it was sent from is context only, so there is no isolation
-- policy. The sender is kept as a name and email too, so a feedback still
-- says who sent it after the account is deleted.
CREATE TABLE feedback (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id      bigint      REFERENCES users (id) ON DELETE SET NULL,
    sender       text        NOT NULL DEFAULT '',
    email        text        NOT NULL DEFAULT '',
    workspace_id bigint      REFERENCES workspaces (id) ON DELETE SET NULL,
    title        text        NOT NULL CHECK (length(title) BETWEEN 1 AND 120),
    description  text        NOT NULL CHECK (length(description) BETWEEN 1 AND 5000),
    status       text        NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'done')),
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX feedback_created_idx ON feedback (created_at DESC);
CREATE INDEX feedback_new_idx ON feedback (id) WHERE status = 'new';

-- +goose StatementBegin
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'agnts_tenant') THEN
        GRANT SELECT, INSERT, UPDATE, DELETE ON feedback TO agnts_tenant;
    END IF;
EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'grants skipped: %', SQLERRM;
END;
$$;
-- +goose StatementEnd

-- +goose Down
DROP TABLE feedback;
