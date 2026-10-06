-- +goose Up
-- One row per Claude Code invocation, so token spend can be shown per
-- ticket and per stage. A code run can hold several calls (the first
-- pass and fix attempts); model_stage tells them apart. ticket_id is
-- copied from the run so totals need no join. partial is true when the
-- stream ended without a result line and the numbers were summed from
-- the assistant messages seen; cost is then unknown (0).
CREATE TABLE claude_calls (
    id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    run_id             bigint        NOT NULL REFERENCES runs (id) ON DELETE CASCADE,
    ticket_id          bigint        NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
    model_stage        text          NOT NULL,
    model              text          NOT NULL DEFAULT '',
    input_tokens       bigint        NOT NULL DEFAULT 0,
    output_tokens      bigint        NOT NULL DEFAULT 0,
    cache_read_tokens  bigint        NOT NULL DEFAULT 0,
    cache_write_tokens bigint        NOT NULL DEFAULT 0,
    cost_usd           numeric(12,6) NOT NULL DEFAULT 0,
    turns              integer       NOT NULL DEFAULT 0,
    duration_ms        bigint        NOT NULL DEFAULT 0,
    partial            boolean       NOT NULL DEFAULT false,
    created_at         timestamptz   NOT NULL DEFAULT now()
);
CREATE INDEX claude_calls_ticket_id_idx ON claude_calls (ticket_id, created_at);
CREATE INDEX claude_calls_created_at_idx ON claude_calls (created_at);

-- +goose Down
DROP TABLE claude_calls;
