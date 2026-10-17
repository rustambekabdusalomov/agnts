-- +goose Up
-- Run history: one transcript per Claude Code / Codex invocation, ticket
-- stages and background calls (assistant, brief, detect, reflect, rules,
-- second opinion, translate) alike, for the Admin console. body is the
-- normalised event stream as gzipped JSONL, appended in gzip members while
-- the invocation runs; the prompt is kept apart so lists never load it.
-- ticket_key has no foreign key so history outlives deleted tasks, like
-- events.
CREATE TABLE transcripts (
    id                   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id         bigint        NOT NULL REFERENCES workspaces (id) ON DELETE CASCADE,
    run_id               bigint        REFERENCES runs (id) ON DELETE SET NULL,
    ticket_key           text          NOT NULL DEFAULT '',
    -- What a background call is about: a repository, a rule, a language.
    subject              text          NOT NULL DEFAULT '',
    -- The Claude account that ran it; claude_label is copied so the
    -- history still says whose it was once the connection is gone.
    claude_connection_id bigint        REFERENCES claude_connections (id) ON DELETE SET NULL,
    claude_label         text          NOT NULL DEFAULT '',
    purpose              text          NOT NULL,
    model_stage          text          NOT NULL DEFAULT '',
    engine               text          NOT NULL CHECK (engine IN ('claude', 'codex')),
    model                text          NOT NULL DEFAULT '',
    session_id           text          NOT NULL DEFAULT '',
    started_at           timestamptz   NOT NULL DEFAULT now(),
    finished_at          timestamptz,
    -- How the invocation ended. A stall is not an ending: the run goes on
    -- after agnts nudges Claude, so stalls are counted instead.
    status               text          NOT NULL DEFAULT 'running'
                         CHECK (status IN ('running', 'done', 'error', 'timeout', 'cancelled', 'oom')),
    exit_reason          text          NOT NULL DEFAULT '',
    turns                integer       NOT NULL DEFAULT 0,
    tool_calls           integer       NOT NULL DEFAULT 0,
    tool_errors          integer       NOT NULL DEFAULT 0,
    stalls               integer       NOT NULL DEFAULT 0,
    input_tokens         bigint        NOT NULL DEFAULT 0,
    output_tokens        bigint        NOT NULL DEFAULT 0,
    cache_read_tokens    bigint        NOT NULL DEFAULT 0,
    cache_write_tokens   bigint        NOT NULL DEFAULT 0,
    cost_usd             numeric(12,6) NOT NULL DEFAULT 0,
    prompt               bytea         NOT NULL DEFAULT '',
    body                 bytea         NOT NULL DEFAULT '',
    raw_bytes            integer       NOT NULL DEFAULT 0,
    truncated            boolean       NOT NULL DEFAULT false
);
CREATE INDEX transcripts_started_idx ON transcripts (started_at DESC, id DESC);
CREATE INDEX transcripts_workspace_idx ON transcripts (workspace_id, started_at DESC);
CREATE INDEX transcripts_run_idx ON transcripts (run_id) WHERE run_id IS NOT NULL;
CREATE INDEX transcripts_ticket_idx ON transcripts (workspace_id, ticket_key) WHERE ticket_key <> '';
CREATE INDEX transcripts_running_idx ON transcripts (id) WHERE status = 'running';

ALTER TABLE transcripts ENABLE ROW LEVEL SECURITY;
ALTER TABLE transcripts FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON transcripts USING (agnts_all() OR workspace_id = agnts_ws())
    WITH CHECK (agnts_all() OR workspace_id = agnts_ws());

ALTER TABLE claude_calls ADD COLUMN transcript_id bigint REFERENCES transcripts (id) ON DELETE SET NULL;

-- Who on the operator side read what. admin_name is copied so the log
-- still says who it was after the Admin account is deleted. Server-wide:
-- no workspace policy.
CREATE TABLE admin_audit (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    admin_id     bigint      REFERENCES users (id) ON DELETE SET NULL,
    admin_name   text        NOT NULL,
    action       text        NOT NULL,
    target       text        NOT NULL,
    workspace_id bigint      REFERENCES workspaces (id) ON DELETE SET NULL,
    ip           text        NOT NULL DEFAULT '',
    created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX admin_audit_created_idx ON admin_audit (created_at DESC, id DESC);

-- +goose Down
DROP TABLE admin_audit;
ALTER TABLE claude_calls DROP COLUMN transcript_id;
DROP TABLE transcripts;
DELETE FROM system_settings WHERE key = 'run_history';
